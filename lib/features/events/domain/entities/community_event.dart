import 'package:equatable/equatable.dart';

enum EventTimeframe {
  upcoming('upcoming'),
  ongoing('ongoing');

  const EventTimeframe(this.apiValue);

  final String apiValue;
}

class CommunityEvent extends Equatable {
  const CommunityEvent({
    required this.id,
    required this.title,
    required this.description,
    required this.eventDate,
    required this.attendanceStartTime,
    required this.attendanceEndTime,
    required this.rewardPoints,
    required this.latitude,
    required this.longitude,
    required this.radiusMeters,
    this.bannerUrl,
  });

  factory CommunityEvent.fromJson(Map<String, dynamic> json) {
    if (json['status'] != 'PUBLISHED' && json['status'] != 'CLOSED') {
      throw FormatException(
        'Unsupported public event status: ${json['status']}',
      );
    }

    return CommunityEvent(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      eventDate: _parseDate(json['eventDate']),
      attendanceStartTime: _parseDate(json['attendanceStartTime']),
      attendanceEndTime: _parseDate(json['attendanceEndTime']),
      rewardPoints: (json['rewardPoints'] as num).toInt(),
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      radiusMeters: (json['radiusMeters'] as num?)?.toInt() ?? 50,
      bannerUrl: json['bannerUrl'] as String?,
    );
  }

  final String id;
  final String title;
  final String description;
  final DateTime eventDate;
  final DateTime attendanceStartTime;
  final DateTime attendanceEndTime;
  final int rewardPoints;
  final double latitude;
  final double longitude;
  final int radiusMeters;
  final String? bannerUrl;

  bool isUpcomingAt(DateTime now) => attendanceStartTime.isAfter(now);

  bool isOngoingAt(DateTime now) =>
      !attendanceStartTime.isAfter(now) && attendanceEndTime.isAfter(now);

  String get coordinateLabel =>
      '${latitude.toStringAsFixed(6)}, ${longitude.toStringAsFixed(6)}';

  static DateTime _parseDate(Object? value) => switch (value) {
    String raw => DateTime.parse(raw),
    int milliseconds => DateTime.fromMillisecondsSinceEpoch(milliseconds),
    num milliseconds => DateTime.fromMillisecondsSinceEpoch(
      milliseconds.toInt(),
    ),
    _ => throw const FormatException('Invalid event date'),
  };

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    eventDate,
    attendanceStartTime,
    attendanceEndTime,
    rewardPoints,
    latitude,
    longitude,
    radiusMeters,
    bannerUrl,
  ];
}
