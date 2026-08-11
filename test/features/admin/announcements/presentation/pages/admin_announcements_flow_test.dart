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
import 'package:kompak_app/features/admin/announcements/presentation/bloc/admin_announcements_cubit.dart';
import 'package:kompak_app/features/admin/announcements/presentation/bloc/announcement_form_cubit.dart';
import 'package:kompak_app/features/admin/announcements/presentation/pages/admin_announcements_page.dart';
import 'package:kompak_app/features/admin/announcements/presentation/pages/announcement_form_page.dart';
import 'package:kompak_app/features/announcements/data/datasources/announcements_remote_data_source.dart';
import 'package:kompak_app/features/announcements/data/repositories/announcements_repository_impl.dart';
import 'package:kompak_app/features/announcements/domain/entities/community_announcement.dart';

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

class _AnnouncementsAdapter implements HttpClientAdapter {
  _AnnouncementsAdapter({this.failReads = false}) {
    announcements = List.generate(6, (index) {
      final number = index + 1;
      return {
        'id': 'announcement-$number',
        'createdBy': 'admin-1',
        'title': 'Pengumuman Warga $number',
        'description':
            'Detail pengumuman warga nomor $number untuk seluruh lingkungan.',
        'createdAt': DateTime(2026, 8, 11 - index).millisecondsSinceEpoch,
        'updatedAt': DateTime(2026, 8, 11 - index).millisecondsSinceEpoch,
      };
    });
  }

  bool failReads;
  late final List<Map<String, dynamic>> announcements;
  final requests = <RequestOptions>[];
  String? lastAuthorization;

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

    if (options.method == 'GET' && options.path == '/announcements') {
      if (failReads) {
        return _jsonResponse({
          'success': false,
          'message': 'Server pengumuman sedang bermasalah.',
        }, 503);
      }
      return _jsonResponse({'success': true, 'data': announcements}, 200);
    }

    if (options.method == 'POST' && options.path == '/announcements') {
      final body = Map<String, dynamic>.from(options.data as Map);
      announcements.insert(0, {
        'id': 'announcement-new',
        'createdBy': 'admin-1',
        'title': body['title'],
        'description': body['description'],
        'createdAt': DateTime(2026, 8, 12).millisecondsSinceEpoch,
        'updatedAt': DateTime(2026, 8, 12).millisecondsSinceEpoch,
      });
      return _jsonResponse({
        'success': true,
        'data': {'announcementId': 'announcement-new'},
      }, 201);
    }

    final idMatch = RegExp(
      r'^/announcements/([^/]+)$',
    ).firstMatch(options.path);
    if (idMatch != null && options.method == 'PATCH') {
      final id = idMatch.group(1)!;
      final index = announcements.indexWhere((item) => item['id'] == id);
      if (index == -1) return _notFound();
      final body = Map<String, dynamic>.from(options.data as Map);
      announcements[index] = {
        ...announcements[index],
        ...body,
        'updatedAt': DateTime(2026, 8, 12).millisecondsSinceEpoch,
      };
      return _jsonResponse({
        'success': true,
        'data': announcements[index],
      }, 200);
    }

    if (idMatch != null && options.method == 'DELETE') {
      final id = idMatch.group(1)!;
      announcements.removeWhere((item) => item['id'] == id);
      return _jsonResponse({'success': true}, 200);
    }

