import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/community_event.dart';

abstract class CommunityEventsRemoteDataSource {
  Future<List<CommunityEvent>> getEvents(EventTimeframe timeframe);

  Future<CommunityEvent> getEvent(String eventId);
}

@LazySingleton(as: CommunityEventsRemoteDataSource)
class CommunityEventsRemoteDataSourceImpl
    implements CommunityEventsRemoteDataSource {
  CommunityEventsRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<List<CommunityEvent>> getEvents(EventTimeframe timeframe) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/events',
        queryParameters: {'timeframe': timeframe.apiValue},
      );
      final payload = response.data;
      if (payload == null ||
          payload['success'] != true ||
          payload['data'] is! List) {
        throw const FormatException('Invalid events response');
      }

      return (payload['data'] as List)
          .map(
            (item) =>
                CommunityEvent.fromJson(Map<String, dynamic>.from(item as Map)),
          )
          .toList(growable: false);
    } on DioException catch (error) {
      throw Exception(_message(error, 'Gagal memuat kegiatan.'));
    }
  }

  @override
  Future<CommunityEvent> getEvent(String eventId) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>('/events/$eventId');
      final payload = response.data;
      if (payload == null ||
          payload['success'] != true ||
          payload['data'] is! Map) {
        throw const FormatException('Invalid event detail response');
      }

      return CommunityEvent.fromJson(
        Map<String, dynamic>.from(payload['data'] as Map),
      );
    } on DioException catch (error) {
      throw Exception(_message(error, 'Gagal memuat detail kegiatan.'));
    }
  }

  String _message(DioException error, String fallback) {
    final data = error.response?.data;
    return data is Map ? data['message']?.toString() ?? fallback : fallback;
  }
}
