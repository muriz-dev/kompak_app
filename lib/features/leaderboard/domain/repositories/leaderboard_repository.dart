import '../entities/leaderboard_data.dart';

abstract class LeaderboardRepository {
  Future<LeaderboardData> getLeaderboard({int limit = 50});
}
