import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:meta/meta.dart';
import 'package:rank99/player_model.dart';
import 'package:rank99/player_repo.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'players_state.dart';

class PlayersCubit extends Cubit<PlayersState> {
  final PlayersRepository repository;
  List<Player> allPlayers = [];
  List<Player> selectedPlayers = [];
  static const String _favKey = 'favoritePlayers';
  PlayersCubit(this.repository) : super(PlayersLoading()) {
    loadPlayers();
  }

  void loadPlayers() async {
    try {
      allPlayers = await repository.getPlayers();
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
  Future<void> _saveFavorites() async {
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
    final filtered = query.isEmpty
        ? allPlayers
        : allPlayers.where((p) => p.name.toLowerCase().contains(query.toLowerCase())).toList();
    emit(PlayersLoaded(filtered, selectedPlayers));
  }



  Future<String> toggleSelection(Player player) async {
    if (state is! PlayersLoaded) return '';

    final currentState = state as PlayersLoaded;
    final selected = List<Player>.from(selectedPlayers);
    String message = '';

    if (selected.any((p) => p.playerId == player.playerId)) {
      selected.removeWhere((p) => p.playerId == player.playerId);
      selectedPlayers = selected;
      await _saveFavorites();
      message = 'Player removed from favorites';
    } else if (selected.length < 9) {
      selected.add(player);
      selectedPlayers = selected;
      await _saveFavorites();
      message = 'Player saved to favorites';
    } else {
      message = 'Maximum favorites reached (9 players)';
    }

    emit(PlayersLoaded(currentState.players, selectedPlayers));
    return message;
  }

  Future<void> removeFavorite(Player player) async {
    final selected = List<Player>.from(selectedPlayers);
    selected.removeWhere((p) => p.playerId == player.playerId);
    selectedPlayers = selected;
    await _saveFavorites();

    if (state is PlayersLoaded) {
      final currentState = state as PlayersLoaded;
      emit(PlayersLoaded(currentState.players, selectedPlayers));
    }
  }
}
