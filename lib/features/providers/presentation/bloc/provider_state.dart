part of 'provider_cubit.dart';

sealed class ProviderState {
  const ProviderState();
}

class ProviderLoading extends ProviderState {
  const ProviderLoading();
}

class ProviderNotRegistered extends ProviderState {
  const ProviderNotRegistered();
}

class ProviderAwaitingReview extends ProviderState {
  const ProviderAwaitingReview(this.account);
  final ProviderAccount account;
}

class ProviderReady extends ProviderState {
  const ProviderReady({
    required this.account,
    required this.products,
    this.query = '',
    this.loadingProducts = false,
    this.actionError,
  });

  final ProviderAccount account;
  final List<ProviderProduct> products;
  final String query;
  final bool loadingProducts;
  final String? actionError;

  ProviderReady copyWith({
    ProviderAccount? account,
    List<ProviderProduct>? products,
    String? query,
    bool? loadingProducts,
    String? actionError,
  }) => ProviderReady(
    account: account ?? this.account,
    products: products ?? this.products,
    query: query ?? this.query,
    loadingProducts: loadingProducts ?? false,
    actionError: actionError,
  );
}

class ProviderSubmitting extends ProviderState {
  const ProviderSubmitting({required this.previous});
  final ProviderState previous;
}

class ProviderFormFailure extends ProviderState {
  const ProviderFormFailure({required this.previous, required this.message});
  final ProviderState previous;
  final String message;
}

class ProviderFailure extends ProviderState {
  const ProviderFailure(this.message);
  final String message;
}
