import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/routes/app_router.dart';
import '../../../../core/widgets/user_avatar.dart';
import '../../domain/entities/home_data.dart';
import '../bloc/home_cubit.dart';
import '../bloc/home_state.dart';
import '../widgets/activity_card.dart';
import '../widgets/announcement_card.dart';
import '../widgets/points_card.dart';
import '../widgets/profile_mode_sheet.dart';
import '../../../auth/domain/entities/session_user.dart';
import '../../../auth/presentation/session/session_cubit.dart';
import '../../../auth/presentation/session/session_state.dart';

const _homeInk = Color(0xFF292D33);
const _homeMuted = Color(0xFF62676E);
const _homeBlue = Color(0xFF2F67E8);

@RoutePage()
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final sessionState = context.watch<SessionCubit>().state;
    final activeUser = sessionState is SessionActive ? sessionState.user : null;
    if (activeUser == null) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final userSummary = UserSummary(
      name: activeUser.name,
      points: activeUser.leaderboardPoints,
    );

    return BlocProvider(
      create: (_) => getIt<HomeCubit>()..loadHomeData(),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: BlocBuilder<HomeCubit, HomeState>(
          builder: (context, state) {
            return switch (state) {
              HomeLoaded() => HomeDashboardView(
                userSummary: userSummary,
                activities: state.upcomingActivities,
                announcements: state.announcements,
                onNotificationTap: () =>
                    context.router.push(const NotificationRoute()),
                onProfileTap: () => _showProfileModeSheet(context),
                onRedeemTap: () => AutoTabsRouter.of(context).setActiveIndex(2),
                onViewAllActivities: () =>
                    AutoTabsRouter.of(context).setActiveIndex(1),
                onActivityReminder: (activity) =>
                    _showReminderConfirmation(context, activity),
                onActivityTap: (activity) => context.router.push(
                  ActivityDetailRoute(eventId: activity.id),
                ),
                onAnnouncementTap: () => _showAnnouncementNotice(context),
              ),
              HomeError() => _HomeErrorView(
                message: state.message,
                onRetry: () => context.read<HomeCubit>().loadHomeData(),
              ),
              _ => const _HomeLoadingView(),
            };
          },
        ),
      ),
    );
  }

  void _showReminderConfirmation(
    BuildContext context,
    UpcomingActivity activity,
  ) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text('Pengingat ${activity.title} diaktifkan.')),
      );
  }

  void _showAnnouncementNotice(BuildContext context) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(content: Text('Detail pengumuman segera tersedia.')),
      );
  }

  Future<void> _showProfileModeSheet(BuildContext context) {
    final sessionState = context.read<SessionCubit>().state;
    final activeUser = sessionState is SessionActive ? sessionState.user : null;
    final router = context.router.root;

    return showProfileModeMenu(
      context: context,
      builder: (dialogContext) => ProfileModeSheet(
        name: activeUser?.name ?? 'Profil Anda',
        email: activeUser?.email ?? '',
        canAccessAdmin: activeUser?.role == UserRole.admin,
        onOpenProfile: () {
          Navigator.of(dialogContext).pop();
          router.push(const ProfileRoute());
        },
        onSwitchAdmin: () {
          Navigator.of(dialogContext).pop();
          router.replaceAll([const AdminResidentsRoute()]);
        },
        onSwitchProvider: () {
          Navigator.of(dialogContext).pop();
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              const SnackBar(content: Text('Mode akun UMKM segera tersedia.')),
            );
        },
        onLogout: () {
          Navigator.of(dialogContext).pop();
          context.read<SessionCubit>().logout();
        },
      ),
    );
  }
}

class HomeDashboardView extends StatelessWidget {
  const HomeDashboardView({
    super.key,
    required this.userSummary,
    required this.activities,
    required this.announcements,
    required this.onNotificationTap,
    required this.onProfileTap,
    required this.onRedeemTap,
    required this.onViewAllActivities,
    required this.onActivityReminder,
    required this.onActivityTap,
    required this.onAnnouncementTap,
  });

