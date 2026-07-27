import 'package:auto_route/auto_route.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../features/auth/presentation/pages/reset_password_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/home/presentation/pages/notification_page.dart';
import '../../features/attendance/presentation/pages/activity_detail_page.dart';
import 'main_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/attendance/presentation/pages/attendance_page.dart';
import '../../features/store/presentation/pages/store_page.dart';
import '../../features/store/presentation/pages/point_history_page.dart';
import '../../features/store/presentation/pages/redeem_confirmation_page.dart';
import '../../features/store/domain/entities/store_data.dart';
import '../../features/leaderboard/presentation/pages/leaderboard_page.dart';

part 'app_router.gr.dart';

@AutoRouterConfig()
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
        AutoRoute(page: LoginRoute.page, initial: true),
        AutoRoute(page: RegisterRoute.page),
        AutoRoute(page: ForgotPasswordRoute.page),
        AutoRoute(page: ResetPasswordRoute.page),
        AutoRoute(page: ProfileRoute.page),
        AutoRoute(page: NotificationRoute.page),
        AutoRoute(page: ActivityDetailRoute.page),
        AutoRoute(
          page: MainRoute.page,
          children: [
            AutoRoute(page: HomeRoute.page, initial: true),
            AutoRoute(page: AttendanceRoute.page),
            AutoRoute(page: StoreRoute.page),
            AutoRoute(page: LeaderboardRoute.page),
          ],
        ),
        AutoRoute(page: PointHistoryRoute.page),
        AutoRoute(page: RedeemConfirmationRoute.page),
      ];
}
