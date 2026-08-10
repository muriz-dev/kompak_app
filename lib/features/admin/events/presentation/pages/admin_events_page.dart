import 'dart:math' as math;

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../../core/di/injection.dart';
import '../../../../../core/routes/app_router.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../domain/entities/admin_event.dart';
import '../bloc/admin_events_cubit.dart';
import '../bloc/admin_events_state.dart';

enum _EventFilter { all, draft, upcoming, ongoing, completed, cancelled }

@RoutePage()
class AdminEventsPage extends StatelessWidget {
  const AdminEventsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<AdminEventsCubit>()..loadEvents(),
      child: AdminEventsView(
        onBack: () => context.router.maybePop(),
        onCreateEvent: () async {
          await context.router.push<void>(CreateEventRoute());
        },
      ),
    );
  }
}

class AdminEventsView extends StatefulWidget {
  const AdminEventsView({
    required this.onBack,
    required this.onCreateEvent,
    super.key,
  });

  final VoidCallback onBack;
  final Future<void> Function() onCreateEvent;

  @override
  State<AdminEventsView> createState() => _AdminEventsViewState();
}

class _AdminEventsViewState extends State<AdminEventsView> {
  static const _ink = Color(0xFF2F3236);
  static const _muted = Color(0xFF888A8B);
  static const _field = Color(0xFFF1F1F2);
  static const _orange = Color(0xFFF79009);
  static const _red = Color(0xFFF04438);
  static const _pageSize = 4;

