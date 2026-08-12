import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/admin_point_shop_product.dart';

abstract class AdminPointShopRemoteDataSource {
  Future<AdminPointShopProductPage> getProducts({
    required AdminPointShopProductStatus status,
    required String query,
    required AdminPointShopProductType? type,
    required String? providerId,
    required int page,
    required int pageSize,
  });

  Future<void> updateProductStatus(
    String productId,
    AdminPointShopProductStatus status,
  );
}

@LazySingleton(as: AdminPointShopRemoteDataSource)
class AdminPointShopRemoteDataSourceImpl
    implements AdminPointShopRemoteDataSource {
  const AdminPointShopRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<AdminPointShopProductPage> getProducts({
    required AdminPointShopProductStatus status,
    required String query,
    required AdminPointShopProductType? type,
    required String? providerId,
    required int page,
    required int pageSize,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/rewards/admin/point-shop',
        queryParameters: {
          'status': status.apiValue,
          if (query.trim().isNotEmpty) 'query': query.trim(),
          if (type != null) 'type': type.apiValue,
          'providerId': ?providerId,
          'page': page,
          'pageSize': pageSize,
        },
      );
      return AdminPointShopProductPage.fromJson(_dataMap(response));
    } on DioException catch (error) {
      throw Exception(_message(error, 'Gagal memuat produk Toko Poin.'));
    }
  }

  @override
  Future<void> updateProductStatus(
    String productId,
    AdminPointShopProductStatus status,
  ) async {
    try {
      final response = await _dio.patch<Map<String, dynamic>>(
        '/rewards/$productId',
        data: {'status': status.apiValue},
      );
      _dataMap(response);
    } on DioException catch (error) {
      throw Exception(_message(error, 'Gagal memperbarui produk Toko Poin.'));
    }
  }

  Map<String, dynamic> _dataMap(Response<Map<String, dynamic>> response) {
    final payload = response.data;
    if (payload == null ||
        payload['success'] != true ||
        payload['data'] is! Map) {
      throw const FormatException('Invalid Point Shop response');
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
