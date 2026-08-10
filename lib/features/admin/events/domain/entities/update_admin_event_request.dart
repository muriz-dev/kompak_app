import 'package:equatable/equatable.dart';

import 'create_admin_event_request.dart';

class UpdateAdminEventRequest extends Equatable {
  const UpdateAdminEventRequest({
    required this.title,
    required this.description,
    required this.eventDate,
    required this.attendanceStartTime,
    required this.attendanceEndTime,
    required this.rewardPoints,
    required this.latitude,
    required this.longitude,
    required this.radiusMeters,
    this.existingBannerUrl,
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
  final String? existingBannerUrl;
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
    existingBannerUrl,
    poster,
  ];
}
