import 'dart:math' as math;

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/di/injection.dart';
import '../../../../../core/routes/app_router.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../announcements/domain/entities/community_announcement.dart';
import '../bloc/admin_announcements_cubit.dart';
import '../bloc/admin_announcements_state.dart';

enum _AnnouncementOrder { newest, oldest }

@RoutePage()
class AdminAnnouncementsPage extends StatelessWidget {
  const AdminAnnouncementsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<AdminAnnouncementsCubit>()..loadAnnouncements(),
      child: AdminAnnouncementsView(
        onBack: () => context.router.maybePop(),
        onCreate: () => context.router.push<bool>(AnnouncementFormRoute()),
        onEdit: (announcement) => context.router.push<bool>(
          AnnouncementFormRoute(announcement: announcement),
        ),
      ),
    );
  }
}

class AdminAnnouncementsView extends StatefulWidget {
  const AdminAnnouncementsView({
    required this.onBack,
    required this.onCreate,
    required this.onEdit,
    super.key,
  });

  final VoidCallback onBack;
  final Future<bool?> Function() onCreate;
  final Future<bool?> Function(CommunityAnnouncement announcement) onEdit;

  @override
  State<AdminAnnouncementsView> createState() => _AdminAnnouncementsViewState();
}

class _AdminAnnouncementsViewState extends State<AdminAnnouncementsView> {
  static const _pageSize = 5;
  static const _ink = Color(0xFF2F3236);
  static const _muted = Color(0xFF717680);
  static const _field = Color(0xFFF1F1F2);

