class Player {
  final String playerId;
  final int rank;
  final String imSrc;
  final String name;
  final String nameLink;
  final int age;
  final String origin;
  final String club;
  final int selections;

  Player({
    required this.playerId,
    required this.rank,
    required this.imSrc,
    required this.name,
    required this.nameLink,
    required this.age,
    required this.origin,
    required this.club,
    required this.selections,
  });

  // Convert Player object to JSON Map
  Map<String, dynamic> toJson() {
    return {
      'player_id': playerId,
      'rank': rank,
      'im_src': imSrc,
      'name': name,
      'name_link': nameLink,
      'Age': age,  // Note: PascalCase to match your Supabase columns
      'Origin': origin,
      'Club': club,
      'selections': selections,
    };
  }

  // Create Player object from JSON Map
  factory Player.fromJson(Map<String, dynamic> json) {
    return Player(
      playerId: json['player_id']?.toString() ?? '',
      rank: (json['rank'] as num?)?.toInt() ?? 0,
      imSrc: json['im_src']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Unknown Player',
      nameLink: json['name_link']?.toString() ?? '',
      age: (json['Age'] as num?)?.toInt() ?? 0,  // PascalCase
      origin: json['Origin']?.toString() ?? '',  // PascalCase
      club: json['Club']?.toString() ?? '',      // PascalCase
      selections: (json['selections'] as num?)?.toInt() ?? 0,
    );
  }

  // Optional: Override toString() for debugging
  @override
  String toString() {
    return 'Player{name: $name, rank: $rank, club: $club}';
  }
}