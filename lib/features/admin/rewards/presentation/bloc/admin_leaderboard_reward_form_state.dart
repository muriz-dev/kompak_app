import 'package:equatable/equatable.dart';

import '../../../providers/domain/entities/admin_provider.dart';

sealed class AdminLeaderboardRewardFormState extends Equatable {
  const AdminLeaderboardRewardFormState();
  @override
  List<Object?> get props => [];
}

class AdminLeaderboardRewardFormLoading
    extends AdminLeaderboardRewardFormState {}

class AdminLeaderboardRewardFormReady extends AdminLeaderboardRewardFormState {
  const AdminLeaderboardRewardFormReady({
    required this.providers,
    this.submitting = false,
    this.completed = false,
    this.deleted = false,
    this.error,
  });

  final List<AdminProviderSummary> providers;
  final bool submitting;
  final bool completed;
  final bool deleted;
  final String? error;

  AdminLeaderboardRewardFormReady copyWith({
    bool? submitting,
    bool? completed,
    bool? deleted,
    String? error,
    bool clearError = false,
  }) => AdminLeaderboardRewardFormReady(
    providers: providers,
    submitting: submitting ?? this.submitting,
    completed: completed ?? this.completed,
    deleted: deleted ?? this.deleted,
    error: clearError ? null : error ?? this.error,
  );

  @override
  List<Object?> get props => [providers, submitting, completed, deleted, error];
}

class AdminLeaderboardRewardFormFailure
    extends AdminLeaderboardRewardFormState {
  const AdminLeaderboardRewardFormFailure(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}
