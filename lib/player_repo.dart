import 'package:flutter/cupertino.dart';
import 'package:rank99/player_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PlayersRepository {
  final _supabase = Supabase.instance.client;


  Future<List<Player>> getPlayers() async {
    try {
      final response = await _supabase
          .rpc('get_players_with_ranks')
          .select();
       print(response);
      final players = (response as List).map((p) {
        return Player.fromJson({
          'player_id': p['player_id'] ?? '',
          'rank': p['rank'] ?? 0,
          'im_src': p['im_src'] ?? '',
          'name': p['name'] ?? 'Unknown Player',
          'name_link': '', // Not available in tables
          'age': p['age'] ?? 0,
          'country': p['country'] ?? 'Unknown Origin',
          'Club': p['club'] ?? 'Unknown Club',
          'selections': p['selections'] ?? 0,
        });
      }).toList();
      print(players[0]);
      players.sort((a, b) => a.rank.compareTo(b.rank));
      return players;
    } catch (e, stackTrace) {
      debugPrint('Errord fetching players: $e');
      debugPrint('Stack trace: $stackTrace');
      return [];
    }
  }

  Future<List<Player>> getFifaRankedPlayers() async {
    try {
      final response = await _supabase
          .rpc('get_players_with_fifa_ranks')
          .select();
      print('****************************');
      print(response);
      final players = (response as List).map((p) {
        return Player.fromJson({
          'player_id': p['player_id'] ?? '',
          'rank': p['rank'] ?? 0,
          'im_src': p['im_src'] ?? '',
          'name': p['name'] ?? 'Unknown Player',
          'name_link': '', // Not available in tables
          'age': p['age'] ?? 0,
          'country': p['country'] ?? 'Unknown Origin',
          'Club': p['club'] ?? 'Unknown Club',
          'selections': p['selections'] ?? 0,
        });
      }).toList();
      players.sort((a, b) => a.rank.compareTo(b.rank));
      return players;
    } catch (e, stackTrace) {
      debugPrint('Errord fetching players: $e');
      debugPrint('Stack trace: $stackTrace');
      return [];
    }
  }
  Future<List<Player>> getEARankedPlayers() async {
    try {
      final response = await _supabase
          .rpc('get_players_with_ea_ranks')
          .select();
      print(response);
      final players = (response as List).map((p) {
        return Player.fromJson({
          'player_id': p['player_id'] ?? '',
          'rank': p['rank'] ?? 0,
          'im_src': p['im_src'] ?? '',
          'name': p['name'] ?? 'Unknown Player',
          'name_link': '', // Not available in tables
          'age': p['age'] ?? 0,
          'country': p['country'] ?? 'Unknown Origin',
          'Club': p['club'] ?? 'Unknown Club',
          'selections': p['selections'] ?? 0,
        });
      }).toList();
      print(players[0]);
      players.sort((a, b) => a.rank.compareTo(b.rank));
      return players;
    } catch (e, stackTrace) {
      debugPrint('Errord fetching players: $e');
      debugPrint('Stack trace: $stackTrace');
      return [];
    }
  }
  Future<List<Player>> getTransMarketPlayers() async {
    try {
      final response = await _supabase
          .rpc('get_players_with_transfermarkt_ranks')
          .select();
      print(response);
      final players = (response as List).map((p) {
        return Player.fromJson({
          'player_id': p['player_id'] ?? '',
          'rank': p['rank'] ?? 0,
          'im_src': p['im_src'] ?? '',
          'name': p['name'] ?? 'Unknown Player',
          'name_link': '', // Not available in tables
          'age': p['age'] ?? 0,
          'country': p['country'] ?? 'Unknown Origin',
          'Club': p['club'] ?? 'Unknown Club',
          'selections': p['selections'] ?? 0,
        });
      }).toList();
      print(players[0]);
      players.sort((a, b) => a.rank.compareTo(b.rank));
      return players;
    } catch (e, stackTrace) {
      debugPrint('Errord fetching players: $e');
      debugPrint('Stack trace: $stackTrace');
      return [];
    }
  }
  Future<bool> updatePlayerInSupabase(Player player) async {
    try{
      await Supabase.instance.client
          .from('players')
          .update(player.toJson())
          .eq('player_id', player.playerId);
      return true;
    }catch(e){
      return false;
    }

  }
  Future<Player?> getPlayerById(String playerId) async {
    try {
      final response = await _supabase
          .from('players')
          .select()
          .eq('player_id', playerId)
          .single(); // Ensures you get only one result

      return Player.fromJson(response);
    } catch (e, stackTrace) {
      debugPrint('Error fetching player by ID: $e');
      debugPrint('Stack trace: $stackTrace');
      return null;
    }
  }
}

/*
Player(
        playerId: (p['player_id'] as String?) ?? '',
        rank: (p['rank'] as num?)?.toInt() ?? 0, // Handle bigint → int conversion
        imSrc: (p['im_src'] as String?) ?? '',
        name: (p['name'] as String?) ?? 'Unknown Player',
        nameLink: (p['name_link'] as String?) ?? '',
        age: (p['Age'] as num?)?.toInt() ?? 0, // Note PascalCase 'Age'
        origin: (p['Origin'] as String?) ?? '', // PascalCase 'Origin'
        club: (p['Club'] as String?) ?? '', // PascalCase 'Club'
        selections: (p['selections'] as num?)?.toInt() ?? 0,
      )
 */