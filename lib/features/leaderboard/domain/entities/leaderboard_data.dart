class LeaderboardWinner {
  final String id;
  final String name;
  final String avatarUrl;
  final int points;
  final int rank;

  LeaderboardWinner({
    required this.id,
    required this.name,
    required this.avatarUrl,
    required this.points,
    required this.rank,
  });
}

class LeaderboardEntry {
  final String id;
  final String name;
  final String avatarUrl;
  final String location;
  final int points;
  final int rank;

  LeaderboardEntry({
    required this.id,
    required this.name,
    required this.avatarUrl,
    required this.location,
    required this.points,
    required this.rank,
  });
}

class LeaderboardStats {
  final int totalParticipation;
  final String pointsCollected; // e.g., "42.8K"

  LeaderboardStats({
    required this.totalParticipation,
    required this.pointsCollected,
  });
}

class LeaderboardReward {
  final int rank;
  final String title;
  final String description;

  LeaderboardReward({
    required this.rank,
    required this.title,
    required this.description,
  });
}
