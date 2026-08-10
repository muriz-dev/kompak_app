import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/admin_event.dart';
import '../../domain/entities/admin_event_overview.dart';
import '../../domain/entities/create_admin_event_request.dart';
import '../../domain/entities/update_admin_event_request.dart';

abstract class AdminEventsRemoteDataSource {
  Future<List<AdminEvent>> getEvents();

  Future<AdminEvent> createEvent(CreateAdminEventRequest request);

  Future<AdminEventOverview> getEventOverview(String eventId);

  Future<AdminEvent> updateEvent(
    String eventId,
    UpdateAdminEventRequest request,
  );

  Future<void> deleteEvent(String eventId);

  Future<AdminEvent> updateEventStatus(
    String eventId,
    AdminEventRecordStatus status,
  );
}

@LazySingleton(as: AdminEventsRemoteDataSource)
class AdminEventsRemoteDataSourceImpl implements AdminEventsRemoteDataSource {
  AdminEventsRemoteDataSourceImpl(this._dio) : _uploadDio = Dio();

  AdminEventsRemoteDataSourceImpl.withUploadDio(this._dio, this._uploadDio);

  final Dio _dio;
  final Dio _uploadDio;

  @override
  Future<AdminEvent> createEvent(CreateAdminEventRequest request) async {
    final bannerUrl = request.poster == null
        ? null
        : await _uploadPoster(request.poster!);

    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/events',
        data: {
          'title': request.title.trim(),
          'description': request.description.trim(),
          'eventDate': request.eventDate.toUtc().toIso8601String(),
          'attendanceStartTime': request.attendanceStartTime
              .toUtc()
              .toIso8601String(),
          'attendanceEndTime': request.attendanceEndTime
              .toUtc()
              .toIso8601String(),
          'rewardPoints': request.rewardPoints,
          'latitude': request.latitude,
          'longitude': request.longitude,
          'radiusMeters': request.radiusMeters,
          'status': request.status.apiValue,
          'bannerUrl': ?bannerUrl,
        },
      );
      final data = response.data;
      if (data == null || data['success'] != true || data['data'] is! Map) {
        throw const FormatException('Invalid event creation response');
      }

