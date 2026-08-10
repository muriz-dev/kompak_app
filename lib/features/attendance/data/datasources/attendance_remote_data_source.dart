import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/attendance_check_in.dart';
import '../../domain/entities/attendance_record.dart';

abstract interface class AttendanceRemoteDataSource {
  Future<AttendanceCheckInResult> checkIn(AttendanceCheckInRequest request);

  Future<List<AttendanceRecord>> getMyAttendances();
}

@LazySingleton(as: AttendanceRemoteDataSource)
class AttendanceRemoteDataSourceImpl implements AttendanceRemoteDataSource {
  AttendanceRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<AttendanceCheckInResult> checkIn(
    AttendanceCheckInRequest request,
  ) async {
    try {
      final extension = request.faceImagePath.split('.').last.toLowerCase();
      final imageSubtype = extension == 'png'
          ? 'png'
          : extension == 'webp'
          ? 'webp'
          : 'jpeg';
      final form = FormData.fromMap({
        'eventId': request.eventId,
        'latitude': request.latitude.toString(),
        'longitude': request.longitude.toString(),
        'faceImage': await MultipartFile.fromFile(
          request.faceImagePath,
          filename: 'attendance-face.$extension',
          contentType: DioMediaType('image', imageSubtype),
        ),
      });
      final response = await _dio.post<Map<String, dynamic>>(
        '/attendances',
        data: form,
      );
      final data = _responseData(response.data, 'respons absensi');
      if (data is! Map) throw const FormatException('Invalid attendance data');
      return AttendanceCheckInResult.fromJson(Map<String, dynamic>.from(data));
    } on DioException catch (error) {
      throw AttendanceException(_errorMessage(error));
    }
  }

  @override
  Future<List<AttendanceRecord>> getMyAttendances() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>('/attendances/me');
      final data = _responseData(response.data, 'riwayat absensi');
      if (data is! List) throw const FormatException('Invalid attendance list');
      return data
          .whereType<Map>()
          .map(
            (item) =>
                AttendanceRecord.fromJson(Map<String, dynamic>.from(item)),
          )
          .toList(growable: false);
    } on DioException catch (error) {
      throw AttendanceException(
        _errorMessage(error, fallback: 'Gagal memuat riwayat absensi.'),
      );
    }
  }

  Object? _responseData(Map<String, dynamic>? payload, String label) {
    if (payload == null || payload['success'] != true) {
      throw FormatException('Invalid $label');
    }
    return payload['data'];
  }

  String _errorMessage(
    DioException error, {
    String fallback = 'Absensi gagal dikirim. Silakan coba lagi.',
  }) {
    final payload = error.response?.data;
    if (payload is! Map) return fallback;
    final errors = payload['errors'];
    if (errors is Map && errors['faceCode'] == 'face_mismatch') {
      return 'Wajah tidak cocok dengan identitas terdaftar. Silakan coba lagi.';
    }
    final message = payload['message']?.toString() ?? '';
    if (message.contains('radius')) {
      return 'Anda berada di luar radius lokasi kegiatan.';
    }
    if (message.contains('currently closed')) {
      return 'Waktu absensi untuk kegiatan ini sudah ditutup.';
    }
    if (message.contains('already attended')) {
      return 'Anda sudah melakukan absensi untuk kegiatan ini.';
    }
    if (error.response?.statusCode == 503 ||
        error.response?.statusCode == 504) {
      return 'Layanan verifikasi wajah sedang tidak tersedia. Silakan coba lagi.';
    }
    return message.isNotEmpty ? message : fallback;
  }
}

class AttendanceException implements Exception {
  const AttendanceException(this.message);

  final String message;

  @override
  String toString() => message;
}
