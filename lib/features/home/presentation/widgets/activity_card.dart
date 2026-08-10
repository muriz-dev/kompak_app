import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/home_data.dart';

class ActivityCard extends StatelessWidget {
  const ActivityCard({
    super.key,
    required this.activity,
    required this.onTap,
    required this.onReminderTap,
  });

  final UpcomingActivity activity;
  final VoidCallback onTap;
  final VoidCallback onReminderTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: Color(0xFFE6E8EB)),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        key: ValueKey('home-activity-${activity.id}'),
        onTap: onTap,
        child: SizedBox(
          width: 240,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFBFD1F8),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.campaign_outlined,
                    color: Color(0xFF2F67E8),
                    size: 25,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  activity.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF0F1C2E),
                    fontSize: 16,
                    height: 1.2,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_outlined,
                      size: 17,
                      color: Color(0xFF45524A),
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        DateFormat('dd MMM, HH:mm').format(activity.date),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF45524A),
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  height: 36,
                  child: OutlinedButton(
                    key: ValueKey('home-reminder-${activity.id}'),
                    onPressed: onReminderTap,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF2F67E8),
                      side: const BorderSide(color: Color(0xFF2F67E8)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Ingatkan',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
