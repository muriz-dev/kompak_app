import 'package:equatable/equatable.dart';

import '../../domain/entities/admin_provider.dart';

sealed class AdminProviderDetailState extends Equatable {
  const AdminProviderDetailState();

  @override
  List<Object?> get props => [];
}

class AdminProviderDetailLoading extends AdminProviderDetailState {}

class AdminProviderDetailLoaded extends AdminProviderDetailState {
  const AdminProviderDetailLoaded({
    required this.detail,
    this.updating = false,
    this.actionError,
  });

  final AdminProviderDetail detail;
  final bool updating;
  final String? actionError;

  AdminProviderDetailLoaded copyWith({
    AdminProviderDetail? detail,
    bool? updating,
    String? actionError,
    bool clearActionError = false,
  }) => AdminProviderDetailLoaded(
    detail: detail ?? this.detail,
    updating: updating ?? this.updating,
    actionError: clearActionError ? null : actionError ?? this.actionError,
  );

  @override
  List<Object?> get props => [detail, updating, actionError];
}

class AdminProviderDetailFailure extends AdminProviderDetailState {
  const AdminProviderDetailFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
