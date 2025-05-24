import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shimmer/shimmer.dart';

import '../player_model.dart';
import '../players_cubit.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
      ],
    );
  }
}
class PlayersGrid extends StatelessWidget {
  const PlayersGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlayersCubit, PlayersState>(
      builder: (context, state) {
        if (state is PlayersLoading) {
          return Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: GridView.builder(
              padding: const EdgeInsets.all(8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.8,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: 6, // Number of skeleton items to show
              itemBuilder: (context, index) => const PlayerCardSkeleton(),
            ),
          );
        }

        if (state is PlayersError) return Center(child: Text(state.message));
        if (state is! PlayersLoaded) return const SizedBox.shrink(); // Fallback

        // Now we can safely access state.players
        return GridView.builder(
          padding: const EdgeInsets.all(8),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.8,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: state.players.length,
          itemBuilder: (context, index) => PlayerCard(player: state.players[index]),
        );
      },
    );
  }
}
class PlayerCardSkeleton extends StatelessWidget {
  const PlayerCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Image placeholder
              Container(
                height: 150,
                color: Colors.grey[300],
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 120,
                      height: 16,
                      color: Colors.grey[300],
                    ),
                    const SizedBox(height: 4),
                    Container(
                      width: 80,
                      height: 14,
                      color: Colors.grey[300],
                    ),
                    const SizedBox(height: 4),
                    Container(
                      width: 100,
                      height: 14,
                      color: Colors.grey[300],
                    ),
                  ],
                ),
              ),
            ],
          ),
          // Rank placeholder
          Positioned(
            top: 8,
            right: 8,
            child: CircleAvatar(
              backgroundColor: Colors.grey[300],
              radius: 16,
            ),
          ),
          // Country placeholder
          Positioned(
            bottom: 48,
            left: 8,
            child: Container(
              width: 60,
              height: 24,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
class PlayerCard extends StatelessWidget {
  final Player player;
  const PlayerCard({super.key, required this.player});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Image.network(
                  player.imSrc,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Icon(Icons.error),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(player.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text('Age: ${player.age}'),
                    Text('Club: ${player.club}'),
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            top: 8,
            right: 8,
            child: CircleAvatar(
              backgroundColor: Colors.blue,
              child: Text('${player.rank}'),
            ),
          ),
          Positioned(
            bottom: 48,
            left: 8,
            child: Chip(
              label: Text(player.origin),
              backgroundColor: Colors.green.withOpacity(0.8),
            ),
          ),
          Positioned(
            top: 8,
            left: 8,
            child: BlocBuilder<PlayersCubit, PlayersState>(
              builder: (context, state) {
                final isSelected = state is PlayersLoaded &&
                    state.selected.any((p) => p.playerId == player.playerId);
                return IconButton(
                  icon: Icon(
                    isSelected ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                  ),
                  onPressed: () async {
                    final message = await context.read<PlayersCubit>().toggleSelection(player);
                    if (message.isNotEmpty && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(message),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class FavoritesGrid extends StatelessWidget {
  const FavoritesGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlayersCubit, PlayersState>(
      builder: (context, state) {
        if (state is! PlayersLoaded) return const SizedBox.shrink();

        final selected = state.selected;

        if (selected.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.star_border, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'No favorite players yet',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
                SizedBox(height: 8),
                Text(
                  'Add players to favorites from the Players tab',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return GridView.builder(
          padding: const EdgeInsets.all(8),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.8,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: selected.length,
          itemBuilder: (context, index) => FavoritePlayerCard(player: selected[index]),
        );
      },
    );
  }
}

// New FavoritePlayerCard with delete option
class FavoritePlayerCard extends StatelessWidget {
  final Player player;
  const FavoritePlayerCard({super.key, required this.player});

  void _sharePlayer(BuildContext context) {
    final shareText = '''
🌟 Check out this amazing player! 🌟

⚽ ${player.name}
🏆 Rank: #${player.rank}
👤 Age: ${player.age}
🏠 Origin: ${player.origin}
🏟️ Club: ${player.club}
📊 Selections: ${player.selections}

Shared from Football Players App
''';

    Share.share(
      shareText,
      subject: 'Amazing Player: ${player.name}',
    );
  }

  void _showShareOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Share Player',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildShareOption(
                    context,
                    Icons.share,
                    'Share',
                    Colors.black,
                        () {
                      Navigator.pop(context);
                      _sharePlayer(context);
                    },
                  ),
                  _buildShareOption(
                    context,
                    Icons.copy,
                    'Copy Text',
                    Colors.green,
                        () {
                      Navigator.pop(context);
                      _copyToClipboard(context);
                    },
                  ),
                  _buildShareOption(
                    context,
                    Icons.image,
                    'Share Image',
                    Colors.orange,
                        () {
                      Navigator.pop(context);
                     // _shareWithImage(context);
                      _shareWithImage2(context);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildShareOption(BuildContext context, IconData icon, String label,
      Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            backgroundColor: color.withOpacity(0.1),
            radius: 25,
            child: Icon(icon, color: color, size: 25),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  void _copyToClipboard(BuildContext context) {
    final shareText = '''
⚽ ${player.name}
🏆 Rank: #${player.rank}
👤 Age: ${player.age}
🏠 Origin: ${player.origin}
🏟️ Club: ${player.club}
📊 Selections: ${player.selections}
''';

    Clipboard.setData(ClipboardData(text: shareText));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Player info copied to clipboard'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _shareWithImage(BuildContext context) {
    final shareText = '''
🌟 ${player.name} 🌟
Rank: #${player.rank} | Age: ${player.age}
Origin: ${player.origin} | Club: ${player.club}
Image: ${player.imSrc}
''';

    Share.share(
      shareText,
      subject: 'Player: ${player.name}',
    );
  }
  Future<void> _shareWithImage2(BuildContext context) async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      // Download the image
      final response = await http.get(Uri.parse(player.imSrc));
      if (response.statusCode != 200) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to download image')),
        );
        return;
      }

      // Get temporary directory
      final directory = await getTemporaryDirectory();
      final imagePath = '${directory.path}/player_share.jpg';

      // Save the image
      final file = File(imagePath);
      await file.writeAsBytes(response.bodyBytes);

      // Compress the image if needed (optional)
      final image = img.decodeImage(response.bodyBytes);
      if (image != null) {
        final compressed = img.encodeJpg(image, quality: 85);
        await file.writeAsBytes(compressed);
      }

      // Prepare share text
      final shareText = '''
🌟 ${player.name} 🌟
Rank: #${player.rank} | Age: ${player.age}
Origin: ${player.origin} | Club: ${player.club}
''';

      // Share both image and text
      await Share.shareFiles(
        [imagePath],
        text: shareText,
        subject: 'Check out ${player.name}!',
      );

      // Close loading dialog
      Navigator.pop(context);
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error sharing: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Image.network(
                  player.imSrc,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Icon(Icons.error),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(player.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text('Age: ${player.age}'),
                    Text('Club: ${player.club}'),
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            top: 8,
            right: 8,
            child: CircleAvatar(
              backgroundColor: Colors.blue,
              child: Text('${player.rank}'),
            ),
          ),
          Positioned(
            bottom: 48,
            left: 8,
            child: Chip(
              label: Text(player.origin),
              backgroundColor: Colors.green.withOpacity(0.8),
            ),
          ),
          // Delete Button
          Positioned(
            top: 8,
            left: 8,
            child: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Remove Favorite'),
                      content: Text('Remove ${player.name} from favorites?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          child: const Text('Remove'),
                        ),
                      ],
                    );
                  },
                );

                if (confirmed == true && context.mounted) {
                  await context.read<PlayersCubit>().removeFavorite(player);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${player.name} removed from favorites'),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }
              },
            ),
          ),
          // Share Button
          Positioned(
            top: 50,
            left: 8,
            child: IconButton(
              icon: const Icon(Icons.share, color: Colors.blue),
              onPressed: () => _showShareOptions(context),
            ),
          ),
        ],
      ),
    );
  }
}