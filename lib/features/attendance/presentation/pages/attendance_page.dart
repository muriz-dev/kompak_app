import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
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
                return Center(child: Text(state.message));
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
                                style: TextStyle(color: Colors.red, fontSize: 12),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (state.ongoingEvent != null)
                        OngoingEventCard(event: state.ongoingEvent!),
                      const SizedBox(height: 32),

                      // Kegiatan Mendatang
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Kegiatan Mendatang',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextButton(
                            onPressed: () {},
                            child: const Text('Lihat Semua'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: state.upcomingEvents.length,
                        itemBuilder: (context, index) {
                          return UpcomingEventListTile(
                            event: state.upcomingEvents[index],
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