  final UserSummary userSummary;
  final List<UpcomingActivity> activities;
  final List<Announcement> announcements;
  final VoidCallback onNotificationTap;
  final VoidCallback onProfileTap;
  final VoidCallback onRedeemTap;
  final VoidCallback onViewAllActivities;
  final ValueChanged<UpcomingActivity> onActivityReminder;
  final ValueChanged<UpcomingActivity> onActivityTap;
  final VoidCallback onAnnouncementTap;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        key: const ValueKey('home-dashboard-scroll-view'),
        padding: const EdgeInsets.fromLTRB(24, 18, 24, 34),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _DashboardHeader(
              userName: userSummary.name,
              onNotificationTap: onNotificationTap,
              onProfileTap: onProfileTap,
            ),
            const SizedBox(height: 42),
            Text(
              'Selamat Siang, ${userSummary.name}!',
              style: const TextStyle(
                color: _homeInk,
                fontSize: 27,
                height: 1.15,
                letterSpacing: -0.35,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Senang melihat Anda aktif hari ini di lingkungan RT 04.',
              style: TextStyle(
                color: _homeMuted,
                fontSize: 15,
                height: 1.35,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 16),
            PointsCard(userSummary: userSummary, onRedeemTap: onRedeemTap),
            const SizedBox(height: 28),
            _SectionHeader(
              title: 'Kegiatan Mendatang',
              actionLabel: 'Lihat Semua',
              onActionTap: onViewAllActivities,
            ),
            const SizedBox(height: 14),
            if (activities.isEmpty)
              const _EmptyActivities()
            else
              SizedBox(
                height: 170,
                child: ListView.separated(
                  key: const ValueKey('home-activity-list'),
                  scrollDirection: Axis.horizontal,
                  clipBehavior: Clip.none,
                  itemCount: activities.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final activity = activities[index];
                    return ActivityCard(
                      activity: activity,
                      onTap: () => onActivityTap(activity),
                      onReminderTap: () => onActivityReminder(activity),
                    );
                  },
                ),
              ),
            const SizedBox(height: 28),
            const Text(
              'Pengumuman Terbaru',
              style: TextStyle(
                color: _homeInk,
                fontSize: 21,
                height: 1.2,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            ...announcements.map(
              (announcement) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: AnnouncementCard(
                  announcement: announcement,
                  onTap: onAnnouncementTap,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyActivities extends StatelessWidget {
  const _EmptyActivities();

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey('home-empty-activities'),
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7FB),
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Row(
        children: [
          Icon(Icons.event_available_outlined, color: _homeBlue),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Belum ada kegiatan mendatang.',
              style: TextStyle(color: _homeMuted, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardHeader extends StatelessWidget {
  const _DashboardHeader({
    required this.userName,
    required this.onNotificationTap,
    required this.onProfileTap,
  });

  final String userName;
  final VoidCallback onNotificationTap;
  final VoidCallback onProfileTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: Row(
        children: [
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: SvgPicture.asset(
                'assets/images/brand_logo_blue.svg',
                width: 170,
                height: 48,
              ),
            ),
          ),
          Semantics(
            button: true,
            label: 'Buka notifikasi',
            child: Material(
              color: _homeBlue,
              shape: const CircleBorder(),
              child: InkWell(
                key: const ValueKey('home-notification-button'),
                onTap: onNotificationTap,
                customBorder: const CircleBorder(),
                child: const SizedBox(
                  width: 48,
                  height: 48,
                  child: Icon(
                    Icons.notifications_none_rounded,
                    color: Colors.white,
                    size: 29,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Semantics(
            button: true,
            label: 'Buka profil',
            child: Material(
              color: Colors.transparent,
              shape: const CircleBorder(),
              child: InkWell(
                key: const ValueKey('home-profile-button'),
                onTap: onProfileTap,
                customBorder: const CircleBorder(),
                child: UserAvatar(
                  name: userName,
                  size: 48,
                  borderColor: const Color(0xFF0DBA75),
                  borderWidth: 3,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.actionLabel,
    required this.onActionTap,
  });

  final String title;
  final String actionLabel;
  final VoidCallback onActionTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: _homeInk,
              fontSize: 21,
              height: 1.2,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        TextButton(
          key: const ValueKey('home-view-all-activities'),
          onPressed: onActionTap,
          style: TextButton.styleFrom(
            foregroundColor: _homeBlue,
            minimumSize: const Size(48, 44),
            padding: const EdgeInsets.only(left: 12),
          ),
          child: Text(
            actionLabel,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}

class _HomeLoadingView extends StatelessWidget {
  const _HomeLoadingView();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 18, 24, 34),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _SkeletonBlock(width: double.infinity, height: 48),
            const SizedBox(height: 42),
            const _SkeletonBlock(width: 290, height: 32),
            const SizedBox(height: 10),
            const _SkeletonBlock(width: double.infinity, height: 20),
            const SizedBox(height: 24),
            const _SkeletonBlock(width: double.infinity, height: 150),
            const SizedBox(height: 28),
            const _SkeletonBlock(width: 220, height: 26),
            const SizedBox(height: 14),
            const _SkeletonBlock(width: double.infinity, height: 170),
          ],
        ),
      ),
    );
  }
}

class _SkeletonBlock extends StatelessWidget {
  const _SkeletonBlock({required this.width, required this.height});

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFFF0F1F3),
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}

class _HomeErrorView extends StatelessWidget {
  const _HomeErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off_outlined, color: _homeMuted, size: 48),
              const SizedBox(height: 14),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: _homeMuted, fontSize: 15),
              ),
              const SizedBox(height: 18),
              FilledButton(onPressed: onRetry, child: const Text('Coba Lagi')),
            ],
          ),
        ),
      ),
    );
  }
}
