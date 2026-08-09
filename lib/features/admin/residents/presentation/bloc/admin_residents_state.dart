import 'package:equatable/equatable.dart';

import '../../domain/entities/resident.dart';

sealed class AdminResidentsState extends Equatable {
  const AdminResidentsState();

  @override
  List<Object?> get props => [];
}

class AdminResidentsLoading extends AdminResidentsState {}

class AdminResidentsLoadFailure extends AdminResidentsState {
  const AdminResidentsLoadFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

class AdminResidentsLoaded extends AdminResidentsState {
  const AdminResidentsLoaded({
    required this.residents,
    this.updatingIds = const {},
    this.actionError,
  });

  final List<Resident> residents;
  final Set<String> updatingIds;
  final String? actionError;

  AdminResidentsLoaded copyWith({
    List<Resident>? residents,
    Set<String>? updatingIds,
    String? actionError,
    bool clearActionError = false,
  }) => AdminResidentsLoaded(
    residents: residents ?? this.residents,
    updatingIds: updatingIds ?? this.updatingIds,
    actionError: clearActionError ? null : actionError ?? this.actionError,
  );

  @override
  List<Object?> get props => [residents, updatingIds, actionError];
}
