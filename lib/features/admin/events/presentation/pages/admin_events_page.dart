import 'dart:math' as math;

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../../core/routes/app_router.dart';
import '../../../../../core/theme/app_theme.dart';

enum _EventStatus { upcoming, ongoing, completed }

enum _EventFilter { all, upcoming, ongoing, completed }

class _AdminEventSummary {
  const _AdminEventSummary({
    required this.title,
    required this.dateLabel,
    required this.timeLabel,
    required this.status,
    required this.attendanceCount,
    required this.distributedPoints,
  });

  final String title;
  final String dateLabel;
  final String timeLabel;
  final _EventStatus status;
  final int attendanceCount;
  final int distributedPoints;
}

const _sampleEvents = [
  _AdminEventSummary(
    title: 'Kerja Bakti Blok B',
    dateLabel: '15 Mei 2024',
    timeLabel: '07:00',
    status: _EventStatus.upcoming,
    attendanceCount: 0,
    distributedPoints: 0,
  ),
  _AdminEventSummary(
    title: 'Kerja Bakti Blok A',
    dateLabel: '12 Mei 2024',
    timeLabel: '07:00',
    status: _EventStatus.ongoing,
    attendanceCount: 42,
    distributedPoints: 4200,
  ),
  _AdminEventSummary(
    title: 'Rapat Bulanan RT',
    dateLabel: '05 Mei 2024',
    timeLabel: '19:30',
    status: _EventStatus.completed,
    attendanceCount: 50,
    distributedPoints: 2400,
  ),
  _AdminEventSummary(
    title: 'Penyemprotan Disinfektan',
    dateLabel: '28 April 2024',
    timeLabel: '09:00',
    status: _EventStatus.completed,
    attendanceCount: 20,
    distributedPoints: 1500,
  ),
  _AdminEventSummary(
    title: 'Posyandu Balita',
    dateLabel: '21 April 2024',
    timeLabel: '08:00',
    status: _EventStatus.completed,
    attendanceCount: 36,
    distributedPoints: 1800,
  ),
  _AdminEventSummary(
    title: 'Ronda Malam Bersama',
    dateLabel: '18 Mei 2024',
    timeLabel: '22:00',
    status: _EventStatus.upcoming,
    attendanceCount: 0,
    distributedPoints: 0,
  ),
];

@RoutePage()
class AdminEventsPage extends StatelessWidget {
  const AdminEventsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AdminEventsView(
      onBack: () => context.router.maybePop(),
      onCreateEvent: () => context.router.push(const CreateEventRoute()),
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
  final VoidCallback onCreateEvent;

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
    final filteredEvents = _filteredEvents;
    final pageCount = math.max(1, (filteredEvents.length / _pageSize).ceil());
    final currentPage = _currentPage.clamp(0, pageCount - 1);
    final start = currentPage * _pageSize;
    final end = math.min(start + _pageSize, filteredEvents.length);
    final visibleEvents = start < end
        ? filteredEvents.sublist(start, end)
        : const <_AdminEventSummary>[];

    return Scaffold(
      backgroundColor: const Color(0xFFFEFFFF),
      body: SafeArea(
        child: Column(
          children: [
            _AdminEventsHeader(onBack: widget.onBack),
            Expanded(
              child: ListView(
                key: const ValueKey('admin-events-scroll'),
                padding: const EdgeInsets.fromLTRB(24, 17, 24, 30),
                children: [
                  _SearchAndFilter(
                    controller: _searchController,
                    filterActive: _filter != _EventFilter.all,
                    onSearchChanged: (_) => setState(() => _currentPage = 0),
                    onFilterPressed: _selectFilter,
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: FilledButton.icon(
                      key: const ValueKey('create-event-button'),
                      onPressed: widget.onCreateEvent,
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
                  if (visibleEvents.isEmpty)
                    _EmptyEvents(onReset: _resetFilters)
                  else
                    for (var index = 0; index < visibleEvents.length; index++)
                      Padding(
                        padding: EdgeInsets.only(
                          bottom: index == visibleEvents.length - 1 ? 0 : 16,
                        ),
                        child: _EventCard(event: visibleEvents[index]),
                      ),
                  const SizedBox(height: 20),
                  _EventsPagination(
                    currentPage: currentPage,
                    pageCount: pageCount,
                    visibleCount: visibleEvents.length,
                    totalCount: filteredEvents.length,
                    onPrevious: currentPage == 0
                        ? null
                        : () => setState(() => _currentPage = currentPage - 1),
                    onNext: currentPage >= pageCount - 1
                        ? null
                        : () => setState(() => _currentPage = currentPage + 1),
                    onPageSelected: (page) =>
                        setState(() => _currentPage = page),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<_AdminEventSummary> get _filteredEvents {
    final query = _searchController.text.trim().toLowerCase();
    return _sampleEvents
        .where((event) {
          final matchesSearch =
              query.isEmpty || event.title.toLowerCase().contains(query);
          final matchesStatus = switch (_filter) {
            _EventFilter.all => true,
            _EventFilter.upcoming => event.status == _EventStatus.upcoming,
            _EventFilter.ongoing => event.status == _EventStatus.ongoing,
            _EventFilter.completed => event.status == _EventStatus.completed,
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
    _EventFilter.upcoming => 'Belum Mulai',
    _EventFilter.ongoing => 'Berlangsung',
    _EventFilter.completed => 'Selesai',
  };

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
  const _EventCard({required this.event});

  final _AdminEventSummary event;

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
                            '${event.dateLabel} • ${event.timeLabel}',
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
              _EventStatusBadge(status: event.status),
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
                  icon: Icons.groups_rounded,
                  iconColor: KompakColors.primary,
                  value: '${event.attendanceCount} Warga',
                  label: 'Kehadiran',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _EventMetric(
                  icon: Icons.workspace_premium_rounded,
                  iconColor: _AdminEventsViewState._orange,
                  value: event.distributedPoints == 0
                      ? '0 Pts'
                      : '+${NumberFormat.decimalPattern('en_US').format(event.distributedPoints)} Pts',
                  label: 'Terdistribusi',
                  valueColor: _AdminEventsViewState._orange,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EventStatusBadge extends StatelessWidget {
  const _EventStatusBadge({required this.status});

  final _EventStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, color, icon) = switch (status) {
      _EventStatus.upcoming => (
        'Belum Mulai',
        _AdminEventsViewState._orange,
        null,
      ),
      _EventStatus.ongoing => (
        'Berlangsung',
        _AdminEventsViewState._red,
        Icons.circle,
      ),
      _EventStatus.completed => (
        'Selesai',
        KompakColors.success,
        Icons.check_circle,
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
              size: status == _EventStatus.ongoing ? 8 : 12,
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
          for (var page = 0; page < pageCount; page++) ...[
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
