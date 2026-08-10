import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/routes/app_router.dart';
import '../../domain/entities/community_event.dart';
import '../bloc/activity_detail_cubit.dart';
import '../bloc/activity_detail_state.dart';

const _detailBlue = Color(0xFF2563EB);
const _detailGreen = Color(0xFF10B981);
const _detailInk = Color(0xFF25282D);
const _detailMuted = Color(0xFF6B7077);

@RoutePage()
class ActivityDetailPage extends StatelessWidget {
  const ActivityDetailPage({
    @PathParam('eventId') required this.eventId,
    super.key,
  });

  final String eventId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ActivityDetailCubit>()..loadEvent(eventId),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: BlocBuilder<ActivityDetailCubit, ActivityDetailState>(
          builder: (context, state) => switch (state) {
            ActivityDetailLoaded() => _ActivityDetailView(event: state.event),
            ActivityDetailError() => _ActivityDetailErrorView(
              message: state.message,
              onRetry: () =>
                  context.read<ActivityDetailCubit>().loadEvent(eventId),
            ),
            _ => const Center(child: CircularProgressIndicator()),
          },
        ),
      ),
    );
  }
}

class _ActivityDetailView extends StatelessWidget {
  const _ActivityDetailView({required this.event});

  final CommunityEvent event;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final availability = _availability(event, now);

    return Stack(
      fit: StackFit.expand,
      children: [
        Align(
          alignment: Alignment.topCenter,
          child: SizedBox(
            height: 350,
            width: double.infinity,
            child: _EventBanner(url: event.bannerUrl),
          ),
        ),
        Positioned.fill(
          top: 280,
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
            ),
            child: SingleChildScrollView(
              key: const ValueKey('activity-detail-scroll'),
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 132),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFFD8DADF),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      _StatusBadge(
                        label: availability.label.toUpperCase(),
                        color: availability.color,
                      ),
                      const SizedBox(width: 10),
                      const Icon(Icons.stars_rounded, color: Color(0xFFF59E0B)),
                      const SizedBox(width: 4),
                      Text(
                        '+${event.rewardPoints} Pts',
                        style: const TextStyle(
                          color: Color(0xFFF59E0B),
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    event.title,
                    key: const ValueKey('activity-detail-title'),
                    style: const TextStyle(
                      color: _detailInk,
                      fontSize: 24,
                      height: 1.2,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _InfoCard(
                    icon: Icons.calendar_today_outlined,
                    title: 'Waktu & Tanggal',
                    subtitle: _scheduleLabel(event),
                  ),
                  const SizedBox(height: 14),
                  _InfoCard(
                    icon: Icons.location_on_outlined,
                    title: 'Koordinat Lokasi',
                    subtitle: event.coordinateLabel,
                    trailing: Text(
                      'Radius ${event.radiusMeters} m',
                      style: const TextStyle(
                        color: _detailBlue,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    'Tentang Kegiatan',
                    style: TextStyle(
                      color: _detailInk,
                      fontSize: 19,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    event.description,
                    style: const TextStyle(
                      color: _detailMuted,
                      fontSize: 14,
                      height: 1.55,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: SizedBox(
                      key: const ValueKey('activity-detail-map'),
                      height: 170,
                      child: FlutterMap(
                        options: MapOptions(
                          initialCenter: LatLng(
                            event.latitude,
                            event.longitude,
                          ),
                          initialZoom: 16,
                          interactionOptions: const InteractionOptions(
                            flags:
                                InteractiveFlag.drag |
                                InteractiveFlag.pinchZoom,
                          ),
                        ),
                        children: [
                          TileLayer(
                            urlTemplate:
                                'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            userAgentPackageName: 'com.kompak.app',
                          ),
                          MarkerLayer(
                            markers: [
                              Marker(
                                point: LatLng(event.latitude, event.longitude),
                                width: 46,
                                height: 46,
                                child: const Icon(
                                  Icons.location_pin,
                                  color: _detailBlue,
                                  size: 46,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _CircleButton(
                    icon: Icons.arrow_back_ios_new,
                    onTap: () => context.router.back(),
                  ),
                  _CircleButton(
                    icon: Icons.share_outlined,
                    onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Fitur berbagi segera tersedia.'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Color(0x14000000),
                  offset: Offset(0, -4),
                  blurRadius: 12,
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Status',
                        style: TextStyle(color: _detailMuted, fontSize: 12),
                      ),
                      Text(
                        availability.label,
                        style: TextStyle(
                          color: availability.color,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: FilledButton.icon(
                      key: const ValueKey('activity-check-in-button'),
                      onPressed: availability.canCheckIn
                          ? () => context.router.push(
                              AttendanceScannerRoute(eventId: event.id),
                            )
                          : null,
                      style: FilledButton.styleFrom(
                        backgroundColor: _detailBlue,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: const Color(0xFFDCE6FC),
                        disabledForegroundColor: const Color(0xFF5E78AE),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.face_retouching_natural),
                      label: Text(
                        availability.canCheckIn
                            ? 'Mulai Absensi'
                            : availability.checkInLabel,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _scheduleLabel(CommunityEvent event) {
    final start = event.attendanceStartTime.toLocal();
    final end = event.attendanceEndTime.toLocal();
    return '${DateFormat('dd MMM yyyy').format(start)}, '
        '${DateFormat('HH:mm').format(start)}–${DateFormat('HH:mm').format(end)}';
  }

  _EventAvailability _availability(CommunityEvent event, DateTime now) {
    if (event.isUpcomingAt(now)) {
      return const _EventAvailability(
        'Mendatang',
        _detailBlue,
        canCheckIn: false,
        checkInLabel: 'Absensi belum dibuka',
      );
    }
    if (event.isOngoingAt(now)) {
      return const _EventAvailability(
        'Sedang berlangsung',
        _detailGreen,
        canCheckIn: true,
        checkInLabel: 'Mulai Absensi',
      );
    }
    return const _EventAvailability(
      'Selesai',
      _detailMuted,
      canCheckIn: false,
      checkInLabel: 'Absensi ditutup',
    );
  }
}

class _EventBanner extends StatelessWidget {
  const _EventBanner({required this.url});

  final String? url;

  @override
  Widget build(BuildContext context) {
    if (url != null && url!.isNotEmpty) {
      return Image.network(
        url!,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => const _BannerFallback(),
      );
    }
    return const _BannerFallback();
  }
}

class _BannerFallback extends StatelessWidget {
  const _BannerFallback();

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: Color(0xFFDCE6FC),
      child: Center(
        child: Icon(Icons.event_rounded, color: _detailBlue, size: 76),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(11),
            decoration: BoxDecoration(
              color: _detailBlue,
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(color: _detailMuted, fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: _detailInk,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null) ...[const SizedBox(width: 8), trailing!],
        ],
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  const _CircleButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0x66000000),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 44,
          height: 44,
          child: Icon(icon, color: Colors.white, size: 20),
        ),
      ),
    );
  }
}

class _ActivityDetailErrorView extends StatelessWidget {
  const _ActivityDetailErrorView({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.event_busy_outlined,
                size: 54,
                color: _detailMuted,
              ),
              const SizedBox(height: 14),
              Text(message, textAlign: TextAlign.center),
              const SizedBox(height: 18),
              FilledButton(onPressed: onRetry, child: const Text('Coba Lagi')),
            ],
          ),
        ),
      ),
    );
  }
}

class _EventAvailability {
  const _EventAvailability(
    this.label,
    this.color, {
    required this.canCheckIn,
    required this.checkInLabel,
  });

  final String label;
  final Color color;
  final bool canCheckIn;
  final String checkInLabel;
}
