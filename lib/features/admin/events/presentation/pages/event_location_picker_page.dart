import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../../../core/config/app_config.dart';
import '../../data/services/event_location_service.dart';
import '../../domain/entities/event_location_selection.dart';
import '../widgets/event_form_widgets.dart';

@RoutePage()
class EventLocationPickerPage extends StatefulWidget {
  const EventLocationPickerPage({
    super.key,
    this.initialLatitude,
    this.initialLongitude,
    this.initialRadiusMeters = EventLocationSelection.defaultRadiusMeters,
    this.title = 'Pilih Lokasi',
    this.showRadiusControl = true,
    this.locationService = const GeolocatorEventLocationService(),
  });

  final double? initialLatitude;
  final double? initialLongitude;
  final int initialRadiusMeters;
  final String title;
  final bool showRadiusControl;
  final EventLocationService locationService;

  @override
  State<EventLocationPickerPage> createState() =>
      _EventLocationPickerPageState();
}

class _EventLocationPickerPageState extends State<EventLocationPickerPage> {
  final _mapController = MapController();

  late EventLocationSelection _selection;
  bool _isLocating = false;

  @override
  void initState() {
    super.initState();
    _selection = switch ((widget.initialLatitude, widget.initialLongitude)) {
      (final double latitude, final double longitude) => EventLocationSelection(
        latitude: latitude,
        longitude: longitude,
        radiusMeters: widget.initialRadiusMeters
            .clamp(
              EventLocationSelection.minimumRadiusMeters,
              EventLocationSelection.maximumRadiusMeters,
            )
            .toInt(),
      ),
      _ => EventLocationSelection.jakarta.copyWith(
        radiusMeters: widget.initialRadiusMeters
            .clamp(
              EventLocationSelection.minimumRadiusMeters,
              EventLocationSelection.maximumRadiusMeters,
            )
            .toInt(),
      ),
    };
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final center = LatLng(_selection.latitude, _selection.longitude);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _LocationPickerHeader(
              title: widget.title,
              onBack: () => Navigator.of(context).maybePop(),
            ),
            Expanded(
              child: Stack(
                children: [
                  FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: center,
                      initialZoom: 16,
                      minZoom: 4,
                      maxZoom: 19,
                      onTap: (_, point) => _moveTo(point),
                      onPositionChanged: (camera, _) {
                        final next = _selection.copyWith(
                          latitude: camera.center.latitude,
                          longitude: camera.center.longitude,
                        );
                        if (next != _selection) {
                          setState(() => _selection = next);
                        }
                      },
                    ),
                    children: [
                      TileLayer(
                        urlTemplate: AppConfig.mapTileUrl,
                        userAgentPackageName: AppConfig.mapUserAgentPackageName,
                      ),
                      CircleLayer(
                        key: const ValueKey('event-radius-circle'),
                        circles: [
                          CircleMarker(
                            point: center,
                            radius: _selection.radiusMeters.toDouble(),
                            useRadiusInMeter: true,
                            color: eventFormBlue.withValues(alpha: 0.16),
                            borderColor: eventFormBlue.withValues(alpha: 0.82),
                            borderStrokeWidth: 2,
                          ),
                        ],
                      ),
                    ],
                  ),
                  const IgnorePointer(child: Center(child: _CenterMapPin())),
                  Positioned(
                    top: 16,
                    left: 24,
                    right: 24,
                    child: _CoordinatePill(selection: _selection),
                  ),
                  Positioned(
                    right: 20,
                    bottom: 52,
                    child: _CurrentLocationButton(
                      isLoading: _isLocating,
                      onPressed: _isLocating ? null : _useCurrentLocation,
                    ),
                  ),
                  Positioned(
                    right: 8,
                    bottom: 4,
                    child: _MapAttribution(
                      attribution: AppConfig.mapAttribution,
                    ),
                  ),
                ],
              ),
            ),
            if (widget.showRadiusControl)
              _RadiusControlPanel(
                radiusMeters: _selection.radiusMeters,
                onChanged: _changeRadius,
              ),
            _ConfirmationBar(onConfirm: _confirmSelection),
          ],
        ),
      ),
    );
  }

  void _moveTo(LatLng point) {
    _mapController.move(point, _mapController.camera.zoom);
  }

  Future<void> _useCurrentLocation() async {
    setState(() => _isLocating = true);
    try {
      final location = await widget.locationService.getCurrentLocation();
      if (!mounted) return;
      _mapController.move(LatLng(location.latitude, location.longitude), 17);
      setState(
        () => _selection = location.copyWith(
          radiusMeters: _selection.radiusMeters,
        ),
      );
    } on EventLocationException catch (error) {
      if (!mounted) return;
      _showLocationError(error.failure);
    } finally {
      if (mounted) setState(() => _isLocating = false);
    }
  }

  void _showLocationError(EventLocationFailure failure) {
    final message = switch (failure) {
      EventLocationFailure.serviceDisabled =>
        'Aktifkan layanan lokasi untuk menggunakan posisi Anda.',
      EventLocationFailure.permissionDenied =>
        'Izin lokasi diperlukan untuk menggunakan posisi Anda.',
      EventLocationFailure.permissionDeniedForever =>
        'Izinkan akses lokasi melalui pengaturan aplikasi.',
      EventLocationFailure.unavailable =>
        'Lokasi saat ini belum dapat ditemukan. Coba lagi.',
    };
    final canOpenSettings =
        failure == EventLocationFailure.serviceDisabled ||
        failure == EventLocationFailure.permissionDeniedForever;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          action: canOpenSettings
              ? SnackBarAction(
                  label: 'Pengaturan',
                  onPressed: () => widget.locationService.openSettings(failure),
                )
              : null,
        ),
      );
  }

  void _confirmSelection() {
    Navigator.of(context).maybePop(_selection);
  }

  void _changeRadius(int radiusMeters) {
    setState(
      () => _selection = _selection.copyWith(radiusMeters: radiusMeters),
    );
  }
}

