import 'package:injectable/injectable.dart';

import '../../domain/entities/admin_provider.dart';
import '../../domain/repositories/admin_providers_repository.dart';
import '../datasources/admin_providers_remote_data_source.dart';

@LazySingleton(as: AdminProvidersRepository)
class AdminProvidersRepositoryImpl implements AdminProvidersRepository {
  const AdminProvidersRepositoryImpl(this._remoteDataSource);

  final AdminProvidersRemoteDataSource _remoteDataSource;

  @override
  Future<AdminProviderPage> getProviders({
    String query = '',
    AdminProviderStatus? status,
    int page = 1,
    int pageSize = 4,
  }) => _remoteDataSource.getProviders(
    query: query,
    status: status,
    page: page,
    pageSize: pageSize,
  );

  @override
  Future<AdminProviderDetail> getProviderDetail(String providerId) =>
      _remoteDataSource.getProviderDetail(providerId);

  @override
  Future<void> updateStatus(String providerId, AdminProviderStatus status) =>
      _remoteDataSource.updateStatus(providerId, status);
}
