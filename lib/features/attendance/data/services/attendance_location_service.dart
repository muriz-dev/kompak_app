import 'package:geolocator/geolocator.dart';

enum AttendanceLocationFailure {
  serviceDisabled,
  permissionDenied,
  permissionDeniedForever,
  unavailable,
}

class AttendanceLocationException implements Exception {
  const AttendanceLocationException(this.failure);

  final AttendanceLocationFailure failure;
}

class AttendanceCoordinates {
  const AttendanceCoordinates({
    required this.latitude,
    required this.longitude,
  });

  final double latitude;
  final double longitude;
}

abstract interface class AttendanceLocationService {
  Future<AttendanceCoordinates> getCurrentLocation();

  Future<bool> openSettings(AttendanceLocationFailure failure);
}

class GeolocatorAttendanceLocationService implements AttendanceLocationService {
  const GeolocatorAttendanceLocationService();

  @override
  Future<AttendanceCoordinates> getCurrentLocation() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      throw const AttendanceLocationException(
        AttendanceLocationFailure.serviceDisabled,
      );
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever) {
      throw const AttendanceLocationException(
        AttendanceLocationFailure.permissionDeniedForever,
      );
    }
    if (permission == LocationPermission.denied) {
      throw const AttendanceLocationException(
        AttendanceLocationFailure.permissionDenied,
      );
    }

    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 12),
        ),
      );
      return AttendanceCoordinates(
        latitude: position.latitude,
        longitude: position.longitude,
      );
    } catch (_) {
      throw const AttendanceLocationException(
        AttendanceLocationFailure.unavailable,
      );
    }
  }

  @override
  Future<bool> openSettings(AttendanceLocationFailure failure) =>
      switch (failure) {
        AttendanceLocationFailure.serviceDisabled =>
          Geolocator.openLocationSettings(),
        AttendanceLocationFailure.permissionDeniedForever =>
          Geolocator.openAppSettings(),
        AttendanceLocationFailure.permissionDenied ||
        AttendanceLocationFailure.unavailable => Future.value(false),
      };
}
