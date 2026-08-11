import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/store_data.dart';

abstract class PointShopRemoteDataSource {
  Future<PointShopData> getCatalog();
  Future<RewardRedemption> redeem({
    required StoreItem item,
    required String idempotencyKey,
  });
  Future<PointHistoryData> getPointHistory();
}

@LazySingleton(as: PointShopRemoteDataSource)
class PointShopRemoteDataSourceImpl implements PointShopRemoteDataSource {
  const PointShopRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<PointShopData> getCatalog() async {
    try {
      final responses = await Future.wait([
        _dio.get<Map<String, dynamic>>('/auth/me'),
        _dio.get<Map<String, dynamic>>('/rewards/point-shop'),
      ]);
      final user = _dataMap(responses[0], 'profil pengguna');
      final catalogPayload = responses[1].data;
      if (catalogPayload == null ||
          catalogPayload['success'] != true ||
          catalogPayload['data'] is! List) {
        throw const FormatException('Invalid point shop response');
      }

      return PointShopData(
        balance: (user['balance'] as num?)?.toInt() ?? 0,
        items: (catalogPayload['data'] as List)
            .map(
              (entry) =>
                  StoreItem.fromJson(Map<String, dynamic>.from(entry as Map)),
            )
            .toList(growable: false),
      );
    } on DioException catch (error) {
      throw Exception(_message(error, 'Gagal memuat Toko Poin.'));
    }
  }

  @override
  Future<RewardRedemption> redeem({
    required StoreItem item,
    required String idempotencyKey,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/reward-redemptions',
        data: {'rewardId': item.id, 'idempotencyKey': idempotencyKey},
      );
      return RewardRedemption.fromJson(
        _dataMap(response, 'penukaran poin'),
        item: item,
      );
    } on DioException catch (error) {
      throw Exception(_message(error, 'Gagal menukar poin.'));
    }
  }

  @override
  Future<PointHistoryData> getPointHistory() async {
    try {
      final responses = await Future.wait([
        _dio.get<Map<String, dynamic>>('/points/me'),
        _dio.get<Map<String, dynamic>>('/reward-redemptions/me'),
      ]);
      final data = _dataMap(responses[0], 'riwayat poin');
      if (data['entries'] is! List) {
        throw const FormatException('Invalid point history response');
      }
      final redemptionPayload = responses[1].data;
      if (redemptionPayload == null ||
          redemptionPayload['success'] != true ||
          redemptionPayload['data'] is! List) {
        throw const FormatException('Invalid redemptions response');
      }
      return PointHistoryData(
        balance: (data['balance'] as num?)?.toInt() ?? 0,
        entries: (data['entries'] as List)
            .map(
              (entry) => PointHistoryEntry.fromJson(
                Map<String, dynamic>.from(entry as Map),
              ),
            )
            .toList(growable: false),
        pendingRedemptions: (redemptionPayload['data'] as List)
            .map((entry) => Map<String, dynamic>.from(entry as Map))
            .where((entry) => entry['status'] == 'PENDING')
            .map((entry) {
              final reward = Map<String, dynamic>.from(entry['reward'] as Map);
              reward['provider'] = entry['provider'];
              return RewardRedemption.fromJson(
                entry,
                item: StoreItem.fromJson(reward),
              );
            })
            .toList(growable: false),
      );
    } on DioException catch (error) {
      throw Exception(_message(error, 'Gagal memuat riwayat poin.'));
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
    final data = error.response?.data;
    return data is Map ? data['message']?.toString() ?? fallback : fallback;
  }
}
