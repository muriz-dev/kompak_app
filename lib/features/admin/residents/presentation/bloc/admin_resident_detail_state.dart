import 'package:equatable/equatable.dart';

import '../../domain/entities/resident.dart';

sealed class AdminResidentDetailState extends Equatable {
  const AdminResidentDetailState();

  @override
  List<Object?> get props => [];
}

class AdminResidentDetailLoading extends AdminResidentDetailState {}

class AdminResidentDetailLoaded extends AdminResidentDetailState {
  const AdminResidentDetailLoaded({
    required this.resident,
    this.updatingStatus = false,
    this.actionError,
  });

  final Resident resident;
  final bool updatingStatus;
  final String? actionError;

  AdminResidentDetailLoaded copyWith({
    Resident? resident,
    bool? updatingStatus,
    String? actionError,
    bool clearActionError = false,
  }) => AdminResidentDetailLoaded(
    resident: resident ?? this.resident,
    updatingStatus: updatingStatus ?? this.updatingStatus,
    actionError: clearActionError ? null : actionError ?? this.actionError,
  );

  @override
  List<Object?> get props => [resident, updatingStatus, actionError];
}

class AdminResidentDetailFailure extends AdminResidentDetailState {
  const AdminResidentDetailFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
