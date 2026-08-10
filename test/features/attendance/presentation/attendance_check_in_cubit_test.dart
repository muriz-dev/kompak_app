import 'package:flutter_test/flutter_test.dart';
import 'package:kompak_app/features/attendance/domain/entities/attendance_check_in.dart';
import 'package:kompak_app/features/attendance/domain/entities/attendance_record.dart';
import 'package:kompak_app/features/attendance/domain/repositories/attendance_repository.dart';
import 'package:kompak_app/features/attendance/presentation/bloc/attendance_check_in_cubit.dart';

void main() {
  test('emits the server-issued attendance result after check-in', () async {
    final repository = _AttendanceRepository();
    final cubit = AttendanceCheckInCubit(repository);
    addTearDown(cubit.close);

    await cubit.submit(
      eventId: 'event-1',
      faceImagePath: '/tmp/face.jpg',
      latitude: -6.2,
      longitude: 106.8,
    );

    final state = cubit.state as AttendanceCheckInSuccess;
    expect(state.result.attendanceId, 'attendance-server-id');
    expect(state.result.pointsEarned, 75);
    expect(repository.request?.eventId, 'event-1');
    expect(repository.request?.latitude, -6.2);
  });
}

class _AttendanceRepository implements AttendanceRepository {
  AttendanceCheckInRequest? request;

  @override
  Future<AttendanceCheckInResult> checkIn(
    AttendanceCheckInRequest request,
  ) async {
    this.request = request;
    return const AttendanceCheckInResult(
      attendanceId: 'attendance-server-id',
      pointsEarned: 75,
    );
  }

  @override
  Future<List<AttendanceRecord>> getMyAttendances() async => const [];
}
