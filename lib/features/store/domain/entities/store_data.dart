import 'package:equatable/equatable.dart';

enum ItemType { icon, image }

enum RewardType {
  voucher('VOUCHER', 'Voucher'),
  product('PRODUCT', 'Produk'),
  service('SERVICE', 'Layanan'),
  other('OTHER', 'Lainnya');

  const RewardType(this.apiValue, this.label);

  final String apiValue;
  final String label;

  static RewardType fromApi(String value) => RewardType.values.firstWhere(
    (type) => type.apiValue == value,
    orElse: () => RewardType.other,
  );
}

class StoreStats extends Equatable {
  const StoreStats({required this.totalPoints});

  final int totalPoints;

  @override
  List<Object?> get props => [totalPoints];
}

class StoreCategory extends Equatable {
  const StoreCategory({required this.id, required this.name});

  final String id;
  final String name;

  @override
  List<Object?> get props => [id, name];
}

class RewardProvider extends Equatable {
  const RewardProvider({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    this.logoUrl,
    this.storePhotoUrl,
  });

  factory RewardProvider.fromJson(Map<String, dynamic> json) => RewardProvider(
    id: json['id'] as String,
    name: json['name'] as String,
    address: json['address'] as String,
    latitude: (json['latitude'] as num).toDouble(),
    longitude: (json['longitude'] as num).toDouble(),
    logoUrl: json['logoUrl'] as String?,
    storePhotoUrl: json['storePhotoUrl'] as String?,
  );

  final String id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final String? logoUrl;
  final String? storePhotoUrl;

  @override
  List<Object?> get props => [
    id,
    name,
    address,
    latitude,
    longitude,
    logoUrl,
    storePhotoUrl,
  ];
}

class StoreItem extends Equatable {
  const StoreItem({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrlOrIcon,
    required this.points,
    required this.stock,
    required this.validityDays,
    required this.rewardType,
    required this.provider,
    this.isFeatured = false,
    required this.itemType,
  });

  factory StoreItem.fromJson(Map<String, dynamic> json) {
    final imageUrl = json['imageUrl'] as String?;
    final type = RewardType.fromApi(json['type'] as String? ?? 'OTHER');
    return StoreItem(
      id: json['id'] as String,
      title: json['name'] as String,
      description: json['description'] as String? ?? '',
      imageUrlOrIcon: imageUrl?.isNotEmpty == true
          ? imageUrl!
          : switch (type) {
              RewardType.voucher => 'confirmation_number_outlined',
              RewardType.product => 'redeem_outlined',
              RewardType.service => 'handyman_outlined',
              RewardType.other => 'card_giftcard',
            },
      points: (json['pointsRequired'] as num).toInt(),
      stock: (json['stock'] as num).toInt(),
      validityDays: (json['validityDays'] as num?)?.toInt() ?? 7,
      rewardType: type,
      provider: RewardProvider.fromJson(
        Map<String, dynamic>.from(json['provider'] as Map),
      ),
      isFeatured: json['isFeatured'] == true,
      itemType: imageUrl?.isNotEmpty == true ? ItemType.image : ItemType.icon,
    );
  }

  final String id;
  final String title;
  final String description;
  final String imageUrlOrIcon;
  final int points;
  final int stock;
  final int validityDays;
  final RewardType rewardType;
  final RewardProvider provider;
  final bool isFeatured;
  final ItemType itemType;

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    imageUrlOrIcon,
    points,
    stock,
    validityDays,
    rewardType,
    provider,
    isFeatured,
    itemType,
  ];
}

class PointShopData {
  const PointShopData({required this.balance, required this.items});

  final int balance;
  final List<StoreItem> items;
}

enum RedemptionStatus { pending, completed, rejected, cancelled }

class RewardRedemption extends Equatable {
  const RewardRedemption({
    required this.id,
    required this.item,
    required this.pointsSpent,
    required this.status,
    required this.createdAt,
    required this.expiresAt,
    required this.balance,
    this.claimToken,
  });

  factory RewardRedemption.fromJson(
    Map<String, dynamic> json, {
    required StoreItem item,
  }) => RewardRedemption(
    id: json['id'] as String,
    item: item,
    pointsSpent: (json['pointsSpent'] as num).toInt(),
    status: switch (json['status']) {
      'COMPLETED' => RedemptionStatus.completed,
      'REJECTED' => RedemptionStatus.rejected,
      'CANCELLED' => RedemptionStatus.cancelled,
      _ => RedemptionStatus.pending,
    },
    createdAt: DateTime.parse(json['createdAt'] as String).toLocal(),
    expiresAt: DateTime.parse(json['expiresAt'] as String).toLocal(),
    balance: (json['balance'] as num?)?.toInt() ?? 0,
    claimToken: json['claimToken'] as String?,
  );

  final String id;
  final StoreItem item;
  final int pointsSpent;
  final RedemptionStatus status;
  final DateTime createdAt;
  final DateTime expiresAt;
  final int balance;
  final String? claimToken;

  @override
  List<Object?> get props => [
    id,
    item,
    pointsSpent,
    status,
    createdAt,
    expiresAt,
    balance,
    claimToken,
  ];
}

enum PointDirection { incoming, outgoing }

class PointHistoryEntry extends Equatable {
  const PointHistoryEntry({
    required this.id,
    required this.direction,
    required this.points,
    required this.title,
    required this.occurredAt,
    required this.referenceType,
    this.status,
  });

  factory PointHistoryEntry.fromJson(Map<String, dynamic> json) =>
      PointHistoryEntry(
        id: json['id'] as String,
        direction: json['direction'] == 'OUT'
            ? PointDirection.outgoing
            : PointDirection.incoming,
        points: (json['points'] as num).toInt(),
        title: json['title'] as String,
        occurredAt: DateTime.parse(json['occurredAt'] as String).toLocal(),
        referenceType: json['referenceType'] as String,
        status: json['status'] as String?,
      );

  final String id;
  final PointDirection direction;
  final int points;
  final String title;
  final DateTime occurredAt;
  final String referenceType;
  final String? status;

  @override
  List<Object?> get props => [
    id,
    direction,
    points,
    title,
    occurredAt,
    referenceType,
    status,
  ];
}

class PointHistoryData {
  const PointHistoryData({
    required this.balance,
    required this.entries,
    this.pendingRedemptions = const [],
  });

  final int balance;
  final List<PointHistoryEntry> entries;
  final List<RewardRedemption> pendingRedemptions;
}
