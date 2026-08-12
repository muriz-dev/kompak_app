import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/resident.dart';
import '../../domain/repositories/admin_residents_repository.dart';
import 'admin_resident_form_state.dart';

@injectable
class AdminResidentFormCubit extends Cubit<AdminResidentFormState> {
  AdminResidentFormCubit(this._repository) : super(AdminResidentFormIdle());

  final AdminResidentsRepository _repository;

  Future<bool> save({
    Resident? resident,
    required String name,
    required String phoneNumber,
    required String birthDate,
    required String email,
    String? password,
    String? faceImagePath,
  }) async {
    emit(AdminResidentFormSubmitting());
    try {
      final saved = resident == null
          ? await _repository.createResident(
              name: name,
              phoneNumber: phoneNumber,
              birthDate: birthDate,
              email: email,
              password: password!,
              faceImagePath: faceImagePath!,
            )
          : await _repository.updateResident(
              residentId: resident.id,
              name: name,
              phoneNumber: phoneNumber,
              birthDate: birthDate,
              email: email,
            );
      emit(AdminResidentFormSuccess(saved));
      return true;
    } catch (error) {
      emit(AdminResidentFormFailure(_message(error)));
      return false;
    }
  }

  String _message(Object error) => error.toString().replaceFirst(
    RegExp(r'^(Exception|FormatException):\s*'),
    '',
  );
}
