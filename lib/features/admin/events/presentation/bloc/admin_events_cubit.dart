import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/admin_event.dart';
import '../../domain/repositories/admin_events_repository.dart';
import 'admin_events_state.dart';

@injectable
class AdminEventsCubit extends Cubit<AdminEventsState> {
  AdminEventsCubit(this._repository) : super(AdminEventsLoading());

  final AdminEventsRepository _repository;

  Future<void> loadEvents() async {
    emit(AdminEventsLoading());
    try {
      emit(AdminEventsLoaded(await _repository.getEvents()));
    } catch (error) {
      emit(AdminEventsLoadFailure(_message(error)));
    }
  }

  Future<String?> updateEventStatus(
    String eventId,
    AdminEventRecordStatus status,
  ) async {
    final current = state;
    if (current is! AdminEventsLoaded || current.updatingEventId != null) {
      return null;
    }

    emit(AdminEventsLoaded(current.events, updatingEventId: eventId));
    try {
      final updated = await _repository.updateEventStatus(eventId, status);
      emit(
        AdminEventsLoaded(
          current.events
              .map((event) => event.id == eventId ? updated : event)
              .toList(growable: false),
        ),
      );
      return null;
    } catch (error) {
      emit(current);
      return _message(error);
    }
  }

  String _message(Object error) => error.toString().replaceFirst(
    RegExp(r'^(Exception|FormatException):\s*'),
    '',
  );
}
