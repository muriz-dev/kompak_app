import 'package:auto_route/auto_route.dart';
import 'package:flutter/widgets.dart';

import '../../../../core/routes/app_router.dart';
import 'session_state.dart';

List<PageRouteInfo>? routesForSession(SessionState state) => switch (state) {
  SessionActive() => <PageRouteInfo>[const MainRoute()],
  SessionPending() => <PageRouteInfo>[const PendingApprovalRoute()],
  SessionRejected() => <PageRouteInfo>[const RejectedAccountRoute()],
  SessionBlocked() => <PageRouteInfo>[const BlockedAccountRoute()],
  SessionUnauthenticated() => <PageRouteInfo>[const LoginRoute()],
  _ => null,
};

void replaceForSession(BuildContext context, SessionState state) {
  final routes = routesForSession(state);
  if (routes != null) context.router.replaceAll(routes);
}
