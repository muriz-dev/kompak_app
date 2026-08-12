import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kompak_app/core/auth/session_invalidation_bus.dart';
import 'package:kompak_app/core/auth/session_token_store.dart';
import 'package:kompak_app/core/di/injection.dart';
import 'package:kompak_app/core/network/dio_module.dart';
import 'package:kompak_app/features/admin/providers/data/datasources/admin_providers_remote_data_source.dart';
import 'package:kompak_app/features/admin/providers/data/repositories/admin_providers_repository_impl.dart';
import 'package:kompak_app/features/admin/providers/domain/entities/admin_provider.dart';
import 'package:kompak_app/features/admin/providers/presentation/bloc/admin_provider_detail_cubit.dart';
import 'package:kompak_app/features/admin/providers/presentation/bloc/admin_providers_cubit.dart';
import 'package:kompak_app/features/admin/providers/presentation/bloc/admin_providers_state.dart';
import 'package:kompak_app/features/admin/providers/presentation/pages/admin_providers_page.dart';

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

class _ProvidersAdapter implements HttpClientAdapter {
  final requests = <RequestOptions>[];
  var status = 'PENDING';

  Map<String, dynamic> get provider => {
    'id': 'provider-1',
    'ownerId': 'owner-1',
    'name': 'Warung Bu Harjo',
    'address': 'Jl. Harmoni, No. 12',
    'latitude': -6.2,
    'longitude': 106.8,
    'status': status,
    'logoUrl': null,
    'storePhotoUrl': null,
    'createdAt': DateTime(2026, 1, 12).millisecondsSinceEpoch,
    'updatedAt': DateTime(2026, 8, 12).millisecondsSinceEpoch,
    'owner': {
      'id': 'owner-1',
      'name': 'Siti Aminah',
      'email': 'siti@example.com',
      'phoneNumber': '081234567890',
    },
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

    if (options.method == 'GET' && options.path == '/providers/admin') {
      return _json({
        'success': true,
        'data': {
          'items': [provider],
          'pagination': {
            'page': options.queryParameters['page'] ?? 1,
            'pageSize': options.queryParameters['pageSize'] ?? 4,
            'total': 1,
            'totalPages': 1,
          },
        },
      });
    }

    if (options.method == 'GET' &&
        options.path == '/providers/admin/provider-1') {
      return _json({
        'success': true,
        'data': {
          ...provider,
          'stats': {'completedPoints': 1250, 'activeProducts': 1},
          'products': [
            {
              'id': 'reward-1',
              'name': 'Token Listrik',
              'pointsRequired': 250,
              'stock': 24,
              'type': 'VOUCHER',
              'status': 'ACTIVE',
              'imageUrl': null,
            },
          ],
        },
      });
    }

    if (options.method == 'PATCH' &&
        options.path == '/providers/provider-1/status') {
      status =
          Map<String, dynamic>.from(options.data as Map)['status'] as String;
      return _json({'success': true, 'data': provider});
    }

    return _json({'success': false, 'message': 'Not found'}, statusCode: 404);
  }

  ResponseBody _json(Map<String, dynamic> body, {int statusCode = 200}) =>
      ResponseBody.fromString(
        jsonEncode(body),
        statusCode,
        headers: {
          Headers.contentTypeHeader: ['application/json'],
        },
      );
}

void main() {
  Future<
    ({
      _ProvidersAdapter adapter,
      AdminProvidersRepositoryImpl repository,
      SessionInvalidationBus bus,
    })
  >
  createHarness() async {
    final adapter = _ProvidersAdapter();
    final bus = SessionInvalidationBus();
    final dio = _TestDioModule().dio(_MemoryTokenStore('admin-token'), bus)
      ..httpClientAdapter = adapter;
    final repository = AdminProvidersRepositoryImpl(
      AdminProvidersRemoteDataSourceImpl(dio),
    );
    addTearDown(bus.dispose);
    return (adapter: adapter, repository: repository, bus: bus);
  }

  test('maps provider list, detail, and status update contracts', () async {
    final harness = await createHarness();

    final page = await harness.repository.getProviders(
      query: 'Warung',
      status: AdminProviderStatus.pending,
      page: 1,
      pageSize: 4,
    );
    expect(page.items.single.name, 'Warung Bu Harjo');
    expect(page.items.single.ownerName, 'Siti Aminah');
    expect(page.pagination.total, 1);
    expect(harness.adapter.requests.first.queryParameters, {
      'query': 'Warung',
      'status': 'PENDING',
      'page': 1,
      'pageSize': 4,
    });

    final detail = await harness.repository.getProviderDetail('provider-1');
    expect(detail.stats.completedPoints, 1250);
    expect(detail.stats.activeProducts, 1);
    expect(detail.products.single.name, 'Token Listrik');

    await harness.repository.updateStatus(
      'provider-1',
      AdminProviderStatus.verified,
    );
    expect(harness.adapter.status, 'VERIFIED');
  });

  test('list cubit loads server pagination and filtering', () async {
    final harness = await createHarness();
    final cubit = AdminProvidersCubit(harness.repository);
    addTearDown(cubit.close);

    await cubit.load();
    expect(cubit.state, isA<AdminProvidersLoaded>());

    await cubit.filter(AdminProviderStatus.pending);
    final state = cubit.state as AdminProvidersLoaded;
    expect(state.status, AdminProviderStatus.pending);
    expect(state.data.items.single.id, 'provider-1');
  });

  testWidgets('renders Figma provider list with real API data', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 1000);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await getIt.reset();
    final harness = await createHarness();
    getIt.registerFactory<AdminProvidersCubit>(
      () => AdminProvidersCubit(harness.repository),
    );
    getIt.registerFactory<AdminProviderDetailCubit>(
      () => AdminProviderDetailCubit(harness.repository),
    );
    addTearDown(getIt.reset);

    await tester.pumpWidget(const MaterialApp(home: AdminProvidersPage()));
    await tester.pumpAndSettle();

    expect(find.text('Daftar Provider'), findsOneWidget);
    expect(find.text('Cari nama Provider'), findsOneWidget);
    expect(find.text('Filter'), findsOneWidget);
    expect(find.text('Warung Bu Harjo'), findsOneWidget);
    expect(find.text('Pemilik: Siti Aminah'), findsOneWidget);
    expect(find.text('Pending'), findsOneWidget);
    expect(find.text('Verifikasi Sekarang'), findsOneWidget);
    expect(find.text('Menampilkan 1-1\ndari 1 Provider'), findsOneWidget);
  });
}
