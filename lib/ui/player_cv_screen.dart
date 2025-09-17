import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rank99/player_model.dart';

import '../countries.dart';

class PlayerCvScreen extends StatelessWidget {
  final Player player;

  const PlayerCvScreen(this.player, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(player.name),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/cv_backgroud.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              PlayerImageNameAndClub(player),
              PlayerProfile(player),
            ],
          ),
        ),
      ),
    );
  }
}

class PlayerImageNameAndClub extends StatelessWidget {
  final Player player;

  const PlayerImageNameAndClub(this.player, {super.key});

  @override
  Widget build(BuildContext context) {

    return Row(
      children: [
        CachedNetworkImage(
          width: 150,
          height: 150,
          imageUrl: player.imSrc,
          fit: BoxFit.cover,
          //placeholder: (context, url) => const CircularProgressIndicator(),
          errorWidget: (context, url, error) =>
          const Icon(Icons.person, size: 100),
          fadeInDuration: const Duration(milliseconds: 200),
          fadeOutDuration: const Duration(milliseconds: 100),
        ),
        Column(
          children: [

            Text(player.name,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10,),
            Text(player.club,
                style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        )
      ],
    );
  }

}

class PlayerProfile extends StatelessWidget {
  final Player player;

  const PlayerProfile(this.player, {super.key});

  @override
  Widget build(BuildContext context) {
    final code = countryNameToCode[player.country];
    final flag = code != null ? getFlagEmoji(code) : '';
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        children: [
          Container(
            color: Colors.white,
            child: Text(
                'player profile', // Add your text content
                style: TextStyle(
                  fontFamily: 'Clash Grotesk',
                  color: Color(0xFFDB5461), // Proper hex color format
                )),
          ),
          const SizedBox(height: 10,),
          Container(
            color: Colors.white,
            child: Column(
              children: [
                dataHeader('Date of birth/Age :', player.age.toString()),
                dataHeader('Place of birth  :', '${player.country} $flag'),
                dataHeader('Position :', 'Right Winger'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget dataHeader(String header, String value) {
    return Row(children: [
      Text(header),
      Spacer(),
      Text(value),
    ],);
  }

  String getFlagEmoji(String countryCode) {
    return countryCode
        .toUpperCase()
        .codeUnits
        .map((c) => String.fromCharCode(0x1F1E6 + c - 65))
        .join();
  }
}