class _LocationPickerHeader extends StatelessWidget {
  const _LocationPickerHeader({required this.title, required this.onBack});

  final String title;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 64,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: 8),
              child: IconButton(
                tooltip: 'Kembali',
                onPressed: onBack,
                iconSize: 28,
                color: eventFormInk,
                icon: const Icon(Icons.chevron_left_rounded),
              ),
            ),
          ),
          Text(
            title,
            style: const TextStyle(
              color: eventFormInk,
              fontSize: 20,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _CenterMapPin extends StatelessWidget {
  const _CenterMapPin();

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: const Offset(0, -24),
      child: const Icon(
        Icons.location_pin,
        color: eventFormBlue,
        size: 52,
        shadows: [
          Shadow(color: Color(0x33000000), blurRadius: 8, offset: Offset(0, 3)),
        ],
      ),
    );
  }
}

class _CoordinatePill extends StatelessWidget {
  const _CoordinatePill({required this.selection});

  final EventLocationSelection selection;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1F000000),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.location_on_rounded,
              size: 18,
              color: eventFormBlue,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '${selection.latitude.toStringAsFixed(6)}, '
                '${selection.longitude.toStringAsFixed(6)}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: eventFormInk,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CurrentLocationButton extends StatelessWidget {
  const _CurrentLocationButton({
    required this.isLoading,
    required this.onPressed,
  });

  final bool isLoading;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 3,
      shadowColor: const Color(0x33000000),
      borderRadius: BorderRadius.circular(12),
      child: IconButton(
        key: const ValueKey('event-current-location-button'),
        tooltip: 'Gunakan lokasi saya',
        onPressed: onPressed,
        color: eventFormBlue,
        icon: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2.5),
              )
            : const Icon(Icons.my_location_rounded),
      ),
    );
  }
}

class _MapAttribution extends StatelessWidget {
  const _MapAttribution({required this.attribution});

  final String attribution;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: Text(
          attribution,
          style: const TextStyle(color: eventFormInk, fontSize: 9),
        ),
      ),
    );
  }
}

class _RadiusControlPanel extends StatelessWidget {
  const _RadiusControlPanel({
    required this.radiusMeters,
    required this.onChanged,
  });

  static const _presets = [25, 50, 100, 200];

  final int radiusMeters;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: eventFormOutline)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 14, 24, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Radius Presensi',
                        style: TextStyle(
                          color: eventFormInk,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Warga harus berada di dalam area biru.',
                        style: TextStyle(color: eventFormMuted, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: eventFormBlue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    child: Text(
                      '$radiusMeters m',
                      key: const ValueKey('event-radius-value'),
                      style: const TextStyle(
                        color: eventFormBlue,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: eventFormBlue,
                inactiveTrackColor: eventFormBlue.withValues(alpha: 0.16),
                thumbColor: eventFormBlue,
                overlayColor: eventFormBlue.withValues(alpha: 0.12),
                trackHeight: 3,
              ),
              child: Slider(
                key: const ValueKey('event-radius-slider'),
                value: radiusMeters.toDouble(),
                min: EventLocationSelection.minimumRadiusMeters.toDouble(),
                max: EventLocationSelection.maximumRadiusMeters.toDouble(),
                divisions:
                    EventLocationSelection.maximumRadiusMeters -
                    EventLocationSelection.minimumRadiusMeters,
                label: '$radiusMeters meter',
                onChanged: (value) => onChanged(value.round()),
              ),
            ),
            Row(
              children: [
                for (final preset in _presets) ...[
                  if (preset != _presets.first) const SizedBox(width: 8),
                  Expanded(
                    child: _RadiusPresetButton(
                      radiusMeters: preset,
                      selected: radiusMeters == preset,
                      onPressed: () => onChanged(preset),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RadiusPresetButton extends StatelessWidget {
  const _RadiusPresetButton({
    required this.radiusMeters,
    required this.selected,
    required this.onPressed,
  });

  final int radiusMeters;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 34,
      child: OutlinedButton(
        key: ValueKey('event-radius-preset-$radiusMeters'),
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.zero,
          foregroundColor: selected ? Colors.white : eventFormBlue,
          backgroundColor: selected ? eventFormBlue : Colors.white,
          side: BorderSide(color: selected ? eventFormBlue : eventFormOutline),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text(
          '$radiusMeters m',
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

class _ConfirmationBar extends StatelessWidget {
  const _ConfirmationBar({required this.onConfirm});

  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: eventFormOutline)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
        child: SizedBox(
          width: double.infinity,
          height: 48,
          child: FilledButton(
            key: const ValueKey('confirm-event-location'),
            onPressed: onConfirm,
            style: FilledButton.styleFrom(
              backgroundColor: eventFormBlue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Gunakan Lokasi Ini',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
            ),
          ),
        ),
      ),
    );
  }
}
