import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kompak_app/core/auth/session_invalidation_bus.dart';
import 'package:kompak_app/core/auth/session_token_store.dart';
import 'package:kompak_app/core/network/dio_module.dart';
import 'package:kompak_app/core/theme/app_theme.dart';
import 'package:kompak_app/features/admin/events/data/datasources/admin_events_remote_data_source.dart';
import 'package:kompak_app/features/admin/events/data/repositories/admin_events_repository_impl.dart';
import 'package:kompak_app/features/admin/events/presentation/bloc/admin_events_cubit.dart';
import 'package:kompak_app/features/admin/events/presentation/pages/admin_events_page.dart';

class _MemoryTokenStore implements SessionTokenStore {
  _MemoryTokenStore(this.token);

  String? token;

  @override
  Future<void> clear() async => token = null;

  @override
  Future<String?> read() async => token;

  @override
  Future<void> write(String token) async => this.token = token;
}

class _TestDioModule extends DioModule {}

class _EventsAdapter implements HttpClientAdapter {
  _EventsAdapter({this.failReads = false, this.failUpdates = false}) {
    final now = DateTime.now().toUtc();
    events = [
      _event(
        id: 'draft-1',
        title: 'Rapat Bulanan RT',
        status: 'DRAFT',
        start: now.add(const Duration(days: 2)),
        end: now.add(const Duration(days: 2, hours: 2)),
        rewardPoints: 100,
      ),
      _event(
        id: 'upcoming-1',
        title: 'Kerja Bakti Blok B',
        status: 'PUBLISHED',
        start: now.add(const Duration(days: 1)),
        end: now.add(const Duration(days: 1, hours: 2)),
        rewardPoints: 50,
      ),
      _event(
        id: 'ongoing-1',
        title: 'Posyandu Balita',
        status: 'PUBLISHED',
        start: now.subtract(const Duration(hours: 1)),
        end: now.add(const Duration(hours: 1)),
        rewardPoints: 75,
      ),
      _event(
        id: 'closed-1',
        title: 'Ronda Malam',
        status: 'CLOSED',
        start: now.subtract(const Duration(days: 2)),
        end: now.subtract(const Duration(days: 2, hours: -2)),
        rewardPoints: 40,
      ),
      _event(
        id: 'cancelled-1',
        title: 'Penyemprotan Disinfektan',
        status: 'CANCELLED',
        start: now.add(const Duration(days: 3)),
        end: now.add(const Duration(days: 3, hours: 2)),
        rewardPoints: 25,
      ),
      _event(
        id: 'completed-1',
        title: 'Senam Pagi',
        status: 'PUBLISHED',
        start: now.subtract(const Duration(hours: 3)),
        end: now.subtract(const Duration(hours: 1)),
        rewardPoints: 30,
      ),
    ];
  }

  bool failReads;
  bool failUpdates;
  late final List<Map<String, dynamic>> events;
  final requests = <RequestOptions>[];
  String? lastAuthorization;

