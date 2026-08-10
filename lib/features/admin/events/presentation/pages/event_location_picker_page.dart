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
    this.locationService = const GeolocatorEventLocationService(),
  });

  final double? initialLatitude;
  final double? initialLongitude;
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
      ),
      _ => EventLocationSelection.jakarta,
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
                        final next = EventLocationSelection(
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
      setState(() => _selection = location);
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
}

class _LocationPickerHeader extends StatelessWidget {
  const _LocationPickerHeader({required this.onBack});

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
          const Text(
            'Pilih Lokasi',
            style: TextStyle(
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