    return _notFound();
  }

  ResponseBody _notFound() =>
      _jsonResponse({'success': false, 'message': 'Not found'}, 404);

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
  Future<
    ({
      _AnnouncementsAdapter adapter,
      AnnouncementsRepositoryImpl repository,
      SessionInvalidationBus bus,
    })
  >
  createHarness({bool failReads = false}) async {
    final adapter = _AnnouncementsAdapter(failReads: failReads);
    final tokenStore = _MemoryTokenStore('admin-token');
    final bus = SessionInvalidationBus();
    final dio = _TestDioModule().dio(tokenStore, bus)
      ..httpClientAdapter = adapter;
    final repository = AnnouncementsRepositoryImpl(
      AnnouncementsRemoteDataSourceImpl(dio),
    );
    addTearDown(bus.dispose);
    return (adapter: adapter, repository: repository, bus: bus);
  }

  Future<_AnnouncementsAdapter> pumpList(
    WidgetTester tester, {
    Future<bool?> Function()? onCreate,
    Future<bool?> Function(CommunityAnnouncement)? onEdit,
    bool failReads = false,
    Size size = const Size(390, 1000),
  }) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = size;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final harness = await createHarness(failReads: failReads);
    await tester.pumpWidget(
      MaterialApp(
        key: UniqueKey(),
        theme: AppTheme.light,
        home: BlocProvider(
          create: (_) =>
              AdminAnnouncementsCubit(harness.repository)..loadAnnouncements(),
          child: AdminAnnouncementsView(
            onBack: () {},
            onCreate: onCreate ?? () async => false,
            onEdit: onEdit ?? (_) async => false,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return harness.adapter;
  }

  Future<_AnnouncementsAdapter> pumpForm(
    WidgetTester tester, {
    CommunityAnnouncement? announcement,
    VoidCallback? onComplete,
  }) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final harness = await createHarness();
    await tester.pumpWidget(
      MaterialApp(
        key: UniqueKey(),
        theme: AppTheme.light,
        home: BlocProvider(
          create: (_) => AnnouncementFormCubit(harness.repository),
          child: AnnouncementFormView(
            announcement: announcement,
            onBack: () {},
            onComplete: onComplete ?? () {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return harness.adapter;
  }

  testWidgets('loads the API list with Figma hierarchy and pagination', (
    tester,
  ) async {
    final adapter = await pumpList(tester);

    expect(find.text('Daftar Pengumuman'), findsOneWidget);
    expect(find.text('Cari pengumuman'), findsOneWidget);
    expect(find.text('Filter'), findsOneWidget);
    expect(find.text('Buat Pengumuman'), findsOneWidget);
    expect(find.text('Pengumuman Warga 1'), findsOneWidget);
    expect(find.text('Pengumuman Warga 5'), findsOneWidget);
    expect(find.text('Pengumuman Warga 6'), findsNothing);
    expect(find.text('Menampilkan\n5 dari 6'), findsOneWidget);
    expect(adapter.requests.single.method, 'GET');
    expect(adapter.requests.single.path, '/announcements');
    expect(adapter.lastAuthorization, 'Bearer admin-token');
  });

  testWidgets('searches announcements and opens the edit callback', (
    tester,
  ) async {
    CommunityAnnouncement? edited;
    await pumpList(
      tester,
      onEdit: (announcement) async {
        edited = announcement;
        return false;
      },
    );

    await tester.enterText(
      find.byKey(const ValueKey('announcement-search')),
      'Warga 6',
    );
    await tester.pump();
    expect(find.text('Pengumuman Warga 6'), findsOneWidget);

    await tester.tap(
      find.byKey(const ValueKey('edit-announcement-announcement-6')),
    );
    await tester.pump();
    expect(edited?.id, 'announcement-6');
  });

  testWidgets('refreshes the API list after creating an announcement', (
    tester,
  ) async {
    final adapter = await pumpList(tester, onCreate: () async => true);

    await tester.tap(find.byKey(const ValueKey('create-announcement-button')));
    await tester.pumpAndSettle();

    expect(
      adapter.requests.where((request) => request.method == 'GET'),
      hasLength(2),
    );
  });

  testWidgets('shows the empty Figma form and creates via POST', (
    tester,
  ) async {
    var completed = false;
    final adapter = await pumpForm(tester, onComplete: () => completed = true);

    expect(find.text('Buat Pengumuman Baru'), findsOneWidget);
    expect(find.text('Judul Pengumuman'), findsOneWidget);
    expect(find.text('Detail Pengumuman'), findsOneWidget);
    expect(find.text('Simpan & Publikasi'), findsOneWidget);
    expect(find.text('Hapus'), findsNothing);

    await tester.enterText(
      find.byKey(const ValueKey('announcement-title-field')),
      'Kerja Bakti Blok B',
    );
    await tester.enterText(
      find.byKey(const ValueKey('announcement-description-field')),
      'Warga diminta membawa alat kebersihan masing-masing.',
    );
    await tester.tap(find.byKey(const ValueKey('submit-announcement')));
    await tester.pumpAndSettle();

    final request = adapter.requests.single;
    expect(request.method, 'POST');
    expect(request.path, '/announcements');
    expect(request.data, {
      'title': 'Kerja Bakti Blok B',
      'description': 'Warga diminta membawa alat kebersihan masing-masing.',
    });
    expect(find.text('Pengumuman Berhasil Dipublikasikan!'), findsOneWidget);
    expect(find.text('Lihat Daftar'), findsOneWidget);
    expect(find.text('Buat Pengumuman Lagi'), findsOneWidget);
    expect(completed, isFalse);

    await tester.tap(
      find.byKey(const ValueKey('announcement-success-view-list')),
    );
    await tester.pumpAndSettle();

    expect(completed, isTrue);
  });

  testWidgets('resets the form from the create success modal', (tester) async {
    final adapter = await pumpForm(tester);

    await tester.enterText(
      find.byKey(const ValueKey('announcement-title-field')),
      'Kerja Bakti Blok B',
    );
    await tester.enterText(
      find.byKey(const ValueKey('announcement-description-field')),
      'Warga diminta membawa alat kebersihan masing-masing.',
    );
    await tester.tap(find.byKey(const ValueKey('submit-announcement')));
    await tester.pumpAndSettle();

    expect(adapter.requests, hasLength(1));
    await tester.tap(
      find.byKey(const ValueKey('announcement-success-create-another')),
    );
    await tester.pumpAndSettle();

    expect(
      tester
          .widget<TextFormField>(
            find.byKey(const ValueKey('announcement-title-field')),
          )
          .controller
          ?.text,
      isEmpty,
    );
    expect(
      tester
          .widget<TextFormField>(
            find.byKey(const ValueKey('announcement-description-field')),
          )
          .controller
          ?.text,
      isEmpty,
    );
    expect(find.text('Pengumuman Berhasil Dipublikasikan!'), findsNothing);
  });

  testWidgets('prefills, updates, and deletes an announcement', (tester) async {
    var completed = 0;
    final announcement = CommunityAnnouncement(
      id: 'announcement-1',
      createdBy: 'admin-1',
      title: 'Pengumuman Warga 1',
      description: 'Detail pengumuman warga nomor 1 untuk seluruh lingkungan.',
      createdAt: DateTime(2026, 8, 11),
      updatedAt: DateTime(2026, 8, 11),
    );
    var adapter = await pumpForm(
      tester,
      announcement: announcement,
      onComplete: () => completed++,
    );

    expect(find.text('Detail Pengumuman'), findsWidgets);
    expect(find.text('Pengumuman Warga 1'), findsOneWidget);
    expect(find.text('Simpan Perubahan'), findsOneWidget);
    expect(find.text('Hapus'), findsOneWidget);

    await tester.enterText(
      find.byKey(const ValueKey('announcement-title-field')),
      'Pengumuman Warga Diperbarui',
    );
    await tester.tap(find.byKey(const ValueKey('submit-announcement')));
    await tester.pumpAndSettle();

    final patchRequest = adapter.requests.single;
    expect(patchRequest.method, 'PATCH');
    expect(patchRequest.path, '/announcements/announcement-1');
    expect((patchRequest.data as Map)['title'], 'Pengumuman Warga Diperbarui');
    expect(completed, 1);

    adapter = await pumpForm(
      tester,
      announcement: announcement,
      onComplete: () => completed++,
    );
    await tester.tap(find.byKey(const ValueKey('delete-announcement')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('confirm-delete-announcement')));
    await tester.pumpAndSettle();

    expect(adapter.requests.single.method, 'DELETE');
    expect(adapter.requests.single.path, '/announcements/announcement-1');
    expect(completed, 2);
  });

  testWidgets('fits the list on a narrow phone', (tester) async {
    await pumpList(tester, size: const Size(320, 700));

    expect(find.text('Daftar Pengumuman'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('create-announcement-button')),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });
}
