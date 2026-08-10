import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import '../../features/admin/residents/presentation/pages/admin_residents_page.dart';
import '../../features/admin/events/presentation/pages/admin_events_page.dart';
import '../../features/admin/events/presentation/pages/admin_event_detail_page.dart';
import '../../features/admin/events/presentation/pages/create_event_page.dart';
import '../../features/admin/events/presentation/pages/edit_event_page.dart';
import '../../features/admin/events/presentation/pages/event_location_picker_page.dart';
import '../../features/admin/events/data/services/event_location_service.dart';
import '../../features/admin/events/domain/entities/admin_event.dart';
import '../../features/admin/events/domain/entities/event_location_selection.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../features/auth/presentation/pages/reset_password_page.dart';
import '../../features/auth/presentation/pages/session_gate_page.dart';
import '../../features/auth/presentation/pages/account_status_pages.dart';
import '../../features/auth/presentation/session/session_cubit.dart';
import '../../features/attendance/presentation/pages/attendance_page.dart';
import '../../features/attendance/presentation/pages/attendance_scanner_page.dart';
import '../../features/attendance/data/services/attendance_location_service.dart';
import '../../features/events/presentation/pages/activity_detail_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/home/presentation/pages/notification_page.dart';
import '../../features/store/presentation/pages/store_page.dart';
import '../../features/store/presentation/pages/point_history_page.dart';
import '../../features/store/presentation/pages/redeem_confirmation_page.dart';
import '../../features/store/domain/entities/store_data.dart';
import '../../features/leaderboard/presentation/pages/leaderboard_page.dart';
import 'main_page.dart';
import 'session_guards.dart';

part 'app_router.gr.dart';

@AutoRouterConfig()
class AppRouter extends RootStackRouter {
  AppRouter(SessionCubit sessionCubit)
    : _activeSessionGuard = ActiveSessionGuard(sessionCubit),
      _adminSessionGuard = AdminSessionGuard(sessionCubit);

  final ActiveSessionGuard _activeSessionGuard;
  final AdminSessionGuard _adminSessionGuard;

  @override
  List<AutoRoute> get routes => [
    AutoRoute(page: SessionGateRoute.page, initial: true),
    AutoRoute(page: LoginRoute.page),
    AutoRoute(page: RegisterRoute.page),
    AutoRoute(page: ForgotPasswordRoute.page),
    AutoRoute(page: ResetPasswordRoute.page),
    AutoRoute(page: PendingApprovalRoute.page),
    AutoRoute(page: RejectedAccountRoute.page),
    AutoRoute(page: BlockedAccountRoute.page),
    AutoRoute(
      page: ProfileRoute.page,
      path: '/profile',
      guards: [_activeSessionGuard],
    ),
    AutoRoute(page: NotificationRoute.page, guards: [_activeSessionGuard]),
    AutoRoute(
      page: ActivityDetailRoute.page,
      path: '/events/:eventId',
      guards: [_activeSessionGuard],
    ),
    AutoRoute(
      page: AttendanceScannerRoute.page,
      path: '/events/:eventId/attendance',
      guards: [_activeSessionGuard],
    ),
    AutoRoute(
      page: AdminResidentsRoute.page,
      path: '/admin/residents',
      guards: [_adminSessionGuard],
    ),
    AutoRoute(
      page: AdminEventsRoute.page,
      path: '/admin/events',
      guards: [_adminSessionGuard],
    ),
    AutoRoute(
      page: CreateEventRoute.page,
      path: '/admin/events/create',
      guards: [_adminSessionGuard],
    ),
    AutoRoute(
      page: AdminEventDetailRoute.page,
      path: '/admin/events/:eventId',
      guards: [_adminSessionGuard],
    ),
    AutoRoute(page: EditEventRoute.page, guards: [_adminSessionGuard]),
    AutoRoute(
      page: EventLocationPickerRoute.page,
      path: '/admin/events/create/location',
      guards: [_adminSessionGuard],
    ),
    AutoRoute(
      page: MainRoute.page,
      guards: [_activeSessionGuard],
      children: [
        AutoRoute(page: HomeRoute.page, initial: true),
        AutoRoute(page: AttendanceRoute.page),
        AutoRoute(page: StoreRoute.page),
        AutoRoute(page: LeaderboardRoute.page),
      ],
    ),
    AutoRoute(page: PointHistoryRoute.page, guards: [_activeSessionGuard]),
    AutoRoute(
      page: RedeemConfirmationRoute.page,
      guards: [_activeSessionGuard],
    ),
  ];
}
