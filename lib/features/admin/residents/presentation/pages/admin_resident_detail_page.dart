import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../../core/di/injection.dart';
import '../../../../../core/routes/app_router.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../domain/entities/resident.dart';
import '../bloc/admin_resident_detail_cubit.dart';
import '../bloc/admin_resident_detail_state.dart';

@RoutePage()
class AdminResidentDetailPage extends StatelessWidget {
  const AdminResidentDetailPage({
    @PathParam('residentId') required this.residentId,
    super.key,
  });

  final String residentId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          getIt<AdminResidentDetailCubit>()..loadResident(residentId),
      child: BlocConsumer<AdminResidentDetailCubit, AdminResidentDetailState>(
        listenWhen: (previous, current) =>
            current is AdminResidentDetailLoaded &&
            current.actionError != null &&
            (previous is! AdminResidentDetailLoaded ||
                previous.actionError != current.actionError),
        listener: (context, state) {
          final message = (state as AdminResidentDetailLoaded).actionError;
          if (message == null) return;
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(message)));
        },
        builder: (context, state) {
          return Scaffold(
            backgroundColor: KompakColors.surface,
            appBar: AppBar(
              backgroundColor: KompakColors.surface,
              surfaceTintColor: Colors.transparent,
              centerTitle: true,
              title: const Text(
                'Detail Warga',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
            ),
            body: switch (state) {
              AdminResidentDetailLoaded() => AdminResidentDetailView(
                resident: state.resident,
                updatingStatus: state.updatingStatus,
                onRefresh: () => context
                    .read<AdminResidentDetailCubit>()
                    .loadResident(residentId, showLoading: false),
                onEdit: () => _openEdit(context, state.resident),
                onStatusChange: (status) =>
                    _confirmStatusChange(context, state.resident, status),
              ),
              AdminResidentDetailFailure() => _DetailFailure(
                message: state.message,
                onRetry: () => context
                    .read<AdminResidentDetailCubit>()
                    .loadResident(residentId),
              ),
              _ => const _DetailLoading(),
            },
          );
        },
      ),
    );
  }

  Future<void> _openEdit(BuildContext context, Resident resident) async {
    final changed = await context.router.push<bool>(
      AdminResidentFormRoute(resident: resident),
    );
    if (changed == true && context.mounted) {
      await context.read<AdminResidentDetailCubit>().loadResident(residentId);
    }
  }

  Future<void> _confirmStatusChange(
    BuildContext context,
    Resident resident,
    ResidentStatus status,
  ) async {
    final (title, message, action) = switch (status) {
      ResidentStatus.active => (
        'Aktifkan warga?',
        '${resident.name} akan dapat masuk dan mengikuti kegiatan kembali.',
        'Aktifkan',
      ),
      ResidentStatus.rejected => (
        'Tolak pendaftaran?',
        'Akun ${resident.name} tidak akan dapat masuk ke aplikasi.',
        'Tolak',
      ),
      ResidentStatus.inactive => (
        'Nonaktifkan warga?',
        'Riwayat ${resident.name} tetap tersimpan, tetapi akun tidak dapat digunakan.',
        'Nonaktifkan',
      ),
      ResidentStatus.pending => (
        'Kembalikan ke peninjauan?',
        'Status akun akan dikembalikan ke menunggu persetujuan.',
        'Lanjutkan',
      ),
    };

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Batal'),
          ),
          FilledButton(
            key: ValueKey('confirm-resident-${status.apiValue}'),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style:
                status == ResidentStatus.inactive ||
                    status == ResidentStatus.rejected
                ? FilledButton.styleFrom(backgroundColor: KompakColors.error)
                : null,
            child: Text(action),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    final success = await context.read<AdminResidentDetailCubit>().updateStatus(
      status,
    );
    if (success && context.mounted) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text('$action berhasil.')));
    }
  }
}

class AdminResidentDetailView extends StatelessWidget {
  const AdminResidentDetailView({
    required this.resident,
    required this.updatingStatus,
    required this.onRefresh,
    required this.onEdit,
    required this.onStatusChange,
    super.key,
  });

  final Resident resident;
  final bool updatingStatus;
  final Future<void> Function() onRefresh;
  final VoidCallback onEdit;
  final ValueChanged<ResidentStatus> onStatusChange;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        key: const ValueKey('admin-resident-detail-scroll'),
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
        children: [
          _IdentityHeader(resident: resident),
          const SizedBox(height: 24),
          const _SectionLabel('Informasi Pribadi'),
          const SizedBox(height: 10),
          _InformationPanel(resident: resident),
          const SizedBox(height: 24),
          const _SectionLabel('Kontribusi'),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _MetricTile(
                  label: 'Saldo Poin',
                  value: NumberFormat.decimalPattern(
                    'id_ID',
                  ).format(resident.points),
                  icon: Icons.stars_rounded,
                  color: KompakColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MetricTile(
                  label: 'Poin Peringkat',
                  value: NumberFormat.decimalPattern(
                    'id_ID',
                  ).format(resident.leaderboardPoints),
                  icon: Icons.emoji_events_outlined,
                  color: KompakColors.success,
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          FilledButton.icon(
            key: const ValueKey('edit-resident-button'),
            onPressed: updatingStatus ? null : onEdit,
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.edit_outlined),
            label: const Text('Edit Data Warga'),
          ),
          const SizedBox(height: 10),
          _StatusActions(
            resident: resident,
            busy: updatingStatus,
            onChanged: onStatusChange,
          ),
        ],
      ),
    );
  }
}

class _IdentityHeader extends StatelessWidget {
  const _IdentityHeader({required this.resident});

