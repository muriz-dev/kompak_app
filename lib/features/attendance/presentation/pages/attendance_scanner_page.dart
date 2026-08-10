import 'package:auto_route/auto_route.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/routes/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/widgets/face_scanner_overlay.dart';
import '../../data/services/attendance_location_service.dart';
import '../bloc/attendance_check_in_cubit.dart';

@RoutePage()
class AttendanceScannerPage extends StatefulWidget {
  const AttendanceScannerPage({
    @PathParam('eventId') required this.eventId,
    this.activityPhotoPath,
    this.activityDescription = '',
    this.locationService = const GeolocatorAttendanceLocationService(),
    super.key,
  });

  final String eventId;
  final String? activityPhotoPath;
  final String activityDescription;
  final AttendanceLocationService locationService;

  @override
  State<AttendanceScannerPage> createState() => _AttendanceScannerPageState();
}

class _AttendanceScannerPageState extends State<AttendanceScannerPage> {
  CameraController? _cameraController;
  bool _initializingCamera = true;
  String? _cameraError;
  AttendanceLocationFailure? _locationFailure;
  String? _localError;
  bool _successDialogVisible = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  Future<void> _initializeCamera() async {
    if (mounted) {
      setState(() {
        _initializingCamera = true;
        _cameraError = null;
      });
    }
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        throw CameraException('cameraUnavailable', 'No camera available');
      }
      final frontCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );
      final controller = CameraController(
        frontCamera,
        ResolutionPreset.medium,
        enableAudio: false,
      );
      await controller.initialize();
      if (!mounted) {
        await controller.dispose();
        return;
      }
      await _cameraController?.dispose();
      setState(() {
        _cameraController = controller;
        _initializingCamera = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _initializingCamera = false;
        _cameraError =
            'Kamera tidak dapat dibuka. Periksa izin kamera lalu coba lagi.';
      });
    }
  }

  Future<void> _submit(AttendanceCheckInCubit cubit) async {
    final controller = _cameraController;
    if (controller == null || !controller.value.isInitialized) return;

    setState(() {
      _localError = null;
      _locationFailure = null;
    });

    try {
      final coordinates = await widget.locationService.getCurrentLocation();
      final image = await controller.takePicture();
      if (!mounted) return;
      await cubit.submit(
        eventId: widget.eventId,
        faceImagePath: image.path,
        latitude: coordinates.latitude,
        longitude: coordinates.longitude,
        activityPhotoPath: widget.activityPhotoPath,
        activityDescription: widget.activityDescription,
      );
    } on AttendanceLocationException catch (error) {
      if (!mounted) return;
      setState(() {
        _locationFailure = error.failure;
        _localError = _locationMessage(error.failure);
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _localError = 'Foto wajah gagal diambil. Silakan coba lagi.';
      });
    }
  }

  String _locationMessage(AttendanceLocationFailure failure) =>
      switch (failure) {
        AttendanceLocationFailure.serviceDisabled =>
          'Aktifkan layanan lokasi untuk melakukan absensi.',
        AttendanceLocationFailure.permissionDenied =>
          'Izin lokasi diperlukan untuk memvalidasi kehadiran Anda.',
        AttendanceLocationFailure.permissionDeniedForever =>
          'Izinkan akses lokasi melalui pengaturan aplikasi.',
        AttendanceLocationFailure.unavailable =>
          'Lokasi Anda belum dapat ditemukan. Silakan coba lagi.',
      };

  Future<void> _showSuccess(
    BuildContext context,
    AttendanceCheckInSuccess state,
  ) async {
    if (_successDialogVisible) return;
    _successDialogVisible = true;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 342),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: const BoxDecoration(
                    color: KompakColors.success,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 22),
                const Text(
                  'Scan Wajah Berhasil!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: KompakColors.primary,
                    fontSize: 23,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Identitas Anda sudah terkonfirmasi.\nAnda mendapatkan:',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: KompakColors.mutedInk,
                    fontSize: 15,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF79009),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.stars_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '+${state.result.pointsEarned} Point',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    key: const ValueKey('attendance-success-home-button'),
                    onPressed: () {
                      Navigator.of(dialogContext).pop();
                      context.router.root.navigate(
                        const MainRoute(children: [HomeRoute()]),
                      );
                    },
                    child: const Text('Kembali ke Beranda'),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    key: const ValueKey('attendance-success-history-button'),
                    onPressed: () {
                      Navigator.of(dialogContext).pop();
                      context.router.root.push(const PointHistoryRoute());
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFFE9EFFD),
                      foregroundColor: KompakColors.primary,
                    ),
                    child: const Text('Lihat Riwayat Poin'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    _successDialogVisible = false;
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<AttendanceCheckInCubit>(),
      child: BlocConsumer<AttendanceCheckInCubit, AttendanceCheckInState>(
        listener: (context, state) {
          if (state is AttendanceCheckInSuccess) {
            _showSuccess(context, state);
          }
        },
        builder: (context, state) {
          final submitting = state is AttendanceCheckInSubmitting;
          final apiError = state is AttendanceCheckInFailure
              ? state.message
              : null;
          return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.transparent,
              title: const Text(
                'Absensi Kegiatan',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
            body: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 18, 24, 20),
                child: Column(
                  children: [
                    const Text(
                      'Verifikasi Wajah',
                      style: TextStyle(
                        color: KompakColors.primary,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Pastikan wajah Anda berada di dalam area frame dan pencahayaan cukup.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: KompakColors.mutedInk,
                        fontSize: 15,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: KompakColors.primarySurface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: KompakColors.scannerBorder,
                            width: 4,
                          ),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: _cameraContent(submitting),
                      ),
                    ),
                    if (_localError != null || apiError != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        _localError ?? apiError!,
                        key: const ValueKey('attendance-check-in-error'),
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Color(0xFFDC2626)),
                      ),
                      if (_locationFailure ==
                              AttendanceLocationFailure.serviceDisabled ||
                          _locationFailure ==
                              AttendanceLocationFailure.permissionDeniedForever)
                        TextButton(
                          onPressed: () => widget.locationService.openSettings(
                            _locationFailure!,
                          ),
                          child: const Text('Buka Pengaturan'),
                        ),
                    ],
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        key: const ValueKey('submit-attendance-button'),
                        onPressed:
                            _cameraController?.value.isInitialized == true &&
                                !submitting
                            ? () => _submit(
                                context.read<AttendanceCheckInCubit>(),
                              )
                            : null,
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                        ),
                        child: submitting
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('Verifikasi Kehadiran'),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Foto hanya digunakan untuk verifikasi identitas dan tidak disimpan.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: KompakColors.mutedInk,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _cameraContent(bool submitting) {
    if (_cameraController?.value.isInitialized == true) {
      return FaceScannerOverlay(
        active: !submitting,
        child: SizedBox.expand(child: CameraPreview(_cameraController!)),
      );
    }
    if (_cameraError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.no_photography_outlined, size: 48),
              const SizedBox(height: 12),
              Text(_cameraError!, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              TextButton(
                onPressed: _initializeCamera,
                child: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      );
    }
    return Center(
      child: CircularProgressIndicator(
        color: KompakColors.primary,
        semanticsLabel: _initializingCamera ? 'Membuka kamera' : null,
      ),
    );
  }
}
