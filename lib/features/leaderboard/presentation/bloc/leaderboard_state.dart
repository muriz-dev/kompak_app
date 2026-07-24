import 'package:equatable/equatable.dart';
import '../../domain/entities/leaderboard_data.dart';

abstract class LeaderboardState extends Equatable {
  const LeaderboardState();

  @override
  List<Object?> get props => [];
}

class LeaderboardLoading extends LeaderboardState {}

class LeaderboardLoaded extends LeaderboardState {
  final List<LeaderboardWinner> winners; // Top 3
  final List<LeaderboardEntry> otherEntries; // Rank 4 and below
  final List<LeaderboardReward> rewards;
  final LeaderboardStats stats;
  final LeaderboardEntry currentUserRank; // Rank of the current user

  const LeaderboardLoaded({
    required this.winners,
    required this.otherEntries,
    required this.rewards,
    required this.stats,
    required this.currentUserRank,
  });

  @override
  List<Object?> get props => [winners, otherEntries, rewards, stats, currentUserRank];
}

class LeaderboardError extends LeaderboardState {
  final String message;

  const LeaderboardError(this.message);

  @override
  List<Object?> get props => [message];
}
