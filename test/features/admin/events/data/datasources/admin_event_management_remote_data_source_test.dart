import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kompak_app/features/admin/events/data/datasources/admin_events_remote_data_source.dart';
import 'package:kompak_app/features/admin/events/domain/entities/update_admin_event_request.dart';

void main() {
  test('loads API-backed admin event metrics and documentation', () async {
    final adapter = _ManagementAdapter();
    final dio = Dio(BaseOptions(baseUrl: 'https://api.kompak.test'))
      ..httpClientAdapter = adapter;
    final dataSource = AdminEventsRemoteDataSourceImpl(dio);

    final overview = await dataSource.getEventOverview('event-1');

    expect(adapter.requests.map((request) => request.path).toSet(), {
      '/events/admin/event-1',
      '/attendances/event/event-1',
      '/users',
    });
    expect(overview.event.title, 'Kerja Bakti Blok B');
    expect(overview.attendanceCount, 2);
    expect(overview.activeCitizenCount, 2);
    expect(overview.distributedPoints, 90);
    expect(overview.documentation.single.contributorName, 'Olivia Rhye');
    expect(overview.attendanceRate, 1);
  });

  test('updates the full event contract and deletes the event', () async {
    final adapter = _ManagementAdapter();
    final dio = Dio(BaseOptions(baseUrl: 'https://api.kompak.test'))
      ..httpClientAdapter = adapter;
    final dataSource = AdminEventsRemoteDataSourceImpl(dio);
    final start = DateTime(2026, 8, 12, 7);

    final updated = await dataSource.updateEvent(
      'event-1',
      UpdateAdminEventRequest(
        title: ' Kerja Bakti RW ',
        description: ' Bersihkan taman. ',
        eventDate: start,
        attendanceStartTime: start,
        attendanceEndTime: start.add(const Duration(hours: 2)),
        rewardPoints: 75,
        latitude: -6.2,
        longitude: 106.8,
        radiusMeters: 50,
        existingBannerUrl: 'https://assets.test/poster.jpg',
      ),
    );
    await dataSource.deleteEvent('event-1');

    expect(updated.title, 'Kerja Bakti RW');
    expect(adapter.updateBody?['description'], 'Bersihkan taman.');
    expect(adapter.updateBody?['bannerUrl'], 'https://assets.test/poster.jpg');
    expect(
      adapter.requests.any(
        (request) =>
            request.method == 'DELETE' && request.path == '/events/event-1',
      ),
      isTrue,
    );
  });
}

class _ManagementAdapter implements HttpClientAdapter {
  final requests = <RequestOptions>[];
  Map<String, dynamic>? updateBody;

  final _event = {
    'id': 'event-1',
    'createdBy': 'admin-1',
    'title': 'Kerja Bakti Blok B',
    'description': 'Bersihkan taman bersama.',
    'eventDate': '2026-08-12T07:00:00.000Z',
    'attendanceStartTime': '2026-08-12T07:00:00.000Z',
    'attendanceEndTime': '2026-08-12T09:00:00.000Z',
    'rewardPoints': 50,
    'latitude': -6.2,
    'longitude': 106.8,
    'radiusMeters': 50,
    'status': 'PUBLISHED',
    'bannerUrl': 'https://assets.test/poster.jpg',
  };

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    if (options.method == 'GET' && options.path == '/events/admin/event-1') {
      return _json({'success': true, 'data': _event}, 200);
    }
    if (options.method == 'GET' &&
        options.path == '/attendances/event/event-1') {
      return _json({
        'success': true,
        'data': [
          _attendance(
            id: 'attendance-1',
            name: 'Olivia Rhye',
            points: 50,
            photoUrl: 'https://assets.test/photo-1.jpg',
          ),
          _attendance(id: 'attendance-2', name: 'Budi Santoso', points: 40),
        ],
      }, 200);
    }
    if (options.method == 'GET' && options.path == '/users') {
      expect(options.queryParameters['status'], 'ACTIVE');
      return _json({
        'success': true,
        'data': [
          {'id': 'citizen-1', 'role': 'CITIZEN', 'status': 'ACTIVE'},
          {'id': 'citizen-2', 'role': 'CITIZEN', 'status': 'ACTIVE'},
          {'id': 'admin-1', 'role': 'ADMIN', 'status': 'ACTIVE'},
        ],
      }, 200);
    }
    if (options.method == 'PUT' && options.path == '/events/event-1') {
      updateBody = Map<String, dynamic>.from(options.data as Map);
      return _json({
        'success': true,
        'data': {..._event, ...updateBody!, 'status': 'PUBLISHED'},
      }, 200);
    }
    if (options.method == 'DELETE' && options.path == '/events/event-1') {
      return _json({'success': true, 'message': 'Deleted'}, 200);
    }
    return _json({'success': false, 'message': 'Not found'}, 404);
  }

  Map<String, dynamic> _attendance({
    required String id,
    required String name,
    required int points,
    String? photoUrl,
  }) => {
    'id': id,
    'userId': 'user-$id',
    'eventId': 'event-1',
    'verifiedAt': '2026-08-12T07:30:00.000Z',
    'activityPhotoUrl': photoUrl,
    'activityDescription': photoUrl == null ? null : 'Membersihkan taman.',
    'user': {
      'id': 'user-$id',
      'name': name,
      'phoneNumber': '08123456789',
      'email': '${name.toLowerCase().replaceAll(' ', '.')}@test.com',
    },
    'eventTransaction': {'points': points},
  };

  ResponseBody _json(Map<String, dynamic> body, int statusCode) =>
      ResponseBody.fromString(
        jsonEncode(body),
        statusCode,
        headers: {
          Headers.contentTypeHeader: ['application/json'],
        },
      );
}
