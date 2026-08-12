import 'package:injectable/injectable.dart';

import '../../domain/entities/provider_account.dart';
import '../../domain/repositories/provider_repository.dart';
import '../datasources/provider_remote_data_source.dart';

@LazySingleton(as: ProviderRepository)
class ProviderRepositoryImpl implements ProviderRepository {
  const ProviderRepositoryImpl(this._remote);
  final ProviderRemoteDataSource _remote;

  @override
  Future<ProviderAccount?> getMyProvider() => _remote.getMyProvider();

  @override
  Future<List<ProviderProduct>> getMyProducts({
    String query = '',
    int page = 1,
    int pageSize = 50,
  }) => _remote.getMyProducts(query: query, page: page, pageSize: pageSize);

  @override
  Future<ProviderAccount> register(ProviderRegistrationDraft draft) =>
      _remote.register(draft);

  @override
  Future<ProviderAccount> updateRegistration(
    String providerId,
    ProviderRegistrationDraft draft,
  ) => _remote.updateRegistration(providerId, draft);

  @override
  Future<ProviderProduct> createProduct(
    String providerId,
    ProviderProductDraft draft,
  ) => _remote.createProduct(providerId, draft);

  @override
  Future<ProviderProduct> updateProduct(
    String productId,
    String providerId,
    ProviderProductDraft draft,
  ) => _remote.updateProduct(productId, providerId, draft);

  @override
  Future<void> deleteProduct(String productId) =>
      _remote.deleteProduct(productId);
}
