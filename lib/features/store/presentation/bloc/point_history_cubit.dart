import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/store_data.dart';
import '../../domain/repositories/point_shop_repository.dart';

enum PointHistoryFilter { all, incoming, outgoing }

sealed class PointHistoryState extends Equatable {
  const PointHistoryState();
  @override
  List<Object?> get props => [];
}

class PointHistoryLoading extends PointHistoryState {}

class PointHistoryLoaded extends PointHistoryState {
  const PointHistoryLoaded({
    required this.balance,
    required this.entries,
    required this.pendingRedemptions,
    this.filter = PointHistoryFilter.all,
  });

  final int balance;
  final List<PointHistoryEntry> entries;
  final List<RewardRedemption> pendingRedemptions;
  final PointHistoryFilter filter;

  List<PointHistoryEntry> get visibleEntries => switch (filter) {
    PointHistoryFilter.all => entries,
    PointHistoryFilter.incoming =>
      entries
          .where((entry) => entry.direction == PointDirection.incoming)
          .toList(growable: false),
    PointHistoryFilter.outgoing =>
      entries
          .where((entry) => entry.direction == PointDirection.outgoing)
          .toList(growable: false),
  };

  PointHistoryLoaded copyWith({PointHistoryFilter? filter}) =>
      PointHistoryLoaded(
        balance: balance,
        entries: entries,
        pendingRedemptions: pendingRedemptions,
        filter: filter ?? this.filter,
      );

  @override
  List<Object?> get props => [balance, entries, pendingRedemptions, filter];
}

class PointHistoryError extends PointHistoryState {
  const PointHistoryError(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}

@injectable
class PointHistoryCubit extends Cubit<PointHistoryState> {
  PointHistoryCubit(this._repository) : super(PointHistoryLoading());

  final PointShopRepository _repository;

  Future<void> load() async {
    emit(PointHistoryLoading());
    try {
      final data = await _repository.getPointHistory();
      emit(
        PointHistoryLoaded(
          balance: data.balance,
          entries: data.entries,
          pendingRedemptions: data.pendingRedemptions,
        ),
      );
    } catch (error) {
      emit(PointHistoryError(error.toString().replaceFirst('Exception: ', '')));
    }
  }

  void changeFilter(PointHistoryFilter filter) {
    final current = state;
    if (current is PointHistoryLoaded) emit(current.copyWith(filter: filter));
  }
}
