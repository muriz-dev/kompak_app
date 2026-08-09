import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/resident.dart';

abstract class AdminResidentsRemoteDataSource {
  Future<List<Resident>> getResidents();
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
  Future<Resident> updateStatus(
    String residentId,
    ResidentStatus status,
  ) async {
    if (status != ResidentStatus.active &&
        status != ResidentStatus.rejected &&
        status != ResidentStatus.pending) {
      throw ArgumentError.value(status, 'status', 'Status cannot be updated');
    }

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

  String _message(DioException error, String fallback) {
    final data = error.response?.data;
    return data is Map ? data['message']?.toString() ?? fallback : fallback;
  }
}
