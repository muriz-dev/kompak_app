import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/store_data.dart';
import '../../domain/repositories/point_shop_repository.dart';

sealed class RedeemState extends Equatable {
  const RedeemState();

  @override
  List<Object?> get props => [];
}

class RedeemInitial extends RedeemState {}

class RedeemSubmitting extends RedeemState {}

class RedeemSucceeded extends RedeemState {
  const RedeemSucceeded(this.redemption);
  final RewardRedemption redemption;

  @override
  List<Object?> get props => [redemption];
}

class RedeemFailed extends RedeemState {
  const RedeemFailed(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}

@injectable
class RedeemCubit extends Cubit<RedeemState> {
  RedeemCubit(this._repository) : super(RedeemInitial());

  final PointShopRepository _repository;
  late final String _idempotencyKey =
      'mobile-${DateTime.now().microsecondsSinceEpoch.toRadixString(36)}';

  Future<void> redeem(StoreItem item) async {
    if (state is RedeemSubmitting || state is RedeemSucceeded) return;
    emit(RedeemSubmitting());
    try {
      final redemption = await _repository.redeem(
        item: item,
        idempotencyKey: _idempotencyKey,
      );
      emit(RedeemSucceeded(redemption));
    } catch (error) {
      emit(RedeemFailed(error.toString().replaceFirst('Exception: ', '')));
    }
  }
}
