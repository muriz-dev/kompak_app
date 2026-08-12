import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/provider_account.dart';
import '../../domain/repositories/provider_repository.dart';

part 'provider_state.dart';

@injectable
class ProviderCubit extends Cubit<ProviderState> {
  ProviderCubit(this._repository) : super(const ProviderLoading());

  final ProviderRepository _repository;

  Future<void> load() async {
    emit(const ProviderLoading());
    try {
      final account = await _repository.getMyProvider();
      if (account == null) {
        emit(const ProviderNotRegistered());
      } else if (account.status == ProviderStatus.verified) {
        final products = await _repository.getMyProducts();
        emit(ProviderReady(account: account, products: products));
      } else {
        emit(ProviderAwaitingReview(account));
      }
    } catch (error) {
      emit(ProviderFailure(_message(error)));
    }
  }

  Future<bool> submitRegistration(ProviderRegistrationDraft draft) async {
    final current = state;
    emit(ProviderSubmitting(previous: current));
    try {
      final existing = switch (current) {
        ProviderAwaitingReview(:final account) => account,
        ProviderSubmitting(previous: ProviderAwaitingReview(:final account)) =>
          account,
        _ => null,
      };
      final account = existing == null
          ? await _repository.register(draft)
          : await _repository.updateRegistration(existing.id, draft);
      emit(ProviderAwaitingReview(account));
      return true;
    } catch (error) {
      emit(ProviderFormFailure(previous: current, message: _message(error)));
      return false;
    }
  }

  Future<void> search(String query) async {
    final current = state;
    if (current is! ProviderReady) return;
    emit(current.copyWith(loadingProducts: true, query: query));
    try {
      final products = await _repository.getMyProducts(query: query);
      emit(current.copyWith(products: products, query: query));
    } catch (error) {
      emit(
        current.copyWith(loadingProducts: false, actionError: _message(error)),
      );
    }
  }

  Future<void> refresh() => load();

  String _message(Object error) => error.toString().replaceFirst(
    RegExp(r'^(Exception|FormatException):\s*'),
    '',
  );
}
