import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import '../../features/admin/residents/presentation/pages/admin_residents_page.dart';
import '../../features/admin/providers/presentation/pages/admin_provider_detail_page.dart';
import '../../features/admin/providers/presentation/pages/admin_providers_page.dart';
import '../../features/admin/providers/presentation/pages/admin_point_shop_page.dart';
import '../../features/admin/rewards/domain/entities/admin_leaderboard_reward.dart';
import '../../features/admin/rewards/presentation/pages/admin_leaderboard_reward_form_page.dart';
import '../../features/admin/rewards/presentation/pages/admin_leaderboard_reward_picker_page.dart';
import '../../features/admin/rewards/presentation/pages/admin_leaderboard_rewards_page.dart';
import '../../features/announcements/domain/entities/community_announcement.dart';
import '../../features/admin/announcements/presentation/pages/admin_announcements_page.dart';
import '../../features/admin/announcements/presentation/pages/announcement_form_page.dart';
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
import '../../features/providers/domain/entities/provider_account.dart';
import '../../features/providers/presentation/pages/provider_entry_page.dart';
import '../../features/providers/presentation/pages/provider_product_form_page.dart';
import '../../features/providers/presentation/pages/provider_profile_page.dart';
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
      page: AdminProvidersRoute.page,
      path: '/admin/providers',
      guards: [_adminSessionGuard],
    ),
    AutoRoute(
      page: AdminProviderDetailRoute.page,
      path: '/admin/providers/:providerId',
      guards: [_adminSessionGuard],
    ),
    AutoRoute(
      page: AdminPointShopRoute.page,
      path: '/admin/point-shop',
      guards: [_adminSessionGuard],
    ),
    AutoRoute(
      page: AdminPointShopAddRoute.page,
      path: '/admin/point-shop/add',
      guards: [_adminSessionGuard],
    ),
    AutoRoute(
      page: AdminLeaderboardRewardsRoute.page,
      path: '/admin/leaderboard-rewards',
      guards: [_adminSessionGuard],
    ),
    AutoRoute(
      page: AdminLeaderboardRewardFormRoute.page,
      path: '/admin/leaderboard-rewards/edit',
      guards: [_adminSessionGuard],
    ),
    AutoRoute(
      page: AdminLeaderboardRewardPickerRoute.page,
      path: '/admin/leaderboard-rewards/pick',
      guards: [_adminSessionGuard],
    ),
    AutoRoute(
      page: AdminEventsRoute.page,
      path: '/admin/events',
      guards: [_adminSessionGuard],
    ),
    AutoRoute(
      page: AdminAnnouncementsRoute.page,
      path: '/admin/announcements',
      guards: [_adminSessionGuard],
    ),
    AutoRoute(
      page: AnnouncementFormRoute.page,
      path: '/admin/announcements/form',
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
      page: ProviderEntryRoute.page,
      path: '/provider',
      guards: [_activeSessionGuard],
    ),
    AutoRoute(
      page: ProviderProductFormRoute.page,
      path: '/provider/products/form',
      guards: [_activeSessionGuard],
    ),
    AutoRoute(
      page: ProviderProfileRoute.page,
      path: '/provider/profile',
      guards: [_activeSessionGuard],
    ),
    AutoRoute(
      page: RedeemConfirmationRoute.page,
      guards: [_activeSessionGuard],
    ),
  ];
}
