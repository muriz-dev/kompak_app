import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/create_admin_event_request.dart';
import '../../domain/repositories/admin_events_repository.dart';
import 'create_event_state.dart';

@injectable
class CreateEventCubit extends Cubit<CreateEventState> {
  CreateEventCubit(this._repository) : super(CreateEventInitial());

  final AdminEventsRepository _repository;

  Future<void> createEvent(CreateAdminEventRequest request) async {
    if (state is CreateEventSubmitting) return;

    emit(CreateEventSubmitting());
    try {
      emit(CreateEventSuccess(await _repository.createEvent(request)));
    } catch (error) {
      emit(CreateEventFailure(_message(error)));
    }
  }

  void reset() => emit(CreateEventInitial());

  String _message(Object error) => error.toString().replaceFirst(
    RegExp(r'^(Exception|FormatException):\s*'),
    '',
  );
}
