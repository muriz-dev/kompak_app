import '../entities/resident.dart';

abstract class AdminResidentsRepository {
  Future<List<Resident>> getResidents();
  Future<Resident> updateStatus(String residentId, ResidentStatus status);
}
