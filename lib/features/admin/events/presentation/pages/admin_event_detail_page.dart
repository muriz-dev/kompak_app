import 'dart:math' as math;

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../../core/di/injection.dart';
import '../../../../../core/routes/app_router.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../domain/entities/admin_event.dart';
import '../../domain/entities/admin_event_overview.dart';
import '../bloc/admin_event_detail_cubit.dart';
import '../bloc/admin_event_detail_state.dart';
import '../widgets/event_documentation_viewer.dart';

@RoutePage()
class AdminEventDetailPage extends StatelessWidget {
  const AdminEventDetailPage({
    @PathParam('eventId') required this.eventId,
    super.key,
  });

  final String eventId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<AdminEventDetailCubit>()..loadEvent(eventId),
      child: AdminEventDetailView(
        eventId: eventId,
        onBack: () => context.router.maybePop(),
        onEdit: (event) =>
            context.router.push<bool>(EditEventRoute(event: event)),
      ),
    );
  }
}

class AdminEventDetailView extends StatefulWidget {
  const AdminEventDetailView({
    required this.eventId,
    required this.onBack,
    required this.onEdit,
    super.key,
  });

  final String eventId;
  final VoidCallback onBack;
  final Future<bool?> Function(AdminEvent event) onEdit;

  @override
  State<AdminEventDetailView> createState() => _AdminEventDetailViewState();
}

class _AdminEventDetailViewState extends State<AdminEventDetailView> {
  static const _ink = KompakColors.ink;
  static const _muted = KompakColors.mutedInk;
  static const _blue = KompakColors.primary;
  static const _green = KompakColors.success;
  static const _pageSize = 5;

