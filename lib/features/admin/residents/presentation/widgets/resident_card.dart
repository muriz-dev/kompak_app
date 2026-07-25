import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/resident.dart';

class ResidentCard extends StatelessWidget {
  final Resident resident;
  final VoidCallback onEdit;
  final VoidCallback onRestore;
  final VoidCallback onDelete;

  const ResidentCard({
    super.key,
    required this.resident,
    required this.onEdit,
    required this.onRestore,
    required this.onDelete,
  });

  static const _ink = Color(0xFF22262D);
  static const _muted = Color(0xFF667085);
  static const _green = Color(0xFF0BBF74);
  static const _coral = Color(0xFFF27470);

  @override
  Widget build(BuildContext context) {
    final isActive = resident.isActive;
    final subduedInk = isActive ? _ink : const Color(0xFF5E6765);

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 12, 12),
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
                  style: TextStyle(
                    color: subduedInk,
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
                      style: TextStyle(
                        color: subduedInk,
                        fontSize: 18,
                        height: 1.2,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${resident.householdRole} · ${NumberFormat.decimalPattern('id_ID').format(resident.points)} pts',
                      style: TextStyle(
                        color: isActive ? _muted : const Color(0xFF7A8381),
                        fontSize: 13,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              const Text(
                'Alamat:',
                style: TextStyle(
                  color: _muted,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  resident.address,
                  style: TextStyle(
                    color: subduedInk,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _StatusChip(isActive: isActive),
              const Spacer(),
              if (isActive)
                IconButton(
                  tooltip: 'Edit ${resident.name}',
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined),
                  color: const Color(0xFF34443F),
                )
              else ...[
                IconButton(
                  tooltip: 'Aktifkan kembali ${resident.name}',
                  onPressed: onRestore,
                  icon: const Icon(Icons.history_rounded),
                  color: const Color(0xFF66716E),
                ),
                IconButton(
                  tooltip: 'Hapus ${resident.name}',
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline_rounded),
                  color: const Color(0xFF66716E),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Color _avatarColor(ResidentAvatarTone tone) {
    return switch (tone) {
      ResidentAvatarTone.mint => const Color(0xFF83F0C3),
      ResidentAvatarTone.lavender => const Color(0xFFDCE2FF),
      ResidentAvatarTone.sky => const Color(0xFFDCEAFB),
      ResidentAvatarTone.peach => const Color(0xFFFFD7AD),
    };
  }
}

class _StatusChip extends StatelessWidget {
  final bool isActive;

  const _StatusChip({required this.isActive});

  @override
  Widget build(BuildContext context) {
    final color = isActive ? ResidentCard._green : ResidentCard._coral;
    final label = isActive ? 'Aktif' : 'Tidak Aktif';

    return Semantics(
      label: 'Status $label',
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.circle, size: 8, color: Colors.white),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
