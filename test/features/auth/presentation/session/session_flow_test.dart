import 'dart:async';
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
import 'package:kompak_app/core/routes/app_router.dart';
import 'package:kompak_app/core/routes/main_page.dart';
import 'package:kompak_app/features/announcements/domain/entities/community_announcement.dart';
import 'package:kompak_app/features/announcements/domain/repositories/announcements_repository.dart';
import 'package:kompak_app/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:kompak_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:kompak_app/features/auth/domain/entities/session_user.dart';
import 'package:kompak_app/features/auth/presentation/session/session_cubit.dart';
import 'package:kompak_app/features/auth/presentation/session/session_navigation.dart';
import 'package:kompak_app/features/auth/presentation/session/session_state.dart';
import 'package:kompak_app/features/home/presentation/bloc/home_cubit.dart';
import 'package:kompak_app/features/events/domain/entities/community_event.dart';
import 'package:kompak_app/features/events/domain/repositories/community_events_repository.dart';
import 'package:kompak_app/main.dart';

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

class _SessionAdapter implements HttpClientAdapter {
  _SessionAdapter({
    required this.status,
    this.responseStatus = 200,
    this.balance = 1200,
    this.leaderboardPoints = 90,
  });

  String status;
  int responseStatus;
  int balance;
  int leaderboardPoints;
  String? lastAuthorization;

  Map<String, dynamic> get user => {
    'id': 'resident-1',
    'name': 'Olivia Rhye',
    'phoneNumber': '+628123456789',
    'birthDate': '1995-06-12',
    'email': 'olivia@example.com',
    'balance': balance,
    'leaderboardPoints': leaderboardPoints,
    'status': status,
    'role': 'CITIZEN',
  };

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    lastAuthorization = options.headers['Authorization'] as String?;
    final body = responseStatus == 200
        ? {
            'success': true,
            'data': options.path == '/auth/login'
                ? {'token': 'login-token', 'user': user}
                : user,
          }
        : {'success': false, 'message': 'Unauthorized'};

    return ResponseBody.fromString(
      jsonEncode(body),
      responseStatus,
      headers: {
        Headers.contentTypeHeader: ['application/json'],
      },
    );
  }
}

