import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../domain/repositories/announcements_repository.dart';
import 'announcement_detail_state.dart';

@injectable
class AnnouncementDetailCubit extends Cubit<AnnouncementDetailState> {
  AnnouncementDetailCubit(this._repository)
    : super(AnnouncementDetailLoading());

  final AnnouncementsRepository _repository;

  Future<void> loadAnnouncement(
    String announcementId, {
    bool showLoading = true,
  }) async {
    if (showLoading) emit(AnnouncementDetailLoading());

    try {
      final announcement = await _repository.getAnnouncement(announcementId);
      emit(AnnouncementDetailLoaded(announcement));
    } catch (error) {
      emit(AnnouncementDetailError(_message(error)));
    }
  }

  String _message(Object error) => error.toString().replaceFirst(
    RegExp(r'^(Exception|FormatException):\s*'),
    '',
  );
}
