import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/auth/session_invalidation_bus.dart';
import '../../data/models/login_request.dart';
import '../../domain/entities/session_user.dart';
import '../../domain/repositories/auth_repository.dart';
import 'session_state.dart';

@lazySingleton
class SessionCubit extends Cubit<SessionState> {
  SessionCubit(this._repository, this._invalidationBus)
    : super(SessionInitial()) {
    _invalidationSubscription = _invalidationBus.stream.listen((_) {
      emit(SessionUnauthenticated());
    });
  }

  final AuthRepository _repository;
  final SessionInvalidationBus _invalidationBus;
  late final StreamSubscription<void> _invalidationSubscription;

  Future<void> restoreSession() async {
    emit(SessionChecking());
    try {
      final user = await _repository.restoreSession();
      if (user == null) {
        emit(SessionUnauthenticated());
      } else {
        _emitUser(user);
      }
    } catch (error) {
      emit(SessionFailure(_message(error)));
    }
  }

  Future<void> login(LoginRequest request) async {
    emit(SessionChecking());
    try {
      _emitUser(await _repository.login(request));
    } catch (error) {
      emit(SessionFailure(_message(error)));
    }
  }

  Future<void> refreshSession() async {
    emit(SessionChecking());
    try {
      final user = await _repository.refreshSession();
      if (user == null) {
        emit(SessionUnauthenticated());
      } else {
        _emitUser(user);
      }
    } catch (error) {
      emit(SessionFailure(_message(error)));
    }
  }

  Future<void> logout() async {
    await _repository.logout();
    emit(SessionUnauthenticated());
  }

  void _emitUser(SessionUser user) {
    emit(switch (user.status) {
      UserStatus.active => SessionActive(user),
      UserStatus.pending => SessionPending(user),
      UserStatus.rejected => SessionRejected(user),
      UserStatus.inactive => SessionBlocked(user),
    });
  }

  String _message(Object error) => error.toString().replaceFirst(
    RegExp(r'^(Exception|FormatException):\s*'),
    '',
  );

  @override
  Future<void> close() async {
    await _invalidationSubscription.cancel();
    return super.close();
  }
}
