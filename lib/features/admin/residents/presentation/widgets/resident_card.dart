import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/resident.dart';

class ResidentCard extends StatelessWidget {
  const ResidentCard({
    required this.resident,
    required this.onApprove,
    required this.onReject,
    this.updating = false,
    super.key,
  });

  final Resident resident;
  final VoidCallback onApprove;
  final VoidCallback onReject;
  final bool updating;

  static const _ink = Color(0xFF22262D);
  static const _muted = Color(0xFF667085);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E9EE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: _avatarColor(resident.avatarTone),
                child: Text(
                  resident.initials,
                  style: const TextStyle(
                    color: _ink,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
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
                      style: const TextStyle(
                        color: _ink,
                        fontSize: 18,
                        height: 1.2,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${resident.roleLabel} · ${NumberFormat.decimalPattern('id_ID').format(resident.points)} poin',
                      style: const TextStyle(
                        color: _muted,
                        fontSize: 13,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              _StatusChip(status: resident.status),
            ],
          ),
          const SizedBox(height: 18),
          _ContactRow(icon: Icons.mail_outline_rounded, text: resident.email),
          const SizedBox(height: 10),
          _ContactRow(icon: Icons.phone_outlined, text: resident.phoneNumber),
          if (resident.status == ResidentStatus.pending ||
              resident.status == ResidentStatus.rejected) ...[
            const SizedBox(height: 18),
            if (updating)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: CircularProgressIndicator(),
                ),
              )
            else
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      key: ValueKey('reject-${resident.id}'),
                      onPressed: onReject,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFD92D20),
                        side: const BorderSide(color: Color(0xFFFDA29B)),
                      ),
                      child: const Text('Tolak'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      key: ValueKey('approve-${resident.id}'),
                      onPressed: onApprove,
                      child: Text(
                        resident.status == ResidentStatus.rejected
                            ? 'Setujui Ulang'
                            : 'Setujui',
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ],
      ),
    );
  }

  Color _avatarColor(ResidentAvatarTone tone) => switch (tone) {
    ResidentAvatarTone.mint => const Color(0xFF83F0C3),
    ResidentAvatarTone.lavender => const Color(0xFFDCE2FF),
    ResidentAvatarTone.sky => const Color(0xFFDCEAFB),
    ResidentAvatarTone.peach => const Color(0xFFFFD7AD),
  };
}

class _ContactRow extends StatelessWidget {
  const _ContactRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: ResidentCard._muted),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: ResidentCard._ink,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final ResidentStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, color, surface) = switch (status) {
      ResidentStatus.pending => (
        'Menunggu',
        const Color(0xFFB54708),
        const Color(0xFFFFFAEB),
      ),
      ResidentStatus.active => (
        'Aktif',
        const Color(0xFF067647),
        const Color(0xFFECFDF3),
      ),
      ResidentStatus.rejected => (
        'Ditolak',
        const Color(0xFFB42318),
        const Color(0xFFFEF3F2),
      ),
      ResidentStatus.inactive => (
        'Nonaktif',
        const Color(0xFF475467),
        const Color(0xFFF2F4F7),
      ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
