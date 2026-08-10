import 'package:geolocator/geolocator.dart';

import '../../domain/entities/event_location_selection.dart';

enum EventLocationFailure {
  serviceDisabled,
  permissionDenied,
  permissionDeniedForever,
  unavailable,
}

class EventLocationException implements Exception {
  const EventLocationException(this.failure);

  final EventLocationFailure failure;
}

abstract interface class EventLocationService {
  Future<EventLocationSelection> getCurrentLocation();

  Future<bool> openSettings(EventLocationFailure failure);
}

class GeolocatorEventLocationService implements EventLocationService {
  const GeolocatorEventLocationService();

  @override
  Future<EventLocationSelection> getCurrentLocation() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      throw const EventLocationException(EventLocationFailure.serviceDisabled);
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      throw const EventLocationException(
        EventLocationFailure.permissionDeniedForever,
      );
    }
    if (permission == LocationPermission.denied) {
      throw const EventLocationException(EventLocationFailure.permissionDenied);
    }

    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 12),
        ),
      );
      return EventLocationSelection(
        latitude: position.latitude,
        longitude: position.longitude,
      );
    } catch (_) {
      throw const EventLocationException(EventLocationFailure.unavailable);
    }
  }

  @override
  Future<bool> openSettings(EventLocationFailure failure) => switch (failure) {
    EventLocationFailure.serviceDisabled => Geolocator.openLocationSettings(),
    EventLocationFailure.permissionDeniedForever =>
      Geolocator.openAppSettings(),
    EventLocationFailure.permissionDenied ||
    EventLocationFailure.unavailable => Future.value(false),
  };
}
