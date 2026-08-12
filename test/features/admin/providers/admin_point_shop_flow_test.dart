import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kompak_app/core/auth/session_invalidation_bus.dart';
import 'package:kompak_app/core/auth/session_token_store.dart';
import 'package:kompak_app/core/di/injection.dart';
import 'package:kompak_app/core/network/dio_module.dart';
import 'package:kompak_app/features/admin/providers/data/datasources/admin_point_shop_remote_data_source.dart';
import 'package:kompak_app/features/admin/providers/data/repositories/admin_point_shop_repository_impl.dart';
import 'package:kompak_app/features/admin/providers/domain/entities/admin_point_shop_product.dart';
import 'package:kompak_app/features/admin/providers/presentation/bloc/admin_point_shop_cubit.dart';
import 'package:kompak_app/features/admin/providers/presentation/bloc/admin_point_shop_state.dart';
import 'package:kompak_app/features/admin/providers/presentation/pages/admin_point_shop_page.dart';

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

class _PointShopAdapter implements HttpClientAdapter {
  final requests = <RequestOptions>[];
  var productStatus = 'ACTIVE';

  Map<String, dynamic> get product => {
    'id': 'reward-1',
    'providerId': 'provider-1',
    'name': 'Voucher Sembako Premium',
    'description': 'Voucher belanja warga',
    'pointsRequired': 250,
    'stock': 24,
    'type': 'VOUCHER',
    'source': 'POINT_SHOP',
    'status': productStatus,
    'isFeatured': true,
    'imageUrl': null,
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
    if (options.method == 'GET' &&
        options.path == '/rewards/admin/point-shop') {
      final requestedStatus = options.queryParameters['status'];
      final items = requestedStatus == productStatus ? [product] : const [];
      return _json({
        'success': true,
        'data': {
          'items': items,
          'pagination': {
            'page': options.queryParameters['page'] ?? 1,
            'pageSize': options.queryParameters['pageSize'] ?? 3,
            'total': items.length,
            'totalPages': items.isEmpty ? 0 : 1,
          },
        },
      });
    }
    if (options.method == 'PATCH' && options.path == '/rewards/reward-1') {
      productStatus =
          Map<String, dynamic>.from(options.data as Map)['status'] as String;
      return _json({'success': true, 'data': product});
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
      _PointShopAdapter adapter,
      AdminPointShopRepositoryImpl repository,
      SessionInvalidationBus bus,
    })
  >
  createHarness() async {
    final adapter = _PointShopAdapter();
    final bus = SessionInvalidationBus();
    final dio = _TestDioModule().dio(_MemoryTokenStore('admin-token'), bus)
      ..httpClientAdapter = adapter;
    final repository = AdminPointShopRepositoryImpl(
      AdminPointShopRemoteDataSourceImpl(dio),
    );
    addTearDown(bus.dispose);
    return (adapter: adapter, repository: repository, bus: bus);
  }

  test('maps global and provider-specific Point Shop queries', () async {
    final harness = await createHarness();
    final page = await harness.repository.getProducts(
      status: AdminPointShopProductStatus.active,
      query: 'Voucher',
      type: AdminPointShopProductType.voucher,
      providerId: 'provider-1',
    );

    expect(page.items.single.name, 'Voucher Sembako Premium');
    expect(page.items.single.pointsRequired, 250);
    expect(harness.adapter.requests.single.queryParameters, {
      'status': 'ACTIVE',
      'query': 'Voucher',
      'type': 'VOUCHER',
      'providerId': 'provider-1',
      'page': 1,
      'pageSize': 3,
    });
  });

  test(
    'cubit removes a product through the reversible status lifecycle',
    () async {
      final harness = await createHarness();
      final cubit = AdminPointShopCubit(harness.repository);
      addTearDown(cubit.close);

      await cubit.initialize(status: AdminPointShopProductStatus.active);
      final product = (cubit.state as AdminPointShopLoaded).data.items.single;
      await cubit.toggleProduct(product);

      expect(harness.adapter.productStatus, 'INACTIVE');
      final state = cubit.state as AdminPointShopLoaded;
      expect(state.data.items, isEmpty);
      expect(state.actionMessage, 'Produk dihapus dari Toko Poin.');
    },
  );

  testWidgets('renders the Figma Point Shop product list with API data', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 1000);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await getIt.reset();
    final harness = await createHarness();
    getIt.registerFactory<AdminPointShopCubit>(
      () => AdminPointShopCubit(harness.repository),
    );
    addTearDown(getIt.reset);

    await tester.pumpWidget(const MaterialApp(home: AdminPointShopPage()));
    await tester.pumpAndSettle();

    expect(find.text('Daftar Produk Toko Poin'), findsOneWidget);
    expect(find.text('Cari Produk'), findsOneWidget);
    expect(find.text('Filter'), findsOneWidget);
    expect(find.text('Voucher Sembako Premium'), findsOneWidget);
    expect(find.text('Stock: 24'), findsOneWidget);
    expect(find.text('Aktif'), findsOneWidget);
    expect(find.text('Hapus'), findsOneWidget);
    expect(find.byKey(const ValueKey('admin-point-shop-add')), findsOneWidget);
  });
}
