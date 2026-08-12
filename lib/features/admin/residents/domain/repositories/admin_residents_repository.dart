import '../entities/resident.dart';

abstract class AdminResidentsRepository {
  Future<List<Resident>> getResidents();
  Future<Resident> getResident(String residentId);
  Future<Resident> createResident({
    required String name,
    required String phoneNumber,
    required String birthDate,
    required String email,
    required String password,
    required String faceImagePath,
  });
  Future<Resident> updateResident({
    required String residentId,
    required String name,
    required String phoneNumber,
    required String birthDate,
    required String email,
  });
  Future<Resident> updateStatus(String residentId, ResidentStatus status);
}
