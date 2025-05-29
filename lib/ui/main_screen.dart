import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:rank99/ui/players_screen.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shimmer/shimmer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../countries.dart';
import '../player_model.dart';
import '../players_cubit.dart';
import 'fav_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  String? _selectedFilter;
  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        await context.read<PlayersCubit>().loadPlayers();
      },
      child: Scaffold(
         appBar:  AppBar(
            title: _currentIndex == 0
                ? _buildSearchField()
                : const Text('Favorite Players'),
          ),
        body: _currentIndex == 0 ? const PlayersGrid() : const FavoritesGrid(),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Players'),
            BottomNavigationBarItem(icon: Icon(Icons.star), label: 'Favorites'),
          ],
          onTap: (index) => setState(() => _currentIndex = index),
        ),
      ),
    );
  }
  Widget _buildSearchField() {
    return Row(
      children: [
        const Icon(Icons.sports_soccer, size: 30),
        const SizedBox(width: 10),
        Expanded(
          child: TextField(
            controller: _searchController,
            decoration: const InputDecoration(
              hintText: 'Search players...',
              border: InputBorder.none,
            ),
            onChanged: (value) => context.read<PlayersCubit>().search(value),
          ),
        ),
        const SizedBox(width: 10),
        // Dropdown menu button with filter handling
        DropdownButton<String>(
          value: _selectedFilter,
          icon: const Icon(Icons.arrow_drop_down),
          elevation: 4,
          underline: Container(height: 0),
          onChanged: (String? newValue) {
            setState(() => _selectedFilter = newValue);

            // Handle filter selection
            if (newValue == 'Transfers Market') {
             context.read<PlayersCubit>().loadPlayers(playerType: PlayerType.transfermarkt);

            } else if (newValue == 'Fifa Rank') {
              context.read<PlayersCubit>().loadPlayers(playerType: PlayerType.fifarank);

            } else if (newValue == 'EA Rank') {
              context.read<PlayersCubit>().loadPlayers(playerType: PlayerType.earank);

            }
            else{
              context.read<PlayersCubit>().loadPlayers();
            }
          },
          items: <String>['Transfers Market', 'Fifa Rank', 'EA Rank','Ranker']
              .map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Row(
                children: [
                  const Icon(Icons.sports_soccer, size: 16),
                  const SizedBox(width: 4),
                  Text(value),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}




