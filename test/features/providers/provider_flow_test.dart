import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kompak_app/core/auth/session_invalidation_bus.dart';
import 'package:kompak_app/core/auth/session_token_store.dart';
import 'package:kompak_app/core/network/dio_module.dart';
import 'package:kompak_app/features/providers/data/datasources/provider_remote_data_source.dart';
import 'package:kompak_app/features/providers/data/repositories/provider_repository_impl.dart';
import 'package:kompak_app/features/providers/domain/entities/provider_account.dart';
import 'package:kompak_app/features/providers/presentation/bloc/provider_cubit.dart';
import 'package:kompak_app/features/providers/presentation/pages/provider_entry_page.dart';

class _MemoryTokenStore implements SessionTokenStore {
  @override
  Future<void> clear() async {}
  @override
  Future<String?> read() async => 'citizen-token';
  @override
  Future<void> write(String token) async {}
}

class _TestDioModule extends DioModule {}

class _ProviderAdapter implements HttpClientAdapter {
  final requests = <RequestOptions>[];
  String status = 'VERIFIED';

  Map<String, dynamic> get product => {
    'id': 'reward-1',
    'providerId': 'provider-1',
    'name': 'Voucher Belanja',
    'description': 'Voucher untuk warga',
    'pointsRequired': 250,
    'stock': 10,
    'type': 'VOUCHER',
    'source': 'POINT_SHOP',
    'status': 'ACTIVE',
    'imageUrl': null,
  };

  Map<String, dynamic> get account => {
    'id': 'provider-1',
    'ownerId': 'owner-1',
    'name': 'Warung Berkah',
    'address': 'Jl. Harmoni No. 12',
    'latitude': -6.2,
    'longitude': 106.8,
    'status': status,
    'logoUrl': null,
    'storePhotoUrl': null,
    'createdAt': DateTime(2026, 8, 1).millisecondsSinceEpoch,
    'owner': {
      'name': 'Ahmad',
      'email': 'ahmad@example.com',
      'phoneNumber': '081234567890',
    },
    'stats': {'completedPoints': 1250, 'activeProducts': 1},
    'products': [product],
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
    if (options.method == 'GET' && options.path == '/providers/me') {
      return _json({'success': true, 'data': account});
    }
    if (options.method == 'GET' && options.path == '/rewards/provider/me') {
      return _json({
        'success': true,
        'data': {
          'items': [product],
          'pagination': {
            'page': 1,
            'pageSize': 50,
            'total': 1,
            'totalPages': 1,
          },
        },
      });
    }
    if (options.method == 'POST' && options.path == '/rewards') {
      return _json({
        'success': true,
        'data': {...product, 'status': 'INACTIVE'},
      }, statusCode: 201);
    }
    if (options.method == 'PATCH' && options.path == '/rewards/reward-1') {
      return _json({
        'success': true,
        'data': {...product, ...Map<String, dynamic>.from(options.data as Map)},
      });
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
  Future<({ProviderRepositoryImpl repository, _ProviderAdapter adapter})>
  harness() async {
    final bus = SessionInvalidationBus();
    addTearDown(bus.dispose);
    final adapter = _ProviderAdapter();
    final dio = _TestDioModule().dio(_MemoryTokenStore(), bus)
      ..httpClientAdapter = adapter;
    return (
      repository: ProviderRepositoryImpl(ProviderRemoteDataSourceImpl(dio)),
      adapter: adapter,
    );
  }

  test('loads the owner-scoped provider dashboard contract', () async {
    final setup = await harness();
    final account = await setup.repository.getMyProvider();
    final products = await setup.repository.getMyProducts(query: 'Voucher');

    expect(account!.name, 'Warung Berkah');
    expect(account.stats.completedPoints, 1250);
    expect(products.single.name, 'Voucher Belanja');
    expect(setup.adapter.requests[1].queryParameters['query'], 'Voucher');
  });

  test('creates provider products as Point Shop offerings', () async {
    final setup = await harness();
    await setup.repository.createProduct(
      'provider-1',
      const ProviderProductDraft(
        name: 'Voucher Belanja',
        description: 'Voucher untuk warga',
        pointsRequired: 250,
        stock: 10,
        type: ProviderProductType.voucher,
      ),
    );
    final request = setup.adapter.requests.single;
    expect(request.path, '/rewards');
    expect(request.data, containsPair('source', 'POINT_SHOP'));
    expect(request.data, containsPair('providerId', 'provider-1'));
  });

  test('cubit resolves a verified account to its products', () async {
    final setup = await harness();
    final cubit = ProviderCubit(setup.repository);
    addTearDown(cubit.close);

    await cubit.load();
    final state = cubit.state as ProviderReady;
    expect(state.account.status, ProviderStatus.verified);
    expect(state.products.single.id, 'reward-1');
  });

  testWidgets('renders the filled provider dashboard structure', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 1000);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    final account = ProviderAccount.fromJson(_ProviderAdapter().account);

    await tester.pumpWidget(
      MaterialApp(
        home: ProviderDashboardView(
          state: ProviderReady(account: account, products: account.products),
          onRefresh: () async {},
          onSearch: (_) async {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Halo, Warung Berkah'), findsOneWidget);
    expect(find.text('TRANSAKSI POIN'), findsOneWidget);
    expect(find.text('PRODUK AKTIF'), findsOneWidget);
    expect(find.text('Voucher Belanja'), findsOneWidget);
    expect(find.text('Edit Produk'), findsOneWidget);
  });
}
