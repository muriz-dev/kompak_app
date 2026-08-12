import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../../core/di/injection.dart';
import '../../../../../core/routes/app_router.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../auth/domain/entities/session_user.dart';
import '../../../../auth/presentation/session/session_cubit.dart';
import '../../../../auth/presentation/session/session_state.dart';
import '../../../../home/presentation/widgets/profile_mode_sheet.dart';
import '../../../shared/presentation/widgets/admin_dashboard_header.dart';
import '../../domain/entities/resident.dart';
import '../bloc/admin_residents_cubit.dart';
import '../bloc/admin_residents_state.dart';
import '../widgets/resident_card.dart';
import '../widgets/resident_summary_tile.dart';

enum _ResidentFilter { all, pending, active, rejected, inactive }

enum _ManagementAction {
  addResident,
  announcements,
  providers,
  pointStore,
  events,
  rewards,
}

@RoutePage()
class AdminResidentsPage extends StatelessWidget {
  const AdminResidentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final sessionState = context.watch<SessionCubit>().state;
    final activeUser = sessionState is SessionActive ? sessionState.user : null;

    if (activeUser == null) {
      return const Scaffold(
        backgroundColor: Color(0xFFFEFFFF),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return BlocProvider(
      create: (_) => getIt<AdminResidentsCubit>()..loadResidents(),
      child: _AdminResidentsView(user: activeUser),
    );
  }
}

class _AdminResidentsView extends StatefulWidget {
  const _AdminResidentsView({required this.user});

  final SessionUser user;

  @override
  State<_AdminResidentsView> createState() => _AdminResidentsViewState();
}

class _AdminResidentsViewState extends State<_AdminResidentsView> {
  static const _ink = Color(0xFF2F3236);
  static const _muted = Color(0xFF68696A);
  static const _field = Color(0xFFF1F1F2);
  static const _pageSize = 4;

