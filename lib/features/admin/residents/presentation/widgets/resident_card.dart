import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../../core/theme/app_theme.dart';
import '../../domain/entities/resident.dart';

class ResidentCard extends StatelessWidget {
  const ResidentCard({
    required this.resident,
    required this.onTap,
    required this.onApprove,
    required this.onReject,
    this.updating = false,
    super.key,
  });

  final Resident resident;
  final VoidCallback onTap;
  final VoidCallback onApprove;
  final VoidCallback onReject;
  final bool updating;

  static const _ink = Color(0xFF2F3236);
  static const _muted = Color(0xFF8D9199);

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Buka detail ${resident.name}',
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 180),
        opacity: resident.status == ResidentStatus.inactive ? 0.7 : 1,
        child: InkWell(
          key: ValueKey('resident-card-${resident.id}'),
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFF1F1F2)),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0D000000),
                  offset: Offset(0, 1),
                  blurRadius: 2,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: _avatarColor(resident.avatarTone),
                      child: Text(
                        resident.initials,
                        style: const TextStyle(
                          color: _ink,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            resident.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: _ink,
                              fontSize: 16,
                              height: 1.2,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${resident.roleLabel} • ${NumberFormat.decimalPattern('id_ID').format(resident.points)} poin',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: _muted,
                              fontSize: 10,
                              height: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    _StatusChip(status: resident.status),
                  ],
                ),
                const SizedBox(height: 14),
                _ContactLine(label: 'Telepon:', value: resident.phoneNumber),
                const SizedBox(height: 5),
                _ContactLine(label: 'Email:', value: resident.email),
                if (resident.status == ResidentStatus.pending ||
                    resident.status == ResidentStatus.rejected) ...[
                  const SizedBox(height: 14),
                  if (updating)
                    const Center(
                      child: SizedBox.square(
                        dimension: 24,
                        child: CircularProgressIndicator(strokeWidth: 2.5),
                      ),
                    )
                  else if (resident.status == ResidentStatus.pending)
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            key: ValueKey('reject-${resident.id}'),
                            onPressed: onReject,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFFD92D20),
                              side: const BorderSide(color: Color(0xFFFDA29B)),
                              minimumSize: const Size.fromHeight(38),
                              visualDensity: VisualDensity.compact,
                            ),
                            child: const Text('Tolak'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: FilledButton(
                            key: ValueKey('approve-${resident.id}'),
                            onPressed: onApprove,
                            style: FilledButton.styleFrom(
                              minimumSize: const Size.fromHeight(38),
                              visualDensity: VisualDensity.compact,
                            ),
                            child: const Text('Setujui'),
                          ),
                        ),
                      ],
                    )
                  else
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        key: ValueKey('approve-${resident.id}'),
                        onPressed: onApprove,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: KompakColors.primary,
                          side: const BorderSide(color: KompakColors.primary),
                          minimumSize: const Size.fromHeight(38),
                          visualDensity: VisualDensity.compact,
                        ),
                        child: const Text('Setujui Ulang'),
                      ),
                    ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _avatarColor(ResidentAvatarTone tone) => switch (tone) {
    ResidentAvatarTone.mint => const Color(0xFF85F8C4),
    ResidentAvatarTone.lavender => const Color(0xFFDBE1FF),
    ResidentAvatarTone.sky => const Color(0xFFCBDBF5),
    ResidentAvatarTone.peach => const Color(0xFFFFD7AD),
  };
}

class _ContactLine extends StatelessWidget {
  const _ContactLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 52,
          child: Text(
            label,
            style: const TextStyle(
              color: Color(0xFF717680),
              fontSize: 10,
              height: 1.35,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: ResidentCard._ink,
              fontSize: 12,
              height: 1.2,
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
    final (label, color) = switch (status) {
      ResidentStatus.pending => ('Menunggu', const Color(0xFFF79009)),
      ResidentStatus.active => ('Aktif', KompakColors.success),
      ResidentStatus.rejected => ('Ditolak', const Color(0xFFF04438)),
      ResidentStatus.inactive => ('Nonaktif', const Color(0xFF8D9199)),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5,
            height: 5,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              height: 1.2,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
