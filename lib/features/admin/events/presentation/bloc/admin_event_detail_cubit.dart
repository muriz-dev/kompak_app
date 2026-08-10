import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../domain/repositories/admin_events_repository.dart';
import 'admin_event_detail_state.dart';

@injectable
class AdminEventDetailCubit extends Cubit<AdminEventDetailState> {
  AdminEventDetailCubit(this._repository)
    : super(const AdminEventDetailLoading());

  final AdminEventsRepository _repository;

  Future<void> loadEvent(String eventId) async {
    emit(const AdminEventDetailLoading());
    try {
      emit(AdminEventDetailLoaded(await _repository.getEventOverview(eventId)));
    } catch (error) {
      emit(AdminEventDetailFailure(_message(error)));
    }
  }

  String _message(Object error) => error.toString().replaceFirst(
    RegExp(r'^(Exception|FormatException):\s*'),
    '',
  );
}
