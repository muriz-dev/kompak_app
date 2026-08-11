import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
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
            icon: const Icon(
              Icons.arrow_back_ios,
              color: Colors.black,
              size: 20,
            ),
            onPressed: () {}, // Can hook to auto_route pop if needed
          ),
          title: const Text(
            'Peringkat Warga',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          child: BlocBuilder<LeaderboardCubit, LeaderboardState>(
            builder: (context, state) {
              if (state is LeaderboardLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is LeaderboardError) {
                return _LeaderboardErrorView(
                  message: state.message,
                  onRetry: () =>
                      context.read<LeaderboardCubit>().loadLeaderboardData(),
                );
              } else if (state is LeaderboardLoaded) {
                if (state.winners.isEmpty) {
                  return const _LeaderboardEmptyView();
                }
                return Stack(
                  children: [
                    // Main Scrollable Content
                    Positioned.fill(
                      child: CustomScrollView(
                        slivers: [
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.only(
                                top: 20,
                                bottom: 24,
                              ),
                              child: PodiumWidget(winners: state.winners),
                            ),
                          ),
                          if (state.rewards.isNotEmpty)
                            SliverPadding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
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
                                    value: state.stats.participatingCitizens
                                        .toString(),
                                    subtitle: 'Warga Aktif',
                                    backgroundColor: const Color(
                                      0xFF2563EB,
                                    ), // Blue
                                  ),
                                  const SizedBox(width: 12),
                                  LeaderboardStatsCard(
                                    title: 'POIN\nTERKUMPUL',
                                    value: NumberFormat.compact(
                                      locale: 'id_ID',
                                    ).format(state.stats.totalPoints),
                                    subtitle: '',
                                    backgroundColor: const Color(
                                      0xFF10B981,
                                    ), // Green
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (state.otherEntries.isNotEmpty) ...[
                            SliverPadding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              sliver: SliverToBoxAdapter(
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Peringkat Lainnya',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SliverPadding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              sliver: SliverList(
                                delegate: SliverChildBuilderDelegate(
                                  (context, index) => LeaderboardListItem(
                                    entry: state.otherEntries[index],
                                  ),
                                  childCount: state.otherEntries.length,
                                ),
                              ),
                            ),
                          ],
                          // Extra padding at the bottom so the last item is not hidden by the banner
                          const SliverToBoxAdapter(
                            child: SizedBox(height: 180),
                          ),
                        ],
                      ),
                    ),
                    // Sticky Bottom Banner
                    if (state.currentUserRank case final currentUser?)
                      Positioned(
                        left: 16,
                        right: 16,
                        bottom: 16,
                        child: CurrentUserBanner(
                          currentUser: currentUser,
                          totalCitizens: state.stats.totalCitizens,
                        ),
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

class _LeaderboardEmptyView extends StatelessWidget {
  const _LeaderboardEmptyView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.emoji_events_outlined,
              size: 56,
              color: Color(0xFF2563EB),
            ),
            SizedBox(height: 16),
            Text(
              'Belum ada peringkat warga',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            SizedBox(height: 8),
            Text(
              'Peringkat akan muncul setelah warga memperoleh poin dari kegiatan.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF6B7280), height: 1.4),
            ),
          ],
        ),
      ),
    );
  }
}

class _LeaderboardErrorView extends StatelessWidget {
  const _LeaderboardErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_outlined,
              size: 52,
              color: Color(0xFF6B7280),
            ),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 20),
            FilledButton(onPressed: onRetry, child: const Text('Coba Lagi')),
          ],
        ),
      ),
    );
  }
}
