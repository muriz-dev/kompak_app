import 'package:injectable/injectable.dart';

import '../../domain/entities/leaderboard_data.dart';
import '../../domain/repositories/leaderboard_repository.dart';
import '../datasources/leaderboard_remote_data_source.dart';

@LazySingleton(as: LeaderboardRepository)
class LeaderboardRepositoryImpl implements LeaderboardRepository {
  const LeaderboardRepositoryImpl(this._remoteDataSource);

  final LeaderboardRemoteDataSource _remoteDataSource;

  @override
  Future<LeaderboardData> getLeaderboard({int limit = 50}) =>
      _remoteDataSource.getLeaderboard(limit: limit);
}
