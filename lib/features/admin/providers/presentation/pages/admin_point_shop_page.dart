import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../../core/di/injection.dart';
import '../../../../../core/routes/app_router.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../domain/entities/admin_point_shop_product.dart';
import '../bloc/admin_point_shop_cubit.dart';
import '../bloc/admin_point_shop_state.dart';

@RoutePage()
class AdminPointShopPage extends StatelessWidget {
  const AdminPointShopPage({this.providerId, this.providerName, super.key});

  final String? providerId;
  final String? providerName;

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => getIt<AdminPointShopCubit>()
      ..initialize(
        status: AdminPointShopProductStatus.active,
        providerId: providerId,
      ),
    child: _AdminPointShopView(
      providerId: providerId,
      providerName: providerName,
      isAdding: false,
    ),
  );
}

@RoutePage()
class AdminPointShopAddPage extends StatelessWidget {
  const AdminPointShopAddPage({this.providerId, this.providerName, super.key});

  final String? providerId;
  final String? providerName;

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => getIt<AdminPointShopCubit>()
      ..initialize(
        status: AdminPointShopProductStatus.inactive,
        providerId: providerId,
      ),
    child: _AdminPointShopView(
      providerId: providerId,
      providerName: providerName,
      isAdding: true,
    ),
  );
}

class _AdminPointShopView extends StatefulWidget {
  const _AdminPointShopView({
    required this.providerId,
    required this.providerName,
    required this.isAdding,
  });

  final String? providerId;
  final String? providerName;
  final bool isAdding;

  @override
  State<_AdminPointShopView> createState() => _AdminPointShopViewState();
}

class _AdminPointShopViewState extends State<_AdminPointShopView> {
  final _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _search(String value) {
    _debounce?.cancel();
    _debounce = Timer(
      const Duration(milliseconds: 350),
      () => context.read<AdminPointShopCubit>().search(value),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AdminPointShopCubit, AdminPointShopState>(
      listenWhen: (previous, current) =>
          current is AdminPointShopLoaded &&
          current.actionMessage != null &&
          (previous is! AdminPointShopLoaded ||
              previous.actionMessage != current.actionMessage),
      listener: (context, state) {
        if (state case AdminPointShopLoaded(actionMessage: final message?)) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(message)));
        }
      },
      builder: (context, state) => Scaffold(
        backgroundColor: const Color(0xFFFEFFFF),
        appBar: AppBar(
          backgroundColor: const Color(0xFFFEFFFF),
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            onPressed: () => context.router.maybePop(),
            icon: const Icon(Icons.chevron_left_rounded, size: 28),
          ),
          title: Text(
            widget.isAdding
                ? 'Tambah Produk Toko Poin'
                : 'Daftar Produk Toko Poin',
            style: const TextStyle(
              color: Color(0xFF2F3236),
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          centerTitle: true,
        ),
        floatingActionButton: widget.isAdding
            ? null
            : FloatingActionButton(
                key: const ValueKey('admin-point-shop-add'),
                onPressed: () => context.router.push(
                  AdminPointShopAddRoute(
                    providerId: widget.providerId,
                    providerName: widget.providerName,
                  ),
                ),
                elevation: 0,
                backgroundColor: KompakColors.success,
                foregroundColor: Colors.white,
                shape: const CircleBorder(),
                child: const Icon(Icons.add_rounded, size: 38),
              ),
        body: switch (state) {
          AdminPointShopLoaded() => _ProductList(
            state: state,
            controller: _searchController,
            onSearch: _search,
            isAdding: widget.isAdding,
            providerName: widget.providerName,
          ),
          AdminPointShopFailure() => _FailureView(
            message: state.message,
            onRetry: context.read<AdminPointShopCubit>().load,
          ),
          _ => const Center(child: CircularProgressIndicator()),
        },
      ),
    );
  }
}

class _ProductList extends StatelessWidget {
  const _ProductList({
    required this.state,
    required this.controller,
    required this.onSearch,
    required this.isAdding,
    required this.providerName,
  });

  final AdminPointShopLoaded state;
  final TextEditingController controller;
  final ValueChanged<String> onSearch;
  final bool isAdding;
  final String? providerName;

