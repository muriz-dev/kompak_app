import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/leaderboard_data.dart';

class PodiumWidget extends StatelessWidget {
  const PodiumWidget({super.key, required this.winners});

  final List<LeaderboardEntry> winners;

  @override
  Widget build(BuildContext context) {
    final ordered = <LeaderboardEntry>[
      ...winners.where((winner) => winner.rank == 2),
      ...winners.where((winner) => winner.rank == 1),
      ...winners.where((winner) => winner.rank == 3),
    ];

    if (ordered.length == 1) {
      return Center(
        child: SizedBox(width: 132, height: 300, child: _podium(ordered.first)),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        height: 300,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            for (var index = 0; index < ordered.length; index++) ...[
              if (index > 0) const SizedBox(width: 8),
              Expanded(child: _podium(ordered[index])),
            ],
          ],
        ),
      ),
    );
  }

  Widget _podium(LeaderboardEntry winner) {
    final color = switch (winner.rank) {
      1 => const Color(0xFF2563EB),
      2 => const Color(0xFF10B981),
      _ => const Color(0xFFF59E0B),
    };
    final height = switch (winner.rank) {
      1 => 180.0,
      2 => 140.0,
      _ => 120.0,
    };
    final rankText = switch (winner.rank) {
      1 => '1st',
      2 => '2nd',
      _ => '3rd',
    };

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        CircleAvatar(
          radius: winner.rank == 1 ? 36 : 30,
          backgroundColor: color.withValues(alpha: 0.12),
          child: Text(
            _initials(winner.name),
            style: TextStyle(color: color, fontWeight: FontWeight.w700),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          winner.name,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          height: height,
          decoration: BoxDecoration(
            color: color,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(16),
              bottom: Radius.circular(4),
            ),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                rankText,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.stars, color: color, size: 12),
                    const SizedBox(width: 2),
                    Flexible(
                      child: Text(
                        NumberFormat.decimalPattern(
                          'id_ID',
                        ).format(winner.points),
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: color,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _initials(String name) {
    final words = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty);
    return words.take(2).map((word) => word[0].toUpperCase()).join();
  }
}
