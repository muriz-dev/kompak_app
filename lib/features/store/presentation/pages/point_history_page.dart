import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/routes/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/kompak_bottom_navigation.dart';
import '../../domain/entities/store_data.dart';
import '../bloc/point_history_cubit.dart';
import '../widgets/reward_redemption_dialog.dart';

@RoutePage()
class PointHistoryPage extends StatelessWidget {
  const PointHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<PointHistoryCubit>()..load(),
      child: const _PointHistoryView(),
    );
  }
}

class _PointHistoryView extends StatelessWidget {
  const _PointHistoryView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KompakColors.surface,
      appBar: AppBar(
        backgroundColor: KompakColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          tooltip: 'Kembali',
          icon: const Icon(
            Icons.chevron_left,
            color: KompakColors.ink,
            size: 28,
          ),
          onPressed: () => context.router.maybePop(),
        ),
        title: const Text(
          'Riwayat Poin',
          style: TextStyle(
            color: KompakColors.ink,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: BlocBuilder<PointHistoryCubit, PointHistoryState>(
        builder: (context, state) => switch (state) {
          PointHistoryLoading() => const _HistoryLoading(),
          PointHistoryError(:final message) => _HistoryError(
            message: message,
            onRetry: () => context.read<PointHistoryCubit>().load(),
          ),
          PointHistoryLoaded() => _HistoryLoadedView(state: state),
        },
      ),
      bottomNavigationBar: KompakBottomNavigation(
        currentIndex: 2,
        onSelected: (index) => _openMainTab(context, index),
      ),
    );
  }

  void _openMainTab(BuildContext context, int index) {
    final childRoute = switch (index) {
      1 => const AttendanceRoute(),
      2 => const StoreRoute(),
      3 => const LeaderboardRoute(),
      _ => const HomeRoute(),
    };
    context.router.replaceAll([
      MainRoute(children: [childRoute]),
    ]);
  }
}

class _HistoryLoadedView extends StatelessWidget {
  const _HistoryLoadedView({required this.state});

  final PointHistoryLoaded state;

  @override
  Widget build(BuildContext context) {
    final groups = _groupEntries(state.visibleEntries);
    final pendingById = {
      for (final redemption in state.pendingRedemptions)
        redemption.id: redemption,
    };

    return RefreshIndicator(
      onRefresh: () => context.read<PointHistoryCubit>().load(),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          _BalanceCard(balance: state.balance),
          const SizedBox(height: 18),
          _HistoryFilters(active: state.filter),
          const SizedBox(height: 18),
          if (groups.isEmpty)
            const _HistoryEmptyState()
          else
            for (final group in groups) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
                child: Text(
                  group.label,
                  style: const TextStyle(
                    color: KompakColors.mutedInk,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              for (final entry in group.entries)
                _HistoryItem(
                  entry: entry,
                  pendingRedemption: pendingById[entry.id],
                ),
              const SizedBox(height: 4),
            ],
        ],
      ),
    );
  }
}

class _BalanceCard extends StatelessWidget {
  const _BalanceCard({required this.balance});

  final int balance;

