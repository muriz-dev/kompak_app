import 'package:equatable/equatable.dart';

enum AdminEventRecordStatus {
  draft,
  published,
  closed,
  cancelled;

  String get apiValue => switch (this) {
    AdminEventRecordStatus.draft => 'DRAFT',
    AdminEventRecordStatus.published => 'PUBLISHED',
    AdminEventRecordStatus.closed => 'CLOSED',
    AdminEventRecordStatus.cancelled => 'CANCELLED',
  };

  static AdminEventRecordStatus fromApi(String value) => switch (value) {
    'DRAFT' => AdminEventRecordStatus.draft,
    'PUBLISHED' => AdminEventRecordStatus.published,
    'CLOSED' => AdminEventRecordStatus.closed,
    'CANCELLED' => AdminEventRecordStatus.cancelled,
    _ => throw FormatException('Unsupported event status: $value'),
  };
}

enum AdminEventLifecycle { draft, upcoming, ongoing, completed, cancelled }

class AdminEvent extends Equatable {
  const AdminEvent({
    required this.id,
    required this.createdBy,
    required this.title,
    required this.description,
    required this.eventDate,
    required this.attendanceStartTime,
    required this.attendanceEndTime,
    required this.rewardPoints,
    required this.latitude,
    required this.longitude,
    required this.radiusMeters,
    required this.status,
    this.bannerUrl,
  });

  factory AdminEvent.fromJson(Map<String, dynamic> json) => AdminEvent(
    id: json['id'] as String,
    createdBy: json['createdBy'] as String,
    title: json['title'] as String,
    description: json['description'] as String,
    eventDate: _parseDate(json['eventDate']),
    attendanceStartTime: _parseDate(json['attendanceStartTime']),
    attendanceEndTime: _parseDate(json['attendanceEndTime']),
    rewardPoints: (json['rewardPoints'] as num).toInt(),
    latitude: (json['latitude'] as num).toDouble(),
    longitude: (json['longitude'] as num).toDouble(),
    radiusMeters: (json['radiusMeters'] as num?)?.toInt() ?? 50,
    status: AdminEventRecordStatus.fromApi(json['status'] as String),
    bannerUrl: json['bannerUrl'] as String?,
  );

  final String id;
  final String createdBy;
  final String title;
  final String description;
  final DateTime eventDate;
  final DateTime attendanceStartTime;
  final DateTime attendanceEndTime;
  final int rewardPoints;
  final double latitude;
  final double longitude;
  final int radiusMeters;
  final AdminEventRecordStatus status;
  final String? bannerUrl;

  AdminEventLifecycle lifecycleAt(DateTime now) => switch (status) {
    AdminEventRecordStatus.draft => AdminEventLifecycle.draft,
    AdminEventRecordStatus.cancelled => AdminEventLifecycle.cancelled,
    AdminEventRecordStatus.closed => AdminEventLifecycle.completed,
    AdminEventRecordStatus.published when attendanceStartTime.isAfter(now) =>
      AdminEventLifecycle.upcoming,
    AdminEventRecordStatus.published when attendanceEndTime.isBefore(now) =>
      AdminEventLifecycle.completed,
    AdminEventRecordStatus.published => AdminEventLifecycle.ongoing,
  };

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
    createdBy,
    title,
    description,
    eventDate,
    attendanceStartTime,
    attendanceEndTime,
    rewardPoints,
    latitude,
    longitude,
    radiusMeters,
    status,
    bannerUrl,
  ];
}
