import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../domain/repositories/community_events_repository.dart';
import 'activity_detail_state.dart';

@injectable
class ActivityDetailCubit extends Cubit<ActivityDetailState> {
  ActivityDetailCubit(this._repository) : super(ActivityDetailLoading());

  final CommunityEventsRepository _repository;

  Future<void> loadEvent(String eventId) async {
    emit(ActivityDetailLoading());
    try {
      emit(ActivityDetailLoaded(await _repository.getEvent(eventId)));
    } catch (error) {
      emit(ActivityDetailError(_message(error)));
    }
  }

  String _message(Object error) => error.toString().replaceFirst(
    RegExp(r'^(Exception|FormatException):\s*'),
    '',
  );
}
