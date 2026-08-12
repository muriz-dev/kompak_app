import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/admin_provider.dart';

abstract class AdminProvidersRemoteDataSource {
  Future<AdminProviderPage> getProviders({
    required String query,
    required AdminProviderStatus? status,
    required int page,
    required int pageSize,
  });

  Future<AdminProviderDetail> getProviderDetail(String providerId);

  Future<void> updateStatus(String providerId, AdminProviderStatus status);
}

@LazySingleton(as: AdminProvidersRemoteDataSource)
class AdminProvidersRemoteDataSourceImpl
    implements AdminProvidersRemoteDataSource {
  const AdminProvidersRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<AdminProviderPage> getProviders({
    required String query,
    required AdminProviderStatus? status,
    required int page,
    required int pageSize,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/providers/admin',
        queryParameters: {
          if (query.trim().isNotEmpty) 'query': query.trim(),
          if (status != null) 'status': status.apiValue,
          'page': page,
          'pageSize': pageSize,
        },
      );
      return AdminProviderPage.fromJson(_dataMap(response, 'daftar provider'));
    } on DioException catch (error) {
      throw Exception(_message(error, 'Gagal memuat daftar provider.'));
    }
  }

  @override
  Future<AdminProviderDetail> getProviderDetail(String providerId) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/providers/admin/$providerId',
      );
      return AdminProviderDetail.fromJson(
        _dataMap(response, 'detail provider'),
      );
    } on DioException catch (error) {
      throw Exception(_message(error, 'Gagal memuat detail provider.'));
    }
  }

  @override
  Future<void> updateStatus(
    String providerId,
    AdminProviderStatus status,
  ) async {
    try {
      final response = await _dio.patch<Map<String, dynamic>>(
        '/providers/$providerId/status',
        data: {'status': status.apiValue},
      );
      _dataMap(response, 'status provider');
    } on DioException catch (error) {
      throw Exception(_message(error, 'Gagal memperbarui status provider.'));
    }
  }

  Map<String, dynamic> _dataMap(
    Response<Map<String, dynamic>> response,
    String label,
  ) {
    final payload = response.data;
    if (payload == null ||
        payload['success'] != true ||
        payload['data'] is! Map) {
      throw FormatException('Invalid $label response');
    }
    return Map<String, dynamic>.from(payload['data'] as Map);
  }

  String _message(DioException error, String fallback) {
    final payload = error.response?.data;
    return payload is Map
        ? payload['message']?.toString() ?? fallback
        : fallback;
  }
}
