import 'dart:io';

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
  AttendanceRemoteDataSourceImpl(this._dio) : _uploadDio = Dio();

  AttendanceRemoteDataSourceImpl.withUploadDio(this._dio, this._uploadDio);

  final Dio _dio;
  final Dio _uploadDio;

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
      final activityPhotoUrl = request.activityPhotoPath == null
          ? null
          : await _uploadActivityPhoto(request.activityPhotoPath!);
      final form = FormData.fromMap({
        'eventId': request.eventId,
        'latitude': request.latitude.toString(),
        'longitude': request.longitude.toString(),
        ...?(activityPhotoUrl == null
            ? null
            : {'activityPhotoUrl': activityPhotoUrl}),
        if (request.activityDescription.trim().isNotEmpty)
          'activityDescription': request.activityDescription.trim(),
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

  Future<String> _uploadActivityPhoto(String path) async {
    final file = File(path);
    final bytes = await file.readAsBytes();
    if (bytes.length > 5 * 1024 * 1024) {
      throw const AttendanceException(
        'Ukuran foto kegiatan maksimal 5 MB. Silakan pilih foto lain.',
      );
    }
    final extension = path.split('.').last.toLowerCase();
    final subtype = extension == 'png'
        ? 'png'
        : extension == 'webp'
        ? 'webp'
        : 'jpeg';
    final contentType = 'image/$subtype';
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/storage/upload-url',
        data: {
          'folder': 'attendances',
          'contentType': contentType,
          'contentLength': bytes.length,
        },
      );
      final data = response.data;
      final uploadData = data?['data'];
      if (data == null ||
          data['success'] != true ||
          uploadData is! Map ||
          uploadData['uploadUrl'] is! String ||
          uploadData['publicUrl'] is! String) {
        throw const FormatException('Invalid activity photo upload response');
      }
      await _uploadDio.put<void>(
        uploadData['uploadUrl'] as String,
        data: Stream<List<int>>.value(bytes),
        options: Options(
          headers: {
            Headers.contentTypeHeader: contentType,
            Headers.contentLengthHeader: bytes.length,
          },
        ),
      );
      return uploadData['publicUrl'] as String;
    } on DioException catch (error) {
      throw AttendanceException(
        _errorMessage(
          error,
          fallback: 'Foto kegiatan gagal diunggah. Silakan coba lagi.',
        ),
      );
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
