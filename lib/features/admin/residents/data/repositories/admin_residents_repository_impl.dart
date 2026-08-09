import 'package:injectable/injectable.dart';

import '../../domain/entities/resident.dart';
import '../../domain/repositories/admin_residents_repository.dart';
import '../datasources/admin_residents_remote_data_source.dart';

@LazySingleton(as: AdminResidentsRepository)
class AdminResidentsRepositoryImpl implements AdminResidentsRepository {
  const AdminResidentsRepositoryImpl(this._remoteDataSource);

  final AdminResidentsRemoteDataSource _remoteDataSource;

  @override
  Future<List<Resident>> getResidents() => _remoteDataSource.getResidents();

  @override
  Future<Resident> updateStatus(String residentId, ResidentStatus status) =>
      _remoteDataSource.updateStatus(residentId, status);
}
