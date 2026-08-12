import 'package:equatable/equatable.dart';

enum AdminProviderStatus {
  pending('PENDING', 'Pending'),
  verified('VERIFIED', 'Verified'),
  rejected('REJECTED', 'Ditolak'),
  inactive('INACTIVE', 'Nonaktif');

  const AdminProviderStatus(this.apiValue, this.label);

  final String apiValue;
  final String label;

  static AdminProviderStatus fromApi(String value) => switch (value) {
    'PENDING' => AdminProviderStatus.pending,
    'VERIFIED' => AdminProviderStatus.verified,
    'REJECTED' => AdminProviderStatus.rejected,
    'INACTIVE' => AdminProviderStatus.inactive,
    _ => throw FormatException('Unsupported provider status: $value'),
  };
}

class AdminProviderOwner extends Equatable {
  const AdminProviderOwner({
    required this.id,
    required this.name,
    required this.email,
    required this.phoneNumber,
  });

  factory AdminProviderOwner.fromJson(Map<String, dynamic> json) =>
      AdminProviderOwner(
        id: json['id']?.toString() ?? '',
        name: json['name']?.toString() ?? 'Sponsor eksternal',
        email: json['email']?.toString() ?? '',
        phoneNumber: json['phoneNumber']?.toString() ?? '',
      );

  final String id;
  final String name;
  final String email;
  final String phoneNumber;

  @override
  List<Object?> get props => [id, name, email, phoneNumber];
}

class AdminProviderSummary extends Equatable {
  const AdminProviderSummary({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.status,
    required this.createdAt,
    this.owner,
    this.logoUrl,
    this.storePhotoUrl,
  });

  factory AdminProviderSummary.fromJson(Map<String, dynamic> json) {
    final owner = json['owner'];
    return AdminProviderSummary(
      id: json['id'] as String,
      name: json['name'] as String,
      address: json['address'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      status: AdminProviderStatus.fromApi(json['status'] as String),
      createdAt: _parseDate(json['createdAt']),
      owner: owner is Map
          ? AdminProviderOwner.fromJson(Map<String, dynamic>.from(owner))
          : null,
      logoUrl: json['logoUrl'] as String?,
      storePhotoUrl: json['storePhotoUrl'] as String?,
    );
  }

  final String id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final AdminProviderStatus status;
  final DateTime createdAt;
  final AdminProviderOwner? owner;
  final String? logoUrl;
  final String? storePhotoUrl;

  String get ownerName => owner?.name ?? 'Sponsor eksternal';

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
    logoUrl,
    storePhotoUrl,
  ];
}

class AdminProviderPagination extends Equatable {
  const AdminProviderPagination({
    required this.page,
    required this.pageSize,
    required this.total,
    required this.totalPages,
  });

  factory AdminProviderPagination.fromJson(Map<String, dynamic> json) =>
      AdminProviderPagination(
        page: (json['page'] as num).toInt(),
        pageSize: (json['pageSize'] as num).toInt(),
        total: (json['total'] as num).toInt(),
        totalPages: (json['totalPages'] as num).toInt(),
      );

  final int page;
  final int pageSize;
  final int total;
  final int totalPages;

  @override
  List<Object?> get props => [page, pageSize, total, totalPages];
}

class AdminProviderPage extends Equatable {
  const AdminProviderPage({required this.items, required this.pagination});

  factory AdminProviderPage.fromJson(Map<String, dynamic> json) =>
      AdminProviderPage(
        items: (json['items'] as List)
            .map(
              (item) => AdminProviderSummary.fromJson(
                Map<String, dynamic>.from(item as Map),
              ),
            )
            .toList(growable: false),
        pagination: AdminProviderPagination.fromJson(
          Map<String, dynamic>.from(json['pagination'] as Map),
        ),
      );

  final List<AdminProviderSummary> items;
  final AdminProviderPagination pagination;

  @override
  List<Object?> get props => [items, pagination];
}

class AdminProviderProduct extends Equatable {
  const AdminProviderProduct({
    required this.id,
    required this.name,
    required this.pointsRequired,
    required this.stock,
    required this.type,
    required this.status,
    this.imageUrl,
  });

  factory AdminProviderProduct.fromJson(Map<String, dynamic> json) =>
      AdminProviderProduct(
        id: json['id'] as String,
        name: json['name'] as String,
        pointsRequired: (json['pointsRequired'] as num).toInt(),
        stock: (json['stock'] as num).toInt(),
        type: json['type']?.toString() ?? 'OTHER',
        status: json['status']?.toString() ?? 'INACTIVE',
        imageUrl: json['imageUrl'] as String?,
      );

  final String id;
  final String name;
  final int pointsRequired;
  final int stock;
  final String type;
  final String status;
  final String? imageUrl;

  @override
  List<Object?> get props => [
    id,
    name,
    pointsRequired,
    stock,
    type,
    status,
    imageUrl,
  ];
}

class AdminProviderStats extends Equatable {
  const AdminProviderStats({
    required this.completedPoints,
    required this.activeProducts,
  });

  factory AdminProviderStats.fromJson(Map<String, dynamic> json) =>
      AdminProviderStats(
        completedPoints: (json['completedPoints'] as num?)?.toInt() ?? 0,
        activeProducts: (json['activeProducts'] as num?)?.toInt() ?? 0,
      );

  final int completedPoints;
  final int activeProducts;

  @override
  List<Object?> get props => [completedPoints, activeProducts];
}

class AdminProviderDetail extends Equatable {
  const AdminProviderDetail({
    required this.provider,
    required this.stats,
    required this.products,
  });

  factory AdminProviderDetail.fromJson(Map<String, dynamic> json) =>
      AdminProviderDetail(
        provider: AdminProviderSummary.fromJson(json),
        stats: AdminProviderStats.fromJson(
          Map<String, dynamic>.from(json['stats'] as Map? ?? const {}),
        ),
        products: (json['products'] as List? ?? const [])
            .map(
              (item) => AdminProviderProduct.fromJson(
                Map<String, dynamic>.from(item as Map),
              ),
            )
            .toList(growable: false),
      );

  final AdminProviderSummary provider;
  final AdminProviderStats stats;
  final List<AdminProviderProduct> products;

  @override
  List<Object?> get props => [provider, stats, products];
}

DateTime _parseDate(Object? value) => switch (value) {
  int milliseconds => DateTime.fromMillisecondsSinceEpoch(milliseconds),
  num milliseconds => DateTime.fromMillisecondsSinceEpoch(milliseconds.toInt()),
  String raw =>
    DateTime.tryParse(raw) ?? DateTime.fromMillisecondsSinceEpoch(0),
  _ => DateTime.fromMillisecondsSinceEpoch(0),
};
