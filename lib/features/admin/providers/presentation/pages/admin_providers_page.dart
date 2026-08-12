import 'dart:async';
import 'dart:math' as math;

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/di/injection.dart';
import '../../../../../core/routes/app_router.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../domain/entities/admin_provider.dart';
import '../bloc/admin_providers_cubit.dart';
import '../bloc/admin_providers_state.dart';
import '../widgets/admin_provider_visuals.dart';

@RoutePage()
class AdminProvidersPage extends StatelessWidget {
  const AdminProvidersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<AdminProvidersCubit>()..load(),
      child: const _AdminProvidersView(),
    );
  }
}

class _AdminProvidersView extends StatefulWidget {
  const _AdminProvidersView();

  @override
  State<_AdminProvidersView> createState() => _AdminProvidersViewState();
}

class _AdminProvidersViewState extends State<_AdminProvidersView> {
  final _searchController = TextEditingController();
  Timer? _searchDebounce;

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFEFFFF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFEFFFF),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          key: const ValueKey('admin-providers-back'),
          onPressed: () => context.router.maybePop(),
          icon: const Icon(Icons.chevron_left_rounded, size: 28),
        ),
        title: const Text(
          'Daftar Provider',
          style: TextStyle(
            color: Color(0xFF2F3236),
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: BlocBuilder<AdminProvidersCubit, AdminProvidersState>(
        builder: (context, state) => switch (state) {
          AdminProvidersLoaded() => RefreshIndicator(
            onRefresh: context.read<AdminProvidersCubit>().refresh,
            child: ListView(
              key: const ValueKey('admin-providers-scroll'),
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
              children: [
                _SearchAndFilter(
                  controller: _searchController,
                  filterActive: state.status != null,
                  onChanged: _onSearchChanged,
                  onFilterPressed: () => _selectFilter(state.status),
                ),
                const SizedBox(height: 20),
                if (state.data.items.isEmpty)
                  _EmptyProviders(
                    filtered:
                        state.status != null || state.query.trim().isNotEmpty,
                    onReset: _resetFilters,
                  )
                else
                  for (var index = 0; index < state.data.items.length; index++)
                    Padding(
                      padding: EdgeInsets.only(
                        bottom: index == state.data.items.length - 1 ? 0 : 16,
                      ),
                      child: _ProviderCard(
                        provider: state.data.items[index],
                        onTap: () => _openProvider(state.data.items[index]),
                      ),
                    ),
                const SizedBox(height: 20),
                _ProvidersPagination(
                  pagination: state.data.pagination,
                  onPrevious: state.data.pagination.page > 1
                      ? () => context.read<AdminProvidersCubit>().goToPage(
                          state.data.pagination.page - 1,
                        )
                      : null,
                  onNext:
                      state.data.pagination.page <
                          state.data.pagination.totalPages
                      ? () => context.read<AdminProvidersCubit>().goToPage(
                          state.data.pagination.page + 1,
                        )
                      : null,
                ),
              ],
            ),
          ),
          AdminProvidersFailure() => _ProvidersFailure(
            message: state.message,
            onRetry: context.read<AdminProvidersCubit>().load,
          ),
          _ => const Center(child: CircularProgressIndicator()),
        },
      ),
    );
  }

  void _onSearchChanged(String value) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 400), () {
      if (!mounted) return;
      context.read<AdminProvidersCubit>().search(value);
    });
  }

  Future<void> _selectFilter(AdminProviderStatus? current) async {
    final selected = await showModalBottomSheet<_ProviderFilterChoice>(
      context: context,
      showDragHandle: true,
      backgroundColor: Colors.white,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Status Provider',
                style: TextStyle(
                  color: Color(0xFF2F3236),
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              RadioGroup<_ProviderFilterChoice>(
                groupValue: _ProviderFilterChoice.values.firstWhere(
                  (choice) => choice.status == current,
                ),
                onChanged: (choice) => Navigator.of(context).pop(choice),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (final choice in _ProviderFilterChoice.values)
                      RadioListTile<_ProviderFilterChoice>(
                        contentPadding: EdgeInsets.zero,
                        value: choice,
                        title: Text(choice.label),
                        activeColor: KompakColors.primary,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
    if (selected != null && mounted) {
      await context.read<AdminProvidersCubit>().filter(selected.status);
    }
  }

  Future<void> _openProvider(AdminProviderSummary provider) async {
    await context.router.push<void>(
      AdminProviderDetailRoute(providerId: provider.id),
    );
    if (mounted) await context.read<AdminProvidersCubit>().refresh();
  }

  Future<void> _resetFilters() async {
    _searchController.clear();
    await context.read<AdminProvidersCubit>().filter(null);
    if (mounted) await context.read<AdminProvidersCubit>().search('');
  }
}

enum _ProviderFilterChoice {
  all(null, 'Semua status'),
  pending(AdminProviderStatus.pending, 'Pending'),
  verified(AdminProviderStatus.verified, 'Verified'),
  rejected(AdminProviderStatus.rejected, 'Ditolak'),
  inactive(AdminProviderStatus.inactive, 'Nonaktif');

  const _ProviderFilterChoice(this.status, this.label);

  final AdminProviderStatus? status;
  final String label;
}

class _SearchAndFilter extends StatelessWidget {
  const _SearchAndFilter({
    required this.controller,
    required this.filterActive,
    required this.onChanged,
    required this.onFilterPressed,
  });

  final TextEditingController controller;
  final bool filterActive;
  final ValueChanged<String> onChanged;
  final VoidCallback onFilterPressed;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 44,
            child: TextField(
              key: const ValueKey('admin-provider-search'),
              controller: controller,
              onChanged: onChanged,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFFF1F1F2),
                hintText: 'Cari nama Provider',
                hintStyle: const TextStyle(
                  color: Color(0xFF8D9199),
                  fontSize: 14,
                ),
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: Color(0xFF8D9199),
                  size: 20,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        SizedBox(
          height: 44,
          child: OutlinedButton.icon(
            key: const ValueKey('admin-provider-filter'),
            onPressed: onFilterPressed,
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF2F3236),
              backgroundColor: filterActive
                  ? KompakColors.primarySurface
                  : Colors.white,
              side: BorderSide(
                color: filterActive
                    ? KompakColors.primary
                    : const Color(0xFFF1F1F2),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.filter_list_rounded, size: 18),
            label: const Text('Filter'),
          ),
        ),
      ],
    );
  }
}

