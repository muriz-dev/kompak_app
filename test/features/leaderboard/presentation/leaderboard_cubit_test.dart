import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kompak_app/features/leaderboard/domain/entities/leaderboard_data.dart';
import 'package:kompak_app/features/leaderboard/domain/repositories/leaderboard_repository.dart';
import 'package:kompak_app/features/leaderboard/presentation/bloc/leaderboard_cubit.dart';
import 'package:kompak_app/features/leaderboard/presentation/bloc/leaderboard_state.dart';
import 'package:kompak_app/features/leaderboard/presentation/widgets/leaderboard_list_item.dart';
import 'package:kompak_app/features/leaderboard/presentation/widgets/podium_widget.dart';

void main() {
  const entries = [
    LeaderboardEntry(id: '1', name: 'Budi Santoso', points: 500, rank: 1),
    LeaderboardEntry(id: '2', name: 'Siti Aminah', points: 300, rank: 2),
    LeaderboardEntry(id: '3', name: 'Andi Wijaya', points: 100, rank: 3),
    LeaderboardEntry(id: '4', name: 'Rina Putri', points: 50, rank: 4),
  ];
  final data = LeaderboardData(
    entries: entries,
    currentUser: entries[3],
    stats: LeaderboardStats(
      totalCitizens: 4,
      participatingCitizens: 4,
      totalPoints: 950,
    ),
    rewards: [
      LeaderboardReward(
        id: 'reward-1',
        rank: 1,
        title: 'Voucher Belanja',
        description: 'Hadiah peringkat pertama',
      ),
    ],
  );

  test(
    'maps the backend screen model into podium and remaining ranks',
    () async {
      final cubit = LeaderboardCubit(_FakeLeaderboardRepository(data));

      await cubit.loadLeaderboardData();

      final loaded = cubit.state as LeaderboardLoaded;
      expect(loaded.winners, entries.take(3));
      expect(loaded.otherEntries, [entries[3]]);
      expect(loaded.currentUserRank, entries[3]);
      expect(loaded.stats.totalPoints, 950);
      expect(loaded.rewards.single.title, 'Voucher Belanja');
    },
  );

  test('parses the enriched leaderboard response', () {
    final parsed = LeaderboardData.fromJson({
      'entries': [
        {'id': '1', 'name': 'Budi Santoso', 'points': 500, 'rank': 1},
      ],
      'currentUser': {'id': '4', 'name': 'Rina Putri', 'points': 50, 'rank': 4},
      'stats': {
        'totalCitizens': 4,
        'participatingCitizens': 4,
        'totalPoints': 950,
      },
      'rewards': [
        {
          'id': 'reward-1',
          'rank': 1,
          'title': 'Voucher Belanja',
          'description': 'Hadiah peringkat pertama',
          'imageUrl': null,
        },
      ],
    });

    expect(parsed.entries.single, entries.first);
    expect(parsed.currentUser, entries[3]);
    expect(parsed.stats.totalPoints, 950);
    expect(parsed.rewards.single.rank, 1);
  });

  testWidgets('renders real names with initials and supports one winner', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              Expanded(child: PodiumWidget(winners: [entries[0]])),
              LeaderboardListItem(entry: entries[3]),
            ],
          ),
        ),
      ),
    );

    expect(find.text('BS'), findsOneWidget);
    expect(find.text('RP'), findsOneWidget);
    expect(find.text('Budi Santoso'), findsOneWidget);
    expect(find.text('Rina Putri'), findsOneWidget);
    expect(find.textContaining('RT 04'), findsNothing);
  });
}

class _FakeLeaderboardRepository implements LeaderboardRepository {
  const _FakeLeaderboardRepository(this.data);

  final LeaderboardData data;

  @override
  Future<LeaderboardData> getLeaderboard({int limit = 50}) async => data;
}
