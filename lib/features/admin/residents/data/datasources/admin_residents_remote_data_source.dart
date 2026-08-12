import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/resident.dart';

abstract class AdminResidentsRemoteDataSource {
  Future<List<Resident>> getResidents();
  Future<Resident> getResident(String residentId);
  Future<Resident> createResident({
    required String name,
    required String phoneNumber,
    required String birthDate,
    required String email,
    required String password,
    required String faceImagePath,
  });
  Future<Resident> updateResident({
    required String residentId,
    required String name,
    required String phoneNumber,
    required String birthDate,
    required String email,
  });
  Future<Resident> updateStatus(String residentId, ResidentStatus status);
}

@LazySingleton(as: AdminResidentsRemoteDataSource)
class AdminResidentsRemoteDataSourceImpl
    implements AdminResidentsRemoteDataSource {
  const AdminResidentsRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<List<Resident>> getResidents() async {
    try {
      final response = await _dio.get('/users');
      final data = response.data;
      if (data is! Map || data['success'] != true || data['data'] is! List) {
        throw const FormatException('Invalid residents response');
      }
      return (data['data'] as List)
          .map(
            (item) => Resident.fromJson(Map<String, dynamic>.from(item as Map)),
          )
          .toList(growable: false);
    } on DioException catch (error) {
      throw Exception(_message(error, 'Gagal memuat data warga.'));
    }
  }

  @override
  Future<Resident> getResident(String residentId) async {
    try {
      final response = await _dio.get('/users/$residentId');
      return _residentFromResponse(response.data, 'Invalid resident response');
    } on DioException catch (error) {
      throw Exception(_message(error, 'Gagal memuat detail warga.'));
    }
  }

  @override
  Future<Resident> createResident({
    required String name,
    required String phoneNumber,
    required String birthDate,
    required String email,
    required String password,
    required String faceImagePath,
  }) async {
    try {
      final extension = faceImagePath.split('.').last.toLowerCase();
      final contentType = switch (extension) {
        'png' => DioMediaType('image', 'png'),
        'webp' => DioMediaType('image', 'webp'),
        _ => DioMediaType('image', 'jpeg'),
      };
      final response = await _dio.post(
        '/users',
        data: FormData.fromMap({
          'name': name.trim(),
          'phoneNumber': phoneNumber.trim(),
          'birthDate': birthDate,
          'email': email.trim().toLowerCase(),
          'password': password,
          'faceImage': await MultipartFile.fromFile(
            faceImagePath,
            filename: 'resident-face.$extension',
            contentType: contentType,
          ),
        }),
      );
      return _residentFromResponse(
        response.data,
        'Invalid resident creation response',
      );
    } on DioException catch (error) {
      throw Exception(_message(error, 'Gagal menambahkan warga.'));
    }
  }

  @override
  Future<Resident> updateResident({
    required String residentId,
    required String name,
    required String phoneNumber,
    required String birthDate,
    required String email,
  }) async {
    try {
      final response = await _dio.patch(
        '/users/$residentId',
        data: {
          'name': name.trim(),
          'phoneNumber': phoneNumber.trim(),
          'birthDate': birthDate,
          'email': email.trim().toLowerCase(),
        },
      );
      return _residentFromResponse(
        response.data,
        'Invalid resident update response',
      );
    } on DioException catch (error) {
      throw Exception(_message(error, 'Gagal menyimpan perubahan warga.'));
    }
  }

  @override
  Future<Resident> updateStatus(
    String residentId,
    ResidentStatus status,
  ) async {
    try {
      final response = await _dio.patch(
        '/users/$residentId/status',
        data: {'status': status.apiValue},
      );
      final data = response.data;
      if (data is! Map || data['success'] != true || data['data'] is! Map) {
        throw const FormatException('Invalid resident response');
      }
      return Resident.fromJson(Map<String, dynamic>.from(data['data'] as Map));
    } on DioException catch (error) {
      throw Exception(_message(error, 'Gagal memperbarui status warga.'));
    }
  }

  Resident _residentFromResponse(Object? data, String formatError) {
    if (data is! Map || data['success'] != true || data['data'] is! Map) {
      throw FormatException(formatError);
    }
    return Resident.fromJson(Map<String, dynamic>.from(data['data'] as Map));
  }

  String _message(DioException error, String fallback) {
    final data = error.response?.data;
    return data is Map ? data['message']?.toString() ?? fallback : fallback;
  }
}
