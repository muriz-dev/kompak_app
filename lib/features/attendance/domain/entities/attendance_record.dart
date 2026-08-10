import 'package:equatable/equatable.dart';

class AttendanceRecord extends Equatable {
  const AttendanceRecord({
    required this.id,
    required this.eventId,
    required this.eventTitle,
    required this.verifiedAt,
    required this.pointsEarned,
  });

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) {
    final event = json['event'] is Map
        ? Map<String, dynamic>.from(json['event'] as Map)
        : const <String, dynamic>{};
    return AttendanceRecord(
      id: json['id']?.toString() ?? '',
      eventId: json['eventId']?.toString() ?? '',
      eventTitle: event['title']?.toString() ?? 'Kegiatan Kompak',
      verifiedAt: _parseDate(json['verifiedAt'] ?? json['createdAt']),
      pointsEarned: _parseInt(event['rewardPoints']),
    );
  }

  final String id;
  final String eventId;
  final String eventTitle;
  final DateTime verifiedAt;
  final int pointsEarned;

  @override
  List<Object?> get props => [
    id,
    eventId,
    eventTitle,
    verifiedAt,
    pointsEarned,
  ];
}

DateTime _parseDate(Object? value) {
  if (value is num) {
    return DateTime.fromMillisecondsSinceEpoch(value.toInt(), isUtc: true);
  }
  return DateTime.tryParse(value?.toString() ?? '') ??
      DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
}

int _parseInt(Object? value) => switch (value) {
  int number => number,
  num number => number.toInt(),
  _ => int.tryParse(value?.toString() ?? '') ?? 0,
};
