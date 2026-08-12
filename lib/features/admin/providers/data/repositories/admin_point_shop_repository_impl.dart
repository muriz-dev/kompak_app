import 'package:injectable/injectable.dart';

import '../../domain/entities/admin_point_shop_product.dart';
import '../../domain/repositories/admin_point_shop_repository.dart';
import '../datasources/admin_point_shop_remote_data_source.dart';

@LazySingleton(as: AdminPointShopRepository)
class AdminPointShopRepositoryImpl implements AdminPointShopRepository {
  const AdminPointShopRepositoryImpl(this._remoteDataSource);

  final AdminPointShopRemoteDataSource _remoteDataSource;

  @override
  Future<AdminPointShopProductPage> getProducts({
    required AdminPointShopProductStatus status,
    String query = '',
    AdminPointShopProductType? type,
    String? providerId,
    int page = 1,
    int pageSize = 3,
  }) => _remoteDataSource.getProducts(
    status: status,
    query: query,
    type: type,
    providerId: providerId,
    page: page,
    pageSize: pageSize,
  );

  @override
  Future<void> updateProductStatus(
    String productId,
    AdminPointShopProductStatus status,
  ) => _remoteDataSource.updateProductStatus(productId, status);
}
