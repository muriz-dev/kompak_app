import 'dart:typed_data';

import 'package:equatable/equatable.dart';

import '../../../providers/domain/entities/admin_point_shop_product.dart';

class AdminRewardProvider extends Equatable {
  const AdminRewardProvider({
    required this.id,
    required this.name,
    this.logoUrl,
  });

  factory AdminRewardProvider.fromJson(Map<String, dynamic> json) =>
      AdminRewardProvider(
        id: json['id'] as String,
        name: json['name'] as String,
        logoUrl: json['logoUrl'] as String?,
      );

  final String id;
  final String name;
  final String? logoUrl;

  @override
  List<Object?> get props => [id, name, logoUrl];
}

class AdminLeaderboardReward extends Equatable {
  const AdminLeaderboardReward({
    required this.id,
    required this.providerId,
    required this.provider,
    required this.name,
    required this.description,
    required this.stock,
    required this.type,
    required this.position,
    this.imageUrl,
  });

  factory AdminLeaderboardReward.fromJson(Map<String, dynamic> json) =>
      AdminLeaderboardReward(
        id: json['id'] as String,
        providerId: json['providerId'] as String,
        provider: AdminRewardProvider.fromJson(
          Map<String, dynamic>.from(json['provider'] as Map),
        ),
        name: json['name'] as String,
        description: json['description']?.toString() ?? '',
        stock: (json['stock'] as num).toInt(),
        type: AdminPointShopProductType.fromApi(
          json['type']?.toString() ?? 'OTHER',
        ),
        position: (json['leaderboardPosition'] as num).toInt(),
        imageUrl: json['imageUrl'] as String?,
      );

  final String id;
  final String providerId;
  final AdminRewardProvider provider;
  final String name;
  final String description;
  final int stock;
  final AdminPointShopProductType type;
  final int position;
  final String? imageUrl;

  @override
  List<Object?> get props => [
    id,
    providerId,
    provider,
    name,
    description,
    stock,
    type,
    position,
    imageUrl,
  ];
}

class AdminLeaderboardRewardDraft extends Equatable {
  const AdminLeaderboardRewardDraft({
    required this.providerId,
    required this.name,
    required this.description,
    required this.type,
    required this.position,
    this.stock = 1,
    this.imageUrl,
    this.imageUpload,
  });

  factory AdminLeaderboardRewardDraft.fromProduct(
    AdminPointShopProduct product,
    int position,
  ) => AdminLeaderboardRewardDraft(
    providerId: product.providerId,
    name: product.name,
    description: product.description,
    type: product.type,
    position: position,
    stock: product.stock,
    imageUrl: product.imageUrl,
  );

  final String providerId;
  final String name;
  final String description;
  final AdminPointShopProductType type;
  final int position;
  final int stock;
  final String? imageUrl;
  final AdminRewardImageUpload? imageUpload;

  Map<String, dynamic> toJson({String? uploadedImageUrl}) => {
    'providerId': providerId,
    'name': name,
    'description': description,
    'pointsRequired': 0,
    'stock': stock,
    'type': type.apiValue,
    'source': 'LEADERBOARD',
    'leaderboardPosition': position,
    if (uploadedImageUrl ?? imageUrl case final String url) 'imageUrl': url,
  };

  @override
  List<Object?> get props => [
    providerId,
    name,
    description,
    type,
    position,
    stock,
    imageUrl,
    imageUpload,
  ];
}

class AdminRewardImageUpload extends Equatable {
  const AdminRewardImageUpload({
    required this.bytes,
    required this.contentType,
  });

  final Uint8List bytes;
  final String contentType;

  @override
  List<Object?> get props => [bytes, contentType];
}
