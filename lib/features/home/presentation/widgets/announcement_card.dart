import 'package:flutter/material.dart';

import '../../domain/entities/home_data.dart';

class AnnouncementCard extends StatelessWidget {
  const AnnouncementCard({
    super.key,
    required this.announcement,
    required this.onTap,
  });

  final Announcement announcement;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Baca pengumuman ${announcement.title}',
      child: Material(
        color: const Color(0xFFE7EDFC),
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          key: ValueKey('home-announcement-${announcement.id}'),
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.person_outline_rounded,
                      size: 18,
                      color: Color(0xFF2F67E8),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        announcement.author,
                        style: const TextStyle(
                          color: Color(0xFF2F67E8),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  announcement.title,
                  style: const TextStyle(
                    color: Color(0xFF292D33),
                    fontSize: 21,
                    height: 1.2,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  announcement.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF68707A),
                    fontSize: 15,
                    height: 1.35,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 12),
                const Row(
                  children: [
                    Flexible(
                      child: Text(
                        'Baca Selengkapnya',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Color(0xFF2F67E8),
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    SizedBox(width: 5),
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 22,
                      color: Color(0xFF2F67E8),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
