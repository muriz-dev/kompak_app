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
  Future<Resident> getResident(String residentId) =>
      _remoteDataSource.getResident(residentId);

  @override
  Future<Resident> createResident({
    required String name,
    required String phoneNumber,
    required String birthDate,
    required String email,
    required String password,
    required String faceImagePath,
  }) => _remoteDataSource.createResident(
    name: name,
    phoneNumber: phoneNumber,
    birthDate: birthDate,
    email: email,
    password: password,
    faceImagePath: faceImagePath,
  );

  @override
  Future<Resident> updateResident({
    required String residentId,
    required String name,
    required String phoneNumber,
    required String birthDate,
    required String email,
  }) => _remoteDataSource.updateResident(
    residentId: residentId,
    name: name,
    phoneNumber: phoneNumber,
    birthDate: birthDate,
    email: email,
  );

  @override
  Future<Resident> updateStatus(String residentId, ResidentStatus status) =>
      _remoteDataSource.updateStatus(residentId, status);
}
