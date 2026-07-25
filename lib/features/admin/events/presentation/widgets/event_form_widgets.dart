import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/material.dart';

const eventFormInk = Color(0xFF262A31);
const eventFormMuted = Color(0xFF667085);
const eventFormBlue = Color(0xFF2F67E8);
const eventFormFill = Color(0xFFF0F1F3);

class EventFormSection extends StatelessWidget {
  final Widget child;

  const EventFormSection({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE6E8EB)),
      ),
      child: child,
    );
  }
}

class EventFieldLabel extends StatelessWidget {
  final String label;
  final Widget child;

  const EventFieldLabel({super.key, required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: eventFormInk,
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}

InputDecoration eventInputDecoration({
  required String hintText,
  Widget? prefixIcon,
  Widget? suffixIcon,
  String? prefixText,
}) {
  const borderRadius = BorderRadius.all(Radius.circular(12));
  return InputDecoration(
    hintText: hintText,
    hintStyle: const TextStyle(
      color: Color(0xFF7B828B),
      fontSize: 15,
      fontWeight: FontWeight.w400,
    ),
    prefixIcon: prefixIcon,
    suffixIcon: suffixIcon,
    prefixText: prefixText,
    prefixStyle: const TextStyle(
      color: eventFormInk,
      fontSize: 16,
      fontWeight: FontWeight.w600,
    ),
    filled: true,
    fillColor: eventFormFill,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 17),
    border: const OutlineInputBorder(
      borderRadius: borderRadius,
      borderSide: BorderSide.none,
    ),
    enabledBorder: const OutlineInputBorder(
      borderRadius: borderRadius,
      borderSide: BorderSide.none,
    ),
    focusedBorder: const OutlineInputBorder(
      borderRadius: borderRadius,
      borderSide: BorderSide(color: eventFormBlue, width: 1.5),
    ),
    errorBorder: const OutlineInputBorder(
      borderRadius: borderRadius,
      borderSide: BorderSide(color: Color(0xFFD92D20)),
    ),
    focusedErrorBorder: const OutlineInputBorder(
      borderRadius: borderRadius,
      borderSide: BorderSide(color: Color(0xFFD92D20), width: 1.5),
    ),
  );
}

class EventPosterPicker extends StatelessWidget {
  final Uint8List? imageBytes;
  final String? fileName;
  final String? errorText;
  final VoidCallback onPick;
  final VoidCallback onRemove;

  const EventPosterPicker({
    super.key,
    required this.imageBytes,
    required this.fileName,
    required this.errorText,
    required this.onPick,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          button: true,
          label: imageBytes == null
              ? 'Pilih poster kegiatan dari galeri'
              : 'Ganti poster kegiatan, file $fileName',
          child: CustomPaint(
            painter: _DashedBorderPainter(
              color: errorText == null
                  ? const Color(0xFFD5D9DE)
                  : const Color(0xFFD92D20),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onPick,
                borderRadius: BorderRadius.circular(14),
                child: SizedBox(
                  width: double.infinity,
                  height: 220,
                  child: imageBytes == null
                      ? const _EmptyPosterPicker()
                      : _PosterPreview(
                          imageBytes: imageBytes!,
                          fileName: fileName ?? 'poster',
                          onRemove: onRemove,
                        ),
                ),
              ),
            ),
          ),
        ),
        if (errorText != null) ...[
          const SizedBox(height: 8),
          Text(
            errorText!,
            style: const TextStyle(color: Color(0xFFD92D20), fontSize: 12),
          ),
        ],
      ],
    );
  }
}

class _EmptyPosterPicker extends StatelessWidget {
  const _EmptyPosterPicker();

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.add_photo_alternate_outlined,
          size: 44,
          color: Color(0xFF9299A1),
        ),
        SizedBox(height: 10),
        Text(
          'Klik untuk unggah poster',
          style: TextStyle(
            color: Color(0xFF364039),
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 4),
        Text(
          'Format JPG/PNG, Maks 5MB',
          style: TextStyle(
            color: Color(0xFF7B828B),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _PosterPreview extends StatelessWidget {
  final Uint8List imageBytes;
  final String fileName;
  final VoidCallback onRemove;

  const _PosterPreview({
    required this.imageBytes,
    required this.fileName,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Image.memory(
            imageBytes,
            fit: BoxFit.cover,
            excludeFromSemantics: true,
          ),
        ),
        Positioned(
          left: 12,
          right: 12,
          bottom: 12,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: const Color(0xE622262D),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.only(left: 12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      fileName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Hapus poster',
                    onPressed: onRemove,
                    color: Colors.white,
                    icon: const Icon(Icons.delete_outline_rounded),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class EventToggleRow extends StatelessWidget {
  final String title;
  final String description;
  final bool value;
  final ValueChanged<bool> onChanged;

  const EventToggleRow({
    super.key,
    required this.title,
    required this.description,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: eventFormInk,
                  fontSize: 16,
                  height: 1.2,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: const TextStyle(
                  color: eventFormMuted,
                  fontSize: 13,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        SwitchTheme(
          data: SwitchThemeData(
            thumbColor: const WidgetStatePropertyAll(Colors.white),
            trackColor: WidgetStateProperty.resolveWith(
              (states) => states.contains(WidgetState.selected)
                  ? eventFormBlue
                  : const Color(0xFFBED1C4),
            ),
            trackOutlineColor: WidgetStateProperty.resolveWith(
              (states) => states.contains(WidgetState.selected)
                  ? eventFormBlue
                  : const Color(0xFFA8BCAF),
            ),
          ),
          child: Switch.adaptive(value: value, onChanged: onChanged),
        ),
      ],
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  final Color color;

  const _DashedBorderPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(14)),
      );

    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final end = math.min(distance + 7, metric.length);
        canvas.drawPath(metric.extractPath(distance, end), paint);
        distance = end + 5;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
