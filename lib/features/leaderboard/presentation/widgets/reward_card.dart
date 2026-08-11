import 'package:flutter/material.dart';
import '../../domain/entities/leaderboard_data.dart';

class RewardCard extends StatelessWidget {
  final List<LeaderboardReward> rewards;

  const RewardCard({super.key, required this.rewards});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.emoji_events, color: Colors.orange, size: 20),
              SizedBox(width: 8),
              Text(
                'Hadiah Pemenang',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...rewards.map((reward) {
            Color avatarColor;
            if (reward.rank == 1) {
              avatarColor = const Color(0xFF2563EB); // Blue
            } else if (reward.rank == 2) {
              avatarColor = const Color(0xFF10B981); // Green
            } else {
              avatarColor = const Color(0xFFF59E0B); // Orange
            }

            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF), // Light Blue
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: avatarColor,
                    child: Text(
                      '${reward.rank}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          reward.title,
                          style: const TextStyle(
                            color: Color(0xFF2563EB), // Blue 600
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        if (reward.description.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            reward.description,
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
