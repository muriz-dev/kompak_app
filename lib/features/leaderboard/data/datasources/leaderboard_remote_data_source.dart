import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/leaderboard_data.dart';

abstract class LeaderboardRemoteDataSource {
  Future<LeaderboardData> getLeaderboard({int limit = 50});
}

@LazySingleton(as: LeaderboardRemoteDataSource)
class LeaderboardRemoteDataSourceImpl implements LeaderboardRemoteDataSource {
  const LeaderboardRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<LeaderboardData> getLeaderboard({int limit = 50}) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/leaderboard',
        queryParameters: {'limit': limit},
      );
      final payload = response.data;
      if (payload == null ||
          payload['success'] != true ||
          payload['data'] is! Map) {
        throw const FormatException('Invalid leaderboard response');
      }

      return LeaderboardData.fromJson(
        Map<String, dynamic>.from(payload['data'] as Map),
      );
    } on DioException catch (error) {
      throw Exception(_message(error));
    }
  }

  String _message(DioException error) {
    final data = error.response?.data;
    return data is Map
        ? data['message']?.toString() ?? 'Gagal memuat peringkat.'
        : 'Gagal memuat peringkat.';
  }
}
