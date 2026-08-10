import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' show LatLng;

import '../../../../../core/config/app_config.dart';

const eventFormInk = Color(0xFF2F3236);
const eventFormMuted = Color(0xFF7A7C80);
const eventFormBlue = Color(0xFF2563EB);
const eventFormFill = Color(0xFFF1F1F2);
const eventFormOutline = Color(0xFFE2E4E5);

class EventFormSection extends StatelessWidget {
  final Widget child;

  const EventFormSection({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF1F1F2)),
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
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
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
  const borderRadius = BorderRadius.all(Radius.circular(8));
  return InputDecoration(
    hintText: hintText,
    hintStyle: const TextStyle(
      color: Color(0xFFB0B2B3),
      fontSize: 14,
      fontWeight: FontWeight.w400,
    ),
    prefixIcon: prefixIcon,
    suffixIcon: suffixIcon,
    prefixText: prefixText,
    prefixStyle: const TextStyle(
      color: eventFormInk,
      fontSize: 14,
      fontWeight: FontWeight.w500,
    ),
    isDense: true,
    filled: true,
    fillColor: eventFormFill,
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
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
  final String? existingImageUrl;
  final String? fileName;
  final String? errorText;
  final VoidCallback onPick;
  final VoidCallback onRemove;

  const EventPosterPicker({
    super.key,
    required this.imageBytes,
    this.existingImageUrl,
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
          label: imageBytes == null && existingImageUrl == null
              ? 'Pilih poster kegiatan dari galeri'
              : 'Ganti poster kegiatan${fileName == null ? '' : ', file $fileName'}',
          child: CustomPaint(
            painter: _DashedBorderPainter(
              color: errorText == null
                  ? eventFormOutline
                  : const Color(0xFFD92D20),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onPick,
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: double.infinity,
                  height: 145,
                  child: imageBytes == null && existingImageUrl == null
                      ? const _EmptyPosterPicker()
                      : _PosterPreview(
                          imageBytes: imageBytes,
                          imageUrl: existingImageUrl,
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
        Icon(Icons.file_upload_outlined, size: 28, color: Color(0xFF7A7C80)),
        SizedBox(height: 8),
        Text(
          'Klik untuk unggah poster',
          style: TextStyle(
            color: eventFormInk,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 2),
        Text(
          'Format JPG/PNG, Max 5MB',
          style: TextStyle(
            color: Color(0xFFB0B2B3),
            fontSize: 10,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}

class _PosterPreview extends StatelessWidget {
  final Uint8List? imageBytes;
  final String? imageUrl;
  final String fileName;
  final VoidCallback onRemove;

  const _PosterPreview({
    required this.imageBytes,
    required this.imageUrl,
    required this.fileName,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: imageBytes != null
              ? Image.memory(
                  imageBytes!,
                  fit: BoxFit.cover,
                  excludeFromSemantics: true,
                )
              : Image.network(
                  imageUrl!,
                  fit: BoxFit.cover,
                  excludeFromSemantics: true,
                  errorBuilder: (_, _, _) => const ColoredBox(
                    color: eventFormFill,
                    child: Center(
                      child: Icon(
                        Icons.broken_image_outlined,
                        color: eventFormMuted,
                      ),
                    ),
                  ),
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

class EventLocationMapPreview extends StatelessWidget {
  const EventLocationMapPreview({
    super.key,
    required this.onTap,
    this.latitude,
    this.longitude,
  });

  final VoidCallback onTap;
  final double? latitude;
  final double? longitude;

  @override
  Widget build(BuildContext context) {
    final hasSelection = latitude != null && longitude != null;

    return Semantics(
      key: const ValueKey('event-location-map'),
      button: true,
      label: hasSelection
          ? 'Ubah titik lokasi kegiatan'
          : 'Pilih titik lokasi kegiatan',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SizedBox(
              width: double.infinity,
              height: 160,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (hasSelection)
                    IgnorePointer(
                      child: FlutterMap(
                        key: ValueKey('event-map-$latitude-$longitude'),
                        options: MapOptions(
                          initialCenter: LatLng(latitude!, longitude!),
                          initialZoom: 16,
                        ),
                        children: [
                          TileLayer(
                            urlTemplate: AppConfig.mapTileUrl,
                            userAgentPackageName:
                                AppConfig.mapUserAgentPackageName,
                          ),
                        ],
                      ),
                    )
                  else
                    Image.asset(
                      'assets/images/event_location_map.png',
                      fit: BoxFit.cover,
                      excludeFromSemantics: true,
                    ),
                  if (hasSelection)
                    IgnorePointer(
                      child: Center(
                        child: Transform.translate(
                          offset: const Offset(0, -14),
                          child: const Icon(
                            Icons.location_pin,
                            color: eventFormBlue,
                            size: 38,
                            shadows: [
                              Shadow(
                                color: Color(0x33000000),
                                blurRadius: 6,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  Positioned(
                    left: 12,
                    bottom: 12,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: const Color(0xFF12B76A),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x26000000),
                            blurRadius: 6,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const SizedBox(
                        width: 36,
                        height: 36,
                        child: Icon(
                          Icons.my_location_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                  if (hasSelection)
                    Positioned(
                      right: 6,
                      bottom: 4,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.88),
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 2,
                          ),
                          child: Text(
                            AppConfig.mapAttribution,
                            style: TextStyle(color: eventFormInk, fontSize: 8),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
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
        RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(12)),
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
