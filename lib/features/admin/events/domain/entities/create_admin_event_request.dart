import 'dart:typed_data';

import 'package:equatable/equatable.dart';

import 'admin_event.dart';

class EventPosterUpload extends Equatable {
  const EventPosterUpload({required this.bytes, required this.contentType});

  final Uint8List bytes;
  final String contentType;

  @override
  List<Object> get props => [bytes, contentType];
}

class CreateAdminEventRequest extends Equatable {
  const CreateAdminEventRequest({
    required this.title,
    required this.description,
    required this.eventDate,
    required this.attendanceStartTime,
    required this.attendanceEndTime,
    required this.rewardPoints,
    required this.latitude,
    required this.longitude,
    this.radiusMeters = 50,
    this.status = AdminEventRecordStatus.published,
    this.poster,
  });

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
  final EventPosterUpload? poster;

  @override
  List<Object?> get props => [
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
    poster,
  ];
}
