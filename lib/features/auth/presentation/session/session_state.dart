import 'package:equatable/equatable.dart';

import '../../domain/entities/session_user.dart';

sealed class SessionState extends Equatable {
  const SessionState();

  @override
  List<Object?> get props => [];
}

class SessionInitial extends SessionState {}

class SessionChecking extends SessionState {}

class SessionUnauthenticated extends SessionState {}

sealed class SessionWithUser extends SessionState {
  const SessionWithUser(this.user);

  final SessionUser user;

  @override
  List<Object?> get props => [user];
}

class SessionActive extends SessionWithUser {
  const SessionActive(super.user);
}

class SessionPending extends SessionWithUser {
  const SessionPending(super.user);
}

class SessionRejected extends SessionWithUser {
  const SessionRejected(super.user);
}

class SessionBlocked extends SessionWithUser {
  const SessionBlocked(super.user);
}

class SessionFailure extends SessionState {
  const SessionFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
