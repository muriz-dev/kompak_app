import '../entities/attendance_check_in.dart';
import '../entities/attendance_record.dart';

abstract interface class AttendanceRepository {
  Future<AttendanceCheckInResult> checkIn(AttendanceCheckInRequest request);

  Future<List<AttendanceRecord>> getMyAttendances();
}
