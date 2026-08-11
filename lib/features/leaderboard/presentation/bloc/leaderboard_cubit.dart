import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../domain/repositories/leaderboard_repository.dart';
import 'leaderboard_state.dart';

@injectable
class LeaderboardCubit extends Cubit<LeaderboardState> {
  LeaderboardCubit(this._repository) : super(LeaderboardLoading());

  final LeaderboardRepository _repository;

  Future<void> loadLeaderboardData() async {
    emit(LeaderboardLoading());
    try {
      final data = await _repository.getLeaderboard();
      emit(
        LeaderboardLoaded(
          winners: data.entries.take(3).toList(growable: false),
          otherEntries: data.entries.skip(3).toList(growable: false),
          rewards: data.rewards,
          stats: data.stats,
          currentUserRank: data.currentUser,
        ),
      );
    } catch (error) {
      emit(LeaderboardError(error.toString().replaceFirst('Exception: ', '')));
    }
  }
}
