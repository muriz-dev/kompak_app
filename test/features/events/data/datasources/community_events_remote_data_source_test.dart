import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kompak_app/features/events/data/datasources/community_events_remote_data_source.dart';
import 'package:kompak_app/features/events/domain/entities/community_event.dart';

void main() {
  test('loads filtered events and event detail from the public API', () async {
    final adapter = _CommunityEventsAdapter();
    final dio = Dio(BaseOptions(baseUrl: 'https://api.kompak.test'))
      ..httpClientAdapter = adapter;
    final dataSource = CommunityEventsRemoteDataSourceImpl(dio);

    final events = await dataSource.getEvents(EventTimeframe.upcoming);
    final detail = await dataSource.getEvent('event-1');

    expect(adapter.requests.first.path, '/events');
    expect(adapter.requests.first.queryParameters, {'timeframe': 'upcoming'});
    expect(adapter.requests.last.path, '/events/event-1');
    expect(events.single.title, 'Kerja Bakti');
    expect(events.single.bannerUrl, 'https://assets.test/events/banner.png');
    expect(detail.id, 'event-1');
    expect(detail.radiusMeters, 75);
  });
}

class _CommunityEventsAdapter implements HttpClientAdapter {
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
    final event = {
      'id': 'event-1',
      'title': 'Kerja Bakti',
      'description': 'Membersihkan lingkungan bersama.',
      'eventDate': '2026-08-20T01:00:00.000Z',
      'attendanceStartTime': '2026-08-20T01:00:00.000Z',
      'attendanceEndTime': '2026-08-20T03:00:00.000Z',
      'rewardPoints': 50,
      'latitude': -6.2,
      'longitude': 106.816666,
      'radiusMeters': 75,
      'status': 'PUBLISHED',
      'bannerUrl': 'https://assets.test/events/banner.png',
    };

    if (options.path == '/events') {
      return _jsonResponse({
        'success': true,
        'data': [event],
      });
    }
    if (options.path == '/events/event-1') {
      return _jsonResponse({'success': true, 'data': event});
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
