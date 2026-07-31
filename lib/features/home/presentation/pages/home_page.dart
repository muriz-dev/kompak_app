import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/routes/app_router.dart';
import '../../domain/entities/home_data.dart';
import '../bloc/home_cubit.dart';
import '../bloc/home_state.dart';
import '../widgets/activity_card.dart';
import '../widgets/announcement_card.dart';
import '../widgets/points_card.dart';

const _homeInk = Color(0xFF292D33);
const _homeMuted = Color(0xFF62676E);
const _homeBlue = Color(0xFF2F67E8);

@RoutePage()
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<HomeCubit>()..loadHomeData(),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: BlocBuilder<HomeCubit, HomeState>(
          builder: (context, state) {
            return switch (state) {
              HomeLoaded() => HomeDashboardView(
                userSummary: state.userSummary,
                activities: state.upcomingActivities,
                announcements: state.announcements,
                onNotificationTap: () =>
                    context.router.push(const NotificationRoute()),
                onProfileTap: () => context.router.push(const ProfileRoute()),
                onRedeemTap: () => AutoTabsRouter.of(context).setActiveIndex(2),
                onViewAllActivities: () =>
                    AutoTabsRouter.of(context).setActiveIndex(1),
                onActivityReminder: (activity) =>
                    _showReminderConfirmation(context, activity),
                onAnnouncementTap: () =>
                    context.router.push(const ActivityDetailRoute()),
              ),
              HomeError() => _HomeErrorView(message: state.message),
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
            const SizedBox(height: 24),
            PointsCard(userSummary: userSummary, onRedeemTap: onRedeemTap),
            const SizedBox(height: 28),
            _SectionHeader(
              title: 'Kegiatan Mendatang',
              actionLabel: 'Lihat Semua',
              onActionTap: onViewAllActivities,
            ),
            const SizedBox(height: 14),
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

class _DashboardHeader extends StatelessWidget {
  const _DashboardHeader({
    required this.onNotificationTap,
    required this.onProfileTap,
  });

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
                child: Container(
                  width: 48,
                  height: 48,
                  padding: const EdgeInsets.all(3),
                  decoration: const BoxDecoration(
                    color: Color(0xFF0DBA75),
                    shape: BoxShape.circle,
                  ),
                  child: ClipOval(
                    child: ColoredBox(
                      color: const Color(0xFFE7EBEF),
                      child: Image.network(
                        'https://i.pravatar.cc/300?img=11',
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => const Icon(
                          Icons.person_rounded,
                          color: Color(0xFF68707A),
                          size: 28,
                        ),
                      ),
                    ),
                  ),
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
  const _HomeErrorView({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: _homeMuted, fontSize: 15),
          ),
        ),
      ),
    );
  }
}
