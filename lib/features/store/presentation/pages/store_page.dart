import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/routes/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/store_data.dart';
import '../bloc/store_cubit.dart';
import '../bloc/store_state.dart';
import '../widgets/category_chips.dart';
import '../widgets/featured_store_item.dart';
import '../widgets/store_item_grid_card.dart';
import '../widgets/store_points_card.dart';

@RoutePage()
class StorePage extends StatelessWidget {
  const StorePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<StoreCubit>()..loadStoreData(),
      child: const _StoreView(),
    );
  }
}

class _StoreView extends StatelessWidget {
  const _StoreView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KompakColors.surface,
      body: SafeArea(
        bottom: false,
        child: BlocBuilder<StoreCubit, StoreState>(
          builder: (context, state) => switch (state) {
            StoreLoading() => const _StoreLoadingState(),
            StoreError(:final message) => _StoreErrorState(
              message: message,
              onRetry: () => context.read<StoreCubit>().loadStoreData(),
            ),
            StoreLoaded() => _StoreLoadedView(state: state),
            _ => const SizedBox.shrink(),
          },
        ),
      ),
    );
  }
}

class _StoreLoadedView extends StatelessWidget {
  const _StoreLoadedView({required this.state});

  final StoreLoaded state;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => context.read<StoreCubit>().loadStoreData(),
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            sliver: SliverList.list(
              children: [
                StorePointsCard(
                  stats: state.stats,
                  onHistoryTap: () =>
                      context.router.push(const PointHistoryRoute()),
                ),
                const SizedBox(height: 16),
                CategoryChips(
                  categories: state.categories,
                  activeCategoryId: state.activeCategoryId,
                  onCategorySelected: (id) =>
                      context.read<StoreCubit>().changeCategory(id),
                ),
                if (state.featuredItem case final featured?) ...[
                  const SizedBox(height: 16),
                  FeaturedStoreItem(
                    item: featured,
                    onRedeem: () => _openRedemption(
                      context,
                      featured,
                      state.stats.totalPoints,
                    ),
                  ),
                ],
                const SizedBox(height: 14),
              ],
            ),
          ),
          if (state.regularItems.isNotEmpty)
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisExtent: 250,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                delegate: SliverChildBuilderDelegate((context, index) {
                  final item = state.regularItems[index];
                  return StoreItemGridCard(
                    item: item,
                    onRedeem: () =>
                        _openRedemption(context, item, state.stats.totalPoints),
                  );
                }, childCount: state.regularItems.length),
              ),
            )
          else if (state.featuredItem == null)
            const SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverToBoxAdapter(child: _StoreEmptyState()),
            ),
          const SliverPadding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 24),
            sliver: SliverToBoxAdapter(child: _EarnMorePointsCallout()),
          ),
        ],
      ),
    );
  }

  Future<void> _openRedemption(
    BuildContext context,
    StoreItem item,
    int availablePoints,
  ) async {
    final redeemed = await context.router.push<bool>(
      RedeemConfirmationRoute(item: item, availablePoints: availablePoints),
    );
    if (redeemed == true && context.mounted) {
      await context.read<StoreCubit>().loadStoreData();
    }
  }
}

class _EarnMorePointsCallout extends StatelessWidget {
  const _EarnMorePointsCallout();

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: KompakColors.primarySurface,
      borderRadius: BorderRadius.circular(12),
    ),
    child: const Row(
      children: [
        CircleAvatar(
          radius: 22,
          backgroundColor: KompakColors.primary,
          child: Icon(Icons.mood_rounded, color: Colors.white, size: 25),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Butuh Poin Tambahan?',
                style: TextStyle(
                  color: KompakColors.ink,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 3),
              Text(
                'Ikuti kegiatan warga dan lakukan presensi untuk mendapatkan poin kontribusi.',
                style: TextStyle(
                  color: KompakColors.mutedInk,
                  fontSize: 12,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _StoreLoadingState extends StatelessWidget {
  const _StoreLoadingState();

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(16),
    children: const [
      _Skeleton(height: 136, color: KompakColors.primarySurface),
      SizedBox(height: 16),
      Row(
        children: [
          _Skeleton(width: 84, height: 36),
          SizedBox(width: 8),
          _Skeleton(width: 76, height: 36),
          SizedBox(width: 8),
          _Skeleton(width: 92, height: 36),
        ],
      ),
      SizedBox(height: 16),
      _Skeleton(height: 340),
      SizedBox(height: 14),
      Row(
        children: [
          Expanded(child: _Skeleton(height: 250)),
          SizedBox(width: 12),
          Expanded(child: _Skeleton(height: 250)),
        ],
      ),
    ],
  );
}

class _Skeleton extends StatelessWidget {
  const _Skeleton({this.width, required this.height, this.color});

  final double? width;
  final double height;
  final Color? color;

  @override
  Widget build(BuildContext context) => Container(
    width: width,
    height: height,
    decoration: BoxDecoration(
      color: color ?? KompakColors.softSurface,
      borderRadius: BorderRadius.circular(12),
    ),
  );
}

class _StoreEmptyState extends StatelessWidget {
  const _StoreEmptyState();

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
    decoration: BoxDecoration(
      color: KompakColors.softSurface,
      borderRadius: BorderRadius.circular(12),
    ),
    child: const Column(
      children: [
        Icon(Icons.redeem_outlined, color: KompakColors.primary, size: 40),
        SizedBox(height: 12),
        Text(
          'Belum ada hadiah tersedia',
          style: TextStyle(
            color: KompakColors.ink,
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
        SizedBox(height: 6),
        Text(
          'Hadiah baru dari provider terverifikasi akan muncul di sini.',
          textAlign: TextAlign.center,
          style: TextStyle(color: KompakColors.mutedInk, height: 1.4),
        ),
      ],
    ),
  );
}

class _StoreErrorState extends StatelessWidget {
  const _StoreErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.storefront_outlined,
            size: 48,
            color: KompakColors.primary,
          ),
          const SizedBox(height: 12),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: onRetry, child: const Text('Coba Lagi')),
        ],
      ),
    ),
  );
}
