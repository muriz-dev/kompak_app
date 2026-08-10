import 'package:equatable/equatable.dart';

class EventLocationSelection extends Equatable {
  const EventLocationSelection({
    required this.latitude,
    required this.longitude,
  });

  static const jakarta = EventLocationSelection(
    latitude: -6.200000,
    longitude: 106.816666,
  );

  final double latitude;
  final double longitude;

  @override
  List<Object> get props => [latitude, longitude];
}
