import 'package:equatable/equatable.dart';
import '../../domain/entities/store_data.dart';

abstract class StoreState extends Equatable {
  const StoreState();

  @override
  List<Object?> get props => [];
}

class StoreLoading extends StoreState {}

class StoreLoaded extends StoreState {
  final StoreStats stats;
  final List<StoreCategory> categories;
  final String activeCategoryId;
  final StoreItem? featuredItem;
  final List<StoreItem> regularItems;

  const StoreLoaded({
    required this.stats,
    required this.categories,
    required this.activeCategoryId,
    this.featuredItem,
    required this.regularItems,
  });

  StoreLoaded copyWith({
    StoreStats? stats,
    List<StoreCategory>? categories,
    String? activeCategoryId,
    StoreItem? featuredItem,
    List<StoreItem>? regularItems,
  }) {
    return StoreLoaded(
      stats: stats ?? this.stats,
      categories: categories ?? this.categories,
      activeCategoryId: activeCategoryId ?? this.activeCategoryId,
      featuredItem: featuredItem ?? this.featuredItem,
      regularItems: regularItems ?? this.regularItems,
    );
  }

  @override
  List<Object?> get props => [stats, categories, activeCategoryId, featuredItem, regularItems];
}

class StoreError extends StoreState {
  final String message;

  const StoreError(this.message);

  @override
  List<Object?> get props => [message];
}