  final _searchController = TextEditingController();
  _EventFilter _filter = _EventFilter.all;
  int _currentPage = 0;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdminEventsCubit, AdminEventsState>(
      builder: (context, state) {
        final events = state is AdminEventsLoaded
            ? state.events
            : const <AdminEvent>[];
        final updatingEventId = state is AdminEventsLoaded
            ? state.updatingEventId
            : null;
        final now = DateTime.now();
        final filteredEvents = _filteredEvents(events, now);
        final pageCount = math.max(
          1,
          (filteredEvents.length / _pageSize).ceil(),
        );
        final currentPage = _currentPage.clamp(0, pageCount - 1);
        final start = currentPage * _pageSize;
        final end = math.min(start + _pageSize, filteredEvents.length);
        final visibleEvents = start < end
            ? filteredEvents.sublist(start, end)
            : const <AdminEvent>[];

        return Scaffold(
          backgroundColor: const Color(0xFFFEFFFF),
          body: SafeArea(
            child: Column(
              children: [
                _AdminEventsHeader(onBack: widget.onBack),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: context.read<AdminEventsCubit>().loadEvents,
                    child: ListView(
                      key: const ValueKey('admin-events-scroll'),
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(24, 17, 24, 30),
                      children: [
                        _SearchAndFilter(
                          controller: _searchController,
                          filterActive: _filter != _EventFilter.all,
                          onSearchChanged: (_) =>
                              setState(() => _currentPage = 0),
                          onFilterPressed: _selectFilter,
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          height: 46,
                          child: FilledButton.icon(
                            key: const ValueKey('create-event-button'),
                            onPressed: _openCreateEvent,
                            style: FilledButton.styleFrom(
                              backgroundColor: KompakColors.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            icon: const Icon(Icons.add_rounded, size: 20),
                            label: const Text(
                              'Buat Kegiatan',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        switch (state) {
                          AdminEventsLoading() => const _LoadingEvents(),
                          AdminEventsLoadFailure(:final message) =>
                            _EventsFailure(
                              message: message,
                              onRetry: context
                                  .read<AdminEventsCubit>()
                                  .loadEvents,
                            ),
                          AdminEventsLoaded() when visibleEvents.isEmpty =>
                            _EmptyEvents(onReset: _resetFilters),
                          AdminEventsLoaded() => Column(
                            children: [
                              for (
                                var index = 0;
                                index < visibleEvents.length;
                                index++
                              )
                                Padding(
                                  padding: EdgeInsets.only(
                                    bottom: index == visibleEvents.length - 1
                                        ? 0
                                        : 16,
                                  ),
                                  child: _EventCard(
                                    event: visibleEvents[index],
                                    lifecycle: visibleEvents[index].lifecycleAt(
                                      now,
                                    ),
                                    actionsEnabled: updatingEventId == null,
                                    isUpdating:
                                        updatingEventId ==
                                        visibleEvents[index].id,
                                    onStatusChange: (status) => _changeStatus(
                                      visibleEvents[index],
                                      status,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        },
                        if (state is AdminEventsLoaded) ...[
                          const SizedBox(height: 20),
                          _EventsPagination(
                            currentPage: currentPage,
                            pageCount: pageCount,
                            visibleCount: visibleEvents.length,
                            totalCount: filteredEvents.length,
                            onPrevious: currentPage == 0
                                ? null
                                : () => setState(
                                    () => _currentPage = currentPage - 1,
                                  ),
                            onNext: currentPage >= pageCount - 1
                                ? null
                                : () => setState(
                                    () => _currentPage = currentPage + 1,
                                  ),
                            onPageSelected: (page) =>
                                setState(() => _currentPage = page),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  List<AdminEvent> _filteredEvents(List<AdminEvent> events, DateTime now) {
    final query = _searchController.text.trim().toLowerCase();
    return events
        .where((event) {
          final matchesSearch =
              query.isEmpty ||
              event.title.toLowerCase().contains(query) ||
              event.description.toLowerCase().contains(query);
          final lifecycle = event.lifecycleAt(now);
          final matchesStatus = switch (_filter) {
            _EventFilter.all => true,
            _EventFilter.draft => lifecycle == AdminEventLifecycle.draft,
            _EventFilter.upcoming => lifecycle == AdminEventLifecycle.upcoming,
            _EventFilter.ongoing => lifecycle == AdminEventLifecycle.ongoing,
            _EventFilter.completed =>
              lifecycle == AdminEventLifecycle.completed,
            _EventFilter.cancelled =>
              lifecycle == AdminEventLifecycle.cancelled,
          };
          return matchesSearch && matchesStatus;
        })
        .toList(growable: false);
  }

  Future<void> _selectFilter() async {
    final selected = await showModalBottomSheet<_EventFilter>(
      context: context,
      showDragHandle: true,
      backgroundColor: Colors.white,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(8, 0, 8, 8),
                child: Text(
                  'Filter Status Kegiatan',
                  style: TextStyle(
                    color: _ink,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              RadioGroup<_EventFilter>(
                groupValue: _filter,
                onChanged: (value) => Navigator.of(context).pop(value),
                child: Column(
                  children: [
                    for (final filter in _EventFilter.values)
                      RadioListTile<_EventFilter>(
                        value: filter,
                        activeColor: KompakColors.primary,
                        title: Text(_filterLabel(filter)),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
    if (selected == null || selected == _filter || !mounted) return;
    setState(() {
      _filter = selected;
      _currentPage = 0;
    });
  }

  String _filterLabel(_EventFilter filter) => switch (filter) {
    _EventFilter.all => 'Semua kegiatan',
    _EventFilter.draft => 'Draft',
    _EventFilter.upcoming => 'Belum Mulai',
    _EventFilter.ongoing => 'Berlangsung',
    _EventFilter.completed => 'Selesai',
    _EventFilter.cancelled => 'Dibatalkan',
  };

  Future<void> _openCreateEvent() async {
    await widget.onCreateEvent();
    if (!mounted) return;
    await context.read<AdminEventsCubit>().loadEvents();
  }

  Future<void> _changeStatus(
    AdminEvent event,
    AdminEventRecordStatus status,
  ) async {
    final action = switch (status) {
      AdminEventRecordStatus.published => (
        title: 'Terbitkan kegiatan?',
        message: 'Kegiatan "${event.title}" akan terlihat oleh seluruh warga.',
        confirmLabel: 'Terbitkan',
        destructive: false,
      ),
      AdminEventRecordStatus.closed => (
        title: 'Tutup kegiatan?',
        message:
            'Absensi untuk kegiatan "${event.title}" akan ditutup permanen.',
        confirmLabel: 'Tutup Kegiatan',
        destructive: false,
      ),
      AdminEventRecordStatus.cancelled => (
        title: 'Batalkan kegiatan?',
        message:
            'Kegiatan "${event.title}" akan dibatalkan dan tidak dapat diterbitkan kembali.',
        confirmLabel: 'Batalkan',
        destructive: true,
      ),
      AdminEventRecordStatus.draft => throw StateError(
        'An event cannot transition back to draft',
      ),
    };

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(action.title),
        content: Text(action.message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Kembali'),
          ),
          FilledButton(
            key: ValueKey('confirm-${status.apiValue.toLowerCase()}'),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: action.destructive
                ? FilledButton.styleFrom(backgroundColor: _red)
                : null,
            child: Text(action.confirmLabel),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    final error = await context.read<AdminEventsCubit>().updateEventStatus(
      event.id,
      status,
    );
    if (!mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          error ??
              switch (status) {
                AdminEventRecordStatus.published =>
                  'Kegiatan berhasil diterbitkan.',
                AdminEventRecordStatus.closed => 'Kegiatan berhasil ditutup.',
                AdminEventRecordStatus.cancelled =>
                  'Kegiatan berhasil dibatalkan.',
                AdminEventRecordStatus.draft => '',
              },
        ),
        backgroundColor: error == null ? KompakColors.success : _red,
      ),
    );
  }

  void _resetFilters() {
    _searchController.clear();
    setState(() {
      _filter = _EventFilter.all;
      _currentPage = 0;
    });
  }
}

class _AdminEventsHeader extends StatelessWidget {
  const _AdminEventsHeader({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 68,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: 12),
              child: IconButton(
                key: const ValueKey('admin-events-back-button'),
                tooltip: 'Kembali',
                onPressed: onBack,
                iconSize: 28,
                color: _AdminEventsViewState._ink,
                icon: const Icon(Icons.chevron_left_rounded),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 64),
            child: Text(
              'Daftar Kegiatan',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: _AdminEventsViewState._ink,
                fontSize: 20,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchAndFilter extends StatelessWidget {
  const _SearchAndFilter({
    required this.controller,
    required this.filterActive,
    required this.onSearchChanged,
    required this.onFilterPressed,
  });

  final TextEditingController controller;
  final bool filterActive;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onFilterPressed;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 44,
            child: TextField(
              key: const ValueKey('event-search-field'),
              controller: controller,
              onChanged: onSearchChanged,
              textInputAction: TextInputAction.search,
              style: const TextStyle(
                fontSize: 14,
                color: _AdminEventsViewState._ink,
              ),
              decoration: InputDecoration(
                hintText: 'Cari nama kegiatan',
                hintStyle: const TextStyle(
                  color: Color(0xFF8D9199),
                  fontSize: 14,
                ),
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  size: 18,
                  color: Color(0xFF8D9199),
                ),
                prefixIconConstraints: const BoxConstraints(minWidth: 38),
                filled: true,
                fillColor: _AdminEventsViewState._field,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                border: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        SizedBox(
          height: 44,
          child: OutlinedButton.icon(
            key: const ValueKey('event-filter-button'),
            onPressed: onFilterPressed,
            style: OutlinedButton.styleFrom(
              foregroundColor: filterActive
                  ? KompakColors.primary
                  : _AdminEventsViewState._ink,
              side: BorderSide(
                color: filterActive
                    ? KompakColors.primary
                    : _AdminEventsViewState._field,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.filter_list_rounded, size: 18),
            label: const Text(
              'Filter',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ),
        ),
      ],
    );
  }
}

class _EventCard extends StatelessWidget {
  const _EventCard({
    required this.event,
    required this.lifecycle,
    required this.actionsEnabled,
    required this.isUpdating,
    required this.onStatusChange,
  });

  final AdminEvent event;
  final AdminEventLifecycle lifecycle;
  final bool actionsEnabled;
  final bool isUpdating;
  final ValueChanged<AdminEventRecordStatus> onStatusChange;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: ValueKey('event-card-${event.title}'),
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: _AdminEventsViewState._field),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: _AdminEventsViewState._ink,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_today_outlined,
                          color: KompakColors.primary,
                          size: 15,
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            '${_dateLabel(event.eventDate)} • ${DateFormat('HH:mm').format(event.attendanceStartTime.toLocal())}',
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: _AdminEventsViewState._muted,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _EventStatusBadge(status: lifecycle),
            ],
          ),
          const SizedBox(height: 16),
          const SizedBox(
            width: double.infinity,
            height: 1,
            child: CustomPaint(painter: _DashedLinePainter()),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _EventMetric(
                  icon: Icons.location_searching_rounded,
                  iconColor: KompakColors.primary,
                  value: '${event.radiusMeters} meter',
                  label: 'Radius Absensi',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _EventMetric(
                  icon: Icons.workspace_premium_rounded,
                  iconColor: _AdminEventsViewState._orange,
                  value:
                      '+${NumberFormat.decimalPattern('id_ID').format(event.rewardPoints)} Pts',
                  label: 'Reward',
                  valueColor: _AdminEventsViewState._orange,
                ),
              ),
            ],
          ),
          if (event.status
              case AdminEventRecordStatus.draft ||
                  AdminEventRecordStatus.published) ...[
            const SizedBox(height: 16),
            _EventActions(
              event: event,
              enabled: actionsEnabled,
              isUpdating: isUpdating,
              onStatusChange: onStatusChange,
            ),
          ],
        ],
      ),
    );
  }

  String _dateLabel(DateTime date) {
    const months = [
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
    final local = date.toLocal();
    return '${local.day.toString().padLeft(2, '0')} ${months[local.month - 1]} ${local.year}';
  }
}

class _EventActions extends StatelessWidget {
  const _EventActions({
    required this.event,
    required this.enabled,
    required this.isUpdating,
    required this.onStatusChange,
  });

  final AdminEvent event;
  final bool enabled;
  final bool isUpdating;
  final ValueChanged<AdminEventRecordStatus> onStatusChange;

  @override
  Widget build(BuildContext context) {
    if (isUpdating) {
      return const SizedBox(
        height: 40,
        child: Center(
          child: SizedBox.square(
            dimension: 22,
            child: CircularProgressIndicator(strokeWidth: 2.5),
          ),
        ),
      );
    }

    if (event.status == AdminEventRecordStatus.draft) {
      return SizedBox(
        width: double.infinity,
        height: 40,
        child: FilledButton.icon(
          key: ValueKey('publish-event-${event.id}'),
          onPressed: enabled
              ? () => onStatusChange(AdminEventRecordStatus.published)
              : null,
          icon: const Icon(Icons.publish_rounded, size: 18),
          label: const Text('Terbitkan'),
        ),
      );
    }

    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 40,
            child: OutlinedButton(
              key: ValueKey('cancel-event-${event.id}'),
              onPressed: enabled
                  ? () => onStatusChange(AdminEventRecordStatus.cancelled)
                  : null,
              style: OutlinedButton.styleFrom(
                foregroundColor: _AdminEventsViewState._red,
                side: const BorderSide(color: _AdminEventsViewState._red),
              ),
              child: const Text('Batalkan'),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: SizedBox(
            height: 40,
            child: FilledButton(
              key: ValueKey('close-event-${event.id}'),
              onPressed: enabled
                  ? () => onStatusChange(AdminEventRecordStatus.closed)
                  : null,
              child: const Text('Tutup'),
            ),
          ),
        ),
      ],
    );
  }
}

class _EventStatusBadge extends StatelessWidget {
  const _EventStatusBadge({required this.status});

  final AdminEventLifecycle status;

  @override
  Widget build(BuildContext context) {
    final (label, color, icon) = switch (status) {
      AdminEventLifecycle.draft => (
        'Draft',
        const Color(0xFF667085),
        Icons.edit_outlined,
      ),
      AdminEventLifecycle.upcoming => (
        'Belum Mulai',
        _AdminEventsViewState._orange,
        null,
      ),
      AdminEventLifecycle.ongoing => (
        'Berlangsung',
        _AdminEventsViewState._red,
        Icons.circle,
      ),
      AdminEventLifecycle.completed => (
        'Selesai',
        KompakColors.success,
        Icons.check_circle,
      ),
      AdminEventLifecycle.cancelled => (
        'Dibatalkan',
        const Color(0xFFF04438),
        Icons.cancel_rounded,
      ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              color: Colors.white,
              size: status == AdminEventLifecycle.ongoing ? 8 : 12,
            ),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _EventMetric extends StatelessWidget {
  const _EventMetric({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
    this.valueColor = _AdminEventsViewState._ink,
  });

  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: iconColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 17, color: Colors.white),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: valueColor,
                  fontSize: 13,
                  fontWeight: valueColor == _AdminEventsViewState._orange
                      ? FontWeight.w500
                      : FontWeight.w400,
                ),
              ),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFFA0A3AA),
                  fontSize: 10,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _EventsPagination extends StatelessWidget {
  const _EventsPagination({
    required this.currentPage,
    required this.pageCount,
    required this.visibleCount,
    required this.totalCount,
    required this.onPrevious,
    required this.onNext,
    required this.onPageSelected,
  });

  final int currentPage;
  final int pageCount;
  final int visibleCount;
  final int totalCount;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;
  final ValueChanged<int> onPageSelected;

  @override
  Widget build(BuildContext context) {
    final pageIndices = switch (pageCount) {
      <= 3 => List.generate(pageCount, (index) => index),
      _ when currentPage == 0 => const [0, 1],
      _ when currentPage == pageCount - 1 => [pageCount - 2, pageCount - 1],
      _ => [currentPage - 1, currentPage, currentPage + 1],
    };

    return Container(
      constraints: const BoxConstraints(minHeight: 72),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE5EEFF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Menampilkan $visibleCount\ndari $totalCount kegiatan',
              style: const TextStyle(
                color: Color(0xFF3D4A42),
                fontSize: 13,
                height: 1.2,
              ),
            ),
          ),
          _PageButton(
            key: const ValueKey('admin-events-previous-page'),
            onPressed: onPrevious,
            icon: Icons.chevron_left_rounded,
          ),
          const SizedBox(width: 8),
          for (final page in pageIndices) ...[
            _PageButton(
              key: ValueKey('admin-events-page-${page + 1}'),
              onPressed: () => onPageSelected(page),
              label: '${page + 1}',
              selected: page == currentPage,
            ),
            const SizedBox(width: 8),
          ],
          _PageButton(
            key: const ValueKey('admin-events-next-page'),
            onPressed: onNext,
            icon: Icons.chevron_right_rounded,
          ),
        ],
      ),
    );
  }
}

class _PageButton extends StatelessWidget {
  const _PageButton({
    super.key,
    required this.onPressed,
    this.icon,
    this.label,
    this.selected = false,
  });

  final VoidCallback? onPressed;
  final IconData? icon;
  final String? label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 40,
      height: 40,
      child: IconButton(
        onPressed: onPressed,
        padding: EdgeInsets.zero,
        style: IconButton.styleFrom(
          backgroundColor: selected ? KompakColors.success : Colors.white,
          disabledBackgroundColor: Colors.white.withValues(alpha: 0.55),
          foregroundColor: selected ? Colors.white : _AdminEventsViewState._ink,
          disabledForegroundColor: const Color(0xFF98A2B3),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        icon: icon != null
            ? Icon(icon, size: 22)
            : Text(
                label!,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: selected ? Colors.white : _AdminEventsViewState._ink,
                ),
              ),
      ),
    );
  }
}

class _LoadingEvents extends StatelessWidget {
  const _LoadingEvents();

  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.symmetric(vertical: 48),
    child: Center(child: CircularProgressIndicator()),
  );
}

class _EventsFailure extends StatelessWidget {
  const _EventsFailure({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          const Icon(
            Icons.cloud_off_rounded,
            size: 42,
            color: Color(0xFF98A2B3),
          ),
          const SizedBox(height: 12),
          const Text(
            'Daftar kegiatan tidak dapat dimuat',
            style: TextStyle(
              color: _AdminEventsViewState._ink,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: _AdminEventsViewState._muted,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 14),
          FilledButton.tonal(
            key: const ValueKey('retry-admin-events'),
            onPressed: onRetry,
            child: const Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }
}

class _EmptyEvents extends StatelessWidget {
  const _EmptyEvents({required this.onReset});

  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        children: [
          const Icon(
            Icons.event_busy_rounded,
            size: 42,
            color: Color(0xFF98A2B3),
          ),
          const SizedBox(height: 12),
          const Text(
            'Kegiatan tidak ditemukan',
            style: TextStyle(
              color: _AdminEventsViewState._ink,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Coba kata kunci atau filter yang berbeda.',
            textAlign: TextAlign.center,
            style: TextStyle(color: _AdminEventsViewState._muted, fontSize: 13),
          ),
          const SizedBox(height: 16),
          TextButton(onPressed: onReset, child: const Text('Reset Pencarian')),
        ],
      ),
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  const _DashedLinePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFBCCAC0)
      ..strokeWidth = 1;
    const dashWidth = 4.0;
    const dashGap = 3.0;
    for (double x = 0; x < size.width; x += dashWidth + dashGap) {
      canvas.drawLine(
        Offset(x, 0.5),
        Offset(math.min(x + dashWidth, size.width), 0.5),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _DashedLinePainter oldDelegate) => false;
}
