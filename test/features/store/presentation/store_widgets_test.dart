import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kompak_app/features/store/domain/entities/store_data.dart';
import 'package:kompak_app/features/store/presentation/widgets/category_chips.dart';
import 'package:kompak_app/features/store/presentation/widgets/reward_redemption_dialog.dart';
import 'package:kompak_app/features/store/presentation/widgets/store_points_card.dart';

void main() {
  const provider = RewardProvider(
    id: 'provider-1',
    name: 'Warung Kompak',
    address: 'Jl. Warga No. 1',
    latitude: -6.2,
    longitude: 106.8,
  );
  const item = StoreItem(
    id: 'reward-1',
    title: 'Voucher Belanja',
    description: 'Voucher kebutuhan warga.',
    imageUrlOrIcon: 'confirmation_number_outlined',
    points: 500,
    stock: 3,
    validityDays: 7,
    rewardType: RewardType.voucher,
    provider: provider,
    isFeatured: true,
    itemType: ItemType.icon,
  );

  testWidgets('point card uses Indonesian formatting and opens history', (
    tester,
  ) async {
    var opened = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StorePointsCard(
            stats: const StoreStats(totalPoints: 1250),
            onHistoryTap: () => opened = true,
          ),
        ),
      ),
    );

    expect(find.text('1.250'), findsOneWidget);
    expect(find.text('Riwayat Poin'), findsOneWidget);
    await tester.tap(find.text('Riwayat Poin'));
    expect(opened, isTrue);
  });

  testWidgets('category chips keep the API-backed category labels', (
    tester,
  ) async {
    String? selected;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CategoryChips(
            categories: const [
              StoreCategory(id: 'all', name: 'Semua Item'),
              StoreCategory(id: 'VOUCHER', name: 'Voucher'),
              StoreCategory(id: 'PRODUCT', name: 'Produk'),
            ],
            activeCategoryId: 'all',
            onCategorySelected: (id) => selected = id,
          ),
        ),
      ),
    );

    expect(find.text('Produk'), findsOneWidget);
    expect(find.text('Poduk'), findsNothing);
    await tester.tap(find.text('Voucher'));
    expect(selected, 'VOUCHER');
  });

  testWidgets('new redemption celebrates creation but keeps pending status', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: RewardRedemptionDialog(
            createdNow: true,
            redemption: RewardRedemption(
              id: 'redemption-1',
              item: item,
              pointsSpent: 500,
              status: RedemptionStatus.pending,
              createdAt: DateTime(2026, 8, 11, 10, 30),
              expiresAt: DateTime(2026, 8, 18, 10, 30),
              balance: 750,
              claimToken: 'signed-token',
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Penukaran Berhasil!'), findsOneWidget);
    expect(find.text('Menunggu Pengambilan'), findsOneWidget);
    expect(find.text('Unduh QR'), findsOneWidget);
    expect(find.text('Kembali ke Beranda'), findsOneWidget);
    expect(find.text('Lihat Riwayat Poin'), findsOneWidget);
  });
}
