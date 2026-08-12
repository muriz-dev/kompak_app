import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../providers/domain/entities/admin_point_shop_product.dart';
import '../../domain/entities/admin_leaderboard_reward.dart';

abstract class AdminLeaderboardRewardsRemoteDataSource {
  Future<List<AdminLeaderboardReward>> getRewards();
  Future<AdminLeaderboardReward> createReward(
    AdminLeaderboardRewardDraft draft,
  );
  Future<AdminLeaderboardReward> updateReward(
    String rewardId,
    AdminLeaderboardRewardDraft draft,
  );
  Future<void> archiveReward(String rewardId);
}

@LazySingleton(as: AdminLeaderboardRewardsRemoteDataSource)
class AdminLeaderboardRewardsRemoteDataSourceImpl
    implements AdminLeaderboardRewardsRemoteDataSource {
  AdminLeaderboardRewardsRemoteDataSourceImpl(this._dio)
    : _uploadDio = Dio(
        BaseOptions(
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
          sendTimeout: const Duration(seconds: 30),
        ),
      );

  final Dio _dio;
  final Dio _uploadDio;

  @override
  Future<List<AdminLeaderboardReward>> getRewards() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/rewards/admin/leaderboard',
      );
      final data = _responseData(response);
      if (data is! List) {
        throw const FormatException('Invalid leaderboard rewards response');
      }
      return data
          .map(
            (item) => AdminLeaderboardReward.fromJson(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList(growable: false);
    } on DioException catch (error) {
      throw Exception(_message(error, 'Gagal memuat hadiah peringkat.'));
    }
  }

  @override
  Future<AdminLeaderboardReward> createReward(
    AdminLeaderboardRewardDraft draft,
  ) async {
    final imageUrl = await _resolveImage(draft);
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/rewards',
        data: draft.toJson(uploadedImageUrl: imageUrl),
      );
      return _reward(response);
    } on DioException catch (error) {
      throw Exception(_message(error, 'Gagal menyimpan hadiah peringkat.'));
    }
  }

  @override
  Future<AdminLeaderboardReward> updateReward(
    String rewardId,
    AdminLeaderboardRewardDraft draft,
  ) async {
    final imageUrl = await _resolveImage(draft);
    try {
      final response = await _dio.patch<Map<String, dynamic>>(
        '/rewards/$rewardId',
        data: draft.toJson(uploadedImageUrl: imageUrl),
      );
      final reward = _rewardMap(response);
      return AdminLeaderboardReward(
        id: reward['id'] as String,
        providerId: reward['providerId'] as String,
        provider: AdminRewardProvider(
          id: reward['providerId'] as String,
          name: '',
        ),
        name: reward['name'] as String,
        description: reward['description']?.toString() ?? '',
        stock: (reward['stock'] as num).toInt(),
        type: AdminPointShopProductType.fromApi(
          reward['type']?.toString() ?? 'OTHER',
        ),
        position: (reward['leaderboardPosition'] as num).toInt(),
        imageUrl: reward['imageUrl'] as String?,
      );
    } on DioException catch (error) {
      throw Exception(_message(error, 'Gagal memperbarui hadiah peringkat.'));
    }
  }

  @override
  Future<void> archiveReward(String rewardId) async {
    try {
      final response = await _dio.patch<Map<String, dynamic>>(
        '/rewards/$rewardId',
        data: {'status': 'INACTIVE'},
      );
      _rewardMap(response);
    } on DioException catch (error) {
      throw Exception(_message(error, 'Gagal menghapus hadiah peringkat.'));
    }
  }

  Future<String?> _resolveImage(AdminLeaderboardRewardDraft draft) async {
    final upload = draft.imageUpload;
    if (upload == null) return draft.imageUrl;
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/storage/upload-url',
        data: {
          'folder': 'rewards',
          'contentType': upload.contentType,
          'contentLength': upload.bytes.length,
        },
      );
      final data = response.data?['data'];
      if (data is! Map ||
          data['uploadUrl'] is! String ||
          data['publicUrl'] is! String) {
        throw const FormatException('Invalid reward image upload response');
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
    } on DioException catch (error) {
      throw Exception(_message(error, 'Gagal mengunggah foto hadiah.'));
    }
  }

  AdminLeaderboardReward _reward(Response<Map<String, dynamic>> response) {
    final data = _rewardMap(response);
    return AdminLeaderboardReward(
      id: data['id'] as String,
      providerId: data['providerId'] as String,
      provider: AdminRewardProvider(id: data['providerId'] as String, name: ''),
      name: data['name'] as String,
      description: data['description']?.toString() ?? '',
      stock: (data['stock'] as num).toInt(),
      type: AdminPointShopProductType.fromApi(
        data['type']?.toString() ?? 'OTHER',
      ),
      position: (data['leaderboardPosition'] as num).toInt(),
      imageUrl: data['imageUrl'] as String?,
    );
  }

  Map<String, dynamic> _rewardMap(Response<Map<String, dynamic>> response) {
    final data = _responseData(response);
    if (data is! Map) throw const FormatException('Invalid reward response');
    return Map<String, dynamic>.from(data);
  }

  Object? _responseData(Response<Map<String, dynamic>> response) {
    final payload = response.data;
    if (payload == null || payload['success'] != true) {
      throw const FormatException('Invalid rewards response');
    }
    return payload['data'];
  }

  String _message(DioException error, String fallback) {
    final payload = error.response?.data;
    return payload is Map
        ? payload['message']?.toString() ?? fallback
        : fallback;
  }
}
