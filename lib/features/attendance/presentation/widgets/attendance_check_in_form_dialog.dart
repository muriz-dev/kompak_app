import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/theme/app_theme.dart';

class AttendanceCheckInFormData {
  const AttendanceCheckInFormData({
    this.activityPhotoPath,
    this.activityDescription = '',
  });

  final String? activityPhotoPath;
  final String activityDescription;
}

Future<AttendanceCheckInFormData?> showAttendanceCheckInFormDialog(
  BuildContext context,
) {
  return showDialog<AttendanceCheckInFormData>(
    context: context,
    barrierDismissible: false,
    barrierColor: const Color(0xE62F3236),
    builder: (_) => const _AttendanceCheckInFormDialog(),
  );
}

class _AttendanceCheckInFormDialog extends StatefulWidget {
  const _AttendanceCheckInFormDialog();

  @override
  State<_AttendanceCheckInFormDialog> createState() =>
      _AttendanceCheckInFormDialogState();
}

class _AttendanceCheckInFormDialogState
    extends State<_AttendanceCheckInFormDialog> {
  final _descriptionController = TextEditingController();
  final _imagePicker = ImagePicker();
  String? _photoPath;
  bool _pickingPhoto = false;

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    setState(() => _pickingPhoto = true);
    try {
      final photo = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1800,
      );
      if (mounted && photo != null) setState(() => _photoPath = photo.path);
    } finally {
      if (mounted) setState(() => _pickingPhoto = false);
    }
  }

  void _continue() {
    Navigator.of(context).pop(
      AttendanceCheckInFormData(
        activityPhotoPath: _photoPath,
        activityDescription: _descriptionController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Lengkapi Absensi',
                style: TextStyle(
                  color: KompakColors.ink,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Tambahkan dokumentasi kegiatan jika diperlukan.',
                style: TextStyle(color: KompakColors.mutedInk, height: 1.35),
              ),
              const SizedBox(height: 18),
              _PhotoPicker(
                path: _photoPath,
                picking: _pickingPhoto,
                onTap: _pickPhoto,
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _descriptionController,
                minLines: 3,
                maxLines: 5,
                maxLength: 500,
                textInputAction: TextInputAction.newline,
                decoration: InputDecoration(
                  hintText:
                      'Tambahkan catatan atau kesan\nkegiatan... (Opsional)',
                  hintStyle: const TextStyle(color: KompakColors.mutedInk),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: KompakColors.outline),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: KompakColors.outline),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: KompakColors.primary,
                      width: 1.5,
                    ),
                  ),
                  contentPadding: const EdgeInsets.all(14),
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  key: const ValueKey('attendance-scan-now-button'),
                  onPressed: _continue,
                  icon: const Icon(Icons.face_retouching_natural),
                  label: const Text('Scan Wajah Sekarang'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Center(
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Nanti saja'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PhotoPicker extends StatelessWidget {
  const _PhotoPicker({
    required this.path,
    required this.picking,
    required this.onTap,
  });

  final String? path;
  final bool picking;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final hasPhoto = path != null;
    return GestureDetector(
      onTap: picking ? null : onTap,
      child: CustomPaint(
        painter: _DashedBorderPainter(color: KompakColors.outline, radius: 12),
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: 112),
          padding: const EdgeInsets.all(12),
          child: hasPhoto
              ? Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        File(path!),
                        width: 76,
                        height: 76,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Foto kegiatan dipilih',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                    const Icon(
                      Icons.edit_outlined,
                      color: KompakColors.primary,
                    ),
                  ],
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (picking)
                      const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    else
                      const Icon(
                        Icons.attach_file_rounded,
                        color: KompakColors.primary,
                        size: 28,
                      ),
                    const SizedBox(height: 8),
                    const Text(
                      'Lampirkan Foto Kegiatan (Opsional)',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: KompakColors.mutedInk),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  const _DashedBorderPainter({required this.color, required this.radius});

  final Color color;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(radius)),
      );
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final end = (distance + 6).clamp(0, metric.length).toDouble();
        canvas.drawPath(metric.extractPath(distance, end), paint);
        distance += 10;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.radius != radius;
}
