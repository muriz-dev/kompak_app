import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kompak_app/core/auth/session_invalidation_bus.dart';
import 'package:kompak_app/core/auth/session_token_store.dart';
import 'package:kompak_app/core/di/injection.dart';
import 'package:kompak_app/core/network/dio_module.dart';
import 'package:kompak_app/features/admin/residents/data/datasources/admin_residents_remote_data_source.dart';
import 'package:kompak_app/features/admin/residents/data/repositories/admin_residents_repository_impl.dart';
import 'package:kompak_app/features/admin/residents/presentation/bloc/admin_residents_cubit.dart';
import 'package:kompak_app/features/admin/residents/presentation/pages/admin_residents_page.dart';
import 'package:kompak_app/features/auth/domain/entities/session_user.dart';
import 'package:kompak_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:kompak_app/features/auth/presentation/session/session_cubit.dart';

const _adminUser = SessionUser(
  id: 'admin-1',
  name: 'Admin RT',
  email: 'admin@example.com',
  phoneNumber: '081234567890',
  birthDate: '1990-01-01',
  balance: 0,
  leaderboardPoints: 0,
  status: UserStatus.active,
  role: UserRole.admin,
);

class _StaticAuthRepository implements AuthRepository {
  @override
  Future<SessionUser?> restoreSession() async => _adminUser;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

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

class _ResidentsAdapter implements HttpClientAdapter {
  _ResidentsAdapter({this.failReads = false});

  bool failReads;
  String? lastAuthorization;
  final requests = <RequestOptions>[];
  final residents = <Map<String, dynamic>>[
    {
      'id': 'pending-1',
      'name': 'Budi Pratama',
      'phoneNumber': '081234567890',
      'birthDate': '1990-04-15',
      'email': 'budi@example.com',
      'balance': 1200,
      'leaderboardPoints': 80,
      'status': 'PENDING',
      'role': 'CITIZEN',
    },
    {
      'id': 'active-1',
      'name': 'Siti Rahma',
      'phoneNumber': '081298765432',
      'birthDate': '1994-10-08',
      'email': 'siti@example.com',
      'balance': 850,
      'leaderboardPoints': 55,
      'status': 'ACTIVE',
      'role': 'CITIZEN',
    },
    {
      'id': 'rejected-1',
      'name': 'Agus Mulyadi',
      'phoneNumber': '081277788899',
      'birthDate': '1988-01-20',
      'email': 'agus@example.com',
      'balance': 0,
      'leaderboardPoints': 0,
      'status': 'REJECTED',
      'role': 'CITIZEN',
    },
  ];

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

    if (options.method == 'GET' && options.path == '/users') {
      if (failReads) {
        return _jsonResponse({
          'success': false,
          'message': 'Server sedang bermasalah.',
        }, 503);
      }
      return _jsonResponse({'success': true, 'data': residents}, 200);
    }

    final statusMatch = RegExp(
      r'^/users/([^/]+)/status$',
    ).firstMatch(options.path);
    if (options.method == 'PATCH' && statusMatch != null) {
      final id = statusMatch.group(1);
      final requestData = Map<String, dynamic>.from(options.data as Map);
      final resident = residents.firstWhere((item) => item['id'] == id);
      resident['status'] = requestData['status'];
      return _jsonResponse({'success': true, 'data': resident}, 200);
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
  Future<_ResidentsAdapter> pumpPage(
    WidgetTester tester, {
    bool failReads = false,
    Size size = const Size(390, 1200),
  }) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = size;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await getIt.reset();
    final adapter = _ResidentsAdapter(failReads: failReads);
    final tokenStore = _MemoryTokenStore('admin-token');
    final invalidationBus = SessionInvalidationBus();
    final sessionCubit = SessionCubit(_StaticAuthRepository(), invalidationBus);
    await sessionCubit.restoreSession();
    final dio = _TestDioModule().dio(tokenStore, invalidationBus)
      ..httpClientAdapter = adapter;
    final repository = AdminResidentsRepositoryImpl(
      AdminResidentsRemoteDataSourceImpl(dio),
    );
    getIt.registerFactory<AdminResidentsCubit>(
      () => AdminResidentsCubit(repository),
    );

    addTearDown(() async {
      await sessionCubit.close();
      invalidationBus.dispose();
      await getIt.reset();
    });

    await tester.pumpWidget(
      BlocProvider.value(
        value: sessionCubit,
        child: const MaterialApp(home: AdminResidentsPage()),
      ),
    );
    await tester.pumpAndSettle();
    return adapter;
  }

