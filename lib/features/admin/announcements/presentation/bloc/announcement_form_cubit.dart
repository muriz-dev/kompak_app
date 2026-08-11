import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../announcements/domain/repositories/announcements_repository.dart';
import 'announcement_form_state.dart';

@injectable
class AnnouncementFormCubit extends Cubit<AnnouncementFormState> {
  AnnouncementFormCubit(this._repository) : super(AnnouncementFormInitial());

  final AnnouncementsRepository _repository;

  Future<void> create({
    required String title,
    required String description,
  }) async {
    if (_busy) return;
    emit(AnnouncementFormSubmitting());
    try {
      await _repository.createAnnouncement(
        title: title,
        description: description,
      );
      emit(const AnnouncementFormSuccess(deleted: false));
    } catch (error) {
      emit(AnnouncementFormFailure(_message(error)));
    }
  }

  Future<void> update({
    required String announcementId,
    required String title,
    required String description,
  }) async {
    if (_busy) return;
    emit(AnnouncementFormSubmitting());
    try {
      await _repository.updateAnnouncement(
        announcementId: announcementId,
        title: title,
        description: description,
      );
      emit(const AnnouncementFormSuccess(deleted: false));
    } catch (error) {
      emit(AnnouncementFormFailure(_message(error)));
    }
  }

  Future<void> delete(String announcementId) async {
    if (_busy) return;
    emit(AnnouncementFormDeleting());
    try {
      await _repository.deleteAnnouncement(announcementId);
      emit(const AnnouncementFormSuccess(deleted: true));
    } catch (error) {
      emit(AnnouncementFormFailure(_message(error)));
    }
  }

  bool get _busy =>
      state is AnnouncementFormSubmitting || state is AnnouncementFormDeleting;

  String _message(Object error) => error.toString().replaceFirst(
    RegExp(r'^(Exception|FormatException):\s*'),
    '',
  );
}
