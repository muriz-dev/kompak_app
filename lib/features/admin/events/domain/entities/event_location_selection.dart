import 'package:equatable/equatable.dart';

class EventLocationSelection extends Equatable {
  const EventLocationSelection({
    required this.latitude,
    required this.longitude,
    this.radiusMeters = defaultRadiusMeters,
  });

  static const defaultRadiusMeters = 50;
  static const minimumRadiusMeters = 1;
  static const maximumRadiusMeters = 1000;

  static const jakarta = EventLocationSelection(
    latitude: -6.200000,
    longitude: 106.816666,
  );

  final double latitude;
  final double longitude;
  final int radiusMeters;

  EventLocationSelection copyWith({
    double? latitude,
    double? longitude,
    int? radiusMeters,
  }) {
    return EventLocationSelection(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      radiusMeters: radiusMeters ?? this.radiusMeters,
    );
  }

  @override
  List<Object> get props => [latitude, longitude, radiusMeters];
}
