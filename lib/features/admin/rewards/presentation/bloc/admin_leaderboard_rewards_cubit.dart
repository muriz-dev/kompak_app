import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../domain/repositories/admin_leaderboard_rewards_repository.dart';
import 'admin_leaderboard_rewards_state.dart';

@injectable
class AdminLeaderboardRewardsCubit extends Cubit<AdminLeaderboardRewardsState> {
  AdminLeaderboardRewardsCubit(this._repository)
    : super(AdminLeaderboardRewardsLoading());

  final AdminLeaderboardRewardsRepository _repository;

  Future<void> load({bool showLoading = true}) async {
    if (showLoading) emit(AdminLeaderboardRewardsLoading());
    try {
      emit(AdminLeaderboardRewardsLoaded(await _repository.getRewards()));
    } catch (error) {
      emit(AdminLeaderboardRewardsFailure(_message(error)));
    }
  }

  Future<void> refresh() => load(showLoading: false);

  String _message(Object error) => error.toString().replaceFirst(
    RegExp(r'^(Exception|FormatException):\s*'),
    '',
  );
}