  @override
  Widget build(BuildContext context) {
    final pagination = state.data.pagination;
    return RefreshIndicator(
      onRefresh: context.read<AdminPointShopCubit>().refresh,
      child: ListView(
        key: ValueKey(isAdding ? 'point-shop-add-scroll' : 'point-shop-scroll'),
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 100),
        children: [
          if (providerName != null) ...[
            Text(
              providerName!,
              style: const TextStyle(
                color: Color(0xFF5F6672),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
          ],
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  onChanged: onSearch,
                  decoration: InputDecoration(
                    hintText: 'Cari Produk',
                    hintStyle: const TextStyle(
                      color: Color(0xFF8D9199),
                      fontSize: 14,
                    ),
                    prefixIcon: const Icon(
                      Icons.search_rounded,
                      color: Color(0xFF8D9199),
                      size: 19,
                    ),
                    filled: true,
                    fillColor: const Color(0xFFF1F1F2),
                    contentPadding: const EdgeInsets.symmetric(vertical: 13),
                    border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              OutlinedButton.icon(
                key: const ValueKey('point-shop-filter'),
                onPressed: () => _showFilter(context, state.type),
                icon: const Icon(Icons.filter_list_rounded, size: 17),
                label: const Text('Filter'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF2F3236),
                  side: const BorderSide(color: Color(0xFFF1F1F2)),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 13,
                    vertical: 13,
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
            _EmptyProducts(isAdding: isAdding)
          else
            for (final product in state.data.items) ...[
              _ProductCard(
                product: product,
                isAdding: isAdding,
                updating: state.updatingProductId == product.id,
              ),
              const SizedBox(height: 14),
            ],
          if (pagination.total > 0) ...[
            const SizedBox(height: 2),
            _Pagination(
              page: pagination.page,
              totalPages: pagination.totalPages,
              total: pagination.total,
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _showFilter(
    BuildContext context,
    AdminPointShopProductType? current,
  ) async {
    final selected = await showModalBottomSheet<AdminPointShopProductType?>(
      context: context,
      showDragHandle: true,
      backgroundColor: Colors.white,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: RadioGroup<AdminPointShopProductType?>(
            groupValue: current,
            onChanged: (value) => Navigator.of(sheetContext).pop(value),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Jenis Produk',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
                RadioListTile<AdminPointShopProductType?>(
                  value: null,
                  title: const Text('Semua jenis'),
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
      ),
    );
    if (context.mounted && selected != current) {
      await context.read<AdminPointShopCubit>().filter(selected);
    }
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({
    required this.product,
    required this.isAdding,
    required this.updating,
  });

  final AdminPointShopProduct product;
  final bool isAdding;
  final bool updating;

  @override
  Widget build(BuildContext context) {
    return Container(
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
              Positioned(
                right: 12,
                top: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 11,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: isAdding
                        ? const Color(0xFF8D9199)
                        : KompakColors.success,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    isAdding ? 'Belum di toko' : 'Aktif',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              if (product.stock == 0)
                Positioned.fill(
                  child: ColoredBox(
                    color: const Color(0x550B1C30),
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: .9),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: const Text(
                          'Segera Restock',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(14),
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
                          color: Color(0xFF2F3236),
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.stars_rounded,
                      color: KompakColors.warning,
                      size: 15,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      NumberFormat.decimalPattern(
                        'id_ID',
                      ).format(product.pointsRequired),
                      style: const TextStyle(
                        color: KompakColors.warning,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 7),
                Row(
                  children: [
                    Icon(
                      Icons.inventory_2_outlined,
                      size: 14,
                      color: product.stock == 0
                          ? KompakColors.error
                          : const Color(0xFFB0B2B3),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Stock: ${product.stock}',
                      style: TextStyle(
                        color: product.stock == 0
                            ? KompakColors.error
                            : const Color(0xFFB0B2B3),
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                FilledButton(
                  key: ValueKey('point-shop-product-${product.id}'),
                  onPressed: updating
                      ? null
                      : () => isAdding
                            ? context.read<AdminPointShopCubit>().toggleProduct(
                                product,
                              )
                            : _confirmRemove(context),
                  style: FilledButton.styleFrom(
                    backgroundColor: isAdding
                        ? KompakColors.success
                        : const Color(0xFFFAC5C1),
                    foregroundColor: isAdding
                        ? Colors.white
                        : KompakColors.error,
                    disabledBackgroundColor: const Color(0xFFF1F1F2),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: updating
                      ? const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(isAdding ? 'Tambahkan ke Toko' : 'Hapus'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmRemove(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Hapus dari Toko Poin?'),
        content: Text(
          '${product.name} tidak lagi terlihat oleh warga, tetapi data produk tetap tersimpan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: FilledButton.styleFrom(backgroundColor: KompakColors.error),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await context.read<AdminPointShopCubit>().toggleProduct(product);
    }
  }
}

class _ProductImage extends StatelessWidget {
  const _ProductImage({required this.product});

  final AdminPointShopProduct product;

  @override
  Widget build(BuildContext context) {
    final fallback = ColoredBox(
      color: KompakColors.primarySurface,
      child: Center(
        child: Icon(
          switch (product.type) {
            AdminPointShopProductType.voucher =>
              Icons.confirmation_number_outlined,
            AdminPointShopProductType.product => Icons.redeem_outlined,
            AdminPointShopProductType.service => Icons.handyman_outlined,
            AdminPointShopProductType.other => Icons.card_giftcard_outlined,
          },
          color: KompakColors.primary,
          size: 48,
        ),
      ),
    );
    final url = product.imageUrl;
    return SizedBox(
      height: 160,
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

class _Pagination extends StatelessWidget {
  const _Pagination({
    required this.page,
    required this.totalPages,
    required this.total,
  });

  final int page;
  final int totalPages;
  final int total;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: const Color(0xFFE5EEFF),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      children: [
        Expanded(
          child: Text(
            'Menampilkan halaman $page\ndari $total Produk',
            style: const TextStyle(color: Color(0xFF3D4A42), fontSize: 12),
          ),
        ),
        IconButton.filled(
          onPressed: page > 1
              ? () => context.read<AdminPointShopCubit>().goToPage(page - 1)
              : null,
          style: IconButton.styleFrom(
            backgroundColor: Colors.white,
            disabledBackgroundColor: Colors.white.withValues(alpha: .5),
          ),
          icon: const Icon(Icons.chevron_left_rounded),
        ),
        const SizedBox(width: 8),
        Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: KompakColors.success,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '$page',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: 8),
        IconButton.filled(
          onPressed: page < totalPages
              ? () => context.read<AdminPointShopCubit>().goToPage(page + 1)
              : null,
          style: IconButton.styleFrom(
            backgroundColor: Colors.white,
            disabledBackgroundColor: Colors.white.withValues(alpha: .5),
          ),
          icon: const Icon(Icons.chevron_right_rounded),
        ),
      ],
    ),
  );
}

class _EmptyProducts extends StatelessWidget {
  const _EmptyProducts({required this.isAdding});
  final bool isAdding;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 42),
    decoration: BoxDecoration(
      color: const Color(0xFFF5F7FB),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      children: [
        Icon(
          isAdding ? Icons.playlist_add_check_rounded : Icons.storefront,
          color: KompakColors.primary,
          size: 44,
        ),
        const SizedBox(height: 12),
        Text(
          isAdding
              ? 'Tidak ada produk yang dapat ditambahkan'
              : 'Belum ada produk di Toko Poin',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 5),
        Text(
          isAdding
              ? 'Produk nonaktif dari provider akan muncul di sini.'
              : 'Tekan tombol tambah untuk memilih produk provider.',
          textAlign: TextAlign.center,
          style: const TextStyle(color: Color(0xFF8D9199)),
        ),
      ],
    ),
  );
}

class _FailureView extends StatelessWidget {
  const _FailureView({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function({bool showLoading}) onRetry;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.cloud_off_outlined, size: 44),
          const SizedBox(height: 12),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () => onRetry(),
            child: const Text('Coba Lagi'),
          ),
        ],
      ),
    ),
  );
}
