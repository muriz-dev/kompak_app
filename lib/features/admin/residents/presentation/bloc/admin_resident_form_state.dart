import 'package:equatable/equatable.dart';

import '../../domain/entities/resident.dart';

sealed class AdminResidentFormState extends Equatable {
  const AdminResidentFormState();

  @override
  List<Object?> get props => [];
}

class AdminResidentFormIdle extends AdminResidentFormState {}

class AdminResidentFormSubmitting extends AdminResidentFormState {}

class AdminResidentFormSuccess extends AdminResidentFormState {
  const AdminResidentFormSuccess(this.resident);

  final Resident resident;

  @override
  List<Object?> get props => [resident];
}

class AdminResidentFormFailure extends AdminResidentFormState {
  const AdminResidentFormFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
