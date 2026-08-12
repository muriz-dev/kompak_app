import '../entities/admin_point_shop_product.dart';

abstract class AdminPointShopRepository {
  Future<AdminPointShopProductPage> getProducts({
    required AdminPointShopProductStatus status,
    String query = '',
    AdminPointShopProductType? type,
    String? providerId,
    int page = 1,
    int pageSize = 3,
  });

  Future<void> updateProductStatus(
    String productId,
    AdminPointShopProductStatus status,
  );
}
