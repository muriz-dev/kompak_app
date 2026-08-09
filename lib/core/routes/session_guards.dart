import 'package:auto_route/auto_route.dart';

import '../../features/auth/domain/entities/session_user.dart';
import '../../features/auth/presentation/session/session_cubit.dart';
import '../../features/auth/presentation/session/session_state.dart';
import 'app_router.dart';

class ActiveSessionGuard extends AutoRouteGuard {
  const ActiveSessionGuard(this._sessionCubit);

  final SessionCubit _sessionCubit;

  @override
  void onNavigation(NavigationResolver resolver, StackRouter router) {
    if (_sessionCubit.state is SessionActive) {
      resolver.next();
    } else {
      resolver.redirectUntil(const SessionGateRoute());
    }
  }
}

class AdminSessionGuard extends AutoRouteGuard {
  const AdminSessionGuard(this._sessionCubit);

  final SessionCubit _sessionCubit;

  @override
  void onNavigation(NavigationResolver resolver, StackRouter router) {
    final state = _sessionCubit.state;
    if (state is SessionActive && state.user.role == UserRole.admin) {
      resolver.next();
    } else if (state is SessionActive) {
      resolver.redirectUntil(const MainRoute());
    } else {
      resolver.redirectUntil(const SessionGateRoute());
    }
  }
}
