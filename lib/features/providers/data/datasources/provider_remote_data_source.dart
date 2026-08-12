import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/provider_account.dart';

abstract class ProviderRemoteDataSource {
  Future<ProviderAccount?> getMyProvider();

  Future<List<ProviderProduct>> getMyProducts({
    required String query,
    required int page,
    required int pageSize,
  });

  Future<ProviderAccount> register(ProviderRegistrationDraft draft);
  Future<ProviderAccount> updateRegistration(
    String providerId,
    ProviderRegistrationDraft draft,
  );
  Future<ProviderProduct> createProduct(
    String providerId,
    ProviderProductDraft draft,
  );
  Future<ProviderProduct> updateProduct(
    String productId,
    String providerId,
    ProviderProductDraft draft,
  );
  Future<void> deleteProduct(String productId);
}

@LazySingleton(as: ProviderRemoteDataSource)
class ProviderRemoteDataSourceImpl implements ProviderRemoteDataSource {
  ProviderRemoteDataSourceImpl(this._dio)
    : _uploadDio = Dio(
        BaseOptions(
          connectTimeout: const Duration(seconds: 30),
          sendTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
        ),
      );

  final Dio _dio;
  final Dio _uploadDio;

  @override
  Future<ProviderAccount?> getMyProvider() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>('/providers/me');
      return ProviderAccount.fromJson(_map(response, 'provider'));
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) return null;
      throw Exception(_message(error, 'Gagal memuat akun provider.'));
    }
  }

  @override
  Future<List<ProviderProduct>> getMyProducts({
    required String query,
    required int page,
    required int pageSize,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/rewards/provider/me',
        queryParameters: {
          if (query.trim().isNotEmpty) 'query': query.trim(),
          'page': page,
          'pageSize': pageSize,
        },
      );
      final data = _map(response, 'produk provider');
      return (data['items'] as List? ?? const [])
          .map(
            (item) => ProviderProduct.fromJson(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList(growable: false);
    } on DioException catch (error) {
      throw Exception(_message(error, 'Gagal memuat produk provider.'));
    }
  }

  @override
  Future<ProviderAccount> register(ProviderRegistrationDraft draft) async {
    final logoUrl = await _resolveImage(draft.logoUpload, 'providers');
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/providers',
        data: _providerPayload(draft, logoUrl ?? draft.logoUrl),
      );
      return _accountFromMutation(response);
    } on DioException catch (error) {
      throw Exception(_message(error, 'Gagal mengirim pendaftaran provider.'));
    }
  }

  @override
  Future<ProviderAccount> updateRegistration(
    String providerId,
    ProviderRegistrationDraft draft,
  ) async {
    final logoUrl = await _resolveImage(draft.logoUpload, 'providers');
    try {
      await _dio.patch<Map<String, dynamic>>(
        '/providers/$providerId',
        data: _providerPayload(draft, logoUrl ?? draft.logoUrl),
      );
      final account = await getMyProvider();
      if (account == null) {
        throw const FormatException('Provider missing after update');
      }
      return account;
    } on DioException catch (error) {
      throw Exception(
        _message(error, 'Gagal memperbarui pendaftaran provider.'),
      );
    }
  }

  @override
  Future<ProviderProduct> createProduct(
    String providerId,
    ProviderProductDraft draft,
  ) async {
    final imageUrl = await _resolveImage(draft.imageUpload, 'rewards');
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/rewards',
        data: _productPayload(providerId, draft, imageUrl ?? draft.imageUrl),
      );
      return ProviderProduct.fromJson(_map(response, 'produk'));
    } on DioException catch (error) {
      throw Exception(_message(error, 'Gagal menambahkan produk.'));
    }
  }

  @override
  Future<ProviderProduct> updateProduct(
    String productId,
    String providerId,
    ProviderProductDraft draft,
  ) async {
    final imageUrl = await _resolveImage(draft.imageUpload, 'rewards');
    try {
      final response = await _dio.patch<Map<String, dynamic>>(
        '/rewards/$productId',
        data: _productPayload(
          providerId,
          draft,
          imageUrl ?? draft.imageUrl,
          includeFixedFields: false,
        ),
      );
      return ProviderProduct.fromJson(_map(response, 'produk'));
    } on DioException catch (error) {
      throw Exception(_message(error, 'Gagal memperbarui produk.'));
    }
  }

  @override
  Future<void> deleteProduct(String productId) async {
    try {
      final response = await _dio.delete<Map<String, dynamic>>(
        '/rewards/$productId',
      );
      final body = response.data;
      if (body == null || body['success'] != true) {
        throw const FormatException('Invalid product deletion response');
      }
    } on DioException catch (error) {
      throw Exception(_message(error, 'Gagal menghapus produk.'));
    }
  }

  Future<String?> _resolveImage(
    ProviderImageUpload? upload,
    String folder,
  ) async {
    if (upload == null) return null;
    final response = await _dio.post<Map<String, dynamic>>(
      '/storage/upload-url',
      data: {
        'folder': folder,
        'contentType': upload.contentType,
        'contentLength': upload.bytes.length,
      },
    );
    final data = response.data?['data'];
    if (data is! Map ||
        data['uploadUrl'] is! String ||
        data['publicUrl'] is! String) {
      throw const FormatException('Invalid image upload response');
    }
    await _uploadDio.put<void>(
      data['uploadUrl'] as String,
      data: Stream<List<int>>.value(upload.bytes),
      options: Options(
        headers: {
          Headers.contentTypeHeader: upload.contentType,
          Headers.contentLengthHeader: upload.bytes.length,
        },
      ),
    );
    return data['publicUrl'] as String;
  }

  Map<String, dynamic> _providerPayload(
    ProviderRegistrationDraft draft,
    String? logoUrl,
  ) => {
    'name': draft.name.trim(),
    'address': draft.address.trim(),
    'latitude': draft.latitude,
    'longitude': draft.longitude,
    'logoUrl': ?logoUrl,
  };

  Map<String, dynamic> _productPayload(
    String providerId,
    ProviderProductDraft draft,
    String? imageUrl, {
    bool includeFixedFields = true,
  }) => {
    'name': draft.name.trim(),
    'description': draft.description.trim(),
    'pointsRequired': draft.pointsRequired,
    'stock': draft.stock,
    'type': draft.type.apiValue,
    if (includeFixedFields) 'source': 'POINT_SHOP',
    if (includeFixedFields) 'providerId': providerId,
    'imageUrl': ?imageUrl,
  };

  ProviderAccount _accountFromMutation(
    Response<Map<String, dynamic>> response,
  ) {
    final data = _map(response, 'provider');
    return ProviderAccount.fromJson({
      ...data,
      'owner': const <String, dynamic>{},
      'stats': const <String, dynamic>{},
      'products': const <dynamic>[],
    });
  }

  Map<String, dynamic> _map(
    Response<Map<String, dynamic>> response,
    String label,
  ) {
    final body = response.data;
    if (body == null || body['success'] != true || body['data'] is! Map) {
      throw FormatException('Invalid $label response');
    }
    return Map<String, dynamic>.from(body['data'] as Map);
  }

  String _message(DioException error, String fallback) {
    final data = error.response?.data;
    return data is Map ? data['message']?.toString() ?? fallback : fallback;
  }
}
