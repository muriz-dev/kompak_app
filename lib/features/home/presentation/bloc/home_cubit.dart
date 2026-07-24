import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../domain/entities/home_data.dart';
import 'home_state.dart';

@injectable
class HomeCubit extends Cubit<HomeState> {
  HomeCubit() : super(HomeLoading());

  void loadHomeData() async {
    emit(HomeLoading());
    try {
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));

      // Mock Data
      final userSummary = UserSummary(
        name: 'Pak Budi',
        points: 1250,
        level: 'Warga Aktif',
        pointsToNextLevel: 150,
        levelProgress: 1250 / 1400, // Just a rough calculation for UI
      );

      final upcomingActivities = [
        UpcomingActivity(
          id: '1',
          title: 'Rapat Triwulan RT',
          date: DateTime(2026, 11, 15, 19, 30),
          tag: 'PENTING',
          isImportant: true,
        ),
        UpcomingActivity(
          id: '2',
          title: 'Kerja Bakti',
          date: DateTime(2026, 11, 20, 8, 0),
          tag: 'INFO',
          isImportant: false,
        ),
      ];

      final announcements = [
        Announcement(
          id: '1',
          title: 'Penyesuaian Jadwal Keamanan Malam',
          author: 'Oleh: Sekretaris RT 04',
          description:
              'Sehubungan dengan perbaikan gerbang utama, jadwal ronda malam untuk minggu...',
          tag: 'Mendesak',
          imageUrl: 'https://via.placeholder.com/400x200', // Mock image
        ),
      ];

      emit(HomeLoaded(
        userSummary: userSummary,
        upcomingActivities: upcomingActivities,
        announcements: announcements,
      ));
    } catch (e) {
      emit(HomeError(e.toString()));
    }
  }
}
