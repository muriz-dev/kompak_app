import '../entities/store_data.dart';

abstract class PointShopRepository {
  Future<PointShopData> getCatalog();

  Future<RewardRedemption> redeem({
    required StoreItem item,
    required String idempotencyKey,
  });

  Future<PointHistoryData> getPointHistory();
}