  final Resident resident;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: KompakColors.primarySurface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: KompakColors.primaryBorder,
            child: Text(
              resident.initials,
              style: const TextStyle(
                color: KompakColors.ink,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  resident.name,
                  key: const ValueKey('admin-resident-detail-name'),
                  style: const TextStyle(
                    color: KompakColors.ink,
                    fontSize: 20,
                    height: 1.2,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  resident.roleLabel,
                  style: const TextStyle(
                    color: KompakColors.mutedInk,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 10),
                _ResidentStatusBadge(status: resident.status),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InformationPanel extends StatelessWidget {
  const _InformationPanel({required this.resident});

  final Resident resident;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: KompakColors.surface,
        border: Border.all(color: KompakColors.outline),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          _InformationRow(
            icon: Icons.email_outlined,
            label: 'Email',
            value: resident.email,
          ),
          const Divider(height: 1, color: KompakColors.outline),
          _InformationRow(
            icon: Icons.phone_outlined,
            label: 'Nomor Telepon',
            value: resident.phoneNumber,
          ),
          const Divider(height: 1, color: KompakColors.outline),
          _InformationRow(
            icon: Icons.cake_outlined,
            label: 'Tanggal Lahir',
            value: _birthDateLabel(resident.birthDate),
          ),
        ],
      ),
    );
  }
}

class _InformationRow extends StatelessWidget {
  const _InformationRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 21, color: KompakColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: KompakColors.mutedInk,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: const TextStyle(
                    color: KompakColors.ink,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
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

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: KompakColors.softSurface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 23),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              color: KompakColors.ink,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(color: KompakColors.mutedInk, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _StatusActions extends StatelessWidget {
  const _StatusActions({
    required this.resident,
    required this.busy,
    required this.onChanged,
  });

  final Resident resident;
  final bool busy;
  final ValueChanged<ResidentStatus> onChanged;

  @override
  Widget build(BuildContext context) {
    if (busy) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(12),
          child: CircularProgressIndicator(),
        ),
      );
    }

    return switch (resident.status) {
      ResidentStatus.pending => Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => onChanged(ResidentStatus.rejected),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
                foregroundColor: KompakColors.error,
              ),
              child: const Text('Tolak'),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: OutlinedButton(
              onPressed: () => onChanged(ResidentStatus.active),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
              ),
              child: const Text('Setujui'),
            ),
          ),
        ],
      ),
      ResidentStatus.active => OutlinedButton.icon(
        key: const ValueKey('deactivate-resident-button'),
        onPressed: () => onChanged(ResidentStatus.inactive),
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(48),
          foregroundColor: KompakColors.error,
          side: const BorderSide(color: KompakColors.error),
        ),
        icon: const Icon(Icons.person_off_outlined),
        label: const Text('Nonaktifkan Warga'),
      ),
      ResidentStatus.rejected || ResidentStatus.inactive => OutlinedButton.icon(
        key: const ValueKey('reactivate-resident-button'),
        onPressed: () => onChanged(ResidentStatus.active),
        style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
        icon: const Icon(Icons.person_add_alt_outlined),
        label: const Text('Aktifkan Warga'),
      ),
    };
  }
}

class _ResidentStatusBadge extends StatelessWidget {
  const _ResidentStatusBadge({required this.status});

  final ResidentStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, color, surface) = switch (status) {
      ResidentStatus.pending => (
        'Menunggu',
        KompakColors.warning,
        KompakColors.warningSurface,
      ),
      ResidentStatus.active => (
        'Aktif',
        KompakColors.success,
        KompakColors.successSurface,
      ),
      ResidentStatus.rejected => (
        'Ditolak',
        KompakColors.error,
        KompakColors.errorSurface,
      ),
      ResidentStatus.inactive => (
        'Nonaktif',
        KompakColors.mutedInk,
        KompakColors.softSurface,
      ),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);
  final String label;

  @override
  Widget build(BuildContext context) => Text(
    label,
    style: const TextStyle(
      color: KompakColors.ink,
      fontSize: 17,
      fontWeight: FontWeight.w700,
    ),
  );
}

class _DetailLoading extends StatelessWidget {
  const _DetailLoading();

  @override
  Widget build(BuildContext context) {
    return ListView(
      key: const ValueKey('admin-resident-detail-loading'),
      padding: const EdgeInsets.all(20),
      children: const [
        _Skeleton(height: 128),
        SizedBox(height: 24),
        _Skeleton(width: 150, height: 20),
        SizedBox(height: 10),
        _Skeleton(height: 180),
        SizedBox(height: 24),
        Row(
          children: [
            Expanded(child: _Skeleton(height: 116)),
            SizedBox(width: 12),
            Expanded(child: _Skeleton(height: 116)),
          ],
        ),
      ],
    );
  }
}

class _Skeleton extends StatelessWidget {
  const _Skeleton({this.width, required this.height});
  final double? width;
  final double height;

  @override
  Widget build(BuildContext context) => Container(
    width: width,
    height: height,
    decoration: BoxDecoration(
      color: KompakColors.softSurface,
      borderRadius: BorderRadius.circular(14),
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
            Icons.person_search_outlined,
            color: KompakColors.error,
            size: 48,
          ),
          const SizedBox(height: 16),
          const Text(
            'Data warga tidak dapat dimuat',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: KompakColors.mutedInk),
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Coba Lagi'),
          ),
        ],
      ),
    ),
  );
}

String _birthDateLabel(String value) {
  final date = DateTime.tryParse(value);
  if (date == null) return value;
  const months = [
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];
  return '${date.day.toString().padLeft(2, '0')} ${months[date.month - 1]} ${date.year}';
}
