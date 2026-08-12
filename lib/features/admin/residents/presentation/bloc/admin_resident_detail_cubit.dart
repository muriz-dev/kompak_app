import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/resident.dart';
import '../../domain/repositories/admin_residents_repository.dart';
import 'admin_resident_detail_state.dart';

@injectable
class AdminResidentDetailCubit extends Cubit<AdminResidentDetailState> {
  AdminResidentDetailCubit(this._repository)
    : super(AdminResidentDetailLoading());

  final AdminResidentsRepository _repository;

  Future<void> loadResident(
    String residentId, {
    bool showLoading = true,
  }) async {
    if (showLoading) emit(AdminResidentDetailLoading());
    try {
      emit(
        AdminResidentDetailLoaded(
          resident: await _repository.getResident(residentId),
        ),
      );
    } catch (error) {
      emit(AdminResidentDetailFailure(_message(error)));
    }
  }

  Future<bool> updateStatus(ResidentStatus status) async {
    final current = state;
    if (current is! AdminResidentDetailLoaded || current.updatingStatus) {
      return false;
    }

    emit(current.copyWith(updatingStatus: true, clearActionError: true));
    try {
      final resident = await _repository.updateStatus(
        current.resident.id,
        status,
      );
      emit(
        current.copyWith(
          resident: resident,
          updatingStatus: false,
          clearActionError: true,
        ),
      );
      return true;
    } catch (error) {
      emit(
        current.copyWith(updatingStatus: false, actionError: _message(error)),
      );
      return false;
    }
  }

  String _message(Object error) => error.toString().replaceFirst(
    RegExp(r'^(Exception|FormatException):\s*'),
    '',
  );
}
