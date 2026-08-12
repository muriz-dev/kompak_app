import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../providers/domain/entities/admin_provider.dart';
import '../../../providers/domain/repositories/admin_providers_repository.dart';
import '../../domain/entities/admin_leaderboard_reward.dart';
import '../../domain/repositories/admin_leaderboard_rewards_repository.dart';
import 'admin_leaderboard_reward_form_state.dart';

@injectable
class AdminLeaderboardRewardFormCubit
    extends Cubit<AdminLeaderboardRewardFormState> {
  AdminLeaderboardRewardFormCubit(this._repository, this._providersRepository)
    : super(AdminLeaderboardRewardFormLoading());

  final AdminLeaderboardRewardsRepository _repository;
  final AdminProvidersRepository _providersRepository;

  Future<void> loadProviders() async {
    try {
      final page = await _providersRepository.getProviders(
        status: AdminProviderStatus.verified,
        pageSize: 50,
      );
      emit(AdminLeaderboardRewardFormReady(providers: page.items));
    } catch (error) {
      emit(AdminLeaderboardRewardFormFailure(_message(error)));
    }
  }

  Future<void> save(
    AdminLeaderboardRewardDraft draft, {
    String? rewardId,
  }) async {
    final current = state;
    if (current is! AdminLeaderboardRewardFormReady || current.submitting) {
      return;
    }
    emit(current.copyWith(submitting: true, clearError: true));
    try {
      if (rewardId == null) {
        await _repository.createReward(draft);
      } else {
        await _repository.updateReward(rewardId, draft);
      }
      emit(current.copyWith(completed: true, clearError: true));
    } catch (error) {
      emit(current.copyWith(error: _message(error), clearError: false));
    }
  }

  Future<void> archive(String rewardId) async {
    final current = state;
    if (current is! AdminLeaderboardRewardFormReady || current.submitting) {
      return;
    }
    emit(current.copyWith(submitting: true, clearError: true));
    try {
      await _repository.archiveReward(rewardId);
      emit(current.copyWith(deleted: true, clearError: true));
    } catch (error) {
      emit(current.copyWith(error: _message(error), clearError: false));
    }
  }

  String _message(Object error) => error.toString().replaceFirst(
    RegExp(r'^(Exception|FormatException):\s*'),
    '',
  );
}