      return AdminEvent.fromJson(
        Map<String, dynamic>.from(data['data'] as Map),
      );
    } on DioException catch (error) {
      throw Exception(_message(error, fallback: 'Gagal membuat kegiatan.'));
    }
  }

  @override
  Future<List<AdminEvent>> getEvents() async {
    try {
      final response = await _dio.get('/events/admin');
      final data = response.data;
      if (data is! Map || data['success'] != true || data['data'] is! List) {
        throw const FormatException('Invalid admin events response');
      }

      return (data['data'] as List)
          .map(
            (item) =>
                AdminEvent.fromJson(Map<String, dynamic>.from(item as Map)),
          )
          .toList(growable: false);
    } on DioException catch (error) {
      throw Exception(_message(error));
    }
  }

  @override
  Future<AdminEventOverview> getEventOverview(String eventId) async {
    try {
      final responses = await Future.wait([
        _dio.get<Map<String, dynamic>>('/events/admin/$eventId'),
        _dio.get<Map<String, dynamic>>('/attendances/event/$eventId'),
        _dio.get<Map<String, dynamic>>(
          '/users',
          queryParameters: {'status': 'ACTIVE'},
        ),
      ]);

      final eventData = _responseData(responses[0], 'admin event detail');
      final attendanceData = _responseData(responses[1], 'event attendances');
      final userData = _responseData(responses[2], 'active citizens');
      if (eventData is! Map || attendanceData is! List || userData is! List) {
        throw const FormatException('Invalid admin event overview response');
      }

      final attendances = attendanceData
          .map(
            (item) => AdminEventAttendance.fromJson(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList(growable: false);
      final activeCitizenCount = userData.where((item) {
        final user = item as Map;
        return user['role'] == 'CITIZEN' && user['status'] == 'ACTIVE';
      }).length;

      return AdminEventOverview(
        event: AdminEvent.fromJson(Map<String, dynamic>.from(eventData)),
        attendances: attendances,
        activeCitizenCount: activeCitizenCount,
      );
    } on DioException catch (error) {
      throw Exception(
        _message(error, fallback: 'Gagal memuat detail kegiatan.'),
      );
    }
  }

  @override
  Future<AdminEvent> updateEvent(
    String eventId,
    UpdateAdminEventRequest request,
  ) async {
    final bannerUrl = request.poster == null
        ? request.existingBannerUrl
        : await _uploadPoster(request.poster!);
    try {
      final response = await _dio.put<Map<String, dynamic>>(
        '/events/$eventId',
        data: {
          'title': request.title.trim(),
          'description': request.description.trim(),
          'eventDate': request.eventDate.toUtc().toIso8601String(),
          'attendanceStartTime': request.attendanceStartTime
              .toUtc()
              .toIso8601String(),
          'attendanceEndTime': request.attendanceEndTime
              .toUtc()
              .toIso8601String(),
          'rewardPoints': request.rewardPoints,
          'latitude': request.latitude,
          'longitude': request.longitude,
          'radiusMeters': request.radiusMeters,
          'bannerUrl': ?bannerUrl,
        },
      );
      final data = _responseData(response, 'event update');
      if (data is! Map) {
        throw const FormatException('Invalid event update response');
      }
      return AdminEvent.fromJson(Map<String, dynamic>.from(data));
    } on DioException catch (error) {
      throw Exception(
        _message(error, fallback: 'Gagal menyimpan perubahan kegiatan.'),
      );
    }
  }

  @override
  Future<void> deleteEvent(String eventId) async {
    try {
      final response = await _dio.delete<Map<String, dynamic>>(
        '/events/$eventId',
      );
      final data = response.data;
      if (data == null || data['success'] != true) {
        throw const FormatException('Invalid event deletion response');
      }
    } on DioException catch (error) {
      throw Exception(_message(error, fallback: 'Gagal menghapus kegiatan.'));
    }
  }

  @override
  Future<AdminEvent> updateEventStatus(
    String eventId,
    AdminEventRecordStatus status,
  ) async {
    try {
      final response = await _dio.patch<Map<String, dynamic>>(
        '/events/$eventId',
        data: {'status': status.apiValue},
      );
      final data = response.data;
      if (data == null || data['success'] != true || data['data'] is! Map) {
        throw const FormatException('Invalid event update response');
      }

      return AdminEvent.fromJson(
        Map<String, dynamic>.from(data['data'] as Map),
      );
    } on DioException catch (error) {
      throw Exception(
        _message(error, fallback: 'Gagal mengubah status kegiatan.'),
      );
    }
  }

  Future<String> _uploadPoster(EventPosterUpload poster) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/storage/upload-url',
        data: {
          'folder': 'events',
          'contentType': poster.contentType,
          'contentLength': poster.bytes.length,
        },
      );
      final data = response.data;
      final uploadData = data?['data'];
      if (data == null ||
          data['success'] != true ||
          uploadData is! Map ||
          uploadData['uploadUrl'] is! String ||
          uploadData['publicUrl'] is! String) {
        throw const FormatException('Invalid poster upload response');
      }

      await _uploadDio.put<void>(
        uploadData['uploadUrl'] as String,
        data: Stream<List<int>>.value(poster.bytes),
        options: Options(
          headers: {
            Headers.contentTypeHeader: poster.contentType,
            Headers.contentLengthHeader: poster.bytes.length,
          },
        ),
      );
      return uploadData['publicUrl'] as String;
    } on DioException catch (error) {
      throw Exception(_message(error, fallback: 'Gagal mengunggah poster.'));
    }
  }

  Object? _responseData(Response<Map<String, dynamic>> response, String name) {
    final body = response.data;
    if (body == null || body['success'] != true || !body.containsKey('data')) {
      throw FormatException('Invalid $name response');
    }
    return body['data'];
  }

  String _message(
    DioException error, {
    String fallback = 'Gagal memuat daftar kegiatan.',
  }) {
    final data = error.response?.data;
    return data is Map ? data['message']?.toString() ?? fallback : fallback;
  }
}
