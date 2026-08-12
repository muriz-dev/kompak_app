import 'package:injectable/injectable.dart';

import '../../domain/entities/admin_leaderboard_reward.dart';
import '../../domain/repositories/admin_leaderboard_rewards_repository.dart';
import '../datasources/admin_leaderboard_rewards_remote_data_source.dart';

@LazySingleton(as: AdminLeaderboardRewardsRepository)
class AdminLeaderboardRewardsRepositoryImpl
    implements AdminLeaderboardRewardsRepository {
  const AdminLeaderboardRewardsRepositoryImpl(this._remoteDataSource);

  final AdminLeaderboardRewardsRemoteDataSource _remoteDataSource;

  @override
  Future<List<AdminLeaderboardReward>> getRewards() =>
      _remoteDataSource.getRewards();

  @override
  Future<AdminLeaderboardReward> createReward(
    AdminLeaderboardRewardDraft draft,
  ) => _remoteDataSource.createReward(draft);

  @override
  Future<AdminLeaderboardReward> updateReward(
    String rewardId,
    AdminLeaderboardRewardDraft draft,
  ) => _remoteDataSource.updateReward(rewardId, draft);

  @override
  Future<void> archiveReward(String rewardId) =>
      _remoteDataSource.archiveReward(rewardId);
}
