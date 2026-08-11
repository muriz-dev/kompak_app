import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../announcements/domain/entities/community_announcement.dart';
import '../../../announcements/domain/repositories/announcements_repository.dart';
import '../../../events/domain/entities/community_event.dart';
import '../../../events/domain/repositories/community_events_repository.dart';
import '../../domain/entities/home_data.dart';
import 'home_state.dart';

@injectable
class HomeCubit extends Cubit<HomeState> {
  HomeCubit(this._eventsRepository, this._announcementsRepository)
    : super(HomeLoading());

  final CommunityEventsRepository _eventsRepository;
  final AnnouncementsRepository _announcementsRepository;

  Future<void> loadHomeData() async {
    emit(HomeLoading());
    try {
      final results = await Future.wait<Object>([
        _eventsRepository.getEvents(EventTimeframe.upcoming),
        _announcementsRepository.getAnnouncements(),
      ]);
      final events = results[0] as List<CommunityEvent>;
      final apiAnnouncements = results[1] as List<CommunityAnnouncement>;

      final upcomingActivities = events
          .map(
            (event) => UpcomingActivity(
              id: event.id,
              title: event.title,
              date: event.attendanceStartTime.toLocal(),
              tag: 'KEGIATAN',
            ),
          )
          .toList(growable: false);

      final announcements = apiAnnouncements
          .map(
            (announcement) => Announcement(
              id: announcement.id,
              title: announcement.title,
              author: 'Oleh: Pengurus RT',
              description: announcement.description,
              tag: '',
              imageUrl: '',
            ),
          )
          .toList(growable: false);

      emit(
        HomeLoaded(
          upcomingActivities: upcomingActivities,
          announcements: announcements,
        ),
      );
    } catch (error) {
      emit(HomeError(_message(error)));
    }
  }

  String _message(Object error) => error.toString().replaceFirst(
    RegExp(r'^(Exception|FormatException):\s*'),
    '',
  );
}
