import 'package:flutter/cupertino.dart';
import 'package:rank99/player_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PlayersRepository {
  final _supabase = Supabase.instance.client;

  Future<List<Player>> getPlayers() async {
    try {
      final response = await _supabase.from('players').select();
      print('Response from Supabase:');
        print(response);
      return (response as List).map((p) => Player(
        playerId: (p['player_id'] as String?) ?? '',
        rank: (p['rank'] as num?)?.toInt() ?? 0, // Handle bigint → int conversion
        imSrc: (p['im_src'] as String?) ?? '',
        name: (p['name'] as String?) ?? 'Unknown Player',
        nameLink: (p['name_link'] as String?) ?? '',
        age: (p['Age'] as num?)?.toInt() ?? 0, // Note PascalCase 'Age'
        origin: (p['Origin'] as String?) ?? '', // PascalCase 'Origin'
        club: (p['Club'] as String?) ?? '', // PascalCase 'Club'
        selections: (p['selections'] as num?)?.toInt() ?? 0,
      )).toList();
    } catch (e, stackTrace) {
      debugPrint('Error fetching players: $e');
      debugPrint('Stack trace: $stackTrace');
      return [];
    }
  }

}