import 'package:flutter/material.dart';

import '../../domain/entities/admin_event.dart';
import 'event_form_widgets.dart';

enum EventSuccessAction { viewList, createAnother }

class EventSuccessDialog extends StatelessWidget {
  const EventSuccessDialog({required this.status, super.key});

  final AdminEventRecordStatus status;

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
                  'Kegiatan Berhasil Dibuat!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: eventFormBlue,
                    fontSize: 24,
                    height: 1.2,
                    letterSpacing: -0.3,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  status == AdminEventRecordStatus.published
                      ? 'Kegiatan Anda telah dipublikasikan dan dapat dilihat oleh warga.'
                      : 'Kegiatan Anda telah disimpan sebagai draft dan belum terlihat oleh warga.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF626262),
                    fontSize: 16,
                    height: 1.4,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton(
                    onPressed: () =>
                        Navigator.of(context).pop(EventSuccessAction.viewList),
                    style: FilledButton.styleFrom(
                      backgroundColor: eventFormBlue,
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
                    onPressed: () => Navigator.of(
                      context,
                    ).pop(EventSuccessAction.createAnother),
                    style: TextButton.styleFrom(
                      foregroundColor: eventFormBlue,
                      backgroundColor: const Color(0xFFE8EEFC),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'Buat Lagi',
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
          color: Color(0xFF0BBF74),
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Container(
          width: 44,
          height: 44,
          decoration: const BoxDecoration(
            color: Color(0xFFE9F9F1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.check_rounded,
            color: Color(0xFF0AAE69),
            size: 32,
            weight: 800,
          ),
        ),
      ),
    );
  }
}
