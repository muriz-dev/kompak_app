import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../announcements/domain/repositories/announcements_repository.dart';
import 'admin_announcements_state.dart';

@injectable
class AdminAnnouncementsCubit extends Cubit<AdminAnnouncementsState> {
  AdminAnnouncementsCubit(this._repository)
    : super(AdminAnnouncementsLoading());

  final AnnouncementsRepository _repository;

  Future<void> loadAnnouncements() async {
    emit(AdminAnnouncementsLoading());
    try {
      emit(AdminAnnouncementsLoaded(await _repository.getAnnouncements()));
    } catch (error) {
      emit(AdminAnnouncementsLoadFailure(_message(error)));
    }
  }

  String _message(Object error) => error.toString().replaceFirst(
    RegExp(r'^(Exception|FormatException):\s*'),
    '',
  );
}
