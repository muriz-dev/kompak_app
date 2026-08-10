import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/routes/app_router.dart';
import '../bloc/attendance_cubit.dart';
import '../bloc/attendance_state.dart';
import '../widgets/attendance_stats_card.dart';
import '../widgets/ongoing_event_card.dart';
import '../widgets/upcoming_event_list_tile.dart';

@RoutePage()
class AttendancePage extends StatelessWidget {
  const AttendancePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<AttendanceCubit>()..loadAttendanceData(),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: BlocBuilder<AttendanceCubit, AttendanceState>(
            builder: (context, state) {
              if (state is AttendanceLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is AttendanceError) {
                return _AttendanceErrorView(
                  message: state.message,
                  onRetry: () =>
                      context.read<AttendanceCubit>().loadAttendanceData(),
                );
              } else if (state is AttendanceLoaded) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      const Text(
                        'Absensi Kegiatan',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Mari berpartisipasi dan bangun kerukunan di RT 04.',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Stats Cards
                      Row(
                        children: [
                          AttendanceStatsCard(
                            title: 'HADIR BULAN INI',
                            value: state.stats.totalEventsAttended.toString(),
                            suffix: 'Kegiatan',
                            backgroundColor: const Color(0xFF2563EB), // Blue
                          ),
                          const SizedBox(width: 16),
                          AttendanceStatsCard(
                            title: 'POTENSI POINT',
                            value: '+${state.stats.potentialPoints}',
                            suffix: 'Points',
                            backgroundColor: const Color(0xFF10B981), // Green
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),

                      // Sedang Berlangsung
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Sedang Berlangsung',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Row(
                            children: const [
                              Icon(Icons.circle, color: Colors.red, size: 8),
                              SizedBox(width: 4),
                              Text(
                                'Langsung',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (state.ongoingEvent != null)
                        OngoingEventCard(
                          event: state.ongoingEvent!,
                          onDetailTap: () => context.router.push(
                            ActivityDetailRoute(
                              eventId: state.ongoingEvent!.id,
                            ),
                          ),
                        )
                      else
                        const _EmptyEventMessage(
                          key: ValueKey('attendance-empty-ongoing'),
                          message:
                              'Tidak ada kegiatan yang sedang berlangsung.',
                        ),
                      const SizedBox(height: 32),

                      // Kegiatan Mendatang
                      const Text(
                        'Kegiatan Mendatang',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (state.upcomingEvents.isEmpty)
                        const _EmptyEventMessage(
                          key: ValueKey('attendance-empty-upcoming'),
                          message: 'Belum ada kegiatan mendatang.',
                        )
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: state.upcomingEvents.length,
                          itemBuilder: (context, index) {
                            final event = state.upcomingEvents[index];
                            return UpcomingEventListTile(
                              event: event,
                              onDetailTap: () => context.router.push(
                                ActivityDetailRoute(eventId: event.id),
                              ),
                            );
                          },
                        ),
                    ],
                  ),
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

class _AttendanceErrorView extends StatelessWidget {
  const _AttendanceErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_outlined,
              color: Color(0xFF62676E),
              size: 48,
            ),
            const SizedBox(height: 14),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 18),
            FilledButton(onPressed: onRetry, child: const Text('Coba Lagi')),
          ],
        ),
      ),
    );
  }
}

class _EmptyEventMessage extends StatelessWidget {
  const _EmptyEventMessage({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7FB),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        message,
        style: const TextStyle(color: Color(0xFF62676E), fontSize: 14),
      ),
    );
  }
}
