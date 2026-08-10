import 'package:equatable/equatable.dart';

import '../../domain/entities/community_event.dart';

sealed class ActivityDetailState extends Equatable {
  const ActivityDetailState();

  @override
  List<Object?> get props => [];
}

class ActivityDetailLoading extends ActivityDetailState {}

class ActivityDetailLoaded extends ActivityDetailState {
  const ActivityDetailLoaded(this.event);

  final CommunityEvent event;

  @override
  List<Object?> get props => [event];
}

class ActivityDetailError extends ActivityDetailState {
  const ActivityDetailError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