void main() {
  test('routes active admins to the resident dashboard first', () {
    const user = SessionUser(
      id: 'admin-1',
      name: 'Admin',
      email: 'admin@example.com',
      phoneNumber: '081234567890',
      birthDate: '1980-01-01',
      balance: 0,
      leaderboardPoints: 0,
      status: UserStatus.active,
      role: UserRole.admin,
    );

    final routes = routesForSession(const SessionActive(user));

    expect(routes, hasLength(1));
    expect(routes!.single, isA<MainRoute>());
  });

  test('routes active citizens to the resident dashboard', () {
    const user = SessionUser(
      id: 'citizen-1',
      name: 'Citizen',
      email: 'citizen@example.com',
      phoneNumber: '081234567891',
      birthDate: '1990-01-01',
      balance: 0,
      leaderboardPoints: 0,
      status: UserStatus.active,
      role: UserRole.citizen,
    );

    final routes = routesForSession(const SessionActive(user));

    expect(routes, hasLength(1));
    expect(routes!.single, isA<MainRoute>());
  });

  Future<
    ({
      SessionCubit cubit,
      _SessionAdapter adapter,
      AppRouter router,
      _MemoryTokenStore tokenStore,
    })
  >
  pumpSessionApp(
    WidgetTester tester, {
    required String? token,
    String status = 'PENDING',
    int responseStatus = 200,
    int balance = 1200,
    int leaderboardPoints = 90,
  }) async {
    tester.view.devicePixelRatio = 2;
    tester.view.physicalSize = const Size(780, 1688);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await getIt.reset();
    getIt.registerFactory<HomeCubit>(
      () =>
          HomeCubit(_EmptyEventsRepository(), _EmptyAnnouncementsRepository()),
    );

    final adapter = _SessionAdapter(
      status: status,
      responseStatus: responseStatus,
      balance: balance,
      leaderboardPoints: leaderboardPoints,
    );
    final tokenStore = _MemoryTokenStore(token);
    final bus = SessionInvalidationBus();
    final dio = _TestDioModule().dio(tokenStore, bus)
      ..httpClientAdapter = adapter;
    final repository = AuthRepositoryImpl(
      AuthRemoteDataSourceImpl(dio),
      tokenStore,
    );
    final cubit = SessionCubit(repository, bus);
    final router = AppRouter(cubit);

    addTearDown(() async {
      await cubit.close();
      bus.dispose();
      await getIt.reset();
    });

    await tester.pumpWidget(
      BlocProvider.value(
        value: cubit,
        child: MainApp(appRouter: router),
      ),
    );
    await tester.pumpAndSettle();
    return (
      cubit: cubit,
      adapter: adapter,
      router: router,
      tokenStore: tokenStore,
    );
  }

  testWidgets('opens login when no saved token exists', (tester) async {
    await pumpSessionApp(tester, token: null);

    expect(find.text('Selamat Datang!'), findsOneWidget);
    expect(find.text('Masuk'), findsOneWidget);
  });

  testWidgets('opens pending approval and enters the app after approval', (
    tester,
  ) async {
    final harness = await pumpSessionApp(tester, token: 'pending-token');

    expect(find.text('Menunggu Persetujuan'), findsOneWidget);
    expect(harness.adapter.lastAuthorization, 'Bearer pending-token');
    harness.adapter.status = 'ACTIVE';

    await tester.tap(find.text('Cek Status'));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();

    expect(find.byType(MainPage), findsOneWidget);
    expect(find.text('Selamat Siang, Olivia Rhye!'), findsOneWidget);
    expect(find.text('1.200'), findsOneWidget);
    expect(find.text('Menunggu Persetujuan'), findsNothing);
  });

  testWidgets('home shows spendable balance instead of leaderboard points', (
    tester,
  ) async {
    await pumpSessionApp(
      tester,
      token: 'active-token',
      status: 'ACTIVE',
      balance: 4750,
      leaderboardPoints: 0,
    );

    expect(find.text('4.750'), findsOneWidget);
    expect(find.text('0'), findsNothing);
  });

  testWidgets('balance updates do not reset the active route', (tester) async {
    final harness = await pumpSessionApp(
      tester,
      token: 'active-token',
      status: 'ACTIVE',
    );
    unawaited(harness.router.push<void>(const NotificationRoute()));
    await tester.pumpAndSettle();
    expect(find.text('Notifikasi'), findsOneWidget);

    harness.cubit.updateBalance(750);
    await tester.pumpAndSettle();

    expect(find.text('Notifikasi'), findsOneWidget);
    final state = harness.cubit.state as SessionActive;
    expect(state.user.balance, 750);
  });

  testWidgets('routes a pending login and stores its token', (tester) async {
    final harness = await pumpSessionApp(tester, token: null);

    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), 'olivia@example.com');
    await tester.enterText(fields.at(1), 'password123');
    await tester.tap(find.text('Masuk'));
    await tester.pumpAndSettle();

    expect(find.text('Menunggu Persetujuan'), findsOneWidget);
    expect(harness.tokenStore.token, 'login-token');
  });

  testWidgets('opens the rejection state for a rejected resident', (
    tester,
  ) async {
    await pumpSessionApp(tester, token: 'rejected-token', status: 'REJECTED');

    expect(find.text('Pendaftaran Ditolak'), findsOneWidget);
    expect(find.text('Kembali ke Login'), findsOneWidget);
  });

  testWidgets('clears an expired session and returns to login', (tester) async {
    await pumpSessionApp(tester, token: 'expired-token', responseStatus: 401);

    expect(find.text('Selamat Datang!'), findsOneWidget);
  });

  testWidgets('keeps the token when session refresh fails temporarily', (
    tester,
  ) async {
    final harness = await pumpSessionApp(
      tester,
      token: 'retry-token',
      responseStatus: 503,
    );

    expect(find.text('Tidak dapat memeriksa sesi'), findsOneWidget);
    expect(find.text('Coba Lagi'), findsOneWidget);
    expect(harness.tokenStore.token, 'retry-token');
  });
}

class _EmptyEventsRepository implements CommunityEventsRepository {
  @override
  Future<CommunityEvent> getEvent(String eventId) => throw UnimplementedError();

  @override
  Future<List<CommunityEvent>> getEvents(EventTimeframe timeframe) async => [];
}

class _EmptyAnnouncementsRepository implements AnnouncementsRepository {
  @override
  Future<List<CommunityAnnouncement>> getAnnouncements() async => [];

  @override
  Future<void> createAnnouncement({
    required String title,
    required String description,
  }) => throw UnimplementedError();

  @override
  Future<void> deleteAnnouncement(String announcementId) =>
      throw UnimplementedError();

  @override
  Future<CommunityAnnouncement> updateAnnouncement({
    required String announcementId,
    required String title,
    required String description,
  }) => throw UnimplementedError();
}
