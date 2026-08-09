import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/di/injection.dart';
import '../../../../../core/routes/app_router.dart';
import '../../domain/entities/resident.dart';
import '../bloc/admin_residents_cubit.dart';
import '../bloc/admin_residents_state.dart';
import '../widgets/resident_card.dart';
import '../widgets/resident_summary_tile.dart';

enum _ResidentFilter { all, pending, active, rejected, inactive }

@RoutePage()
class AdminResidentsPage extends StatelessWidget {
  const AdminResidentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<AdminResidentsCubit>()..loadResidents(),
      child: const _AdminResidentsView(),
    );
  }
}

class _AdminResidentsView extends StatefulWidget {
  const _AdminResidentsView();

  @override
  State<_AdminResidentsView> createState() => _AdminResidentsViewState();
}

class _AdminResidentsViewState extends State<_AdminResidentsView> {
  static const _blue = Color(0xFF2F67E8);
  static const _green = Color(0xFF10B96C);
  static const _ink = Color(0xFF22262D);
  static const _muted = Color(0xFF667085);
  static const _pageSize = 4;

  final _searchController = TextEditingController();
  _ResidentFilter _filter = _ResidentFilter.pending;
  int _currentPage = 0;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AdminResidentsCubit, AdminResidentsState>(
      listenWhen: (previous, current) =>
          current is AdminResidentsLoaded &&
          current.actionError != null &&
          (previous is! AdminResidentsLoaded ||
              previous.actionError != current.actionError),
      listener: (context, state) {
        final message = (state as AdminResidentsLoaded).actionError;
        if (message == null) return;
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(message)));
      },
      builder: (context, state) {
        final residents = state is AdminResidentsLoaded
            ? state.residents
            : const <Resident>[];
        final filteredResidents = _filterResidents(residents);
        final pageCount = _pageCount(filteredResidents);
        final currentPage = _currentPage.clamp(0, pageCount - 1);
        final visibleResidents = _visibleResidents(
          filteredResidents,
          currentPage,
        );

        return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: RefreshIndicator(
              onRefresh: context.read<AdminResidentsCubit>().loadResidents,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
                children: [
                  const _Header(),
                  const SizedBox(height: 28),
                  _Summary(
                    residents: residents,
                    loading: state is AdminResidentsLoading,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 54,
                    child: FilledButton.icon(
                      onPressed: () =>
                          context.router.push(const CreateEventRoute()),
                      style: FilledButton.styleFrom(
                        backgroundColor: _blue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      icon: const Icon(Icons.add_task_rounded),
                      label: const Text(
                        'Kegiatan Baru',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  TextField(
                    controller: _searchController,
                    onChanged: (_) => setState(() => _currentPage = 0),
                    textInputAction: TextInputAction.search,
                    decoration: InputDecoration(
                      hintText: 'Cari nama, email, atau nomor telepon…',
                      hintStyle: const TextStyle(color: _muted),
                      prefixIcon: const Icon(
                        Icons.search_rounded,
                        color: _muted,
                      ),
                      suffixIcon: _searchController.text.isEmpty
                          ? null
                          : IconButton(
                              tooltip: 'Hapus pencarian',
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _currentPage = 0);
                              },
                              icon: const Icon(Icons.close_rounded),
                            ),
                      filled: true,
                      fillColor: const Color(0xFFEEF1F4),
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 52,
                          child: OutlinedButton.icon(
                            key: const ValueKey('resident-status-filter'),
                            onPressed: _selectFilter,
                            icon: const Icon(Icons.filter_list_rounded),
                            label: Text(_filterLabel),
                            style: _secondaryButtonStyle,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: SizedBox(
                          height: 52,
                          child: OutlinedButton.icon(
                            onPressed: state is AdminResidentsLoading
                                ? null
                                : context
                                      .read<AdminResidentsCubit>()
                                      .loadResidents,
                            icon: const Icon(Icons.refresh_rounded),
                            label: const Text('Muat Ulang'),
                            style: _secondaryButtonStyle,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  switch (state) {
                    AdminResidentsLoading() => const _LoadingResidents(),
                    AdminResidentsLoadFailure(:final message) =>
                      _ResidentsFailure(
                        message: message,
                        onRetry: context
                            .read<AdminResidentsCubit>()
                            .loadResidents,
                      ),
                    AdminResidentsLoaded() when visibleResidents.isEmpty =>
                      _EmptyResidents(onReset: _resetFilters),
                    AdminResidentsLoaded(:final updatingIds) => Column(
                      children: [
                        for (final resident in visibleResidents)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 14),
                            child: ResidentCard(
                              resident: resident,
                              updating: updatingIds.contains(resident.id),
                              onApprove: () => _confirmStatusChange(
                                resident,
                                ResidentStatus.active,
                              ),
                              onReject: () => _confirmStatusChange(
                                resident,
                                ResidentStatus.rejected,
                              ),
                            ),
                          ),
                      ],
                    ),
                  },
                  if (state is AdminResidentsLoaded) ...[
                    const SizedBox(height: 8),
                    _PaginationPanel(
                      currentPage: currentPage,
                      pageCount: pageCount,
                      visibleCount: visibleResidents.length,
                      totalCount: filteredResidents.length,
                      onPrevious: _currentPage == 0
                          ? null
                          : () => setState(() => _currentPage--),
                      onNext: _currentPage >= pageCount - 1
                          ? null
                          : () => setState(() => _currentPage++),
                      onPageSelected: (page) =>
                          setState(() => _currentPage = page),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  List<Resident> _filterResidents(List<Resident> residents) {
    final query = _searchController.text.trim().toLowerCase();
    return residents
        .where((resident) {
          final matchesQuery =
              query.isEmpty ||
              resident.name.toLowerCase().contains(query) ||
              resident.email.toLowerCase().contains(query) ||
              resident.phoneNumber.toLowerCase().contains(query);
          final matchesFilter = switch (_filter) {
            _ResidentFilter.all => true,
            _ResidentFilter.pending =>
              resident.status == ResidentStatus.pending,
            _ResidentFilter.active => resident.status == ResidentStatus.active,
            _ResidentFilter.rejected =>
              resident.status == ResidentStatus.rejected,
            _ResidentFilter.inactive =>
              resident.status == ResidentStatus.inactive,
          };
          return matchesQuery && matchesFilter;
        })
        .toList(growable: false);
  }

  List<Resident> _visibleResidents(List<Resident> residents, int currentPage) {
    if (residents.isEmpty) return const [];
    final start = (currentPage * _pageSize).clamp(0, residents.length);
    final end = (start + _pageSize).clamp(0, residents.length);
    return residents.sublist(start, end);
  }

  int _pageCount(List<Resident> residents) {
    final count = (residents.length / _pageSize).ceil();
    return count == 0 ? 1 : count;
  }

  ButtonStyle get _secondaryButtonStyle => OutlinedButton.styleFrom(
    foregroundColor: _ink,
    side: const BorderSide(color: Color(0xFFDDE2E8)),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
  );

  String get _filterLabel => switch (_filter) {
    _ResidentFilter.all => 'Semua Status',
    _ResidentFilter.pending => 'Menunggu',
    _ResidentFilter.active => 'Aktif',
    _ResidentFilter.rejected => 'Ditolak',
    _ResidentFilter.inactive => 'Nonaktif',
  };

  Future<void> _selectFilter() async {
    final selected = await showModalBottomSheet<_ResidentFilter>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const ListTile(
                title: Text(
                  'Status warga',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
              ),
              RadioGroup<_ResidentFilter>(
                groupValue: _filter,
                onChanged: (value) => Navigator.of(context).pop(value),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (final filter in _ResidentFilter.values)
                      RadioListTile<_ResidentFilter>(
                        value: filter,
                        title: Text(switch (filter) {
                          _ResidentFilter.all => 'Semua status',
                          _ResidentFilter.pending => 'Menunggu persetujuan',
                          _ResidentFilter.active => 'Aktif',
                          _ResidentFilter.rejected => 'Ditolak',
                          _ResidentFilter.inactive => 'Nonaktif',
                        }),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
    if (selected != null && selected != _filter) {
      setState(() {
        _filter = selected;
        _currentPage = 0;
      });
    }
  }

  Future<void> _confirmStatusChange(
    Resident resident,
    ResidentStatus status,
  ) async {
    final approving = status == ResidentStatus.active;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(approving ? 'Setujui warga?' : 'Tolak pendaftaran?'),
        content: Text(
          approving
              ? '${resident.name} akan mendapatkan akses ke fitur warga.'
              : '${resident.name} tidak akan dapat mengakses fitur warga.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Batal'),
          ),
          FilledButton(
            key: ValueKey('confirm-${status.apiValue}-${resident.id}'),
            onPressed: () => Navigator.of(context).pop(true),
            style: approving
                ? null
                : FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFD92D20),
                  ),
            child: Text(approving ? 'Setujui' : 'Tolak'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    final success = await context.read<AdminResidentsCubit>().updateStatus(
      resident,
      status,
    );
    if (!success || !mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            approving
                ? '${resident.name} berhasil disetujui.'
                : 'Pendaftaran ${resident.name} ditolak.',
          ),
        ),
      );
  }

  void _resetFilters() {
    _searchController.clear();
    setState(() {
      _filter = _ResidentFilter.pending;
      _currentPage = 0;
    });
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.fromLTRB(12, 32, 12, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Manajemen Warga',
            style: TextStyle(
              color: _AdminResidentsViewState._ink,
              fontSize: 30,
              height: 1.15,
              letterSpacing: -0.4,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Tinjau pendaftaran dan kelola status warga.',
            style: TextStyle(
              color: Color(0xFF626262),
              fontSize: 16,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

class _Summary extends StatelessWidget {
  const _Summary({required this.residents, required this.loading});

  final List<Resident> residents;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    String count(ResidentStatus status) => loading
        ? '—'
        : residents
              .where((resident) => resident.status == status)
              .length
              .toString();

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: ResidentSummaryTile(
                label: 'Total Warga',
                value: loading ? '—' : '${residents.length}',
                color: _AdminResidentsViewState._green,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: ResidentSummaryTile(
                label: 'Menunggu',
                value: count(ResidentStatus.pending),
                color: const Color(0xFFF79009),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: ResidentSummaryTile(
                label: 'Aktif',
                value: count(ResidentStatus.active),
                color: _AdminResidentsViewState._blue,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: ResidentSummaryTile(
                label: 'Ditolak',
                value: count(ResidentStatus.rejected),
                color: const Color(0xFFD92D20),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _LoadingResidents extends StatelessWidget {
  const _LoadingResidents();

  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.symmetric(vertical: 48),
    child: Center(child: CircularProgressIndicator()),
  );
}

class _ResidentsFailure extends StatelessWidget {
  const _ResidentsFailure({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 40),
    child: Column(
      children: [
        const Icon(Icons.cloud_off_rounded, size: 44, color: Color(0xFF667085)),
        const SizedBox(height: 12),
        const Text(
          'Data warga tidak dapat dimuat',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 6),
        Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Color(0xFF667085)),
        ),
        const SizedBox(height: 14),
        FilledButton.tonal(
          key: const ValueKey('retry-residents'),
          onPressed: onRetry,
          child: const Text('Coba Lagi'),
        ),
      ],
    ),
  );
}

class _EmptyResidents extends StatelessWidget {
  const _EmptyResidents({required this.onReset});

  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 36),
    child: Column(
      children: [
        const Icon(
          Icons.person_search_outlined,
          size: 42,
          color: Color(0xFF667085),
        ),
        const SizedBox(height: 12),
        const Text(
          'Warga tidak ditemukan',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 6),
        const Text(
          'Coba kata pencarian atau status yang berbeda.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Color(0xFF667085)),
        ),
        const SizedBox(height: 12),
        TextButton(onPressed: onReset, child: const Text('Reset pencarian')),
      ],
    ),
  );
}

class _PaginationPanel extends StatelessWidget {
  const _PaginationPanel({
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
    final pageButtons = <Widget>[
      _PageButton(
        semanticLabel: 'Halaman sebelumnya',
        onPressed: onPrevious,
        child: const Icon(Icons.chevron_left_rounded),
      ),
      const SizedBox(width: 8),
      for (final page in pageIndices) ...[
        _PageButton(
          semanticLabel: 'Halaman ${page + 1}',
          selected: currentPage == page,
          onPressed: () => onPageSelected(page),
          child: Text('${page + 1}'),
        ),
        const SizedBox(width: 8),
      ],
      _PageButton(
        semanticLabel: 'Halaman berikutnya',
        onPressed: onNext,
        child: const Icon(Icons.chevron_right_rounded),
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE3EDFF),
        borderRadius: BorderRadius.circular(16),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final label = Text(
            'Menampilkan $visibleCount dari $totalCount warga',
            style: const TextStyle(
              color: Color(0xFF344054),
              fontSize: 13,
              height: 1.3,
              fontWeight: FontWeight.w500,
            ),
          );
          final controls = Row(
            mainAxisSize: MainAxisSize.min,
            children: pageButtons,
          );
          if (constraints.maxWidth < 340) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [label, const SizedBox(height: 12), controls],
            );
          }
          return Row(
            children: [
              Expanded(child: label),
              const SizedBox(width: 12),
              controls,
            ],
          );
        },
      ),
    );
  }
}

class _PageButton extends StatelessWidget {
  const _PageButton({
    required this.semanticLabel,
    required this.child,
    required this.onPressed,
    this.selected = false,
  });

  final String semanticLabel;
  final Widget child;
  final VoidCallback? onPressed;
  final bool selected;

  @override
  Widget build(BuildContext context) => Semantics(
    label: semanticLabel,
    selected: selected,
    button: true,
    child: SizedBox(
      width: 42,
      height: 44,
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          padding: EdgeInsets.zero,
          foregroundColor: selected ? Colors.white : const Color(0xFF27303A),
          backgroundColor: selected ? const Color(0xFF10B96C) : Colors.white,
          disabledForegroundColor: const Color(0xFF98A2B3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(11),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        child: child,
      ),
    ),
  );
}
