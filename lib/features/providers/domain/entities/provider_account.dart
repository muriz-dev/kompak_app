import 'dart:typed_data';

import 'package:equatable/equatable.dart';

enum ProviderStatus {
  pending('PENDING'),
  verified('VERIFIED'),
  rejected('REJECTED'),
  inactive('INACTIVE');

  const ProviderStatus(this.apiValue);
  final String apiValue;

  static ProviderStatus fromApi(String value) => values.firstWhere(
    (status) => status.apiValue == value,
    orElse: () => ProviderStatus.pending,
  );
}

enum ProviderProductType {
  voucher('VOUCHER', 'Voucher'),
  product('PRODUCT', 'Produk'),
  service('SERVICE', 'Layanan'),
  other('OTHER', 'Lainnya');

  const ProviderProductType(this.apiValue, this.label);
  final String apiValue;
  final String label;

  static ProviderProductType fromApi(String value) => values.firstWhere(
    (type) => type.apiValue == value,
    orElse: () => ProviderProductType.other,
  );
}

class ProviderOwner extends Equatable {
  const ProviderOwner({
    required this.name,
    required this.email,
    required this.phoneNumber,
  });

  factory ProviderOwner.fromJson(Map<String, dynamic> json) => ProviderOwner(
    name: json['name']?.toString() ?? '',
    email: json['email']?.toString() ?? '',
    phoneNumber: json['phoneNumber']?.toString() ?? '',
  );

  final String name;
  final String email;
  final String phoneNumber;

  @override
  List<Object?> get props => [name, email, phoneNumber];
}

class ProviderProduct extends Equatable {
  const ProviderProduct({
    required this.id,
    required this.providerId,
    required this.name,
    required this.description,
    required this.pointsRequired,
    required this.stock,
    required this.type,
    required this.isActive,
    this.imageUrl,
  });

  factory ProviderProduct.fromJson(Map<String, dynamic> json) =>
      ProviderProduct(
        id: json['id'] as String,
        providerId: json['providerId']?.toString() ?? '',
        name: json['name'] as String,
        description: json['description']?.toString() ?? '',
        pointsRequired: (json['pointsRequired'] as num).toInt(),
        stock: (json['stock'] as num?)?.toInt() ?? 0,
        type: ProviderProductType.fromApi(json['type']?.toString() ?? 'OTHER'),
        isActive: json['status'] == 'ACTIVE',
        imageUrl: json['imageUrl'] as String?,
      );

  final String id;
  final String providerId;
  final String name;
  final String description;
  final int pointsRequired;
  final int stock;
  final ProviderProductType type;
  final bool isActive;
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
    isActive,
    imageUrl,
  ];
}

class ProviderStats extends Equatable {
  const ProviderStats({
    required this.completedPoints,
    required this.activeProducts,
  });

  factory ProviderStats.fromJson(Map<String, dynamic> json) => ProviderStats(
    completedPoints: (json['completedPoints'] as num?)?.toInt() ?? 0,
    activeProducts: (json['activeProducts'] as num?)?.toInt() ?? 0,
  );

  final int completedPoints;
  final int activeProducts;

  @override
  List<Object?> get props => [completedPoints, activeProducts];
}

class ProviderAccount extends Equatable {
  const ProviderAccount({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.status,
    required this.createdAt,
    required this.owner,
    required this.stats,
    required this.products,
    this.logoUrl,
    this.storePhotoUrl,
  });

  factory ProviderAccount.fromJson(
    Map<String, dynamic> json,
  ) => ProviderAccount(
    id: json['id'] as String,
    name: json['name'] as String,
    address: json['address'] as String,
    latitude: (json['latitude'] as num).toDouble(),
    longitude: (json['longitude'] as num).toDouble(),
    status: ProviderStatus.fromApi(json['status'] as String),
    createdAt: _parseDate(json['createdAt']),
    owner: ProviderOwner.fromJson(
      Map<String, dynamic>.from(json['owner'] as Map? ?? const {}),
    ),
    stats: ProviderStats.fromJson(
      Map<String, dynamic>.from(json['stats'] as Map? ?? const {}),
    ),
    products: (json['products'] as List? ?? const [])
        .map(
          (item) =>
              ProviderProduct.fromJson(Map<String, dynamic>.from(item as Map)),
        )
        .toList(growable: false),
    logoUrl: json['logoUrl'] as String?,
    storePhotoUrl: json['storePhotoUrl'] as String?,
  );

  final String id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final ProviderStatus status;
  final DateTime createdAt;
  final ProviderOwner owner;
  final ProviderStats stats;
  final List<ProviderProduct> products;
  final String? logoUrl;
  final String? storePhotoUrl;

  @override
  List<Object?> get props => [
    id,
    name,
    address,
    latitude,
    longitude,
    status,
    createdAt,
    owner,
    stats,
    products,
    logoUrl,
    storePhotoUrl,
  ];
}

class ProviderRegistrationDraft {
  const ProviderRegistrationDraft({
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    this.logoUrl,
    this.logoUpload,
  });

  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final String? logoUrl;
  final ProviderImageUpload? logoUpload;
}

class ProviderProductDraft {
  const ProviderProductDraft({
    required this.name,
    required this.description,
    required this.pointsRequired,
    required this.stock,
    required this.type,
    this.imageUrl,
    this.imageUpload,
  });

  final String name;
  final String description;
  final int pointsRequired;
  final int stock;
  final ProviderProductType type;
  final String? imageUrl;
  final ProviderImageUpload? imageUpload;
}

class ProviderImageUpload {
  const ProviderImageUpload({required this.bytes, required this.contentType});

  final Uint8List bytes;
  final String contentType;
}

DateTime _parseDate(Object? value) => switch (value) {
  int milliseconds => DateTime.fromMillisecondsSinceEpoch(milliseconds),
  num milliseconds => DateTime.fromMillisecondsSinceEpoch(milliseconds.toInt()),
  String value =>
    DateTime.tryParse(value) ?? DateTime.fromMillisecondsSinceEpoch(0),
  _ => DateTime.fromMillisecondsSinceEpoch(0),
};