  final _searchController = TextEditingController();
  _ResidentFilter _filter = _ResidentFilter.all;
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
        _showMessage(message);
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
          backgroundColor: const Color(0xFFFEFFFF),
          body: SafeArea(
            child: RefreshIndicator(
              onRefresh: context.read<AdminResidentsCubit>().loadResidents,
              child: ListView(
                key: const ValueKey('admin-dashboard-scroll'),
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 30),
                children: [
                  AdminDashboardHeader(
                    userName: widget.user.name,
                    onProfileTap: _showAdminProfileMenu,
                  ),
                  const SizedBox(height: 24),
                  const _DashboardIntro(),
                  const SizedBox(height: 24),
                  const _SectionTitle('Ringkasan Warga'),
                  const SizedBox(height: 10),
                  _Summary(
                    residents: residents,
                    loading: state is AdminResidentsLoading,
                  ),
                  const SizedBox(height: 24),
                  _ManagementGrid(onSelected: _handleManagementAction),
                  const SizedBox(height: 24),
                  const _SectionTitle('Daftar Warga'),
                  const SizedBox(height: 10),
                  TextField(
                    key: const ValueKey('resident-search'),
                    controller: _searchController,
                    onChanged: (_) => setState(() => _currentPage = 0),
                    textInputAction: TextInputAction.search,
                    style: const TextStyle(fontSize: 13, color: _ink),
                    decoration: InputDecoration(
                      hintText: 'Cari nama, email, atau nomor telepon...',
                      hintStyle: const TextStyle(
                        color: Color(0xFF8D9199),
                        fontSize: 12,
                      ),
                      prefixIcon: const Icon(
                        Icons.search_rounded,
                        size: 18,
                        color: Color(0xFF8D9199),
                      ),
                      prefixIconConstraints: const BoxConstraints(minWidth: 38),
                      suffixIcon: _searchController.text.isEmpty
                          ? null
                          : IconButton(
                              tooltip: 'Hapus pencarian',
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _currentPage = 0);
                              },
                              icon: const Icon(Icons.close_rounded, size: 18),
                            ),
                      filled: true,
                      fillColor: _field,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _ToolbarButton(
                          key: const ValueKey('resident-status-filter'),
                          icon: Icons.filter_list_rounded,
                          label: _filterLabel,
                          onPressed: _selectFilter,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _ToolbarButton(
                          key: const ValueKey('reload-residents'),
                          icon: Icons.refresh_rounded,
                          label: 'Muat Ulang',
                          onPressed: state is AdminResidentsLoading
                              ? null
                              : context
                                    .read<AdminResidentsCubit>()
                                    .loadResidents,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
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
                            padding: const EdgeInsets.only(bottom: 10),
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
                    const SizedBox(height: 2),
                    _PaginationPanel(
                      currentPage: currentPage,
                      pageCount: pageCount,
                      visibleCount: visibleResidents.length,
                      totalCount: filteredResidents.length,
                      onPrevious: currentPage == 0
                          ? null
                          : () =>
                                setState(() => _currentPage = currentPage - 1),
                      onNext: currentPage >= pageCount - 1
                          ? null
                          : () =>
                                setState(() => _currentPage = currentPage + 1),
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

  String get _filterLabel => switch (_filter) {
    _ResidentFilter.all => 'Filter',
    _ResidentFilter.pending => 'Menunggu',
    _ResidentFilter.active => 'Aktif',
    _ResidentFilter.rejected => 'Ditolak',
    _ResidentFilter.inactive => 'Nonaktif',
  };

  Future<void> _selectFilter() async {
    final selected = await showModalBottomSheet<_ResidentFilter>(
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

  void _handleManagementAction(_ManagementAction action) {
    if (action == _ManagementAction.events) {
      context.router.push(const AdminEventsRoute());
      return;
    }
    if (action == _ManagementAction.announcements) {
      context.router.push(const AdminAnnouncementsRoute());
      return;
    }
    if (action == _ManagementAction.providers) {
      context.router.push(const AdminProvidersRoute());
      return;
    }
    if (action == _ManagementAction.pointStore) {
      context.router.push(AdminPointShopRoute());
      return;
    }
    if (action == _ManagementAction.rewards) {
      context.router.push(const AdminLeaderboardRewardsRoute());
      return;
    }

    final label = switch (action) {
      _ManagementAction.addResident => 'Tambah warga',
      _ManagementAction.announcements => 'Manajemen pengumuman',
      _ManagementAction.providers => 'Manajemen provider',
      _ManagementAction.pointStore => 'Manajemen toko poin',
      _ManagementAction.events => 'Manajemen kegiatan',
      _ManagementAction.rewards => 'Manajemen reward',
    };
    _showMessage('$label belum tersedia.');
  }

  Future<void> _showAdminProfileMenu() {
    return showProfileModeMenu(
      context: context,
      builder: (dialogContext) => ProfileModeSheet(
        name: widget.user.name,
        email: widget.user.email,
        canAccessAdmin: true,
        currentMode: ProfileAccountMode.admin,
        onOpenProfile: () {
          Navigator.of(dialogContext).pop();
          context.router.root.push(const ProfileRoute());
        },
        onSwitchResident: () {
          Navigator.of(dialogContext).pop();
          context.router.root.replaceAll([
            const MainRoute(children: [HomeRoute()]),
          ]);
        },
        onSwitchProvider: () {
          Navigator.of(dialogContext).pop();
          context.router.root.push(const ProviderEntryRoute());
        },
        onLogout: () {
          Navigator.of(dialogContext).pop();
          context.read<SessionCubit>().logout();
        },
      ),
    );
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
    _showMessage(
      approving
          ? '${resident.name} berhasil disetujui.'
          : 'Pendaftaran ${resident.name} ditolak.',
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _resetFilters() {
    _searchController.clear();
    setState(() {
      _filter = _ResidentFilter.all;
      _currentPage = 0;
    });
  }
}

class _DashboardIntro extends StatelessWidget {
  const _DashboardIntro();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Dashboard Admin',
          style: TextStyle(
            color: _AdminResidentsViewState._ink,
            fontSize: 25,
            height: 1.2,
            letterSpacing: -0.2,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 6),
        Text(
          'Kelola warga, kegiatan, dan layanan komunitas.',
          style: TextStyle(
            color: _AdminResidentsViewState._muted,
            fontSize: 14,
            height: 1.35,
          ),
        ),
        SizedBox(height: 6),
        Text(
          'RT 004 / RW 012 · Kelurahan Harmoni',
          style: TextStyle(
            color: KompakColors.primary,
            fontSize: 12,
            height: 1.2,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        label,
        style: const TextStyle(
          color: _AdminResidentsViewState._ink,
          fontSize: 17,
          fontWeight: FontWeight.w700,
        ),
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
    final distributedPoints = residents.fold<int>(
      0,
      (total, resident) => total + resident.points,
    );

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFE9EFFD),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: ResidentSummaryTile(
                  label: 'Total Warga',
                  value: loading ? '—' : '${residents.length}',
                  color: KompakColors.success,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ResidentSummaryTile(
                  label: 'Menunggu',
                  value: count(ResidentStatus.pending),
                  color: KompakColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: ResidentSummaryTile(
                  label: 'Warga Aktif',
                  value: count(ResidentStatus.active),
                  color: KompakColors.primary,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ResidentSummaryTile(
                  label: 'Total Saldo Poin',
                  value: loading ? '—' : _compactNumber(distributedPoints),
                  color: KompakColors.success,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _compactNumber(int value) {
    if (value < 1000) return NumberFormat.decimalPattern('id_ID').format(value);
    final tenths = (value + 50) ~/ 100;
    final whole = tenths ~/ 10;
    final decimal = tenths % 10;
    return decimal == 0 ? '${whole}k' : '$whole.${decimal}k';
  }
}

class _ManagementGrid extends StatelessWidget {
  const _ManagementGrid({required this.onSelected});

  final ValueChanged<_ManagementAction> onSelected;

  @override
  Widget build(BuildContext context) {
    const items = [
      (_ManagementAction.addResident, 'Tambah Warga', Icons.person_add_alt_1),
      (_ManagementAction.announcements, 'Pengumuman', Icons.campaign_rounded),
      (_ManagementAction.providers, 'Provider', Icons.groups_2_rounded),
      (_ManagementAction.pointStore, 'Toko Poin', Icons.storefront_rounded),
      (_ManagementAction.events, 'Kegiatan', Icons.event_available_rounded),
      (_ManagementAction.rewards, 'Reward', Icons.stars_rounded),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle('Menu Pengelolaan'),
        const SizedBox(height: 10),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            mainAxisExtent: 96,
          ),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final (action, label, icon) = items[index];
            return _ManagementButton(
              key: ValueKey('management-${action.name}'),
              label: label,
              icon: icon,
              color: index.isEven ? KompakColors.success : KompakColors.primary,
              onTap: () => onSelected(action),
            );
          },
        ),
      ],
    );
  }
}

class _ManagementButton extends StatelessWidget {
  const _ManagementButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
    super.key,
  });

  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFF1F1F2)),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                child: Icon(icon, size: 21, color: Colors.white),
              ),
              const SizedBox(height: 7),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: _AdminResidentsViewState._ink,
                  fontSize: 10,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ToolbarButton extends StatelessWidget {
  const _ToolbarButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    super.key,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: _AdminResidentsViewState._ink,
          side: const BorderSide(color: Color(0xFFF1F1F2)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),
        icon: Icon(icon, size: 16),
        label: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
      ),
    );
  }
}

class _LoadingResidents extends StatelessWidget {
  const _LoadingResidents();

  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.symmetric(vertical: 40),
    child: Center(child: CircularProgressIndicator()),
  );
}

class _ResidentsFailure extends StatelessWidget {
  const _ResidentsFailure({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 32),
    child: Column(
      children: [
        const Icon(Icons.cloud_off_rounded, size: 40, color: Color(0xFF667085)),
        const SizedBox(height: 10),
        const Text(
          'Data warga tidak dapat dimuat',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 6),
        Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Color(0xFF667085), fontSize: 12),
        ),
        const SizedBox(height: 12),
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
    padding: const EdgeInsets.symmetric(vertical: 30),
    child: Column(
      children: [
        const Icon(
          Icons.person_search_outlined,
          size: 40,
          color: Color(0xFF667085),
        ),
        const SizedBox(height: 10),
        const Text(
          'Warga tidak ditemukan',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 5),
        const Text(
          'Coba kata pencarian atau status yang berbeda.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Color(0xFF667085), fontSize: 12),
        ),
        const SizedBox(height: 10),
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

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFE3EDFF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Menampilkan $visibleCount dari $totalCount warga',
              style: const TextStyle(
                color: Color(0xFF344054),
                fontSize: 10,
                height: 1.2,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 8),
          _PageButton(
            semanticLabel: 'Halaman sebelumnya',
            onPressed: onPrevious,
            child: const Icon(Icons.chevron_left_rounded, size: 18),
          ),
          for (final page in pageIndices) ...[
            const SizedBox(width: 6),
            _PageButton(
              semanticLabel: 'Halaman ${page + 1}',
              selected: currentPage == page,
              onPressed: () => onPageSelected(page),
              child: Text('${page + 1}'),
            ),
          ],
          const SizedBox(width: 6),
          _PageButton(
            semanticLabel: 'Halaman berikutnya',
            onPressed: onNext,
            child: const Icon(Icons.chevron_right_rounded, size: 18),
          ),
        ],
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
    child: SizedBox.square(
      dimension: 36,
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          padding: EdgeInsets.zero,
          foregroundColor: selected ? Colors.white : const Color(0xFF27303A),
          backgroundColor: selected ? KompakColors.success : Colors.white,
          disabledForegroundColor: const Color(0xFF98A2B3),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
        ),
        child: child,
      ),
    ),
  );
}
