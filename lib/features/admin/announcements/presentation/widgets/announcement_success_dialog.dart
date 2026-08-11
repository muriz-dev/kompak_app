import 'package:flutter/material.dart';

import '../../../../../core/theme/app_theme.dart';

enum AnnouncementSuccessAction { viewList, createAnother }

class AnnouncementSuccessDialog extends StatelessWidget {
  const AnnouncementSuccessDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Dialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 8,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(28, 32, 28, 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const _SuccessMark(),
                const SizedBox(height: 28),
                const Text(
                  'Pengumuman Berhasil Dipublikasikan!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: KompakColors.primary,
                    fontSize: 24,
                    height: 1.2,
                    letterSpacing: -0.3,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Pengumuman Anda sudah dipublikasikan dan dapat dilihat oleh warga.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: KompakColors.mutedInk,
                    fontSize: 16,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton(
                    key: const ValueKey('announcement-success-view-list'),
                    onPressed: () => Navigator.of(
                      context,
                    ).pop(AnnouncementSuccessAction.viewList),
                    style: FilledButton.styleFrom(
                      backgroundColor: KompakColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'Lihat Daftar',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: TextButton(
                    key: const ValueKey('announcement-success-create-another'),
                    onPressed: () => Navigator.of(
                      context,
                    ).pop(AnnouncementSuccessAction.createAnother),
                    style: TextButton.styleFrom(
                      foregroundColor: KompakColors.primary,
                      backgroundColor: const Color(0xFFE8EEFC),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'Buat Pengumuman Lagi',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SuccessMark extends StatelessWidget {
  const _SuccessMark();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Berhasil',
      image: true,
      child: Container(
        width: 88,
        height: 88,
        decoration: const BoxDecoration(
          color: KompakColors.success,
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Container(
          width: 44,
          height: 44,
          decoration: const BoxDecoration(
            color: KompakColors.successSurface,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.check_rounded,
            color: KompakColors.success,
            size: 32,
            weight: 800,
          ),
        ),
      ),
    );
  }
}
