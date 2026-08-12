import 'package:equatable/equatable.dart';

import '../../domain/entities/admin_point_shop_product.dart';

sealed class AdminPointShopState extends Equatable {
  const AdminPointShopState();

  @override
  List<Object?> get props => [];
}

class AdminPointShopLoading extends AdminPointShopState {}

class AdminPointShopLoaded extends AdminPointShopState {
  const AdminPointShopLoaded({
    required this.data,
    required this.status,
    required this.query,
    required this.type,
    this.updatingProductId,
    this.actionMessage,
  });

  final AdminPointShopProductPage data;
  final AdminPointShopProductStatus status;
  final String query;
  final AdminPointShopProductType? type;
  final String? updatingProductId;
  final String? actionMessage;

  AdminPointShopLoaded copyWith({
    AdminPointShopProductPage? data,
    String? updatingProductId,
    bool clearUpdatingProduct = false,
    String? actionMessage,
    bool clearActionMessage = false,
  }) => AdminPointShopLoaded(
    data: data ?? this.data,
    status: status,
    query: query,
    type: type,
    updatingProductId: clearUpdatingProduct
        ? null
        : updatingProductId ?? this.updatingProductId,
    actionMessage: clearActionMessage
        ? null
        : actionMessage ?? this.actionMessage,
  );

  @override
  List<Object?> get props => [
    data,
    status,
    query,
    type,
    updatingProductId,
    actionMessage,
  ];
}

class AdminPointShopFailure extends AdminPointShopState {
  const AdminPointShopFailure(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}
