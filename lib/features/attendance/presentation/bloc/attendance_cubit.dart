import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../domain/entities/attendance_data.dart';
import 'attendance_state.dart';

@injectable
class AttendanceCubit extends Cubit<AttendanceState> {
  AttendanceCubit() : super(AttendanceLoading());

  void loadAttendanceData() async {
    emit(AttendanceLoading());
    try {
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));

      // Mock Data
      final stats = AttendanceStats(
        totalEventsAttended: 12,
        potentialPoints: 400,
      );

      final ongoingEvent = OngoingEvent(
        id: '1',
        title: 'Rapat Rutin & Kerja Bakti',
        imageUrl:
            'https://images.pexels.com/photos/28434145/pexels-photo-28434145.jpeg',
        tag: 'MENDESAK',
        timeRemaining: 'Berakhir dlm 45 mnt',
        participantCount: 24,
        points: 100,
      );

      final upcomingEvents = [
        UpcomingEventItem(
          id: '2',
          month: 'MEI',
          date: '24',
          title: 'Posyandu Melati',
          location: 'Balai Warga RT 04',
          points: 50,
        ),
        UpcomingEventItem(
          id: '3',
          month: 'MEI',
          date: '26',
          title: 'Siskamling Malam',
          location: 'Pos Ronda Utama',
          points: 75,
        ),
        UpcomingEventItem(
          id: '4',
          month: 'JUN',
          date: '02',
          title: 'Senam Sehat',
          location: 'Lapangan Serbaguna',
          points: 30,
        ),
      ];

      emit(
        AttendanceLoaded(
          stats: stats,
          ongoingEvent: ongoingEvent,
          upcomingEvents: upcomingEvents,
        ),
      );
    } catch (e) {
      emit(AttendanceError(e.toString()));
    }
  }
}
