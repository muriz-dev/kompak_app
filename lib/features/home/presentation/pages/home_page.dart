import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/routes/app_router.dart';
import '../bloc/home_cubit.dart';
import '../bloc/home_state.dart';
import '../widgets/points_card.dart';
import '../widgets/activity_card.dart';
import '../widgets/announcement_card.dart';

@RoutePage()
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<HomeCubit>()..loadHomeData(),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: SvgPicture.asset(
            'assets/images/brand_logo_blue.svg', 
            height: 32,
          ),
          actions: [
            GestureDetector(
              onTap: () {
                context.router.push(const NotificationRoute());
              },
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Color(0xFF2563EB),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.notifications_none,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: () {
                context.router.push(const ProfileRoute());
              },
              child: const CircleAvatar(
                radius: 18,
                backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=11'),
              ),
            ),
            const SizedBox(width: 20),
          ],
        ),
        body: SafeArea(
          child: BlocBuilder<HomeCubit, HomeState>(
            builder: (context, state) {
              if (state is HomeLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is HomeError) {
                return Center(child: Text(state.message));
              } else if (state is HomeLoaded) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Text(
                        'Selamat Siang, ${state.userSummary.name}!',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Senang melihat Anda aktif hari ini di lingkungan RT 04.',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 18),

                      // Temporary entry point while role-aware navigation is
                      // being added to the authentication session.
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: FilledButton.icon(
                          onPressed: () =>
                              context.router.push(const AdminResidentsRoute()),
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFF2F67E8),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          icon: const Icon(Icons.admin_panel_settings_outlined),
                          label: const Text(
                            'Buka pratinjau admin',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Points Card
                      PointsCard(
                        userSummary: state.userSummary,
                        onRedeemTap: () {
                          // TODO: Navigate to store or change tab
                          AutoTabsRouter.of(
                            context,
                          ).setActiveIndex(2); // Index of Store
                        },
                      ),
                      const SizedBox(height: 32),

                      // Kegiatan Mendatang
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Kegiatan Mendatang',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextButton(
                            onPressed: () {},
                            child: const Text('Lihat Semua'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 210,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: state.upcomingActivities.length,
                          itemBuilder: (context, index) {
                            return ActivityCard(
                              activity: state.upcomingActivities[index],
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Pengumuman Terbaru
                      const Text(
                        'Pengumuman Terbaru',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: state.announcements.length,
                        itemBuilder: (context, index) {
                          return AnnouncementCard(
                            announcement: state.announcements[index],
                          );
                        },
                      ),
                    ],
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }
}
