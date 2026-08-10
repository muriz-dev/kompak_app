import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/update_admin_event_request.dart';
import '../../domain/repositories/admin_events_repository.dart';
import 'edit_event_state.dart';

@injectable
class EditEventCubit extends Cubit<EditEventState> {
  EditEventCubit(this._repository) : super(const EditEventInitial());

  final AdminEventsRepository _repository;

  Future<void> updateEvent(
    String eventId,
    UpdateAdminEventRequest request,
  ) async {
    if (state is EditEventSubmitting || state is EditEventDeleting) return;
    emit(const EditEventSubmitting());
    try {
      emit(EditEventSuccess(await _repository.updateEvent(eventId, request)));
    } catch (error) {
      emit(EditEventFailure(_message(error)));
    }
  }

  Future<void> deleteEvent(String eventId) async {
    if (state is EditEventSubmitting || state is EditEventDeleting) return;
    emit(const EditEventDeleting());
    try {
      await _repository.deleteEvent(eventId);
      emit(const EditEventDeleted());
    } catch (error) {
      emit(EditEventFailure(_message(error)));
    }
  }

  String _message(Object error) => error.toString().replaceFirst(
    RegExp(r'^(Exception|FormatException):\s*'),
    '',
  );
}