  int _page = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFEFFFF),
      body: SafeArea(
        child: Column(
          children: [
            _DetailHeader(onBack: widget.onBack),
            Expanded(
              child: BlocBuilder<AdminEventDetailCubit, AdminEventDetailState>(
                builder: (context, state) => switch (state) {
                  AdminEventDetailLoading() => const _DetailLoading(),
                  AdminEventDetailFailure(:final message) => _DetailFailure(
                    message: message,
                    onRetry: () => context
                        .read<AdminEventDetailCubit>()
                        .loadEvent(widget.eventId),
                  ),
                  AdminEventDetailLoaded(:final overview) => _buildLoaded(
                    context,
                    overview,
                  ),
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoaded(BuildContext context, AdminEventOverview overview) {
    final attendees = overview.attendances;
    final pageCount = math.max(1, (attendees.length / _pageSize).ceil());
    final page = _page.clamp(0, pageCount - 1);
    final start = page * _pageSize;
    final end = math.min(start + _pageSize, attendees.length);
    final visible = start < end
        ? attendees.sublist(start, end)
        : const <AdminEventAttendance>[];
    final event = overview.event;

    return Column(
      children: [
        Expanded(
          child: RefreshIndicator(
            onRefresh: () =>
                context.read<AdminEventDetailCubit>().loadEvent(event.id),
            child: ListView(
              key: const ValueKey('admin-event-detail-scroll'),
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(24, 18, 24, 28),
              children: [
                Text(
                  event.title,
                  style: const TextStyle(
                    color: _ink,
                    fontSize: 23,
                    height: 1.2,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_outlined,
                      size: 18,
                      color: _blue,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${_dateLabel(event.eventDate)} • '
                        '${DateFormat('HH:mm').format(event.attendanceStartTime.toLocal())}–'
                        '${DateFormat('HH:mm').format(event.attendanceEndTime.toLocal())}',
                        style: const TextStyle(
                          color: _muted,
                          fontSize: 14,
                          height: 1.25,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: _MetricCard(
                        key: const ValueKey('distributed-points-card'),
                        color: _blue,
                        value:
                            '+${NumberFormat.decimalPattern('en_US').format(overview.distributedPoints)}',
                        label: 'Point Terdistribusi',
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _MetricCard(
                        key: const ValueKey('total-participation-card'),
                        color: _green,
                        value: overview.activeCitizenCount > 0
                            ? '${overview.attendanceCount}/${overview.activeCitizenCount}'
                            : '${overview.attendanceCount}',
                        label: 'Total Partisipasi',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _AttendanceSummary(overview: overview),
                const SizedBox(height: 24),
                _SectionTitle(
                  title: 'Dokumentasi Kegiatan',
                  trailing: overview.documentation.isEmpty
                      ? null
                      : '${overview.documentation.length} Foto',
                ),
                const SizedBox(height: 12),
                _DocumentationGrid(
                  documentation: overview.documentation,
                  onOpen: (index) =>
                      _openDocumentation(overview.documentation, index),
                ),
                const SizedBox(height: 22),
                const _SectionTitle(title: 'Daftar Kehadiran'),
                const SizedBox(height: 10),
                if (visible.isEmpty)
                  const _EmptyAttendance()
                else
                  Column(
                    children: [
                      for (var index = 0; index < visible.length; index++)
                        Padding(
                          padding: EdgeInsets.only(
                            bottom: index < visible.length - 1 ? 8 : 0,
                          ),
                          child: _AttendanceRow(
                            attendance: visible[index],
                            colorIndex: start + index,
                          ),
                        ),
                    ],
                  ),
                if (pageCount > 1) ...[
                  const SizedBox(height: 12),
                  _DetailPagination(
                    page: page,
                    pageCount: pageCount,
                    visibleCount: visible.length,
                    totalCount: attendees.length,
                    onPrevious: page == 0
                        ? null
                        : () => setState(() => _page = page - 1),
                    onNext: page >= pageCount - 1
                        ? null
                        : () => setState(() => _page = page + 1),
                  ),
                ],
                const SizedBox(height: 20),
                SizedBox(
                  height: 48,
                  child: FilledButton(
                    key: const ValueKey('edit-event-button'),
                    onPressed: () => _openEdit(context, overview),
                    style: FilledButton.styleFrom(
                      backgroundColor: _blue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Edit Kegiatan',
                      style: TextStyle(fontSize: 15),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        _AttendanceActions(onUnavailable: _showUnavailable),
      ],
    );
  }

  Future<void> _openEdit(
    BuildContext context,
    AdminEventOverview overview,
  ) async {
    final changed = await widget.onEdit(overview.event);
    if (changed == true && mounted && context.mounted) {
      await context.read<AdminEventDetailCubit>().loadEvent(overview.event.id);
    }
  }

  Future<void> _openDocumentation(
    List<AdminEventDocumentation> documentation,
    int initialIndex,
  ) => showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Tutup dokumentasi',
    barrierColor: Colors.transparent,
    pageBuilder: (_, _, _) => EventDocumentationViewer(
      documentation: documentation,
      initialIndex: initialIndex,
    ),
  );

  void _showUnavailable() {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(content: Text('Absensi admin belum tersedia di API.')),
      );
  }

  String _dateLabel(DateTime raw) {
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
    final date = raw.toLocal();
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}

class _DetailHeader extends StatelessWidget {
  const _DetailHeader({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 76,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: 12),
              child: IconButton(
                tooltip: 'Kembali',
                onPressed: onBack,
                icon: const Icon(Icons.chevron_left_rounded, size: 30),
              ),
            ),
          ),
          const Text(
            'Detail Kegiatan',
            style: TextStyle(
              color: _AdminEventDetailViewState._ink,
              fontSize: 21,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.color,
    required this.value,
    required this.label,
    super.key,
  });

  final Color color;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: ValueKey('metric-card-surface-$label'),
      height: 112,
      padding: const EdgeInsets.fromLTRB(20, 18, 16, 16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              height: 1.2,
              fontWeight: FontWeight.w600,
            ),
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              maxLines: 1,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 32,
                height: 1,
                fontWeight: FontWeight.w400,
                letterSpacing: -0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AttendanceSummary extends StatelessWidget {
  const _AttendanceSummary({required this.overview});

  final AdminEventOverview overview;

  @override
  Widget build(BuildContext context) {
    final percentage = (overview.attendanceRate * 100).round();
    return Container(
      key: const ValueKey('attendance-summary-card'),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE5E7EB)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Ringkasan Kehadiran',
                  style: TextStyle(
                    color: _AdminEventDetailViewState._ink,
                    fontSize: 16,
                    height: 1.2,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                overview.activeCitizenCount > 0 ? '$percentage%' : '—',
                style: const TextStyle(
                  color: _AdminEventDetailViewState._green,
                  fontSize: 18,
                  height: 1.2,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              minHeight: 10,
              value: overview.attendanceRate,
              backgroundColor: const Color(0xFFE8EEFD),
              color: _AdminEventDetailViewState._blue,
            ),
          ),
          const SizedBox(height: 7),
          Row(
            children: [
              Text(
                '${overview.attendanceCount} Warga',
                style: const TextStyle(
                  color: _AdminEventDetailViewState._ink,
                  fontSize: 11,
                ),
              ),
              const Spacer(),
              Text(
                overview.activeCitizenCount > 0
                    ? 'Target: ${overview.activeCitizenCount} Warga'
                    : 'Belum ada warga aktif',
                style: const TextStyle(
                  color: _AdminEventDetailViewState._ink,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, this.trailing});

  final String title;
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: _AdminEventDetailViewState._ink,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        if (trailing != null)
          Text(
            trailing!,
            style: const TextStyle(
              color: _AdminEventDetailViewState._blue,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
      ],
    );
  }
}

class _DocumentationGrid extends StatelessWidget {
  const _DocumentationGrid({required this.documentation, required this.onOpen});

  final List<AdminEventDocumentation> documentation;
  final ValueChanged<int> onOpen;

  @override
  Widget build(BuildContext context) {
    if (documentation.isEmpty) {
      return Container(
        height: 92,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: const Color(0xFFF7F8FA),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Text(
          'Belum ada dokumentasi kegiatan.',
          style: TextStyle(
            color: _AdminEventDetailViewState._muted,
            fontSize: 12,
          ),
        ),
      );
    }

    final visible = documentation.take(3).toList(growable: false);
    return SizedBox(
      height: 170,
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: _DocumentationTile(
              documentation: visible.first,
              onTap: () => onOpen(0),
            ),
          ),
          if (visible.length > 1) ...[
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                children: [
                  Expanded(
                    child: _DocumentationTile(
                      documentation: visible[1],
                      onTap: () => onOpen(1),
                    ),
                  ),
                  if (visible.length > 2) ...[
                    const SizedBox(height: 8),
                    Expanded(
                      child: _DocumentationTile(
                        documentation: visible[2],
                        overlay: documentation.length > 3
                            ? '+${documentation.length - 3} Foto'
                            : null,
                        onTap: () => onOpen(2),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _DocumentationTile extends StatelessWidget {
  const _DocumentationTile({
    required this.documentation,
    required this.onTap,
    this.overlay,
  });

  final AdminEventDocumentation documentation;
  final VoidCallback onTap;
  final String? overlay;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF1F3F5),
      borderRadius: BorderRadius.circular(9),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        key: ValueKey('documentation-${documentation.id}'),
        onTap: onTap,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              documentation.url,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => const Center(
                child: Icon(
                  Icons.broken_image_outlined,
                  color: Color(0xFF8A8C90),
                ),
              ),
            ),
            if (overlay != null)
              ColoredBox(
                color: const Color(0x990F172A),
                child: Center(
                  child: Text(
                    overlay!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _AttendanceRow extends StatelessWidget {
  const _AttendanceRow({required this.attendance, required this.colorIndex});

  final AdminEventAttendance attendance;
  final int colorIndex;

  @override
  Widget build(BuildContext context) {
    final name = attendance.attendee.name;
    final initials = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .take(2)
        .map((part) => part[0].toUpperCase())
        .join();
    const avatarColors = [
      Color(0xFF7CEFC3),
      Color(0xFFFFD9B0),
      Color(0xFFDCE3FF),
      Color(0xFFBFD2FF),
      Color(0xFFFFC5C5),
    ];
    final avatarColor = avatarColors[colorIndex % avatarColors.length];
    return Container(
      height: 66,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE5E7EB)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: avatarColor,
            foregroundColor: _AdminEventDetailViewState._ink,
            child: Text(
              initials.isEmpty ? 'W' : initials,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _AdminEventDetailViewState._ink,
                    fontSize: 14,
                    height: 1.2,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  attendance.attendee.secondaryLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _AdminEventDetailViewState._muted,
                    fontSize: 11,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyAttendance extends StatelessWidget {
  const _EmptyAttendance();

  @override
  Widget build(BuildContext context) => Container(
    height: 88,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: const Color(0xFFF7F8FA),
      borderRadius: BorderRadius.circular(12),
    ),
    child: const Text(
      'Belum ada warga yang hadir.',
      style: TextStyle(color: _AdminEventDetailViewState._muted, fontSize: 12),
    ),
  );
}

class _DetailPagination extends StatelessWidget {
  const _DetailPagination({
    required this.page,
    required this.pageCount,
    required this.visibleCount,
    required this.totalCount,
    this.onPrevious,
    this.onNext,
  });

  final int page;
  final int pageCount;
  final int visibleCount;
  final int totalCount;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) => Container(
    constraints: const BoxConstraints(minHeight: 72),
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    decoration: BoxDecoration(
      color: const Color(0xFFE8EEFD),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      children: [
        Expanded(
          child: Text(
            'Menampilkan $visibleCount\ndari $totalCount Warga',
            style: const TextStyle(
              color: _AdminEventDetailViewState._muted,
              fontSize: 12,
              height: 1.35,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        _PaginationButton(
          icon: Icons.chevron_left_rounded,
          onPressed: onPrevious,
        ),
        const SizedBox(width: 8),
        _PaginationButton(
          label: '${page + 1}',
          selected: true,
          onPressed: () {},
        ),
        if (page + 1 < pageCount) ...[
          const SizedBox(width: 8),
          _PaginationButton(label: '${page + 2}', onPressed: onNext),
        ],
        const SizedBox(width: 8),
        _PaginationButton(icon: Icons.chevron_right_rounded, onPressed: onNext),
      ],
    ),
  );
}

class _PaginationButton extends StatelessWidget {
  const _PaginationButton({
    this.label,
    this.icon,
    this.selected = false,
    this.onPressed,
  });

  final String? label;
  final IconData? icon;
  final bool selected;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 40,
    height: 40,
    child: Material(
      color: selected ? KompakColors.success : Colors.white,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onPressed,
        child: Center(
          child: icon != null
              ? Icon(
                  icon,
                  color: onPressed == null
                      ? const Color(0xFF9AA3B2)
                      : _AdminEventDetailViewState._ink,
                )
              : Text(
                  label!,
                  style: TextStyle(
                    color: selected
                        ? Colors.white
                        : _AdminEventDetailViewState._ink,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
      ),
    ),
  );
}

class _AttendanceActions extends StatelessWidget {
  const _AttendanceActions({required this.onUnavailable});

  final VoidCallback onUnavailable;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: const BoxDecoration(
      color: Colors.white,
      border: Border(top: BorderSide(color: Color(0xFFF0F1F2))),
    ),
    child: Padding(
      padding: const EdgeInsets.fromLTRB(24, 10, 24, 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
            height: 46,
            child: FilledButton(
              key: const ValueKey('manual-attendance-button'),
              onPressed: onUnavailable,
              style: FilledButton.styleFrom(
                backgroundColor: KompakColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Absensi Manual',
                style: TextStyle(fontSize: 15),
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: FilledButton(
              key: const ValueKey('mass-attendance-button'),
              onPressed: onUnavailable,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFE8EEFD),
                foregroundColor: KompakColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Absensi Massal',
                style: TextStyle(fontSize: 15),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

class _DetailLoading extends StatelessWidget {
  const _DetailLoading();

  @override
  Widget build(BuildContext context) => Semantics(
    label: 'Memuat detail kegiatan',
    child: ListView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(24, 18, 24, 24),
      children: [
        const _SkeletonBlock(width: 220, height: 26),
        const SizedBox(height: 10),
        const _SkeletonBlock(width: 170, height: 18),
        const SizedBox(height: 24),
        Row(
          children: [
            const Expanded(child: _SkeletonBlock(height: 112)),
            const SizedBox(width: 16),
            const Expanded(child: _SkeletonBlock(height: 112)),
          ],
        ),
        const SizedBox(height: 16),
        const _SkeletonBlock(height: 104),
        const SizedBox(height: 24),
        const _SkeletonBlock(width: 190, height: 22),
        const SizedBox(height: 12),
        const _SkeletonBlock(height: 170),
      ],
    ),
  );
}

class _SkeletonBlock extends StatelessWidget {
  const _SkeletonBlock({this.width, required this.height});

  final double? width;
  final double height;

  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.centerLeft,
    child: Container(
      width: width ?? double.infinity,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFFF0F2F5),
        borderRadius: BorderRadius.circular(10),
      ),
    ),
  );
}

class _DetailFailure extends StatelessWidget {
  const _DetailFailure({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.event_busy_outlined,
            size: 42,
            color: Color(0xFF7A7C80),
          ),
          const SizedBox(height: 12),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          FilledButton(onPressed: onRetry, child: const Text('Coba Lagi')),
        ],
      ),
    ),
  );
}
