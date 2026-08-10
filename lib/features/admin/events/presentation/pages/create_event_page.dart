import 'dart:typed_data';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../../../../core/di/injection.dart';
import '../../../../../core/routes/app_router.dart';
import '../../domain/entities/admin_event.dart';
import '../../domain/entities/create_admin_event_request.dart';
import '../../domain/entities/event_location_selection.dart';
import '../bloc/create_event_cubit.dart';
import '../bloc/create_event_state.dart';
import '../widgets/event_form_widgets.dart';
import '../widgets/event_success_dialog.dart';
import '../widgets/event_time_range_sheet.dart';

@RoutePage()
class CreateEventPage extends StatelessWidget {
  const CreateEventPage({super.key, this.initialLocation});

  final EventLocationSelection? initialLocation;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<CreateEventCubit>(),
      child: CreateEventView(initialLocation: initialLocation),
    );
  }
}

class CreateEventView extends StatefulWidget {
  const CreateEventView({super.key, this.initialLocation});

  final EventLocationSelection? initialLocation;

  @override
  State<CreateEventView> createState() => _CreateEventViewState();
}

class _CreateEventViewState extends State<CreateEventView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _detailController = TextEditingController();
  final _dateController = TextEditingController();
  final _timeController = TextEditingController();
  final _locationController = TextEditingController();
  final _pointsController = TextEditingController(text: '0');
  final _scrollController = ScrollController();
  final _imagePicker = ImagePicker();

  DateTime? _selectedDate;
  EventTimeRange? _selectedTimeRange;
  Uint8List? _posterBytes;
  String? _posterName;
  String? _posterError;
  EventLocationSelection? _selectedLocation;

  @override
  void initState() {
    super.initState();
    _selectedLocation = widget.initialLocation;
    if (_selectedLocation case final location?) {
      _locationController.text = _locationLabel(location);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _detailController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    _locationController.dispose();
    _pointsController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CreateEventCubit, CreateEventState>(
      listener: _onCreateEventState,
      builder: (context, state) {
        final isPublishing = state is CreateEventSubmitting;
        return Scaffold(
          backgroundColor: const Color(0xFFFEFFFF),
          body: SafeArea(
            child: Column(
              children: [
                _buildHeader(context),
                Expanded(
                  child: Form(
                    key: _formKey,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    child: SingleChildScrollView(
                      controller: _scrollController,
                      padding: const EdgeInsets.fromLTRB(24, 4, 24, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'POSTER KEGIATAN',
                            style: TextStyle(
                              color: eventFormInk,
                              fontSize: 13,
                              letterSpacing: 0.2,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 12),
                          EventPosterPicker(
                            imageBytes: _posterBytes,
                            fileName: _posterName,
                            errorText: _posterError,
                            onPick: _pickPoster,
                            onRemove: _removePoster,
                          ),
                          const SizedBox(height: 24),
                          EventFormSection(child: _buildMainFields()),
                          const SizedBox(height: 24),
                          EventFormSection(child: _buildScheduleFields()),
                          const SizedBox(height: 24),
                          EventFormSection(child: _buildRewardFields()),
                        ],
                      ),
                    ),
                  ),
                ),
                _buildPublishBar(isPublishing),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
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
                onPressed: () => context.router.maybePop(),
                iconSize: 28,
                color: eventFormInk,
                icon: const Icon(Icons.chevron_left_rounded),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 64),
            child: Text(
              'Buat Kegiatan Baru',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: eventFormInk,
                fontSize: 20,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainFields() {
    return Column(
      children: [
        EventFieldLabel(
          label: 'Nama Kegiatan',
          child: TextFormField(
            key: const ValueKey('event-name-field'),
            controller: _nameController,
            textCapitalization: TextCapitalization.sentences,
            textInputAction: TextInputAction.next,
            decoration: eventInputDecoration(
              hintText: 'Contoh: Kerja Bakti Minggu',
            ),
            validator: (value) => value == null || value.trim().isEmpty
                ? 'Masukkan nama kegiatan.'
                : null,
          ),
        ),
        const SizedBox(height: 16),
        EventFieldLabel(
          label: 'Detail Kegiatan',
          child: TextFormField(
            key: const ValueKey('event-detail-field'),
            controller: _detailController,
            minLines: 3,
            maxLines: 5,
            textCapitalization: TextCapitalization.sentences,
            decoration: eventInputDecoration(
              hintText:
                  'Jelaskan detail kegiatan, perlengkapan yang dibawa, dll...',
            ),
            validator: (value) => value == null || value.trim().isEmpty
                ? 'Jelaskan detail kegiatan.'
                : null,
          ),
        ),
      ],
    );
  }

  Widget _buildScheduleFields() {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: EventFieldLabel(
                label: 'Tanggal',
                child: TextFormField(
                  key: const ValueKey('event-date-field'),
                  controller: _dateController,
                  readOnly: true,
                  onTap: _selectDate,
                  decoration: eventInputDecoration(hintText: 'mm/dd/yyyy'),
                  validator: (_) =>
                      _selectedDate == null ? 'Pilih tanggal kegiatan.' : null,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: EventFieldLabel(
                label: 'Waktu',
                child: TextFormField(
                  key: const ValueKey('event-time-field'),
                  controller: _timeController,
                  readOnly: true,
                  onTap: _selectTimeRange,
                  decoration: eventInputDecoration(hintText: '--:-- --'),
                  validator: (_) => _selectedTimeRange == null
                      ? 'Pilih waktu kegiatan.'
                      : null,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        EventFieldLabel(
          label: 'Lokasi',
          child: TextFormField(
            key: const ValueKey('event-location-field'),
            controller: _locationController,
            readOnly: true,
            onTap: _selectLocation,
            decoration: eventInputDecoration(
              hintText: 'Pilih lokasi kegiatan',
              prefixIcon: const Icon(
                Icons.location_on_outlined,
                color: eventFormMuted,
              ),
              suffixIcon: const Icon(
                Icons.chevron_right_rounded,
                color: eventFormMuted,
              ),
            ),
            validator: (_) => _selectedLocation == null
                ? 'Pilih titik lokasi kegiatan.'
                : null,
          ),
        ),
        const SizedBox(height: 12),
        EventLocationMapPreview(
          onTap: _selectLocation,
          latitude: _selectedLocation?.latitude,
          longitude: _selectedLocation?.longitude,
        ),
      ],
    );
  }

  Widget _buildRewardFields() {
    return Column(
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Alokasi Poin',
                style: TextStyle(
                  color: eventFormInk,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.auto_awesome, size: 16, color: eventFormBlue),
                SizedBox(width: 4),
                Text(
                  'Reward',
                  style: TextStyle(
                    color: eventFormBlue,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          key: const ValueKey('event-points-field'),
          controller: _pointsController,
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.done,
          decoration: eventInputDecoration(hintText: '0', prefixText: 'Pts  '),
          validator: (value) {
            final points = int.tryParse(value?.trim() ?? '');
            if (points == null || points < 0) {
              return 'Masukkan poin berupa angka 0 atau lebih.';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildPublishBar(bool isPublishing) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFF1F1F2))),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 10, 24, 12),
        child: SizedBox(
          width: double.infinity,
          height: 46,
          child: FilledButton(
            onPressed: isPublishing ? null : _validateForPublish,
            style: FilledButton.styleFrom(
              backgroundColor: eventFormBlue,
              foregroundColor: Colors.white,
              disabledBackgroundColor: const Color(0xFFAFC3F4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: isPublishing
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  )
                : const Text(
                    'Simpan & Publikasi',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                  ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickPoster() async {
    try {
      final image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1800,
        imageQuality: 88,
      );
      if (image == null) return;

      final lowerName = image.name.toLowerCase();
      final isSupported =
          lowerName.endsWith('.jpg') ||
          lowerName.endsWith('.jpeg') ||
          lowerName.endsWith('.png');
      if (!isSupported) {
        setState(() {
          _posterError = 'Gunakan poster berformat JPG atau PNG.';
          _posterBytes = null;
          _posterName = null;
        });
        return;
      }

      final size = await image.length();
      if (size > 5 * 1024 * 1024) {
        setState(() {
          _posterError = 'Ukuran poster maksimal 5MB.';
          _posterBytes = null;
          _posterName = null;
        });
        return;
      }

      final bytes = await image.readAsBytes();
      if (!mounted) return;
      setState(() {
        _posterBytes = bytes;
        _posterName = image.name;
        _posterError = null;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _posterError = 'Poster tidak dapat dibuka. Pilih file lain.';
      });
    }
  }

  void _removePoster() {
    setState(() {
      _posterBytes = null;
      _posterName = null;
      _posterError = null;
    });
  }

  Future<void> _selectDate() async {
    final now = DateTime.now();
    final selected = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: DateTime(now.year + 5),
    );
    if (selected == null) return;

    setState(() {
      _selectedDate = selected;
      _dateController.text = DateFormat('MM/dd/yyyy').format(selected);
    });
  }

  Future<void> _selectTimeRange() async {
    final selected = await showEventTimeRangeSheet(
      context: context,
      initialRange: _selectedTimeRange,
    );
    if (selected == null || !mounted) return;

    setState(() {
      _selectedTimeRange = selected;
      _timeController.text =
          '${selected.start.format(context)}–${selected.end.format(context)}';
    });
  }

  Future<void> _selectLocation() async {
    final selected = await context.router.push<EventLocationSelection>(
      EventLocationPickerRoute(
        initialLatitude: _selectedLocation?.latitude,
        initialLongitude: _selectedLocation?.longitude,
      ),
    );
    if (selected == null || !mounted) return;

    setState(() {
      _selectedLocation = selected;
      _locationController.text = _locationLabel(selected);
    });
  }

  static String _locationLabel(EventLocationSelection location) {
    return '${location.latitude.toStringAsFixed(6)}, '
        '${location.longitude.toStringAsFixed(6)}';
  }

  void _validateForPublish() {
    FocusManager.instance.primaryFocus?.unfocus();
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('Lengkapi data kegiatan yang masih kosong.'),
          ),
        );
      return;
    }

    context.read<CreateEventCubit>().createEvent(_buildRequest());
  }

  CreateAdminEventRequest _buildRequest() {
    final date = _selectedDate!;
    final range = _selectedTimeRange!;
    final location = _selectedLocation!;
    final start = DateTime(
      date.year,
      date.month,
      date.day,
      range.start.hour,
      range.start.minute,
    );
    var end = DateTime(
      date.year,
      date.month,
      date.day,
      range.end.hour,
      range.end.minute,
    );
    if (range.endsNextDay) {
      end = end.add(const Duration(days: 1));
    }

    return CreateAdminEventRequest(
      title: _nameController.text,
      description: _detailController.text,
      eventDate: start,
      attendanceStartTime: start,
      attendanceEndTime: end,
      rewardPoints: int.parse(_pointsController.text.trim()),
      latitude: location.latitude,
      longitude: location.longitude,
      status: AdminEventRecordStatus.published,
      poster: _posterUpload(),
    );
  }

  EventPosterUpload? _posterUpload() {
    final bytes = _posterBytes;
    if (bytes == null) return null;

    final fileName = _posterName?.toLowerCase() ?? '';
    return EventPosterUpload(
      bytes: bytes,
      contentType: fileName.endsWith('.png') ? 'image/png' : 'image/jpeg',
    );
  }

  void _onCreateEventState(BuildContext context, CreateEventState state) {
    switch (state) {
      case CreateEventFailure(:final message):
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(message)));
        break;
      case CreateEventSuccess(:final event):
        _showSuccessDialog(event.status);
        break;
      case CreateEventInitial() || CreateEventSubmitting():
        break;
    }
  }

  Future<void> _showSuccessDialog(AdminEventRecordStatus status) async {
    final action = await showDialog<EventSuccessAction>(
      context: context,
      barrierDismissible: false,
      barrierColor: const Color(0xBF24282E),
      builder: (context) => EventSuccessDialog(status: status),
    );
    if (!mounted) return;

    switch (action) {
      case EventSuccessAction.viewList:
        await Navigator.of(context).maybePop(true);
        break;
      case EventSuccessAction.createAnother:
        _resetForm();
        context.read<CreateEventCubit>().reset();
        break;
      case null:
        break;
    }
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    _nameController.clear();
    _detailController.clear();
    _dateController.clear();
    _timeController.clear();
    _locationController.clear();
    _pointsController.text = '0';
    setState(() {
      _selectedDate = null;
      _selectedTimeRange = null;
      _posterBytes = null;
      _posterName = null;
      _posterError = null;
      _selectedLocation = null;
    });
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
    );
  }
}
