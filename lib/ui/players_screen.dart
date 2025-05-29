
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';

import '../countries.dart';
import '../player_model.dart';
import '../players_cubit.dart';

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
        }else if(state is PlayersLoaded){
          return GridView.builder(
            padding: const EdgeInsets.all(8),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 0.49,
              //    crossAxisSpacing: 8,
              //   mainAxisSpacing: 8,
            ),
            itemCount: state.players.length,
            itemBuilder: (context, index) => PlayerCard(player: state.players[index]),
          );
        }

        else if (state is PlayersError) return Center(child: Text(state.message));
        return const Center(child: CircularProgressIndicator());

      },
    );
  }
}
class PlayerCardSkeleton extends StatelessWidget {
  const PlayerCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    print('');
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
  String getFlagEmoji(String countryCode) {
    return countryCode.toUpperCase().codeUnits
        .map((c) => String.fromCharCode(0x1F1E6 + c - 65))
        .join();
  }
  @override
  Widget build(BuildContext context) {

    final code = countryNameToCode[player.country];
    final flag = code != null ? getFlagEmoji(code) : '';

    return Card(
      child: SingleChildScrollView(
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CachedNetworkImage(
                  imageUrl: player.imSrc,
                  fit: BoxFit.cover,
                  //placeholder: (context, url) => const CircularProgressIndicator(),
                  errorWidget: (context, url, error) => const Icon(Icons.person, size: 100),
                  fadeInDuration: const Duration(milliseconds: 200),
                  fadeOutDuration: const Duration(milliseconds: 100),
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FittedBox(child: Text(player.name, style: const TextStyle(fontWeight: FontWeight.bold))),
                      Text( player.age.toString()),
                      Text(player.club),
                      Text(
                        '${player.country} $flag',
                        style: TextStyle(fontSize: 10),
                      ),

                      Text(player.rank.toString()),
                    ],
                  ),
                ),
              ],
            ),
            // Positioned(
            //   top: 8,
            //   right: 8,
            //   child: CircleAvatar(
            //     backgroundColor: Colors.blue,
            //     child: Text('${player.rank}'),
            //   ),
            // ),
            // Positioned(
            //   bottom: 0,
            //   left: 8,
            //   child: Chip(
            //     label: Text(player.origin),
            //     backgroundColor: Colors.green.withOpacity(0.8),
            //   ),
            // ),
            Positioned(
              top: 0,
              right: 0,
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
      ),
    );
  }


}