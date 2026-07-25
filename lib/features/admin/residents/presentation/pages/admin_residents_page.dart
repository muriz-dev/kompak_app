import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import '../../../../../core/routes/app_router.dart';
import '../../data/resident_placeholders.dart';
import '../../domain/entities/resident.dart';
import '../widgets/resident_card.dart';
import '../widgets/resident_summary_tile.dart';

enum _ResidentFilter { all, active, inactive }

@RoutePage()
class AdminResidentsPage extends StatefulWidget {
  const AdminResidentsPage({super.key});

  @override
  State<AdminResidentsPage> createState() => _AdminResidentsPageState();
}

class _AdminResidentsPageState extends State<AdminResidentsPage> {
  static const _blue = Color(0xFF2F67E8);
  static const _green = Color(0xFF10B96C);
  static const _ink = Color(0xFF22262D);
  static const _muted = Color(0xFF667085);
  static const _pageSize = 4;
  static const _placeholderTotal = 482;

  final _searchController = TextEditingController();
  _ResidentFilter _filter = _ResidentFilter.all;
  int _currentPage = 0;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Resident> get _filteredResidents {
    final query = _searchController.text.trim().toLowerCase();
    return residentPlaceholders.where((resident) {
      final matchesQuery =
          query.isEmpty ||
          resident.name.toLowerCase().contains(query) ||
          resident.address.toLowerCase().contains(query) ||
          resident.id.toLowerCase().contains(query);
      final matchesFilter = switch (_filter) {
        _ResidentFilter.all => true,
        _ResidentFilter.active => resident.isActive,
        _ResidentFilter.inactive => !resident.isActive,
      };
      return matchesQuery && matchesFilter;
    }).toList();
  }

  List<Resident> get _visibleResidents {
    final residents = _filteredResidents;
    if (residents.isEmpty) return const [];
    final start = (_currentPage * _pageSize).clamp(0, residents.length);
    final end = (start + _pageSize).clamp(0, residents.length);
    return residents.sublist(start, end);
  }

  int get _pageCount {
    final count = (_filteredResidents.length / _pageSize).ceil();
    return count == 0 ? 1 : count;
  }

  @override
  Widget build(BuildContext context) {
    final visibleResidents = _visibleResidents;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(12, 32, 12, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Manajemen Warga',
                    style: TextStyle(
                      color: _ink,
                      fontSize: 30,
                      height: 1.15,
                      letterSpacing: -0.4,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'RT 004 /  RW 012 - Kelurahan Harmoni',
                    style: TextStyle(
                      color: Color(0xFF626262),
                      fontSize: 16,
                      height: 1.35,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            const Row(
              children: [
                Expanded(
                  child: ResidentSummaryTile(
                    label: 'Total Warga',
                    value: '482',
                    color: _green,
                  ),
                ),
                SizedBox(width: 14),
                Expanded(
                  child: ResidentSummaryTile(
                    label: 'Jumlah KK',
                    value: '124',
                    color: _blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            const Row(
              children: [
                Expanded(
                  child: ResidentSummaryTile(
                    label: 'Hadir Rapat',
                    value: '92%',
                    color: _blue,
                  ),
                ),
                SizedBox(width: 14),
                Expanded(
                  child: ResidentSummaryTile(
                    label: 'Poin Terdistribusi',
                    value: '15.4k',
                    color: _green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 54,
              child: FilledButton.icon(
                onPressed: () => context.router.push(const CreateEventRoute()),
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
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ),
            ),
            const SizedBox(height: 18),
            TextField(
              controller: _searchController,
              onChanged: (_) => setState(() => _currentPage = 0),
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'Cari nama warga, alamat, atau NIK…',
                hintStyle: const TextStyle(color: _muted),
                prefixIcon: const Icon(Icons.search_rounded, color: _muted),
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
                      onPressed: () => _showPlaceholderMessage('Export data'),
                      icon: const Icon(Icons.file_download_outlined),
                      label: const Text('Export'),
                      style: _secondaryButtonStyle,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            if (visibleResidents.isEmpty)
              _EmptyResidents(onReset: _resetFilters)
            else
              ...visibleResidents.map(
                (resident) => Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: ResidentCard(
                    resident: resident,
                    onEdit: () =>
                        _showPlaceholderMessage('Edit ${resident.name}'),
                    onRestore: () =>
                        _showPlaceholderMessage('Aktifkan ${resident.name}'),
                    onDelete: () =>
                        _showPlaceholderMessage('Hapus ${resident.name}'),
                  ),
                ),
              ),
            const SizedBox(height: 8),
            _PaginationPanel(
              currentPage: _currentPage,
              pageCount: _pageCount,
              visibleCount: visibleResidents.length,
              filtered:
                  _filter != _ResidentFilter.all ||
                  _searchController.text.trim().isNotEmpty,
              placeholderTotal: _placeholderTotal,
              onPrevious: _currentPage == 0
                  ? null
                  : () => setState(() => _currentPage--),
              onNext: _currentPage >= _pageCount - 1
                  ? null
                  : () => setState(() => _currentPage++),
              onPageSelected: (page) => setState(() => _currentPage = page),
            ),
          ],
        ),
      ),
    );
  }

  ButtonStyle get _secondaryButtonStyle => OutlinedButton.styleFrom(
    foregroundColor: _ink,
    side: const BorderSide(color: Color(0xFFDDE2E8)),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
  );

  String get _filterLabel => switch (_filter) {
    _ResidentFilter.all => 'Filter',
    _ResidentFilter.active => 'Aktif',
    _ResidentFilter.inactive => 'Tidak Aktif',
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
                          _ResidentFilter.active => 'Aktif',
                          _ResidentFilter.inactive => 'Tidak Aktif',
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

  void _resetFilters() {
    _searchController.clear();
    setState(() {
      _filter = _ResidentFilter.all;
      _currentPage = 0;
    });
  }

  void _showPlaceholderMessage(String action) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text('$action akan dihubungkan ke API berikutnya.')),
      );
  }
}

class _EmptyResidents extends StatelessWidget {
  final VoidCallback onReset;

  const _EmptyResidents({required this.onReset});

  @override
  Widget build(BuildContext context) {
    return Padding(
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
}

class _PaginationPanel extends StatelessWidget {
  final int currentPage;
  final int pageCount;
  final int visibleCount;
  final bool filtered;
  final int placeholderTotal;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;
  final ValueChanged<int> onPageSelected;

  const _PaginationPanel({
    required this.currentPage,
    required this.pageCount,
    required this.visibleCount,
    required this.filtered,
    required this.placeholderTotal,
    required this.onPrevious,
    required this.onNext,
    required this.onPageSelected,
  });

  @override
  Widget build(BuildContext context) {
    final totalLabel = filtered
        ? 'hasil placeholder'
        : '$placeholderTotal warga';
    final pageButtons = <Widget>[
      _PageButton(
        semanticLabel: 'Halaman sebelumnya',
        onPressed: onPrevious,
        child: const Icon(Icons.chevron_left_rounded),
      ),
      const SizedBox(width: 8),
      for (var page = 0; page < pageCount.clamp(1, 2); page++) ...[
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
            'Menampilkan $visibleCount dari $totalLabel',
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
  final String semanticLabel;
  final Widget child;
  final VoidCallback? onPressed;
  final bool selected;

  const _PageButton({
    required this.semanticLabel,
    required this.child,
    required this.onPressed,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
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
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
