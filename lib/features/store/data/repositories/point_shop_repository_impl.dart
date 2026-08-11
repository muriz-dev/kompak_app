import 'package:injectable/injectable.dart';

import '../../domain/entities/store_data.dart';
import '../../domain/repositories/point_shop_repository.dart';
import '../datasources/point_shop_remote_data_source.dart';

@LazySingleton(as: PointShopRepository)
class PointShopRepositoryImpl implements PointShopRepository {
  const PointShopRepositoryImpl(this._remoteDataSource);

  final PointShopRemoteDataSource _remoteDataSource;

  @override
  Future<PointShopData> getCatalog() => _remoteDataSource.getCatalog();

  @override
  Future<PointHistoryData> getPointHistory() =>
      _remoteDataSource.getPointHistory();

  @override
  Future<RewardRedemption> redeem({
    required StoreItem item,
    required String idempotencyKey,
  }) => _remoteDataSource.redeem(item: item, idempotencyKey: idempotencyKey);
}
