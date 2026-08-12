import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../../core/di/injection.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../providers/domain/entities/admin_point_shop_product.dart';
import '../../../providers/presentation/bloc/admin_point_shop_cubit.dart';
import '../../../providers/presentation/bloc/admin_point_shop_state.dart';

@RoutePage()
class AdminLeaderboardRewardPickerPage extends StatelessWidget {
  const AdminLeaderboardRewardPickerPage({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) =>
        getIt<AdminPointShopCubit>()
          ..initialize(status: AdminPointShopProductStatus.active),
    child: const _RewardPickerView(),
  );
}

class _RewardPickerView extends StatefulWidget {
  const _RewardPickerView();

  @override
  State<_RewardPickerView> createState() => _RewardPickerViewState();
}

class _RewardPickerViewState extends State<_RewardPickerView> {
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void _search(String query) {
    _debounce?.cancel();
    _debounce = Timer(
      const Duration(milliseconds: 350),
      () => context.read<AdminPointShopCubit>().search(query),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFEFFFF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFEFFFF),
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          onPressed: () => context.router.maybePop(),
          icon: const Icon(Icons.chevron_left_rounded, size: 28),
        ),
        title: const Text(
          'Edit Hadiah',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: BlocBuilder<AdminPointShopCubit, AdminPointShopState>(
        builder: (context, state) => switch (state) {
          AdminPointShopLoaded() => RefreshIndicator(
            onRefresh: context.read<AdminPointShopCubit>().refresh,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        onChanged: _search,
                        decoration: InputDecoration(
                          hintText: 'Cari Produk',
                          prefixIcon: const Icon(
                            Icons.search_rounded,
                            size: 19,
                          ),
                          filled: true,
                          fillColor: const Color(0xFFF1F1F2),
                          border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    OutlinedButton.icon(
                      onPressed: () => _filter(context, state.type),
                      icon: const Icon(Icons.filter_list_rounded, size: 17),
                      label: const Text('Filter'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF2F3236),
                        side: const BorderSide(color: Color(0xFFF1F1F2)),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 13,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (state.data.items.isEmpty)
                  const _EmptyPicker()
                else
                  for (final product in state.data.items) ...[
                    _PickerProductCard(product: product),
                    const SizedBox(height: 14),
                  ],
                if (state.data.pagination.totalPages > 1)
                  _PickerPagination(
                    page: state.data.pagination.page,
                    totalPages: state.data.pagination.totalPages,
                    total: state.data.pagination.total,
                  ),
              ],
            ),
          ),
          AdminPointShopFailure() => Center(child: Text(state.message)),
          _ => const Center(child: CircularProgressIndicator()),
        },
      ),
    );
  }

  Future<void> _filter(
    BuildContext context,
    AdminPointShopProductType? current,
  ) async {
    final selected = await showModalBottomSheet<AdminPointShopProductType?>(
      context: context,
      showDragHandle: true,
      backgroundColor: Colors.white,
      builder: (sheetContext) => SafeArea(
        child: RadioGroup<AdminPointShopProductType?>(
          groupValue: current,
          onChanged: (value) => Navigator.of(sheetContext).pop(value),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const ListTile(
                title: Text(
                  'Jenis Produk',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              const RadioListTile<AdminPointShopProductType?>(
                value: null,
                title: Text('Semua jenis'),
              ),
              for (final type in AdminPointShopProductType.values)
                RadioListTile<AdminPointShopProductType?>(
                  value: type,
                  title: Text(type.label),
                ),
            ],
          ),
        ),
      ),
    );
    if (context.mounted && selected != current) {
      await context.read<AdminPointShopCubit>().filter(selected);
    }
  }
}

class _PickerProductCard extends StatelessWidget {
  const _PickerProductCard({required this.product});
  final AdminPointShopProduct product;

  @override
  Widget build(BuildContext context) => Container(
    clipBehavior: Clip.antiAlias,
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(color: const Color(0xFFF1F1F2)),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Stack(
          children: [
            _ProductImage(product: product),
            const Positioned(
              top: 10,
              right: 10,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: KompakColors.success,
                  borderRadius: BorderRadius.all(Radius.circular(999)),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 11, vertical: 5),
                  child: Text(
                    'Aktif',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.all(13),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      product.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.stars_rounded,
                    size: 15,
                    color: KompakColors.warning,
                  ),
                  const SizedBox(width: 3),
                  Text(
                    NumberFormat.decimalPattern(
                      'id_ID',
                    ).format(product.pointsRequired),
                    style: const TextStyle(color: KompakColors.warning),
                  ),
                ],
              ),
              const SizedBox(height: 7),
              Text(
                'Stock: ${product.stock}',
                style: const TextStyle(color: Color(0xFFB0B2B3)),
              ),
              const SizedBox(height: 13),
              FilledButton(
                key: ValueKey('pick-leaderboard-reward-${product.id}'),
                onPressed: () => context.router.maybePop(product),
                style: FilledButton.styleFrom(
                  backgroundColor: KompakColors.success,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Pilih Reward'),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _ProductImage extends StatelessWidget {
  const _ProductImage({required this.product});
  final AdminPointShopProduct product;

  @override
  Widget build(BuildContext context) {
    final fallback = const ColoredBox(
      color: KompakColors.primarySurface,
      child: Center(
        child: Icon(
          Icons.redeem_outlined,
          size: 46,
          color: KompakColors.primary,
        ),
      ),
    );
    final url = product.imageUrl;
    return SizedBox(
      height: 150,
      width: double.infinity,
      child: url != null && url.isNotEmpty
          ? Image.network(
              url,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => fallback,
            )
          : fallback,
    );
  }
}

class _PickerPagination extends StatelessWidget {
  const _PickerPagination({
    required this.page,
    required this.totalPages,
    required this.total,
  });
  final int page;
  final int totalPages;
  final int total;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.end,
    children: [
      Text('$total Produk'),
      const Spacer(),
      IconButton(
        onPressed: page > 1
            ? () => context.read<AdminPointShopCubit>().goToPage(page - 1)
            : null,
        icon: const Icon(Icons.chevron_left_rounded),
      ),
      Text('$page / $totalPages'),
      IconButton(
        onPressed: page < totalPages
            ? () => context.read<AdminPointShopCubit>().goToPage(page + 1)
            : null,
        icon: const Icon(Icons.chevron_right_rounded),
      ),
    ],
  );
}

class _EmptyPicker extends StatelessWidget {
  const _EmptyPicker();

  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.symmetric(vertical: 60),
    child: Column(
      children: [
        Icon(Icons.inventory_2_outlined, size: 44, color: KompakColors.primary),
        SizedBox(height: 12),
        Text(
          'Belum ada produk aktif yang dapat dipilih.',
          textAlign: TextAlign.center,
        ),
      ],
    ),
  );
}
