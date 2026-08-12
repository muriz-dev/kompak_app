import '../entities/provider_account.dart';

abstract class ProviderRepository {
  Future<ProviderAccount?> getMyProvider();

  Future<List<ProviderProduct>> getMyProducts({
    String query = '',
    int page = 1,
    int pageSize = 50,
  });

  Future<ProviderAccount> register(ProviderRegistrationDraft draft);

  Future<ProviderAccount> updateRegistration(
    String providerId,
    ProviderRegistrationDraft draft,
  );

  Future<ProviderProduct> createProduct(
    String providerId,
    ProviderProductDraft draft,
  );

  Future<ProviderProduct> updateProduct(
    String productId,
    String providerId,
    ProviderProductDraft draft,
  );

  Future<void> deleteProduct(String productId);
}
