import 'package:equatable/equatable.dart';

import '../../domain/entities/admin_event.dart';

sealed class CreateEventState extends Equatable {
  const CreateEventState();

  @override
  List<Object?> get props => [];
}

class CreateEventInitial extends CreateEventState {}

class CreateEventSubmitting extends CreateEventState {}

class CreateEventSuccess extends CreateEventState {
  const CreateEventSuccess(this.event);

  final AdminEvent event;

  @override
  List<Object?> get props => [event];
}

class CreateEventFailure extends CreateEventState {
  const CreateEventFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
