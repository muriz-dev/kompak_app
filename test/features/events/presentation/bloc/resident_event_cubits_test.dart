import 'package:flutter_test/flutter_test.dart';
import 'package:kompak_app/features/attendance/presentation/bloc/attendance_cubit.dart';
import 'package:kompak_app/features/attendance/presentation/bloc/attendance_state.dart';
import 'package:kompak_app/features/attendance/domain/entities/attendance_check_in.dart';
import 'package:kompak_app/features/attendance/domain/entities/attendance_record.dart';
import 'package:kompak_app/features/attendance/domain/repositories/attendance_repository.dart';
import 'package:kompak_app/features/events/domain/entities/community_event.dart';
import 'package:kompak_app/features/events/domain/repositories/community_events_repository.dart';
import 'package:kompak_app/features/events/presentation/bloc/activity_detail_cubit.dart';
import 'package:kompak_app/features/events/presentation/bloc/activity_detail_state.dart';
import 'package:kompak_app/features/home/presentation/bloc/home_cubit.dart';
import 'package:kompak_app/features/home/presentation/bloc/home_state.dart';

void main() {
  late CommunityEvent upcoming;
  late CommunityEvent ongoing;
  late _EventsRepository repository;

  setUp(() {
    final now = DateTime.now();
    upcoming = _event(
      id: 'upcoming-1',
      title: 'Rapat Warga',
      start: now.add(const Duration(days: 1)),
      end: now.add(const Duration(days: 1, hours: 2)),
      points: 40,
    );
    ongoing = _event(
      id: 'ongoing-1',
      title: 'Kerja Bakti',
      start: now.subtract(const Duration(minutes: 30)),
      end: now.add(const Duration(minutes: 30)),
      points: 60,
    );
    repository = _EventsRepository(upcoming: [upcoming], ongoing: [ongoing]);
  });

  test('home maps upcoming API events into dashboard activities', () async {
    final cubit = HomeCubit(repository);
    addTearDown(cubit.close);

    await cubit.loadHomeData();

    final state = cubit.state as HomeLoaded;
    expect(state.upcomingActivities.single.id, 'upcoming-1');
    expect(state.upcomingActivities.single.title, 'Rapat Warga');
  });

  test(
    'attendance maps ongoing and upcoming API events without mock counts',
    () async {
      final attendanceRepository = _AttendanceRepository([
        AttendanceRecord(
          id: 'attendance-1',
          eventId: 'ongoing-1',
          eventTitle: 'Kerja Bakti',
          verifiedAt: DateTime.now(),
          pointsEarned: 60,
        ),
      ]);
      final cubit = AttendanceCubit(repository, attendanceRepository);
      addTearDown(cubit.close);

      await cubit.loadAttendanceData();

      final state = cubit.state as AttendanceLoaded;
      expect(state.ongoingEvent?.id, 'ongoing-1');
      expect(state.ongoingEvent?.participantCount, 0);
      expect(state.upcomingEvents.single.id, 'upcoming-1');
      expect(state.stats.potentialPoints, 100);
      expect(state.stats.totalEventsAttended, 1);
      expect(state.history.single.id, 'attendance-1');
    },
  );

  test('activity detail loads the selected published event', () async {
    final cubit = ActivityDetailCubit(repository);
    addTearDown(cubit.close);

    await cubit.loadEvent('upcoming-1');

    final state = cubit.state as ActivityDetailLoaded;
    expect(state.event, upcoming);
  });
}

class _AttendanceRepository implements AttendanceRepository {
  _AttendanceRepository(this.history);

  final List<AttendanceRecord> history;

  @override
  Future<AttendanceCheckInResult> checkIn(AttendanceCheckInRequest request) =>
      throw UnimplementedError();

  @override
  Future<List<AttendanceRecord>> getMyAttendances() async => history;
}

CommunityEvent _event({
  required String id,
  required String title,
  required DateTime start,
  required DateTime end,
  required int points,
}) => CommunityEvent(
  id: id,
  title: title,
  description: 'Deskripsi $title',
  eventDate: start,
  attendanceStartTime: start,
  attendanceEndTime: end,
  rewardPoints: points,
  latitude: -6.2,
  longitude: 106.8,
  radiusMeters: 50,
);

class _EventsRepository implements CommunityEventsRepository {
  _EventsRepository({required this.upcoming, required this.ongoing});

  final List<CommunityEvent> upcoming;
  final List<CommunityEvent> ongoing;

  @override
  Future<CommunityEvent> getEvent(String eventId) async =>
      [...upcoming, ...ongoing].firstWhere((event) => event.id == eventId);

  @override
  Future<List<CommunityEvent>> getEvents(EventTimeframe timeframe) async =>
      timeframe == EventTimeframe.upcoming ? upcoming : ongoing;
}
