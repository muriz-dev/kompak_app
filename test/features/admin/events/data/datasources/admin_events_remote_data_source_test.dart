import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kompak_app/features/admin/events/data/datasources/admin_events_remote_data_source.dart';
import 'package:kompak_app/features/admin/events/domain/entities/admin_event.dart';
import 'package:kompak_app/features/admin/events/domain/entities/create_admin_event_request.dart';

void main() {
  test('uploads the poster before creating a published event', () async {
    final apiAdapter = _EventCreationApiAdapter();
    final uploadAdapter = _PosterUploadAdapter();
    final apiDio = Dio(BaseOptions(baseUrl: 'https://api.kompak.test'))
      ..httpClientAdapter = apiAdapter;
    final uploadDio = Dio()..httpClientAdapter = uploadAdapter;
    final dataSource = AdminEventsRemoteDataSourceImpl.withUploadDio(
      apiDio,
      uploadDio,
    );
    final start = DateTime(2026, 8, 12, 19, 30);
    final end = DateTime(2026, 8, 12, 21, 30);

    final event = await dataSource.createEvent(
      CreateAdminEventRequest(
        title: '  Rapat Warga  ',
        description: '  Bahas keamanan lingkungan.  ',
        eventDate: start,
        attendanceStartTime: start,
        attendanceEndTime: end,
        rewardPoints: 50,
        latitude: -6.2,
        longitude: 106.816666,
        poster: EventPosterUpload(
          bytes: Uint8List.fromList([1, 2, 3, 4]),
          contentType: 'image/png',
        ),
      ),
    );

    expect(apiAdapter.requests.map((request) => request.path), [
      '/storage/upload-url',
      '/events',
    ]);
    expect(apiAdapter.uploadRequestBody, {
      'folder': 'events',
      'contentType': 'image/png',
      'contentLength': 4,
    });
    expect(uploadAdapter.request?.method, 'PUT');
    expect(uploadAdapter.request?.uri.toString(), 'https://upload.test/banner');
    expect(uploadAdapter.uploadedBytes, [1, 2, 3, 4]);
    expect(apiAdapter.createRequestBody?['title'], 'Rapat Warga');
    expect(
      apiAdapter.createRequestBody?['description'],
      'Bahas keamanan lingkungan.',
    );
    expect(apiAdapter.createRequestBody?['status'], 'PUBLISHED');
    expect(
      apiAdapter.createRequestBody?['bannerUrl'],
      'https://assets.test/events/banner.png',
    );
    expect(apiAdapter.createRequestBody?['latitude'], -6.2);
    expect(apiAdapter.createRequestBody?['longitude'], 106.816666);
    expect(event.status, AdminEventRecordStatus.published);
    expect(event.bannerUrl, 'https://assets.test/events/banner.png');
  });
}

class _EventCreationApiAdapter implements HttpClientAdapter {
  final requests = <RequestOptions>[];
  Map<String, dynamic>? uploadRequestBody;
  Map<String, dynamic>? createRequestBody;

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);

    if (options.method == 'POST' && options.path == '/storage/upload-url') {
      uploadRequestBody = Map<String, dynamic>.from(options.data as Map);
      return _jsonResponse({
        'success': true,
        'data': {
          'uploadUrl': 'https://upload.test/banner',
          'publicUrl': 'https://assets.test/events/banner.png',
          'key': 'events/banner.png',
        },
      }, 200);
    }

    if (options.method == 'POST' && options.path == '/events') {
      createRequestBody = Map<String, dynamic>.from(options.data as Map);
      return _jsonResponse({
        'success': true,
        'data': {
          'id': 'event-1',
          'createdBy': 'admin-1',
          ...createRequestBody!,
        },
      }, 201);
    }

    return _jsonResponse({'success': false, 'message': 'Not found'}, 404);
  }

  ResponseBody _jsonResponse(Map<String, dynamic> body, int statusCode) {
    return ResponseBody.fromString(
      jsonEncode(body),
      statusCode,
      headers: {
        Headers.contentTypeHeader: ['application/json'],
      },
    );
  }
}

class _PosterUploadAdapter implements HttpClientAdapter {
  RequestOptions? request;
  List<int> uploadedBytes = [];

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    request = options;
    if (requestStream != null) {
      await for (final chunk in requestStream) {
        uploadedBytes.addAll(chunk);
      }
    }
    return ResponseBody.fromString('', 200);
  }
}
