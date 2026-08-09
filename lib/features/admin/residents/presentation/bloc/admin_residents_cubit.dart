import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/resident.dart';
import '../../domain/repositories/admin_residents_repository.dart';
import 'admin_residents_state.dart';

@injectable
class AdminResidentsCubit extends Cubit<AdminResidentsState> {
  AdminResidentsCubit(this._repository) : super(AdminResidentsLoading());

  final AdminResidentsRepository _repository;

  Future<void> loadResidents() async {
    emit(AdminResidentsLoading());
    try {
      emit(AdminResidentsLoaded(residents: await _repository.getResidents()));
    } catch (error) {
      emit(AdminResidentsLoadFailure(_message(error)));
    }
  }

  Future<bool> updateStatus(Resident resident, ResidentStatus status) async {
    final current = state;
    if (current is! AdminResidentsLoaded ||
        current.updatingIds.contains(resident.id)) {
      return false;
    }

    emit(
      current.copyWith(
        updatingIds: {...current.updatingIds, resident.id},
        clearActionError: true,
      ),
    );
    try {
      final updated = await _repository.updateStatus(resident.id, status);
      emit(
        current.copyWith(
          residents: [
            for (final item in current.residents)
              if (item.id == updated.id) updated else item,
          ],
          updatingIds: {...current.updatingIds}..remove(resident.id),
          clearActionError: true,
        ),
      );
      return true;
    } catch (error) {
      emit(
        current.copyWith(
          updatingIds: {...current.updatingIds}..remove(resident.id),
          actionError: _message(error),
        ),
      );
      return false;
    }
  }

  String _message(Object error) => error.toString().replaceFirst(
    RegExp(r'^(Exception|FormatException):\s*'),
    '',
  );
}
