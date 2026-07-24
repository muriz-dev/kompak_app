import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../bloc/leaderboard_cubit.dart';
import '../bloc/leaderboard_state.dart';
import '../widgets/podium_widget.dart';
import '../widgets/reward_card.dart';
import '../widgets/leaderboard_list_item.dart';
import '../widgets/current_user_banner.dart';
import '../widgets/leaderboard_stats_card.dart';

@RoutePage()
class LeaderboardPage extends StatelessWidget {
  const LeaderboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<LeaderboardCubit>()..loadLeaderboardData(),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
            onPressed: () {}, // Can hook to auto_route pop if needed
          ),
          title: const Text(
            'Peringkat Warga',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          child: BlocBuilder<LeaderboardCubit, LeaderboardState>(
            builder: (context, state) {
              if (state is LeaderboardLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is LeaderboardError) {
                return Center(child: Text(state.message));
              } else if (state is LeaderboardLoaded) {
                return Stack(
                  children: [
                    // Main Scrollable Content
                    Positioned.fill(
                      child: CustomScrollView(
                        slivers: [
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 20, bottom: 24),
                              child: PodiumWidget(winners: state.winners),
                            ),
                          ),
                          SliverPadding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            sliver: SliverToBoxAdapter(
                              child: RewardCard(rewards: state.rewards),
                            ),
                          ),
                          SliverPadding(
                            padding: const EdgeInsets.all(16),
                            sliver: SliverToBoxAdapter(
                              child: Row(
                                children: [
                                  LeaderboardStatsCard(
                                    title: 'TOTAL\nPARTISIPASI',
                                    value: state.stats.totalParticipation.toString(),
                                    subtitle: 'Warga Aktif',
                                    backgroundColor: const Color(0xFF2563EB), // Blue
                                  ),
                                  const SizedBox(width: 12),
                                  LeaderboardStatsCard(
                                    title: 'POIN\nTERKUMPUL',
                                    value: state.stats.pointsCollected,
                                    subtitle: '',
                                    backgroundColor: const Color(0xFF10B981), // Green
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SliverPadding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            sliver: SliverToBoxAdapter(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Peringkat Lainnya',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () {},
                                    icon: const Icon(Icons.filter_list),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SliverPadding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            sliver: SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (context, index) {
                                  return LeaderboardListItem(
                                    entry: state.otherEntries[index],
                                  );
                                },
                                childCount: state.otherEntries.length,
                              ),
                            ),
                          ),
                          // Extra padding at the bottom so the last item is not hidden by the banner
                          const SliverToBoxAdapter(
                            child: SizedBox(height: 140),
                          ),
                        ],
                      ),
                    ),
                    // Sticky Bottom Banner
                    Positioned(
                      left: 16,
                      right: 16,
                      bottom: 16,
                      child: CurrentUserBanner(currentUser: state.currentUserRank),
                    ),
                  ],
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