  final _searchController = TextEditingController();
  _AnnouncementOrder _order = _AnnouncementOrder.newest;
  int _currentPage = 0;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFEFFFF),
      body: SafeArea(
        child: Column(
          children: [
            _PageHeader(title: 'Daftar Pengumuman', onBack: widget.onBack),
            Expanded(
              child:
                  BlocBuilder<AdminAnnouncementsCubit, AdminAnnouncementsState>(
                    builder: (context, state) {
                      final announcements = state is AdminAnnouncementsLoaded
                          ? _visibleSource(state.announcements)
                          : const <CommunityAnnouncement>[];
                      final pageCount = math.max(
                        1,
                        (announcements.length / _pageSize).ceil(),
                      );
                      final currentPage = _currentPage.clamp(0, pageCount - 1);
                      final start = currentPage * _pageSize;
                      final end = math.min(
                        start + _pageSize,
                        announcements.length,
                      );
                      final visibleAnnouncements = start < end
                          ? announcements.sublist(start, end)
                          : const <CommunityAnnouncement>[];

                      return RefreshIndicator(
                        onRefresh: context
                            .read<AdminAnnouncementsCubit>()
                            .loadAnnouncements,
                        child: ListView(
                          key: const ValueKey('admin-announcements-scroll'),
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(24, 17, 24, 30),
                          children: [
                            _SearchAndFilter(
                              controller: _searchController,
                              order: _order,
                              onSearchChanged: (_) =>
                                  setState(() => _currentPage = 0),
                              onFilterPressed: _selectOrder,
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              height: 46,
                              child: FilledButton.icon(
                                key: const ValueKey(
                                  'create-announcement-button',
                                ),
                                onPressed: _openCreate,
                                style: FilledButton.styleFrom(
                                  backgroundColor: KompakColors.primary,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                icon: const Icon(Icons.add_rounded, size: 20),
                                label: const Text(
                                  'Buat Pengumuman',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            switch (state) {
                              AdminAnnouncementsLoading() =>
                                const _AnnouncementsLoading(),
                              AdminAnnouncementsLoadFailure(:final message) =>
                                _AnnouncementsFailure(
                                  message: message,
                                  onRetry: context
                                      .read<AdminAnnouncementsCubit>()
                                      .loadAnnouncements,
                                ),
                              AdminAnnouncementsLoaded()
                                  when visibleAnnouncements.isEmpty =>
                                _EmptyAnnouncements(onReset: _resetSearch),
                              AdminAnnouncementsLoaded() => Column(
                                children: [
                                  for (
                                    var index = 0;
                                    index < visibleAnnouncements.length;
                                    index++
                                  )
                                    Padding(
                                      padding: EdgeInsets.only(
                                        bottom:
                                            index ==
                                                visibleAnnouncements.length - 1
                                            ? 0
                                            : 16,
                                      ),
                                      child: _AnnouncementListItem(
                                        announcement:
                                            visibleAnnouncements[index],
                                        onEdit: () => _openEdit(
                                          visibleAnnouncements[index],
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            },
                            if (state is AdminAnnouncementsLoaded) ...[
                              const SizedBox(height: 20),
                              _AnnouncementsPagination(
                                currentPage: currentPage,
                                pageCount: pageCount,
                                visibleCount: visibleAnnouncements.length,
                                totalCount: announcements.length,
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
                      );
                    },
                  ),
            ),
          ],
        ),
      ),
    );
  }

  List<CommunityAnnouncement> _visibleSource(
    List<CommunityAnnouncement> announcements,
  ) {
    final query = _searchController.text.trim().toLowerCase();
    final filtered = announcements
        .where(
          (announcement) =>
              query.isEmpty ||
              announcement.title.toLowerCase().contains(query) ||
              announcement.description.toLowerCase().contains(query),
        )
        .toList(growable: false);
    return [...filtered]..sort(
      (left, right) => _order == _AnnouncementOrder.newest
          ? right.createdAt.compareTo(left.createdAt)
          : left.createdAt.compareTo(right.createdAt),
    );
  }

  Future<void> _selectOrder() async {
    final selected = await showModalBottomSheet<_AnnouncementOrder>(
      context: context,
      showDragHandle: true,
      backgroundColor: Colors.white,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const ListTile(
                title: Text(
                  'Urutkan pengumuman',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
              ),
              RadioGroup<_AnnouncementOrder>(
                groupValue: _order,
                onChanged: (value) => Navigator.of(context).pop(value),
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    RadioListTile(
                      value: _AnnouncementOrder.newest,
                      title: Text('Terbaru'),
                    ),
                    RadioListTile(
                      value: _AnnouncementOrder.oldest,
                      title: Text('Terlama'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
    if (selected == null || selected == _order) return;
    setState(() {
      _order = selected;
      _currentPage = 0;
    });
  }

  Future<void> _openCreate() async {
    final changed = await widget.onCreate();
    if (changed != true || !mounted) return;
    await context.read<AdminAnnouncementsCubit>().loadAnnouncements();
  }

  Future<void> _openEdit(CommunityAnnouncement announcement) async {
    final changed = await widget.onEdit(announcement);
    if (changed != true || !mounted) return;
    await context.read<AdminAnnouncementsCubit>().loadAnnouncements();
    if (mounted) _showMessage('Daftar pengumuman berhasil diperbarui.');
  }

  void _resetSearch() {
    _searchController.clear();
    setState(() {
      _order = _AnnouncementOrder.newest;
      _currentPage = 0;
    });
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

class _PageHeader extends StatelessWidget {
  const _PageHeader({required this.title, required this.onBack});

  final String title;
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
              padding: const EdgeInsets.only(left: 8),
              child: IconButton(
                tooltip: 'Kembali',
                onPressed: onBack,
                iconSize: 28,
                color: _AdminAnnouncementsViewState._ink,
                icon: const Icon(Icons.chevron_left_rounded),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 64),
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: _AdminAnnouncementsViewState._ink,
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
    required this.order,
    required this.onSearchChanged,
    required this.onFilterPressed,
  });

  final TextEditingController controller;
  final _AnnouncementOrder order;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onFilterPressed;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            key: const ValueKey('announcement-search'),
            controller: controller,
            onChanged: onSearchChanged,
            textInputAction: TextInputAction.search,
            style: const TextStyle(fontSize: 14),
            decoration: InputDecoration(
              hintText: 'Cari pengumuman',
              hintStyle: const TextStyle(
                color: Color(0xFF8D9199),
                fontSize: 14,
              ),
              prefixIcon: const Icon(
                Icons.search_rounded,
                size: 19,
                color: Color(0xFF8D9199),
              ),
              filled: true,
              fillColor: _AdminAnnouncementsViewState._field,
              contentPadding: const EdgeInsets.symmetric(vertical: 13),
              border: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        SizedBox(
          height: 48,
          child: OutlinedButton.icon(
            key: const ValueKey('announcement-filter'),
            onPressed: onFilterPressed,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              foregroundColor: _AdminAnnouncementsViewState._ink,
              side: BorderSide(
                color: order == _AnnouncementOrder.newest
                    ? const Color(0xFFF1F1F2)
                    : KompakColors.primary,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.filter_list_rounded, size: 18),
            label: const Text('Filter', style: TextStyle(fontSize: 13)),
          ),
        ),
      ],
    );
  }
}

class _AnnouncementListItem extends StatelessWidget {
  const _AnnouncementListItem({
    required this.announcement,
    required this.onEdit,
  });

  final CommunityAnnouncement announcement;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFF1F1F2)),
      ),
      child: InkWell(
        key: ValueKey('announcement-${announcement.id}'),
        onTap: onEdit,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(17, 14, 10, 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      announcement.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: _AdminAnnouncementsViewState._ink,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      announcement.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: _AdminAnnouncementsViewState._muted,
                        fontSize: 11,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                key: ValueKey('edit-announcement-${announcement.id}'),
                tooltip: 'Edit ${announcement.title}',
                onPressed: onEdit,
                visualDensity: VisualDensity.compact,
                color: const Color(0xFF3D4A42),
                icon: const Icon(Icons.edit_outlined, size: 19),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AnnouncementsPagination extends StatelessWidget {
  const _AnnouncementsPagination({
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
    final pages = switch (pageCount) {
      <= 2 => List.generate(pageCount, (index) => index),
      _ when currentPage == 0 => const [0, 1],
      _ when currentPage == pageCount - 1 => [pageCount - 2, pageCount - 1],
      _ => [currentPage, currentPage + 1],
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
              'Menampilkan\n$visibleCount dari $totalCount',
              style: const TextStyle(
                color: Color(0xFF3D4A42),
                fontSize: 13,
                height: 1.15,
              ),
            ),
          ),
          _PageButton(
            label: 'Halaman sebelumnya',
            onPressed: onPrevious,
            child: const Icon(Icons.chevron_left_rounded, size: 20),
          ),
          for (final page in pages) ...[
            const SizedBox(width: 8),
            _PageButton(
              label: 'Halaman ${page + 1}',
              selected: page == currentPage,
              onPressed: () => onPageSelected(page),
              child: Text('${page + 1}'),
            ),
          ],
          const SizedBox(width: 8),
          _PageButton(
            label: 'Halaman berikutnya',
            onPressed: onNext,
            child: const Icon(Icons.chevron_right_rounded, size: 20),
          ),
        ],
      ),
    );
  }
}

class _PageButton extends StatelessWidget {
  const _PageButton({
    required this.label,
    required this.onPressed,
    required this.child,
    this.selected = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final Widget child;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      selected: selected,
      button: true,
      child: SizedBox.square(
        dimension: 40,
        child: TextButton(
          onPressed: onPressed,
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            backgroundColor: selected ? KompakColors.success : Colors.white,
            foregroundColor: selected ? Colors.white : const Color(0xFF2F3236),
            disabledForegroundColor: const Color(0xFF98A2B3),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

class _AnnouncementsLoading extends StatelessWidget {
  const _AnnouncementsLoading();

  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.symmetric(vertical: 56),
    child: Center(child: CircularProgressIndicator()),
  );
}

class _AnnouncementsFailure extends StatelessWidget {
  const _AnnouncementsFailure({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 40),
    child: Column(
      children: [
        const Icon(Icons.cloud_off_rounded, size: 42, color: Color(0xFF717680)),
        const SizedBox(height: 10),
        const Text(
          'Pengumuman tidak dapat dimuat',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 6),
        Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Color(0xFF717680), fontSize: 12),
        ),
        const SizedBox(height: 12),
        FilledButton.tonal(
          key: const ValueKey('retry-announcements'),
          onPressed: onRetry,
          child: const Text('Coba Lagi'),
        ),
      ],
    ),
  );
}

class _EmptyAnnouncements extends StatelessWidget {
  const _EmptyAnnouncements({required this.onReset});

  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 40),
    child: Column(
      children: [
        const Icon(Icons.campaign_outlined, size: 42, color: Color(0xFF717680)),
        const SizedBox(height: 10),
        const Text(
          'Pengumuman tidak ditemukan',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 6),
        const Text(
          'Buat pengumuman baru atau ubah kata pencarian.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Color(0xFF717680), fontSize: 12),
        ),
        const SizedBox(height: 10),
        TextButton(onPressed: onReset, child: const Text('Reset pencarian')),
      ],
    ),
  );
}
