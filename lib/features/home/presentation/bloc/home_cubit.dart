import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../events/domain/entities/community_event.dart';
import '../../../events/domain/repositories/community_events_repository.dart';
import '../../domain/entities/home_data.dart';
import 'home_state.dart';

@injectable
class HomeCubit extends Cubit<HomeState> {
  HomeCubit(this._eventsRepository) : super(HomeLoading());

  final CommunityEventsRepository _eventsRepository;

  Future<void> loadHomeData() async {
    emit(HomeLoading());
    try {
      final events = await _eventsRepository.getEvents(EventTimeframe.upcoming);

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

      final announcements = [
        Announcement(
          id: '1',
          title: 'Penyesuaian Jadwal Keamanan Malam',
          author: 'Oleh: Sekretaris RT 04',
          description:
              'Sehubungan dengan perbaikan gerbang utama, jadwal ronda malam untuk minggu...',
          tag: 'Mendesak',
          imageUrl:
              'https://images.pexels.com/photos/5686082/pexels-photo-5686082.jpeg', // Mock image
        ),
      ];

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
