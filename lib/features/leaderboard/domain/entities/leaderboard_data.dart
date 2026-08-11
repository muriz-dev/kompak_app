import 'package:equatable/equatable.dart';

class LeaderboardData extends Equatable {
  const LeaderboardData({
    required this.entries,
    required this.stats,
    required this.rewards,
    this.currentUser,
  });

  factory LeaderboardData.fromJson(Map<String, dynamic> json) {
    final currentUserJson = json['currentUser'];
    return LeaderboardData(
      entries: (json['entries'] as List? ?? const [])
          .map(
            (entry) => LeaderboardEntry.fromJson(
              Map<String, dynamic>.from(entry as Map),
            ),
          )
          .toList(growable: false),
      currentUser: currentUserJson is Map
          ? LeaderboardEntry.fromJson(
              Map<String, dynamic>.from(currentUserJson),
            )
          : null,
      stats: LeaderboardStats.fromJson(
        Map<String, dynamic>.from(json['stats'] as Map? ?? const {}),
      ),
      rewards: (json['rewards'] as List? ?? const [])
          .map(
            (reward) => LeaderboardReward.fromJson(
              Map<String, dynamic>.from(reward as Map),
            ),
          )
          .toList(growable: false),
    );
  }

  final List<LeaderboardEntry> entries;
  final LeaderboardEntry? currentUser;
  final LeaderboardStats stats;
  final List<LeaderboardReward> rewards;

  @override
  List<Object?> get props => [entries, currentUser, stats, rewards];
}

class LeaderboardEntry extends Equatable {
  const LeaderboardEntry({
    required this.id,
    required this.name,
    required this.points,
    required this.rank,
  });

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) =>
      LeaderboardEntry(
        id: json['id']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        points: (json['points'] as num?)?.toInt() ?? 0,
        rank: (json['rank'] as num?)?.toInt() ?? 0,
      );

  final String id;
  final String name;
  final int points;
  final int rank;

  @override
  List<Object?> get props => [id, name, points, rank];
}

class LeaderboardStats extends Equatable {
  const LeaderboardStats({
    required this.totalCitizens,
    required this.participatingCitizens,
    required this.totalPoints,
  });

  factory LeaderboardStats.fromJson(Map<String, dynamic> json) =>
      LeaderboardStats(
        totalCitizens: (json['totalCitizens'] as num?)?.toInt() ?? 0,
        participatingCitizens:
            (json['participatingCitizens'] as num?)?.toInt() ?? 0,
        totalPoints: (json['totalPoints'] as num?)?.toInt() ?? 0,
      );

  final int totalCitizens;
  final int participatingCitizens;
  final int totalPoints;

  @override
  List<Object?> get props => [
    totalCitizens,
    participatingCitizens,
    totalPoints,
  ];
}

class LeaderboardReward extends Equatable {
  const LeaderboardReward({
    required this.id,
    required this.rank,
    required this.title,
    required this.description,
    this.imageUrl,
  });

  factory LeaderboardReward.fromJson(Map<String, dynamic> json) =>
      LeaderboardReward(
        id: json['id']?.toString() ?? '',
        rank: (json['rank'] as num?)?.toInt() ?? 0,
        title: json['title']?.toString() ?? '',
        description: json['description']?.toString() ?? '',
        imageUrl: json['imageUrl']?.toString(),
      );

  final String id;
  final int rank;
  final String title;
  final String description;
  final String? imageUrl;

  @override
  List<Object?> get props => [id, rank, title, description, imageUrl];
}
