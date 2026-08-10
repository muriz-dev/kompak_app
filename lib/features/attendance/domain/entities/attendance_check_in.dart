import 'package:equatable/equatable.dart';

class AttendanceCheckInRequest extends Equatable {
  const AttendanceCheckInRequest({
    required this.eventId,
    required this.latitude,
    required this.longitude,
    required this.faceImagePath,
  });

  final String eventId;
  final double latitude;
  final double longitude;
  final String faceImagePath;

  @override
  List<Object?> get props => [eventId, latitude, longitude, faceImagePath];
}

class AttendanceCheckInResult extends Equatable {
  const AttendanceCheckInResult({
    required this.attendanceId,
    required this.pointsEarned,
  });

  factory AttendanceCheckInResult.fromJson(Map<String, dynamic> json) =>
      AttendanceCheckInResult(
        attendanceId: json['attendanceId']?.toString() ?? '',
        pointsEarned: switch (json['pointsEarned']) {
          int value => value,
          num value => value.toInt(),
          final value => int.tryParse(value?.toString() ?? '') ?? 0,
        },
      );

  final String attendanceId;
  final int pointsEarned;

  @override
  List<Object?> get props => [attendanceId, pointsEarned];
}
