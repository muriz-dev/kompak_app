import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../domain/entities/leaderboard_data.dart';
import 'leaderboard_state.dart';

@injectable
class LeaderboardCubit extends Cubit<LeaderboardState> {
  LeaderboardCubit() : super(LeaderboardLoading());

  void loadLeaderboardData() async {
    emit(LeaderboardLoading());
    try {
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));

      final winners = [
        LeaderboardWinner(
          id: '1',
          name: 'Budi Santoso',
          avatarUrl: 'https://i.pravatar.cc/150?img=11',
          points: 1500,
          rank: 1,
        ),
        LeaderboardWinner(
          id: '2',
          name: 'Siti Aminah',
          avatarUrl: 'https://i.pravatar.cc/150?img=5',
          points: 1400,
          rank: 2,
        ),
        LeaderboardWinner(
          id: '3',
          name: 'Andi Wijaya',
          avatarUrl: 'https://i.pravatar.cc/150?img=12',
          points: 1000,
          rank: 3,
        ),
      ];

      final rewards = [
        LeaderboardReward(
          rank: 1,
          title: 'Voucher Belanja Rp 500.000',
          description: '+ E-Sertifikat Warga Teladan',
        ),
        LeaderboardReward(
          rank: 2,
          title: 'Voucher Belanja Rp 200.000',
          description: '+ E-Sertifikat Warga Teladan',
        ),
        LeaderboardReward(
          rank: 3,
          title: 'Voucher Belanja Rp 150.000',
          description: '+ E-Sertifikat Warga Teladan',
        ),
      ];

      final stats = LeaderboardStats(
        totalParticipation: 124,
        pointsCollected: '42.8K',
      );

      final otherEntries = [
        LeaderboardEntry(
          id: '4',
          name: 'Ibu Ratna',
          avatarUrl: 'https://i.pravatar.cc/150?img=9',
          location: 'RT 04 / RW 02',
          points: 1850,
          rank: 4,
        ),
        LeaderboardEntry(
          id: '5',
          name: 'Diana Putri',
          avatarUrl: 'https://i.pravatar.cc/150?img=1',
          location: 'RT 01 / RW 02',
          points: 1720,
          rank: 5,
        ),
        LeaderboardEntry(
          id: '6',
          name: 'Haji Mulyono',
          avatarUrl: 'https://i.pravatar.cc/150?img=33',
          location: 'RT 03 / RW 02',
          points: 1540,
          rank: 6,
        ),
        LeaderboardEntry(
          id: '7',
          name: 'Raka Pratama',
          avatarUrl: 'https://i.pravatar.cc/150?img=13',
          location: 'RT 04 / RW 02',
          points: 1490,
          rank: 7,
        ),
        LeaderboardEntry(
          id: '8',
          name: 'Maya Sari',
          avatarUrl: 'https://i.pravatar.cc/150?img=10',
          location: 'RT 02 / RW 02',
          points: 1210,
          rank: 8,
        ),
      ];

      final currentUser = LeaderboardEntry(
        id: 'user_current',
        name: 'PERINGKAT ANDA',
        avatarUrl: 'https://i.pravatar.cc/150?img=60',
        location: '', // Not shown in banner
        points: 840,
        rank: 12, // e.g. 12 / 124
      );

      emit(LeaderboardLoaded(
        winners: winners,
        otherEntries: otherEntries,
        rewards: rewards,
        stats: stats,
        currentUserRank: currentUser,
      ));
    } catch (e) {
      emit(LeaderboardError(e.toString()));
    }
  }
}
