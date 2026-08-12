import 'package:equatable/equatable.dart';

import '../../domain/entities/admin_leaderboard_reward.dart';

sealed class AdminLeaderboardRewardsState extends Equatable {
  const AdminLeaderboardRewardsState();
  @override
  List<Object?> get props => [];
}

class AdminLeaderboardRewardsLoading extends AdminLeaderboardRewardsState {}

class AdminLeaderboardRewardsLoaded extends AdminLeaderboardRewardsState {
  const AdminLeaderboardRewardsLoaded(this.rewards);
  final List<AdminLeaderboardReward> rewards;

  AdminLeaderboardReward? rewardAt(int position) {
    for (final reward in rewards) {
      if (reward.position == position) return reward;
    }
    return null;
  }

  @override
  List<Object?> get props => [rewards];
}

class AdminLeaderboardRewardsFailure extends AdminLeaderboardRewardsState {
  const AdminLeaderboardRewardsFailure(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}
