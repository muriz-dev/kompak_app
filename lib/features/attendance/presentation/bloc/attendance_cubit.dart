import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../events/domain/entities/community_event.dart';
import '../../../events/domain/repositories/community_events_repository.dart';
import '../../domain/entities/attendance_data.dart';
import 'attendance_state.dart';

@injectable
class AttendanceCubit extends Cubit<AttendanceState> {
  AttendanceCubit(this._eventsRepository) : super(AttendanceLoading());

  final CommunityEventsRepository _eventsRepository;

  Future<void> loadAttendanceData() async {
    emit(AttendanceLoading());
    try {
      final results = await Future.wait([
        _eventsRepository.getEvents(EventTimeframe.ongoing),
        _eventsRepository.getEvents(EventTimeframe.upcoming),
      ]);
      final ongoingEvents = results[0];
      final upcomingEvents = results[1];
      final now = DateTime.now();

      final stats = AttendanceStats(
        // Attendance history will replace this value in the check-in slice.
        totalEventsAttended: 0,
        potentialPoints: [
          ...ongoingEvents,
          ...upcomingEvents,
        ].fold(0, (total, event) => total + event.rewardPoints),
      );

      final ongoingEvent = ongoingEvents.isEmpty
          ? null
          : _toOngoingEvent(ongoingEvents.first, now);
      final upcomingItems = upcomingEvents
          .map(_toUpcomingEvent)
          .toList(growable: false);

      emit(
        AttendanceLoaded(
          stats: stats,
          ongoingEvent: ongoingEvent,
          upcomingEvents: upcomingItems,
        ),
      );
    } catch (error) {
      emit(AttendanceError(_message(error)));
    }
  }

  OngoingEvent _toOngoingEvent(CommunityEvent event, DateTime now) {
    final remaining = event.attendanceEndTime.difference(now);
    final timeRemaining = remaining.inHours > 0
        ? 'Berakhir dlm ${remaining.inHours} jam'
        : 'Berakhir dlm ${remaining.inMinutes.clamp(0, 59)} mnt';

    return OngoingEvent(
      id: event.id,
      title: event.title,
      imageUrl: event.bannerUrl ?? '',
      tag: 'BERLANGSUNG',
      timeRemaining: timeRemaining,
      participantCount: 0,
      points: event.rewardPoints,
    );
  }

  UpcomingEventItem _toUpcomingEvent(CommunityEvent event) {
    final localStart = event.attendanceStartTime.toLocal();
    const months = [
      'JAN',
      'FEB',
      'MAR',
      'APR',
      'MEI',
      'JUN',
      'JUL',
      'AGU',
      'SEP',
      'OKT',
      'NOV',
      'DES',
    ];

    return UpcomingEventItem(
      id: event.id,
      month: months[localStart.month - 1],
      date: localStart.day.toString().padLeft(2, '0'),
      title: event.title,
      location: event.coordinateLabel,
      points: event.rewardPoints,
    );
  }

  String _message(Object error) => error.toString().replaceFirst(
    RegExp(r'^(Exception|FormatException):\s*'),
    '',
  );
}
