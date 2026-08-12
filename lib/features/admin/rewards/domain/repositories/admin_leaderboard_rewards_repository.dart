import '../entities/admin_leaderboard_reward.dart';

abstract class AdminLeaderboardRewardsRepository {
  Future<List<AdminLeaderboardReward>> getRewards();

  Future<AdminLeaderboardReward> createReward(
    AdminLeaderboardRewardDraft draft,
  );

  Future<AdminLeaderboardReward> updateReward(
    String rewardId,
    AdminLeaderboardRewardDraft draft,
  );

  Future<void> archiveReward(String rewardId);
}
