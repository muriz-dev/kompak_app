import 'package:equatable/equatable.dart';

import '../../domain/entities/store_data.dart';

abstract class StoreState extends Equatable {
  const StoreState();

  @override
  List<Object?> get props => [];
}

class StoreLoading extends StoreState {}

class StoreLoaded extends StoreState {
  const StoreLoaded({
    required this.stats,
    required this.categories,
    required this.activeCategoryId,
    required this.allItems,
    this.featuredItem,
    required this.regularItems,
  });

  factory StoreLoaded.fromItems({
    required StoreStats stats,
    required List<StoreCategory> categories,
    required String activeCategoryId,
    required List<StoreItem> allItems,
  }) {
    final visibleItems = activeCategoryId == 'all'
        ? allItems
        : allItems
              .where((item) => item.rewardType.apiValue == activeCategoryId)
              .toList(growable: false);
    final featuredItems = visibleItems.where((item) => item.isFeatured);
    final featured = featuredItems.isEmpty ? null : featuredItems.first;

    return StoreLoaded(
      stats: stats,
      categories: categories,
      activeCategoryId: activeCategoryId,
      allItems: allItems,
      featuredItem: featured,
      regularItems: featured == null
          ? visibleItems
          : visibleItems.where((item) => item.id != featured.id).toList(),
    );
  }

  final StoreStats stats;
  final List<StoreCategory> categories;
  final String activeCategoryId;
  final List<StoreItem> allItems;
  final StoreItem? featuredItem;
  final List<StoreItem> regularItems;

  StoreLoaded withCategory(String categoryId) => StoreLoaded.fromItems(
    stats: stats,
    categories: categories,
    activeCategoryId: categoryId,
    allItems: allItems,
  );

  @override
  List<Object?> get props => [
    stats,
    categories,
    activeCategoryId,
    allItems,
    featuredItem,
    regularItems,
  ];
}

class StoreError extends StoreState {
  const StoreError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
