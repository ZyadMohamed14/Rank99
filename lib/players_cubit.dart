import 'dart:convert';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:meta/meta.dart';
import 'package:rank99/player_model.dart';
import 'package:rank99/player_repo.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'players_state.dart';

class PlayersCubit extends Cubit<PlayersState> {
  final PlayersRepository repository;
  List<Player> allPlayers = [];
  List<Player> selectedPlayers = [];
  static const String _favKey = 'favoritePlayers';
  PlayersCubit(this.repository) : super(PlayersLoading()) {
    loadPlayers();
  }

  Future<void> loadPlayers({PlayerType playerType = PlayerType.rankers}) async {
    allPlayers.clear();
    String? deviceId = await _getDeviceId();
    print('******************************************');
    print("Device ID: $deviceId");
  emit(PlayersLoading());
    try {
      switch (playerType) {
        case PlayerType.rankers:
          allPlayers = await repository.getPlayers();
          break;
        case PlayerType.transfermarkt:
          allPlayers = await repository.getTransMarketPlayers();
          break;
        case PlayerType.fifarank:
          allPlayers = await repository.getFifaRankedPlayers();
          break;
        case PlayerType.earank:
          allPlayers = await repository.getEARankedPlayers();
          break;
      }

      await _loadFavorites();
      emit(PlayersLoaded(allPlayers, selectedPlayers));
    } catch (e) {
      emit(PlayersError(e.toString()));
    }
  }
  Future<void> _loadFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favoritesJson = prefs.getStringList(_favKey) ?? [];
      selectedPlayers = favoritesJson
          .map((json) => Player.fromJson(jsonDecode(json)))
          .toList();
    } catch (e) {
      selectedPlayers = [];
    }
  }
  Future<void> _updateFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favoritesJson = selectedPlayers
          .map((player) => jsonEncode(player.toJson()))
          .toList();
      await prefs.setStringList(_favKey, favoritesJson);
    } catch (e) {
      debugPrint('Error saving favorites: $e');
    }
  }
  void search(String query) {
    final lowerQuery = query.toLowerCase();

    final filtered = query.isEmpty
        ? allPlayers
        : allPlayers.where((p) =>
    p.name.toLowerCase().contains(lowerQuery) ||
        p.country.toLowerCase().contains(lowerQuery) ||
        p.club.toLowerCase().contains(lowerQuery)).toList();

    emit(PlayersLoaded(filtered, selectedPlayers));
  }
  Future<String> toggleSelection(Player player) async {
    bool isSelected  =false;
    if (state is! PlayersLoaded) return '';

    final currentState = state as PlayersLoaded;
    final selected = List<Player>.from(selectedPlayers);
    String message = '';

    if (selected.any((p) => p.playerId == player.playerId)) {
      isSelected = true;
      selected.removeWhere((p) => p.playerId == player.playerId);
      selectedPlayers = selected;
      await _updateFavorites();
      await updateVoteForSelectedPlayer(player.playerId,isSelected);
      message = 'Player removed from favorites';
    } else if (selected.length < 9) {
      selected.add(player);
      selectedPlayers = selected;
      await updateVoteForSelectedPlayer(player.playerId,isSelected);
      await _updateFavorites();
      message = 'Player saved to favorites';
    } else {
      message = 'Maximum favorites reached (9 players)';
    }

    emit(PlayersLoaded(currentState.players, selectedPlayers));
    return message;
  }
  Future<void> updateVoteForSelectedPlayer(String playerId, bool isSelected) async {
    if (state is! PlayersLoaded) return;

    final currentState = state as PlayersLoaded;

    // Update local state immediately for responsiveness
    final updatedPlayers = currentState.players.map((p) {
      if (p.playerId == playerId) {
        return Player(
          playerId: p.playerId,
          rank: p.rank,
          imSrc: p.imSrc,
          name: p.name,
          nameLink: p.nameLink,
          age: p.age,
          country: p.country,
          club: p.club,
          selections: p.selections,
        );
      }
      return p;
    }).toList();

   // emit(PlayersLoaded(updatedPlayers, currentState.selected));

    try {
      Player? playerFromSupabase = await repository.getPlayerById(playerId);
      if(playerFromSupabase !=null){
        // Get the updated player to use the correct 'selections' count
        final updatedPlayer = updatedPlayers.firstWhere((p) => p.playerId == playerId);
        print('benz before  is player selected $isSelected');
        print('benz before  ${playerFromSupabase.name}${playerFromSupabase.selections}');
        isSelected?--playerFromSupabase.selections:++playerFromSupabase.selections;
        print('benz after  ${playerFromSupabase.name} ${playerFromSupabase.selections}');
        await Supabase.instance.client
            .from('players')
            .update({
          'selections': playerFromSupabase.selections,
        })
            .eq('player_id', playerFromSupabase.playerId);
      }
      emit(PlayersLoaded(updatedPlayers, currentState.selected));
    } catch (e) {
      // Revert if Supabase update fails
      emit(PlayersLoaded(currentState.players, currentState.selected));
      throw e;
    }
  }
  Future<String?> _getDeviceId() async {
    final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

    try {
      if (Platform.isAndroid) {
        // For Android
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        return androidInfo.id; // May be null or change after factory reset
      } else if (Platform.isIOS) {
        // For iOS
        IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
        return iosInfo.identifierForVendor; // Changes if all vendor apps are uninstalled
      }
    } catch (e) {
      print("Error getting device ID: $e");
    }
    return null;
  }

}
