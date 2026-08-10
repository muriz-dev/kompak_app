import 'package:injectable/injectable.dart';

import '../../domain/entities/attendance_check_in.dart';
import '../../domain/entities/attendance_record.dart';
import '../../domain/repositories/attendance_repository.dart';
import '../datasources/attendance_remote_data_source.dart';

@LazySingleton(as: AttendanceRepository)
class AttendanceRepositoryImpl implements AttendanceRepository {
  AttendanceRepositoryImpl(this._remoteDataSource);

  final AttendanceRemoteDataSource _remoteDataSource;

  @override
  Future<AttendanceCheckInResult> checkIn(AttendanceCheckInRequest request) =>
      _remoteDataSource.checkIn(request);

  @override
  Future<List<AttendanceRecord>> getMyAttendances() =>
      _remoteDataSource.getMyAttendances();
}
