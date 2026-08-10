import 'package:equatable/equatable.dart';

import '../../domain/entities/admin_event.dart';

sealed class AdminEventsState extends Equatable {
  const AdminEventsState();

  @override
  List<Object?> get props => [];
}

class AdminEventsLoading extends AdminEventsState {}

class AdminEventsLoadFailure extends AdminEventsState {
  const AdminEventsLoadFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

class AdminEventsLoaded extends AdminEventsState {
  const AdminEventsLoaded(this.events, {this.updatingEventId});

  final List<AdminEvent> events;
  final String? updatingEventId;

  @override
  List<Object?> get props => [events, updatingEventId];
}
