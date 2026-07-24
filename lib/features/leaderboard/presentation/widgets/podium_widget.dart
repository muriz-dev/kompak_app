import 'package:flutter/material.dart';
import '../../domain/entities/leaderboard_data.dart';

class PodiumWidget extends StatelessWidget {
  final List<LeaderboardWinner> winners;

  const PodiumWidget({super.key, required this.winners});

  @override
  Widget build(BuildContext context) {
    // Sort just to be safe, though BLoC should provide it in rank order
    final sortedWinners = List<LeaderboardWinner>.from(winners)..sort((a, b) => a.rank.compareTo(b.rank));
    
    final firstPlace = sortedWinners.firstWhere((w) => w.rank == 1, orElse: () => winners[0]);
    final secondPlace = sortedWinners.firstWhere((w) => w.rank == 2, orElse: () => winners[1]);
    final thirdPlace = sortedWinners.firstWhere((w) => w.rank == 3, orElse: () => winners[2]);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        height: 300, // Total height for avatars + podium
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // 2nd Place
            Expanded(
              child: _buildPodiumColumn(
                winner: secondPlace,
                height: 140,
                color: const Color(0xFF10B981), // Green
                rankText: '2nd',
              ),
            ),
            const SizedBox(width: 8),
            // 1st Place
            Expanded(
              flex: 1, // Same flex, but can be adjusted if needed
              child: _buildPodiumColumn(
                winner: firstPlace,
                height: 180,
                color: const Color(0xFF2563EB), // Blue
                rankText: '1st',
                isFirst: true,
              ),
            ),
            const SizedBox(width: 8),
            // 3rd Place
            Expanded(
              child: _buildPodiumColumn(
                winner: thirdPlace,
                height: 120,
                color: const Color(0xFFF59E0B), // Orange
                rankText: '3rd',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPodiumColumn({
    required LeaderboardWinner winner,
    required double height,
    required Color color,
    required String rankText,
    bool isFirst = false,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        CircleAvatar(
          radius: isFirst ? 36 : 30,
          backgroundImage: NetworkImage(winner.avatarUrl),
          backgroundColor: Colors.grey.shade200,
        ),
        const SizedBox(height: 8),
        Text(
          winner.name,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          height: height,
          decoration: BoxDecoration(
            color: color,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16), bottom: Radius.circular(4)),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
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
                    Text(
                      '${winner.points} Point',
                      style: TextStyle(
                        color: color,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
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
}