  static Map<String, dynamic> _event({
    required String id,
    required String title,
    required String status,
    required DateTime start,
    required DateTime end,
    required int rewardPoints,
  }) => {
    'id': id,
    'createdBy': 'admin-1',
    'title': title,
    'description': 'Detail $title',
    'eventDate': start.toIso8601String(),
    'attendanceStartTime': start.toIso8601String(),
    'attendanceEndTime': end.toIso8601String(),
    'rewardPoints': rewardPoints,
    'latitude': -6.2,
    'longitude': 106.8,
    'radiusMeters': 50,
    'status': status,
    'bannerUrl': null,
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
    lastAuthorization = options.headers['Authorization'] as String?;

    if (options.method == 'GET' && options.path == '/events/admin') {
      if (failReads) {
        return _jsonResponse({
          'success': false,
          'message': 'Server kegiatan sedang bermasalah.',
        }, 503);
      }
      return _jsonResponse({'success': true, 'data': events}, 200);
    }

    if (options.method == 'PATCH' && options.path.startsWith('/events/')) {
      if (failUpdates) {
        return _jsonResponse({
          'success': false,
          'message': 'Status kegiatan gagal diubah.',
        }, 500);
      }

      final id = options.path.substring('/events/'.length);
      final index = events.indexWhere((event) => event['id'] == id);
      if (index == -1) {
        return _jsonResponse({
          'success': false,
          'message': 'Event not found',
        }, 404);
      }
      final body = Map<String, dynamic>.from(options.data as Map);
      events[index] = {...events[index], 'status': body['status']};
      return _jsonResponse({'success': true, 'data': events[index]}, 200);
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

void main() {
  Future<_EventsAdapter> pumpPage(
    WidgetTester tester, {
    Future<void> Function()? onCreateEvent,
    bool failReads = false,
    bool failUpdates = false,
    Size size = const Size(390, 1000),
  }) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = size;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final adapter = _EventsAdapter(
      failReads: failReads,
      failUpdates: failUpdates,
    );
    final tokenStore = _MemoryTokenStore('admin-token');
    final invalidationBus = SessionInvalidationBus();
    final dio = _TestDioModule().dio(tokenStore, invalidationBus)
      ..httpClientAdapter = adapter;
    final repository = AdminEventsRepositoryImpl(
      AdminEventsRemoteDataSourceImpl(dio),
    );

    addTearDown(invalidationBus.dispose);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: BlocProvider(
          create: (_) => AdminEventsCubit(repository)..loadEvents(),
          child: AdminEventsView(
            onBack: () {},
            onCreateEvent: onCreateEvent ?? () async {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return adapter;
  }

  testWidgets('loads the real admin event endpoint with every lifecycle', (
    tester,
  ) async {
    final adapter = await pumpPage(tester);

    expect(find.text('Daftar Kegiatan'), findsOneWidget);
    expect(find.text('Rapat Bulanan RT'), findsOneWidget);
    expect(find.text('Kerja Bakti Blok B'), findsOneWidget);
    expect(find.text('Posyandu Balita'), findsOneWidget);
    expect(find.text('Ronda Malam'), findsOneWidget);
    expect(find.text('Draft'), findsOneWidget);
    expect(find.text('Belum Mulai'), findsOneWidget);
    expect(find.text('Berlangsung'), findsOneWidget);
    expect(find.text('Selesai'), findsOneWidget);
    expect(find.text('50 meter'), findsNWidgets(4));
    expect(find.text('+100 Pts'), findsOneWidget);
    expect(adapter.requests.single.path, '/events/admin');
    expect(adapter.lastAuthorization, 'Bearer admin-token');
  });

  testWidgets('opens event creation and refreshes after returning', (
    tester,
  ) async {
    var createTapped = false;
    final adapter = await pumpPage(
      tester,
      onCreateEvent: () async => createTapped = true,
    );

    await tester.tap(find.byKey(const ValueKey('create-event-button')));
    await tester.pumpAndSettle();

    expect(createTapped, isTrue);
    expect(adapter.requests.length, 2);
  });

  testWidgets('searches and filters the server-backed event list', (
    tester,
  ) async {
    await pumpPage(tester);

    await tester.enterText(
      find.byKey(const ValueKey('event-search-field')),
      'rapat',
    );
    await tester.pump();

    expect(find.text('Rapat Bulanan RT'), findsOneWidget);
    expect(find.text('Kerja Bakti Blok B'), findsNothing);

    await tester.enterText(
      find.byKey(const ValueKey('event-search-field')),
      '',
    );
    await tester.tap(find.byKey(const ValueKey('event-filter-button')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Draft').last);
    await tester.pumpAndSettle();

    expect(find.text('Rapat Bulanan RT'), findsOneWidget);
    expect(find.text('Kerja Bakti Blok B'), findsNothing);
  });

  testWidgets('paginates through additional events', (tester) async {
    await pumpPage(tester);

    expect(find.text('Rapat Bulanan RT'), findsOneWidget);
    expect(find.text('Penyemprotan Disinfektan'), findsNothing);

    final nextPage = find.byKey(const ValueKey('admin-events-next-page'));
    await tester.dragUntilVisible(
      nextPage,
      find.byKey(const ValueKey('admin-events-scroll')),
      const Offset(0, -500),
    );
    await tester.tap(nextPage);
    await tester.pump();

    expect(find.text('Rapat Bulanan RT'), findsNothing);
    expect(find.text('Penyemprotan Disinfektan'), findsOneWidget);
    expect(find.text('Senam Pagi'), findsOneWidget);
  });

  testWidgets('publishes a draft after confirmation', (tester) async {
    final adapter = await pumpPage(tester);

    await tester.tap(find.byKey(const ValueKey('publish-event-draft-1')));
    await tester.pumpAndSettle();
    expect(find.text('Terbitkan kegiatan?'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('confirm-published')));
    await tester.pumpAndSettle();

    final request = adapter.requests.last;
    expect(request.method, 'PATCH');
    expect(request.path, '/events/draft-1');
    expect(request.data, {'status': 'PUBLISHED'});
    expect(find.text('Kegiatan berhasil diterbitkan.'), findsOneWidget);
    expect(find.byKey(const ValueKey('publish-event-draft-1')), findsNothing);
  });

  testWidgets('closes and cancels published events', (tester) async {
    final adapter = await pumpPage(tester);

    await tester.tap(find.byKey(const ValueKey('close-event-upcoming-1')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('confirm-closed')));
    await tester.pumpAndSettle();

    expect(adapter.requests.last.path, '/events/upcoming-1');
    expect(adapter.requests.last.data, {'status': 'CLOSED'});
    expect(find.text('Kegiatan berhasil ditutup.'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('cancel-event-ongoing-1')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('confirm-cancelled')));
    await tester.pumpAndSettle();

    expect(adapter.requests.last.path, '/events/ongoing-1');
    expect(adapter.requests.last.data, {'status': 'CANCELLED'});
    expect(find.text('Kegiatan berhasil dibatalkan.'), findsOneWidget);
  });

  testWidgets('keeps the prior status and shows an update error', (
    tester,
  ) async {
    await pumpPage(tester, failUpdates: true);

    await tester.tap(find.byKey(const ValueKey('publish-event-draft-1')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('confirm-published')));
    await tester.pumpAndSettle();

    expect(find.text('Status kegiatan gagal diubah.'), findsOneWidget);
    expect(find.byKey(const ValueKey('publish-event-draft-1')), findsOneWidget);
  });

  testWidgets('shows an error state and retries the admin event request', (
    tester,
  ) async {
    final adapter = await pumpPage(tester, failReads: true);

    expect(find.text('Daftar kegiatan tidak dapat dimuat'), findsOneWidget);
    expect(find.text('Server kegiatan sedang bermasalah.'), findsOneWidget);

    adapter.failReads = false;
    final retry = find.byKey(const ValueKey('retry-admin-events'));
    await tester.ensureVisible(retry);
    await tester.tap(retry);
    await tester.pumpAndSettle();

    expect(find.text('Rapat Bulanan RT'), findsOneWidget);
    expect(adapter.requests.length, 2);
  });

  testWidgets('fits the event list on a narrow phone', (tester) async {
    await pumpPage(tester, size: const Size(320, 720));

    expect(find.text('Daftar Kegiatan'), findsOneWidget);
    expect(find.text('Buat Kegiatan'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.drag(
      find.byKey(const ValueKey('admin-events-scroll')),
      const Offset(0, -900),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });
}