  @override
  Widget build(BuildContext context) => Container(
    height: 90,
    clipBehavior: Clip.antiAlias,
    decoration: BoxDecoration(
      color: KompakColors.primary,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Stack(
      children: [
        Positioned(
          right: -20,
          top: -38,
          child: Opacity(
            opacity: 0.18,
            child: SvgPicture.asset(
              'assets/images/app_icon_white.svg',
              width: 135,
              height: 135,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'TOTAL KONTRIBUSI',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: NumberFormat.decimalPattern(
                        'id_ID',
                      ).format(balance),
                      style: const TextStyle(fontSize: 28),
                    ),
                    const TextSpan(
                      text: ' Poin',
                      style: TextStyle(fontSize: 18),
                    ),
                  ],
                ),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  height: 1,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _HistoryFilters extends StatelessWidget {
  const _HistoryFilters({required this.active});

  final PointHistoryFilter active;

  @override
  Widget build(BuildContext context) {
    const options = {
      PointHistoryFilter.all: 'Semua',
      PointHistoryFilter.incoming: 'Masuk',
      PointHistoryFilter.outgoing: 'Keluar',
    };

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.entries
          .map((option) {
            final selected = active == option.key;
            return ChoiceChip(
              label: Text(option.value),
              selected: selected,
              showCheckmark: false,
              selectedColor: KompakColors.success,
              backgroundColor: KompakColors.successSurface,
              side: BorderSide.none,
              labelStyle: TextStyle(
                color: selected ? Colors.white : KompakColors.ink,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              onSelected: (_) =>
                  context.read<PointHistoryCubit>().changeFilter(option.key),
            );
          })
          .toList(growable: false),
    );
  }
}

class _HistoryItem extends StatelessWidget {
  const _HistoryItem({required this.entry, this.pendingRedemption});

  final PointHistoryEntry entry;
  final RewardRedemption? pendingRedemption;

  @override
  Widget build(BuildContext context) {
    final presentation = _entryPresentation(entry);
    final content = Container(
      constraints: const BoxConstraints(minHeight: 76),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE8EAEE)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 21,
            backgroundColor: presentation.color,
            child: Icon(presentation.icon, color: Colors.white, size: 21),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: KompakColors.ink,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatEntryTime(entry.occurredAt),
                  style: const TextStyle(
                    color: KompakColors.mutedInk,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (presentation.statusLabel case final label?)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: presentation.color,
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              const SizedBox(height: 4),
              Text(
                '${entry.direction == PointDirection.incoming ? '+' : '-'}${NumberFormat.decimalPattern('id_ID').format(entry.points)}',
                style: TextStyle(
                  color: presentation.color,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ],
      ),
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: pendingRedemption == null
          ? content
          : Semantics(
              button: true,
              label: 'Buka QR ${entry.title}',
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => showDialog<void>(
                    context: context,
                    builder: (_) =>
                        RewardRedemptionDialog(redemption: pendingRedemption!),
                  ),
                  child: content,
                ),
              ),
            ),
    );
  }
}

class _EntryPresentation {
  const _EntryPresentation({
    required this.color,
    required this.icon,
    this.statusLabel,
  });

  final Color color;
  final IconData icon;
  final String? statusLabel;
}

_EntryPresentation _entryPresentation(PointHistoryEntry entry) {
  final status = entry.status?.toUpperCase();
  final isRefund = entry.referenceType == 'REDEMPTION_REFUND';
  final icon = isRefund
      ? Icons.replay_rounded
      : entry.referenceType == 'EVENT'
      ? Icons.how_to_reg_rounded
      : Icons.shopping_bag_outlined;

  return switch (status) {
    'PENDING' => _EntryPresentation(
      color: KompakColors.warning,
      icon: icon,
      statusLabel: 'Menunggu',
    ),
    'COMPLETED' => _EntryPresentation(
      color: KompakColors.success,
      icon: icon,
      statusLabel: 'Berhasil',
    ),
    'REJECTED' => _EntryPresentation(
      color: isRefund ? KompakColors.success : KompakColors.error,
      icon: icon,
      statusLabel: isRefund ? 'Dikembalikan' : 'Ditolak',
    ),
    'CANCELLED' => _EntryPresentation(
      color: isRefund ? KompakColors.success : KompakColors.error,
      icon: icon,
      statusLabel: isRefund ? 'Dikembalikan' : 'Dibatalkan',
    ),
    _ => _EntryPresentation(
      color: entry.direction == PointDirection.incoming
          ? KompakColors.success
          : KompakColors.error,
      icon: icon,
    ),
  };
}

class _HistoryGroup {
  const _HistoryGroup({required this.label, required this.entries});

  final String label;
  final List<PointHistoryEntry> entries;
}

List<_HistoryGroup> _groupEntries(List<PointHistoryEntry> entries) {
  final grouped = <DateTime, List<PointHistoryEntry>>{};
  for (final entry in entries) {
    final date = DateUtils.dateOnly(entry.occurredAt);
    grouped.putIfAbsent(date, () => []).add(entry);
  }

  return grouped.entries
      .map(
        (group) => _HistoryGroup(
          label: _dateGroupLabel(group.key),
          entries: group.value,
        ),
      )
      .toList(growable: false);
}

String _dateGroupLabel(DateTime date) {
  final today = DateUtils.dateOnly(DateTime.now());
  if (date == today) return 'Hari Ini';
  if (date == today.subtract(const Duration(days: 1))) return 'Kemarin';
  return '${date.day} ${_indonesianMonths[date.month - 1]} ${date.year}';
}

String _formatEntryTime(DateTime value) =>
    '${value.day} ${_indonesianMonths[value.month - 1]} ${value.year}, ${DateFormat('HH:mm').format(value)}';

const _indonesianMonths = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'Mei',
  'Jun',
  'Jul',
  'Agu',
  'Sep',
  'Okt',
  'Nov',
  'Des',
];

class _HistoryLoading extends StatelessWidget {
  const _HistoryLoading();

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(16),
    children: [
      Container(
        height: 90,
        decoration: BoxDecoration(
          color: KompakColors.primarySurface,
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      const SizedBox(height: 18),
      for (var i = 0; i < 4; i++) ...[
        Container(
          height: 76,
          decoration: BoxDecoration(
            color: KompakColors.softSurface,
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        const SizedBox(height: 10),
      ],
    ],
  );
}

class _HistoryEmptyState extends StatelessWidget {
  const _HistoryEmptyState();

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
    decoration: BoxDecoration(
      color: KompakColors.softSurface,
      borderRadius: BorderRadius.circular(12),
    ),
    child: const Column(
      children: [
        Icon(
          Icons.receipt_long_outlined,
          size: 42,
          color: KompakColors.primary,
        ),
        SizedBox(height: 12),
        Text(
          'Belum ada riwayat poin',
          style: TextStyle(
            color: KompakColors.ink,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 6),
        Text(
          'Poin dari presensi dan penukaran hadiah akan tercatat di sini.',
          textAlign: TextAlign.center,
          style: TextStyle(color: KompakColors.mutedInk, height: 1.4),
        ),
      ],
    ),
  );
}

class _HistoryError extends StatelessWidget {
  const _HistoryError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: onRetry, child: const Text('Coba Lagi')),
        ],
      ),
    ),
  );
}
