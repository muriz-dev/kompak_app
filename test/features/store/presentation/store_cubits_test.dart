import 'package:flutter_test/flutter_test.dart';
import 'package:kompak_app/features/store/domain/entities/store_data.dart';
import 'package:kompak_app/features/store/domain/repositories/point_shop_repository.dart';
import 'package:kompak_app/features/store/presentation/bloc/point_history_cubit.dart';
import 'package:kompak_app/features/store/presentation/bloc/redeem_cubit.dart';
import 'package:kompak_app/features/store/presentation/bloc/store_cubit.dart';
import 'package:kompak_app/features/store/presentation/bloc/store_state.dart';

void main() {
  const provider = RewardProvider(
    id: 'provider-1',
    name: 'Warung Kompak',
    address: 'Jl. Warga No. 1',
    latitude: -6.2,
    longitude: 106.8,
  );
  const voucher = StoreItem(
    id: 'reward-1',
    title: 'Voucher Belanja',
    description: 'Voucher dari provider.',
    imageUrlOrIcon: 'confirmation_number_outlined',
    points: 100,
    stock: 2,
    validityDays: 7,
    rewardType: RewardType.voucher,
    provider: provider,
    isFeatured: true,
    itemType: ItemType.icon,
  );
  const product = StoreItem(
    id: 'reward-2',
    title: 'Tas Belanja',
    description: 'Produk ramah lingkungan.',
    imageUrlOrIcon: 'redeem_outlined',
    points: 200,
    stock: 4,
    validityDays: 14,
    rewardType: RewardType.product,
    provider: provider,
    itemType: ItemType.icon,
  );

  test('loads the real catalog and filters it by API reward type', () async {
    final repository = _FakePointShopRepository(
      catalog: const PointShopData(balance: 350, items: [voucher, product]),
    );
    final cubit = StoreCubit(repository);

    await cubit.loadStoreData();
    final loaded = cubit.state as StoreLoaded;
    expect(loaded.stats.totalPoints, 350);
    expect(loaded.featuredItem, voucher);
    expect(loaded.categories.map((item) => item.id), [
      'all',
      'VOUCHER',
      'PRODUCT',
    ]);

    cubit.changeCategory('PRODUCT');
    final filtered = cubit.state as StoreLoaded;
    expect(filtered.featuredItem, isNull);
    expect(filtered.regularItems, [product]);
  });

  test('submits one redemption and exposes the server result', () async {
    final repository = _FakePointShopRepository(
      catalog: const PointShopData(balance: 350, items: [voucher]),
    );
    final cubit = RedeemCubit(repository);

    await cubit.redeem(voucher);

    expect(cubit.state, isA<RedeemSucceeded>());
    expect(repository.redeemCalls, 1);
    expect(repository.lastIdempotencyKey, startsWith('mobile-'));
  });

  test(
    'filters the unified point ledger without changing its balance',
    () async {
      final repository = _FakePointShopRepository(
        catalog: const PointShopData(balance: 350, items: []),
        history: PointHistoryData(
          balance: 350,
          entries: [
            PointHistoryEntry(
              id: 'in',
              direction: PointDirection.incoming,
              points: 50,
              title: 'Kerja Bakti',
              occurredAt: DateTime(2026),
              referenceType: 'EVENT',
            ),
            PointHistoryEntry(
              id: 'out',
              direction: PointDirection.outgoing,
              points: 100,
              title: 'Voucher Belanja',
              occurredAt: DateTime(2026),
              referenceType: 'REDEMPTION',
            ),
          ],
        ),
      );
      final cubit = PointHistoryCubit(repository);

      await cubit.load();
      cubit.changeFilter(PointHistoryFilter.outgoing);

      final loaded = cubit.state as PointHistoryLoaded;
      expect(loaded.balance, 350);
      expect(loaded.visibleEntries.single.id, 'out');
    },
  );
}

class _FakePointShopRepository implements PointShopRepository {
  _FakePointShopRepository({required this.catalog, PointHistoryData? history})
    : history = history ?? const PointHistoryData(balance: 0, entries: []);

  final PointShopData catalog;
  final PointHistoryData history;
  int redeemCalls = 0;
  String? lastIdempotencyKey;

  @override
  Future<PointShopData> getCatalog() async => catalog;

  @override
  Future<PointHistoryData> getPointHistory() async => history;

  @override
  Future<RewardRedemption> redeem({
    required StoreItem item,
    required String idempotencyKey,
  }) async {
    redeemCalls += 1;
    lastIdempotencyKey = idempotencyKey;
    return RewardRedemption(
      id: 'redemption-1',
      item: item,
      pointsSpent: item.points,
      status: RedemptionStatus.pending,
      createdAt: DateTime(2026),
      expiresAt: DateTime(2026, 1, 8),
      balance: catalog.balance - item.points,
      claimToken: 'signed-token',
    );
  }
}
