import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kompak_app/core/auth/session_invalidation_bus.dart';
import 'package:kompak_app/core/auth/session_token_store.dart';
import 'package:kompak_app/core/di/injection.dart';
import 'package:kompak_app/core/network/dio_module.dart';
import 'package:kompak_app/features/admin/providers/domain/entities/admin_point_shop_product.dart';
import 'package:kompak_app/features/admin/rewards/data/datasources/admin_leaderboard_rewards_remote_data_source.dart';
import 'package:kompak_app/features/admin/rewards/data/repositories/admin_leaderboard_rewards_repository_impl.dart';
import 'package:kompak_app/features/admin/rewards/domain/entities/admin_leaderboard_reward.dart';
import 'package:kompak_app/features/admin/rewards/presentation/bloc/admin_leaderboard_rewards_cubit.dart';
import 'package:kompak_app/features/admin/rewards/presentation/bloc/admin_leaderboard_rewards_state.dart';
import 'package:kompak_app/features/admin/rewards/presentation/pages/admin_leaderboard_rewards_page.dart';

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

class _LeaderboardRewardsAdapter implements HttpClientAdapter {
  final requests = <RequestOptions>[];
  var active = true;

  Map<String, dynamic> get reward => {
    'id': 'leaderboard-reward-1',
    'providerId': 'provider-1',
    'name': 'Voucher Sembako Premium',
    'description': 'Hadiah juara warga',
    'pointsRequired': 0,
    'stock': 1,
    'type': 'VOUCHER',
    'source': 'LEADERBOARD',
    'status': active ? 'ACTIVE' : 'INACTIVE',
    'leaderboardPosition': 1,
    'imageUrl': null,
    'validityDays': 7,
    'provider': {'id': 'provider-1', 'name': 'Warung Warga', 'logoUrl': null},
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
        options.path == '/rewards/admin/leaderboard') {
      return _json({
        'success': true,
        'data': active ? [reward] : [],
      });
    }
    if (options.method == 'POST' && options.path == '/rewards') {
      final data = Map<String, dynamic>.from(options.data as Map);
      return _json({
        'success': true,
        'data': {...reward, ...data, 'id': 'created-reward', 'status': 'ACTIVE'}
          ..remove('provider'),
      }, statusCode: 201);
    }
    if (options.method == 'PATCH' &&
        options.path == '/rewards/leaderboard-reward-1') {
      final data = Map<String, dynamic>.from(options.data as Map);
      if (data['status'] == 'INACTIVE') active = false;
      return _json({
        'success': true,
        'data': {...reward, ...data}..remove('provider'),
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
  Future<
    ({
      _LeaderboardRewardsAdapter adapter,
      AdminLeaderboardRewardsRepositoryImpl repository,
      SessionInvalidationBus bus,
    })
  >
  createHarness() async {
    final adapter = _LeaderboardRewardsAdapter();
    final bus = SessionInvalidationBus();
    final dio = _TestDioModule().dio(_MemoryTokenStore('admin-token'), bus)
      ..httpClientAdapter = adapter;
    final repository = AdminLeaderboardRewardsRepositoryImpl(
      AdminLeaderboardRewardsRemoteDataSourceImpl(dio),
    );
    addTearDown(bus.dispose);
    return (adapter: adapter, repository: repository, bus: bus);
  }

  test('maps rank configuration and writes the leaderboard contract', () async {
    final harness = await createHarness();
    final rewards = await harness.repository.getRewards();
    expect(rewards.single.position, 1);
    expect(rewards.single.provider.name, 'Warung Warga');

    await harness.repository.createReward(
      const AdminLeaderboardRewardDraft(
        providerId: 'provider-1',
        name: 'Paket Juara Dua',
        description: 'Hadiah peringkat dua',
        type: AdminPointShopProductType.product,
        position: 2,
      ),
    );
    final request = harness.adapter.requests.last;
    expect(request.data, {
      'providerId': 'provider-1',
      'name': 'Paket Juara Dua',
      'description': 'Hadiah peringkat dua',
      'pointsRequired': 0,
      'stock': 1,
      'type': 'PRODUCT',
      'source': 'LEADERBOARD',
      'leaderboardPosition': 2,
    });

    await harness.repository.archiveReward('leaderboard-reward-1');
    expect(harness.adapter.active, isFalse);
  });

  test('cubit exposes configured and empty rank slots', () async {
    final harness = await createHarness();
    final cubit = AdminLeaderboardRewardsCubit(harness.repository);
    addTearDown(cubit.close);
    await cubit.load();

    final state = cubit.state as AdminLeaderboardRewardsLoaded;
    expect(state.rewardAt(1)?.name, 'Voucher Sembako Premium');
    expect(state.rewardAt(2), isNull);
    expect(state.rewardAt(3), isNull);
  });

  testWidgets('renders Figma filled and empty leaderboard reward states', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 1100);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await getIt.reset();
    final harness = await createHarness();
    getIt.registerFactory<AdminLeaderboardRewardsCubit>(
      () => AdminLeaderboardRewardsCubit(harness.repository),
    );
    addTearDown(getIt.reset);

    await tester.pumpWidget(
      const MaterialApp(home: AdminLeaderboardRewardsPage()),
    );
    await tester.pumpAndSettle();

    expect(find.text('Hadiah Peringkat'), findsOneWidget);
    expect(find.text('Voucher Sembako Premium'), findsOneWidget);
    expect(find.text('Peringkat 1'), findsOneWidget);
    expect(find.text('Edit Hadiah'), findsOneWidget);
    expect(find.text('Hadiah masih kosong'), findsNWidgets(2));
    expect(find.text('Aturan Reset Otomatis'), findsOneWidget);
    expect(find.text('Bulanan (Standard)'), findsOneWidget);
  });
}
