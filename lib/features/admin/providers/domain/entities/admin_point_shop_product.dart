import 'package:equatable/equatable.dart';

import 'admin_provider.dart';

enum AdminPointShopProductStatus {
  active('ACTIVE'),
  inactive('INACTIVE');

  const AdminPointShopProductStatus(this.apiValue);
  final String apiValue;

  static AdminPointShopProductStatus fromApi(String value) => switch (value) {
    'ACTIVE' => AdminPointShopProductStatus.active,
    _ => AdminPointShopProductStatus.inactive,
  };
}

enum AdminPointShopProductType {
  voucher('VOUCHER', 'Voucher'),
  product('PRODUCT', 'Produk'),
  service('SERVICE', 'Layanan'),
  other('OTHER', 'Lainnya');

  const AdminPointShopProductType(this.apiValue, this.label);
  final String apiValue;
  final String label;

  static AdminPointShopProductType fromApi(String value) => values.firstWhere(
    (type) => type.apiValue == value,
    orElse: () => AdminPointShopProductType.other,
  );
}

class AdminPointShopProduct extends Equatable {
  const AdminPointShopProduct({
    required this.id,
    required this.providerId,
    required this.name,
    required this.description,
    required this.pointsRequired,
    required this.stock,
    required this.type,
    required this.status,
    required this.isFeatured,
    this.imageUrl,
  });

  factory AdminPointShopProduct.fromJson(Map<String, dynamic> json) =>
      AdminPointShopProduct(
        id: json['id'] as String,
        providerId: json['providerId'] as String,
        name: json['name'] as String,
        description: json['description']?.toString() ?? '',
        pointsRequired: (json['pointsRequired'] as num).toInt(),
        stock: (json['stock'] as num).toInt(),
        type: AdminPointShopProductType.fromApi(
          json['type']?.toString() ?? 'OTHER',
        ),
        status: AdminPointShopProductStatus.fromApi(
          json['status']?.toString() ?? 'INACTIVE',
        ),
        isFeatured: json['isFeatured'] == true,
        imageUrl: json['imageUrl'] as String?,
      );

  final String id;
  final String providerId;
  final String name;
  final String description;
  final int pointsRequired;
  final int stock;
  final AdminPointShopProductType type;
  final AdminPointShopProductStatus status;
  final bool isFeatured;
  final String? imageUrl;

  @override
  List<Object?> get props => [
    id,
    providerId,
    name,
    description,
    pointsRequired,
    stock,
    type,
    status,
    isFeatured,
    imageUrl,
  ];
}

class AdminPointShopProductPage extends Equatable {
  const AdminPointShopProductPage({
    required this.items,
    required this.pagination,
  });

  factory AdminPointShopProductPage.fromJson(Map<String, dynamic> json) =>
      AdminPointShopProductPage(
        items: (json['items'] as List? ?? const [])
            .map(
              (item) => AdminPointShopProduct.fromJson(
                Map<String, dynamic>.from(item as Map),
              ),
            )
            .toList(growable: false),
        pagination: AdminProviderPagination.fromJson(
          Map<String, dynamic>.from(json['pagination'] as Map),
        ),
      );

  final List<AdminPointShopProduct> items;
  final AdminProviderPagination pagination;

  @override
  List<Object?> get props => [items, pagination];
}
