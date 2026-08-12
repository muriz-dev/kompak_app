import '../entities/admin_provider.dart';

abstract class AdminProvidersRepository {
  Future<AdminProviderPage> getProviders({
    String query = '',
    AdminProviderStatus? status,
    int page = 1,
    int pageSize = 4,
  });

  Future<AdminProviderDetail> getProviderDetail(String providerId);

  Future<void> updateStatus(String providerId, AdminProviderStatus status);
}