class _ProviderCard extends StatelessWidget {
  const _ProviderCard({required this.provider, required this.onTap});

  final AdminProviderSummary provider;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final primary = provider.status == AdminProviderStatus.pending
        ? KompakColors.primary
        : KompakColors.success;

    return Container(
      key: ValueKey('admin-provider-card-${provider.id}'),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFF1F1F2)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AdminProviderLogo(name: provider.name, logoUrl: provider.logoUrl),
              AdminProviderStatusChip(status: provider.status),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            provider.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF2F3236),
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Pemilik: ${provider.ownerName}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Color(0xFFB0B2B3), fontSize: 14),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 44,
            child: FilledButton(
              key: ValueKey('admin-provider-open-${provider.id}'),
              onPressed: onTap,
              style: FilledButton.styleFrom(
                backgroundColor: primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                provider.status == AdminProviderStatus.pending
                    ? 'Verifikasi Sekarang'
                    : 'Lihat Detail',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProvidersPagination extends StatelessWidget {
  const _ProvidersPagination({
    required this.pagination,
    required this.onPrevious,
    required this.onNext,
  });

  final AdminProviderPagination pagination;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    final start = pagination.total == 0
        ? 0
        : (pagination.page - 1) * pagination.pageSize + 1;
    final end = math.min(
      pagination.page * pagination.pageSize,
      pagination.total,
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE5EEFF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              pagination.total == 0
                  ? 'Belum ada Provider'
                  : 'Menampilkan $start-$end\ndari ${pagination.total} Provider',
              style: const TextStyle(
                color: Color(0xFF3D4A42),
                fontSize: 13,
                height: 1.15,
              ),
            ),
          ),
          _PageButton(icon: Icons.chevron_left_rounded, onTap: onPrevious),
          const SizedBox(width: 8),
          _PageButton(label: '${pagination.page}', selected: true),
          const SizedBox(width: 8),
          _PageButton(icon: Icons.chevron_right_rounded, onTap: onNext),
        ],
      ),
    );
  }
}

class _PageButton extends StatelessWidget {
  const _PageButton({this.label, this.icon, this.onTap, this.selected = false});

  final String? label;
  final IconData? icon;
  final VoidCallback? onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: 40,
      child: Material(
        color: selected ? KompakColors.success : Colors.white,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Center(
            child: icon != null
                ? Icon(
                    icon,
                    color: onTap == null
                        ? const Color(0xFFB0B2B3)
                        : const Color(0xFF5F6672),
                  )
                : Text(
                    label ?? '',
                    style: TextStyle(
                      color: selected ? Colors.white : const Color(0xFF2F3236),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

class _EmptyProviders extends StatelessWidget {
  const _EmptyProviders({required this.filtered, required this.onReset});

  final bool filtered;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: KompakColors.softSurface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.storefront_outlined,
            size: 42,
            color: KompakColors.primary,
          ),
          const SizedBox(height: 12),
          Text(
            filtered ? 'Provider tidak ditemukan' : 'Belum ada provider',
            style: const TextStyle(
              color: KompakColors.ink,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (filtered) ...[
            const SizedBox(height: 8),
            TextButton(
              onPressed: onReset,
              child: const Text('Reset pencarian'),
            ),
          ],
        ],
      ),
    );
  }
}

class _ProvidersFailure extends StatelessWidget {
  const _ProvidersFailure({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_rounded, size: 44),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(onPressed: onRetry, child: const Text('Coba Lagi')),
          ],
        ),
      ),
    );
  }
}