  testWidgets('loads the Figma-aligned dashboard with real resident data', (
    tester,
  ) async {
    final adapter = await pumpPage(tester);

    expect(find.text('Dashboard Admin'), findsOneWidget);
    expect(
      find.text('Kelola warga, kegiatan, dan layanan komunitas.'),
      findsOneWidget,
    );
    expect(find.text('RT 004 / RW 012 · Kelurahan Harmoni'), findsOneWidget);
    expect(find.text('Admin'), findsOneWidget);
    expect(find.text('AR'), findsOneWidget);
    expect(find.text('Ringkasan Warga'), findsOneWidget);
    expect(find.text('Total Warga'), findsOneWidget);
    expect(find.text('Menunggu'), findsWidgets);
    expect(find.text('Warga Aktif'), findsOneWidget);
    expect(find.text('Total Saldo Poin'), findsOneWidget);
    expect(find.text('2.1k'), findsOneWidget);
    expect(find.text('Menu Pengelolaan'), findsOneWidget);
    expect(find.text('Daftar Warga'), findsOneWidget);
    expect(find.text('Tambah Warga'), findsOneWidget);
    expect(find.text('Pengumuman'), findsOneWidget);
    expect(find.text('Provider'), findsOneWidget);
    expect(find.text('Toko Poin'), findsOneWidget);
    expect(find.text('Kegiatan'), findsOneWidget);
    expect(find.text('Reward'), findsOneWidget);
    expect(find.text('3'), findsOneWidget);
    expect(find.text('Budi Pratama'), findsOneWidget);
    expect(find.text('Siti Rahma'), findsOneWidget);
    expect(find.text('Agus Mulyadi'), findsOneWidget);
    expect(adapter.requests.single.method, 'GET');
    expect(adapter.requests.single.path, '/users');
    expect(adapter.lastAuthorization, 'Bearer admin-token');
    expect(find.text('Manajemen Warga'), findsNothing);
    expect(find.text('Dashboard Warga'), findsNothing);
  });

  testWidgets('opens the admin account menu from the shared-style header', (
    tester,
  ) async {
    await pumpPage(tester);

    await tester.tap(find.byKey(const ValueKey('admin-profile-button')));
    await tester.pumpAndSettle();

    expect(find.text('Akun Admin'), findsOneWidget);
    expect(find.text('Beralih ke Warga'), findsOneWidget);
    expect(find.text('Beralih ke Admin'), findsNothing);
  });

  testWidgets('keeps the dashboard header usable on a narrow phone', (
    tester,
  ) async {
    await pumpPage(tester, size: const Size(320, 700));

    expect(find.byKey(const ValueKey('admin-mode-badge')), findsOneWidget);
    expect(find.byKey(const ValueKey('admin-profile-button')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('searches the server-backed resident list', (tester) async {
    await pumpPage(tester);

    await tester.enterText(find.byType(TextField), 'tidak ada');
    await tester.pump();

    expect(find.text('Warga tidak ditemukan'), findsOneWidget);
    expect(find.text('Budi Pratama'), findsNothing);

    await tester.enterText(find.byType(TextField), 'budi@example.com');
    await tester.pump();

    expect(find.text('Budi Pratama'), findsOneWidget);
  });

  testWidgets('filters residents by their API status', (tester) async {
    await pumpPage(tester);

    await tester.tap(find.byKey(const ValueKey('resident-status-filter')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Aktif').last);
    await tester.pumpAndSettle();

    expect(find.text('Siti Rahma'), findsOneWidget);
    expect(find.text('Budi Pratama'), findsNothing);
  });

  testWidgets('approves a pending resident through the status API', (
    tester,
  ) async {
    final adapter = await pumpPage(tester);

    final approve = find.byKey(const ValueKey('approve-pending-1'));
    await tester.ensureVisible(approve);
    await tester.pumpAndSettle();
    await tester.tap(approve);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('confirm-ACTIVE-pending-1')));
    await tester.pumpAndSettle();

    final patch = adapter.requests.last;
    expect(patch.method, 'PATCH');
    expect(patch.path, '/users/pending-1/status');
    expect(patch.data, {'status': 'ACTIVE'});
    expect(find.text('Budi Pratama berhasil disetujui.'), findsOneWidget);
    expect(find.text('Budi Pratama'), findsOneWidget);
    expect(find.byKey(const ValueKey('approve-pending-1')), findsNothing);
    expect(adapter.residents.first['status'], 'ACTIVE');
  });

  testWidgets('rejects a pending resident through the status API', (
    tester,
  ) async {
    final adapter = await pumpPage(tester);

    final reject = find.byKey(const ValueKey('reject-pending-1'));
    await tester.ensureVisible(reject);
    await tester.pumpAndSettle();
    await tester.tap(reject);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('confirm-REJECTED-pending-1')));
    await tester.pumpAndSettle();

    final patch = adapter.requests.last;
    expect(patch.method, 'PATCH');
    expect(patch.path, '/users/pending-1/status');
    expect(patch.data, {'status': 'REJECTED'});
    expect(find.text('Pendaftaran Budi Pratama ditolak.'), findsOneWidget);
    expect(find.text('Budi Pratama'), findsOneWidget);
    expect(adapter.residents.first['status'], 'REJECTED');
  });

  testWidgets('shows a retry state when residents cannot be loaded', (
    tester,
  ) async {
    final adapter = await pumpPage(tester, failReads: true);

    expect(find.text('Data warga tidak dapat dimuat'), findsOneWidget);
    expect(find.text('Server sedang bermasalah.'), findsOneWidget);

    adapter.failReads = false;
    final retry = find.byKey(const ValueKey('retry-residents'));
    await tester.ensureVisible(retry);
    await tester.pumpAndSettle();
    await tester.tap(retry);
    await tester.pumpAndSettle();

    expect(find.text('Budi Pratama'), findsOneWidget);
    expect(
      adapter.requests.where((request) => request.method == 'GET').length,
      2,
    );
  });
}
