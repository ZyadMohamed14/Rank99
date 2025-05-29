import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../countries.dart';
import '../player_model.dart';
import '../players_cubit.dart';

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
            childAspectRatio: 0.59,
            crossAxisSpacing: 4,
            mainAxisSpacing: 10,
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



  @override
  Widget build(BuildContext context) {
    final code = countryNameToCode[player.country];
    final flag = code != null ? getFlagEmoji(code) : '';

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Player Image
          SizedBox(
            height: 150,
          width: 150,
            child: Image.network(
              player.imSrc,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const Icon(Icons.error),
            ),
          ),

          // Player Info
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(player.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text('Age: ${player.age}'),
                FittedBox(child: Text('Club: ${player.club}')),
                Text(
                  'Country: ${player.country} $flag',
                  style: const TextStyle(fontSize: 10),
                ),
                Text('Rank: ${player.rank}'),
              ],
            ),
          ),

          // Action Buttons in a Row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Vote Button
                IconButton(
                  icon: const Icon(Icons.thumb_up, color: Colors.blue),
                  onPressed: () => _voteForPlayer(context),
                  tooltip: 'Vote for this player',
                ),

                // Share Button
                IconButton(
                  icon: const Icon(Icons.share, color: Colors.black),
                  onPressed: () => _showShareOptions(context),
                ),

                // Delete Button
                IconButton(
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
                      await context.read<PlayersCubit>().toggleSelection(player);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${player.name} removed from favorites'),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }


  String getFlagEmoji(String countryCode) {
    return countryCode.toUpperCase().codeUnits
        .map((c) => String.fromCharCode(0x1F1E6 + c - 65))
        .join();
  }


  void _sharePlayer(BuildContext context) {
    final shareText = '''
🌟 Check out this amazing player! 🌟

⚽ ${player.name}
🏆 Rank: #${player.rank}
👤 Age: ${player.age}
🏠 Origin: ${player.country}
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
🏠 Origin: ${player.country}
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
Origin: ${player.country} | Club: ${player.club}
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
Origin: ${player.country} | Club: ${player.club}
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
  Future<void> _voteForPlayer(BuildContext context) async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      // Use Cubit to handle the vote
      await context.read<PlayersCubit>().toggleSelection(player);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Voted for ${player.name}! Total votes: ${player.selections + 1}'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to vote: ${e.toString()}'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } finally {
      if (context.mounted) Navigator.pop(context);
    }
  }
}

/*
 // // Delete Button
          // Positioned(
          //   top:56+ 8,
          //   right: 8,
          //   child: IconButton(
          //     icon: const Icon(Icons.delete, color: Colors.red),
          //     onPressed: () async {
          //       final confirmed = await showDialog<bool>(
          //         context: context,
          //         builder: (BuildContext context) {
          //           return AlertDialog(
          //             title: const Text('Remove Favorite'),
          //             content: Text('Remove ${player.name} from favorites?'),
          //             actions: [
          //               TextButton(
          //                 onPressed: () => Navigator.of(context).pop(false),
          //                 child: const Text('Cancel'),
          //               ),
          //               TextButton(
          //                 onPressed: () => Navigator.of(context).pop(true),
          //                 child: const Text('Remove'),
          //               ),
          //             ],
          //           );
          //         },
          //       );
          //
          //       if (confirmed == true && context.mounted) {
          //         await context.read<PlayersCubit>().removeFavorite(player);
          //         ScaffoldMessenger.of(context).showSnackBar(
          //           SnackBar(
          //             content: Text('${player.name} removed from favorites'),
          //             duration: const Duration(seconds: 2),
          //           ),
          //         );
          //       }
          //     },
          //   ),
          // ),
          // // Share Button
          // Positioned(
          //   bottom: 56, // 48 + 8 padding
          //   right: 8,
          //   child: IconButton(
          //     icon: const Icon(Icons.share, color: Colors.black),
          //     onPressed: () => _showShareOptions(context),
          //   ),
          // ),
          // /// vote button
          // Positioned(
          //   bottom: 8,
          //   right: 8,
          //   child: IconButton(
          //     icon: const Icon(Icons.thumb_up, color: Colors.blue),
          //     onPressed: () => _voteForPlayer(context),
          //     tooltip: 'Vote for this player',
          //   ),
          // ),
          //
 */