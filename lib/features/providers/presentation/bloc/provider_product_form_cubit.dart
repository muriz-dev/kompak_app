import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/provider_account.dart';
import '../../domain/repositories/provider_repository.dart';

@injectable
class ProviderProductFormCubit extends Cubit<ProviderProductFormState> {
  ProviderProductFormCubit(this._repository)
    : super(const ProviderProductFormIdle());

  final ProviderRepository _repository;

  Future<bool> save({
    required String providerId,
    required ProviderProductDraft draft,
    ProviderProduct? product,
  }) async {
    emit(const ProviderProductFormSubmitting());
    try {
      if (product == null) {
        await _repository.createProduct(providerId, draft);
      } else {
        await _repository.updateProduct(product.id, providerId, draft);
      }
      emit(const ProviderProductFormSuccess());
      return true;
    } catch (error) {
      emit(ProviderProductFormFailure(_message(error)));
      return false;
    }
  }

  Future<bool> delete(String productId) async {
    emit(const ProviderProductFormSubmitting());
    try {
      await _repository.deleteProduct(productId);
      emit(const ProviderProductFormSuccess());
      return true;
    } catch (error) {
      emit(ProviderProductFormFailure(_message(error)));
      return false;
    }
  }

  String _message(Object error) => error.toString().replaceFirst(
    RegExp(r'^(Exception|FormatException):\s*'),
    '',
  );
}

sealed class ProviderProductFormState {
  const ProviderProductFormState();
}

class ProviderProductFormIdle extends ProviderProductFormState {
  const ProviderProductFormIdle();
}

class ProviderProductFormSubmitting extends ProviderProductFormState {
  const ProviderProductFormSubmitting();
}

class ProviderProductFormSuccess extends ProviderProductFormState {
  const ProviderProductFormSuccess();
}

class ProviderProductFormFailure extends ProviderProductFormState {
  const ProviderProductFormFailure(this.message);
  final String message;
}
