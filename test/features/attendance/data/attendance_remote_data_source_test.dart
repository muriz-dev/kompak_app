import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kompak_app/features/attendance/data/datasources/attendance_remote_data_source.dart';
import 'package:kompak_app/features/attendance/domain/entities/attendance_check_in.dart';

void main() {
  test('submits multipart face and GPS then maps attendance history', () async {
    final directory = await Directory.systemTemp.createTemp('attendance-test');
    addTearDown(() => directory.delete(recursive: true));
    final image = File('${directory.path}/face.jpg')
      ..writeAsBytesSync([0xff, 0xd8, 0xff, 0xd9]);
    final adapter = _AttendanceAdapter();
    final dio = Dio(BaseOptions(baseUrl: 'https://api.kompak.test'))
      ..httpClientAdapter = adapter;
    final dataSource = AttendanceRemoteDataSourceImpl(dio);

    final result = await dataSource.checkIn(
      AttendanceCheckInRequest(
        eventId: 'event-1',
        latitude: -6.2,
        longitude: 106.816666,
        faceImagePath: image.path,
      ),
    );
    final history = await dataSource.getMyAttendances();

    expect(result.attendanceId, 'attendance-1');
    expect(result.pointsEarned, 50);
    final form = adapter.requests.first.data as FormData;
    expect(
      form.fields,
      contains(
        isA<MapEntry<String, String>>()
            .having((field) => field.key, 'key', 'eventId')
            .having((field) => field.value, 'value', 'event-1'),
      ),
    );
    expect(
      form.fields,
      contains(
        isA<MapEntry<String, String>>()
            .having((field) => field.key, 'key', 'latitude')
            .having((field) => field.value, 'value', '-6.2'),
      ),
    );
    expect(form.files.single.key, 'faceImage');
    expect(form.files.single.value.contentType?.mimeType, 'image/jpeg');
    expect(adapter.requests.last.path, '/attendances/me');
    expect(history.single.eventTitle, 'Kerja Bakti');
    expect(history.single.pointsEarned, 50);
  });

  test('maps a face mismatch into an actionable Indonesian error', () async {
    final directory = await Directory.systemTemp.createTemp('attendance-test');
    addTearDown(() => directory.delete(recursive: true));
    final image = File('${directory.path}/face.jpg')
      ..writeAsBytesSync([0xff, 0xd8, 0xff, 0xd9]);
    final dio = Dio(BaseOptions(baseUrl: 'https://api.kompak.test'))
      ..httpClientAdapter = _AttendanceAdapter(faceMismatch: true);
    final dataSource = AttendanceRemoteDataSourceImpl(dio);

    expect(
      () => dataSource.checkIn(
        AttendanceCheckInRequest(
          eventId: 'event-1',
          latitude: -6.2,
          longitude: 106.816666,
          faceImagePath: image.path,
        ),
      ),
      throwsA(
        isA<AttendanceException>().having(
          (error) => error.message,
          'message',
          contains('Wajah tidak cocok'),
        ),
      ),
    );
  });
}

class _AttendanceAdapter implements HttpClientAdapter {
  _AttendanceAdapter({this.faceMismatch = false});

  final bool faceMismatch;
  final requests = <RequestOptions>[];

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    if (options.path == '/attendances' && faceMismatch) {
      return _jsonResponse({
        'success': false,
        'message': 'Face could not be verified',
        'errors': {'faceCode': 'face_mismatch'},
      }, 422);
    }
    if (options.path == '/attendances') {
      return _jsonResponse({
        'success': true,
        'data': {'attendanceId': 'attendance-1', 'pointsEarned': 50},
      }, 201);
    }
    if (options.path == '/attendances/me') {
      return _jsonResponse({
        'success': true,
        'data': [
          {
            'id': 'attendance-1',
            'eventId': 'event-1',
            'verifiedAt': '2026-08-10T08:00:00.000Z',
            'event': {'title': 'Kerja Bakti', 'rewardPoints': 50},
          },
        ],
      });
    }
    return _jsonResponse({'success': false, 'message': 'Not found'}, 404);
  }

  ResponseBody _jsonResponse(Map<String, dynamic> body, [int status = 200]) {
    return ResponseBody.fromString(
      jsonEncode(body),
      status,
      headers: {
        Headers.contentTypeHeader: ['application/json'],
      },
    );
  }
}
