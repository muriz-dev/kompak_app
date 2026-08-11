import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/store_data.dart';
import '../../domain/repositories/point_shop_repository.dart';
import 'store_state.dart';

@injectable
class StoreCubit extends Cubit<StoreState> {
  StoreCubit(this._repository) : super(StoreLoading());

  final PointShopRepository _repository;

  Future<void> loadStoreData() async {
    emit(StoreLoading());
    try {
      final data = await _repository.getCatalog();
      final categories = <StoreCategory>[
        const StoreCategory(id: 'all', name: 'Semua Item'),
        ...RewardType.values
            .where((type) => data.items.any((item) => item.rewardType == type))
            .map((type) => StoreCategory(id: type.apiValue, name: type.label)),
      ];

      emit(
        StoreLoaded.fromItems(
          stats: StoreStats(totalPoints: data.balance),
          categories: categories,
          activeCategoryId: 'all',
          allItems: data.items,
        ),
      );
    } catch (error) {
      emit(StoreError(_readableMessage(error)));
    }
  }

  void changeCategory(String categoryId) {
    final currentState = state;
    if (currentState is StoreLoaded) {
      emit(currentState.withCategory(categoryId));
    }
  }

  String _readableMessage(Object error) =>
      error.toString().replaceFirst('Exception: ', '');
}
