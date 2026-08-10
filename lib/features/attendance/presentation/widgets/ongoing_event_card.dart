import 'package:flutter/material.dart';
import '../../domain/entities/attendance_data.dart';

class OngoingEventCard extends StatelessWidget {
  final OngoingEvent event;
  final VoidCallback onDetailTap;
  final VoidCallback onCheckInTap;

  const OngoingEventCard({
    super.key,
    required this.event,
    required this.onDetailTap,
    required this.onCheckInTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Image Header
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: _EventImage(url: event.imageUrl),
              ),
              // Dark gradient overlay for text readability
              Container(
                height: 160,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.7),
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: 16,
                left: 16,
                right: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            event.tag,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.access_time,
                          color: Colors.white,
                          size: 12,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          event.timeRemaining,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      event.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          // Content Footer
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const Icon(Icons.stars, color: Colors.orange, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '+${event.points} Pts',
                      style: const TextStyle(
                        color: Colors.orange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: onCheckInTap,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    icon: const Icon(
                      Icons.face_retouching_natural,
                      color: Colors.white,
                    ),
                    label: const Text(
                      'Absensi Sekarang',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EventImage extends StatelessWidget {
  const _EventImage({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    if (url.isNotEmpty) {
      return Image.network(
        url,
        height: 160,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => const _EventImageFallback(),
      );
    }
    return const _EventImageFallback();
  }
}

class _EventImageFallback extends StatelessWidget {
  const _EventImageFallback();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 160,
      width: double.infinity,
      child: ColoredBox(
        color: Color(0xFFDCE6FC),
        child: Center(
          child: Icon(Icons.event_rounded, color: Color(0xFF2563EB), size: 54),
        ),
      ),
    );
  }
}
