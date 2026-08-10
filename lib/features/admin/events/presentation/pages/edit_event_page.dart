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
import '../../domain/entities/update_admin_event_request.dart';
import '../bloc/edit_event_cubit.dart';
import '../bloc/edit_event_state.dart';
import '../widgets/event_form_widgets.dart';
import '../widgets/event_time_range_sheet.dart';

@RoutePage()
class EditEventPage extends StatelessWidget {
  const EditEventPage({required this.event, super.key});

  final AdminEvent event;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<EditEventCubit>(),
      child: EditEventView(event: event),
    );
  }
}

class EditEventView extends StatefulWidget {
  const EditEventView({required this.event, super.key});

  final AdminEvent event;

  @override
  State<EditEventView> createState() => _EditEventViewState();
}

class _EditEventViewState extends State<EditEventView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _detailController = TextEditingController();
  final _dateController = TextEditingController();
  final _timeController = TextEditingController();
  final _locationController = TextEditingController();
  final _pointsController = TextEditingController();
  final _imagePicker = ImagePicker();

  late DateTime _selectedDate;
  late EventTimeRange _selectedTimeRange;
  late EventLocationSelection _selectedLocation;
  Uint8List? _posterBytes;
  String? _posterName;
  String? _posterError;
  String? _existingBannerUrl;

  @override
  void initState() {
    super.initState();
    final event = widget.event;
    final start = event.attendanceStartTime.toLocal();
    final end = event.attendanceEndTime.toLocal();
    _selectedDate = DateTime(start.year, start.month, start.day);
    _selectedTimeRange = EventTimeRange(
      start: TimeOfDay.fromDateTime(start),
      end: TimeOfDay.fromDateTime(end),
    );
    _selectedLocation = EventLocationSelection(
      latitude: event.latitude,
      longitude: event.longitude,
    );
    _existingBannerUrl = event.bannerUrl;
    _nameController.text = event.title;
    _detailController.text = event.description;
    _dateController.text = DateFormat('MM/dd/yyyy').format(_selectedDate);
    _pointsController.text = event.rewardPoints.toString();
    _locationController.text = _locationLabel(_selectedLocation);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _timeController.text = _timeLabel(_selectedTimeRange);
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _detailController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    _locationController.dispose();
    _pointsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<EditEventCubit, EditEventState>(
      listener: _onStateChanged,
      builder: (context, state) {
        final busy = state is EditEventSubmitting || state is EditEventDeleting;
        return PopScope(
          canPop: !busy,
          child: Scaffold(
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
                              existingImageUrl: _posterBytes == null
                                  ? _existingBannerUrl
                                  : null,
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
                  _buildActionBar(state),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) => SizedBox(
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
              icon: const Icon(Icons.chevron_left_rounded, size: 28),
            ),
          ),
        ),
        const Text(
          'Edit Kegiatan',
          style: TextStyle(
            color: eventFormInk,
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    ),
  );

  Widget _buildMainFields() => Column(
    children: [
      EventFieldLabel(
        label: 'Nama Kegiatan',
        child: TextFormField(
          key: const ValueKey('edit-event-name-field'),
          controller: _nameController,
          textCapitalization: TextCapitalization.sentences,
          decoration: eventInputDecoration(hintText: 'Nama kegiatan'),
          validator: (value) => value == null || value.trim().isEmpty
              ? 'Masukkan nama kegiatan.'
              : null,
        ),
      ),
      const SizedBox(height: 16),
      EventFieldLabel(
        label: 'Detail Kegiatan',
        child: TextFormField(
          key: const ValueKey('edit-event-detail-field'),
          controller: _detailController,
          minLines: 3,
          maxLines: 5,
          textCapitalization: TextCapitalization.sentences,
          decoration: eventInputDecoration(hintText: 'Detail kegiatan'),
          validator: (value) => value == null || value.trim().isEmpty
              ? 'Jelaskan detail kegiatan.'
              : null,
        ),
      ),
    ],
  );

  Widget _buildScheduleFields() => Column(
    children: [
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: EventFieldLabel(
              label: 'Tanggal',
              child: TextFormField(
                key: const ValueKey('edit-event-date-field'),
                controller: _dateController,
                readOnly: true,
                onTap: _selectDate,
                decoration: eventInputDecoration(hintText: 'mm/dd/yyyy'),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: EventFieldLabel(
              label: 'Waktu',
              child: TextFormField(
                key: const ValueKey('edit-event-time-field'),
                controller: _timeController,
                readOnly: true,
                onTap: _selectTimeRange,
                decoration: eventInputDecoration(hintText: '--:--'),
              ),
            ),
          ),
        ],
      ),
      const SizedBox(height: 16),
      EventFieldLabel(
        label: 'Lokasi',
        child: TextFormField(
          key: const ValueKey('edit-event-location-field'),
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
        ),
      ),
      const SizedBox(height: 12),
      EventLocationMapPreview(
        onTap: _selectLocation,
        latitude: _selectedLocation.latitude,
        longitude: _selectedLocation.longitude,
      ),
    ],
  );

  Widget _buildRewardFields() => Column(
    children: [
      const Row(
        children: [
          Expanded(
            child: Text(
              'Alokasi Poin',
              style: TextStyle(
                color: eventFormInk,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
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
      const SizedBox(height: 8),
      TextFormField(
        key: const ValueKey('edit-event-points-field'),
        controller: _pointsController,
        keyboardType: TextInputType.number,
        decoration: eventInputDecoration(hintText: '0', prefixText: 'Pts  '),
        validator: (value) {
          final points = int.tryParse(value?.trim() ?? '');
          return points == null || points < 0
              ? 'Masukkan poin berupa angka 0 atau lebih.'
              : null;
        },
      ),
    ],
  );

  Widget _buildActionBar(EditEventState state) => DecoratedBox(
    decoration: const BoxDecoration(
      color: Colors.white,
      border: Border(top: BorderSide(color: Color(0xFFF1F1F2))),
    ),
    child: Padding(
      padding: const EdgeInsets.fromLTRB(24, 10, 24, 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
            height: 46,
            child: FilledButton(
              key: const ValueKey('save-event-changes-button'),
              onPressed:
                  state is EditEventSubmitting || state is EditEventDeleting
                  ? null
                  : _validateAndSave,
              style: FilledButton.styleFrom(
                backgroundColor: eventFormBlue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: state is EditEventSubmitting
                  ? const SizedBox.square(
                      dimension: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Simpan Perubahan'),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            height: 42,
            child: TextButton.icon(
              key: const ValueKey('delete-event-button'),
              onPressed:
                  state is EditEventSubmitting || state is EditEventDeleting
                  ? null
                  : _confirmDelete,
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFFD92D20),
              ),
              icon: state is EditEventDeleting
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Color(0xFFD92D20),
                      ),
                    )
                  : const Icon(Icons.delete_outline_rounded, size: 18),
              label: const Text('Hapus Kegiatan'),
            ),
          ),
        ],
      ),
    ),
  );

  Future<void> _pickPoster() async {
    try {
      final image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1800,
        imageQuality: 88,
      );
      if (image == null) return;
      final lowerName = image.name.toLowerCase();
      if (!lowerName.endsWith('.jpg') &&
          !lowerName.endsWith('.jpeg') &&
          !lowerName.endsWith('.png')) {
        setState(() => _posterError = 'Gunakan poster berformat JPG atau PNG.');
        return;
      }
      if (await image.length() > 5 * 1024 * 1024) {
        setState(() => _posterError = 'Ukuran poster maksimal 5MB.');
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
      if (mounted) {
        setState(
          () => _posterError = 'Poster tidak dapat dibuka. Pilih file lain.',
        );
      }
    }
  }

  void _removePoster() => setState(() {
    _posterBytes = null;
    _posterName = null;
    _posterError = null;
    _existingBannerUrl = null;
  });

  Future<void> _selectDate() async {
    final now = DateTime.now();
    final first = _selectedDate.isBefore(DateTime(now.year, now.month, now.day))
        ? _selectedDate
        : DateTime(now.year, now.month, now.day);
    final selected = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: first,
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
      _timeController.text = _timeLabel(selected);
    });
  }

  Future<void> _selectLocation() async {
    final selected = await context.router.push<EventLocationSelection>(
      EventLocationPickerRoute(
        initialLatitude: _selectedLocation.latitude,
        initialLongitude: _selectedLocation.longitude,
      ),
    );
    if (selected == null || !mounted) return;
    setState(() {
      _selectedLocation = selected;
      _locationController.text = _locationLabel(selected);
    });
  }

  void _validateAndSave() {
    FocusManager.instance.primaryFocus?.unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lengkapi data kegiatan yang masih kosong.'),
        ),
      );
      return;
    }
    context.read<EditEventCubit>().updateEvent(
      widget.event.id,
      _buildRequest(),
    );
  }

  UpdateAdminEventRequest _buildRequest() {
    final range = _selectedTimeRange;
    final start = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      range.start.hour,
      range.start.minute,
    );
    var end = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      range.end.hour,
      range.end.minute,
    );
    if (range.endsNextDay) end = end.add(const Duration(days: 1));
    return UpdateAdminEventRequest(
      title: _nameController.text,
      description: _detailController.text,
      eventDate: start,
      attendanceStartTime: start,
      attendanceEndTime: end,
      rewardPoints: int.parse(_pointsController.text.trim()),
      latitude: _selectedLocation.latitude,
      longitude: _selectedLocation.longitude,
      radiusMeters: widget.event.radiusMeters,
      existingBannerUrl: _existingBannerUrl,
      poster: _posterUpload(),
    );
  }

  EventPosterUpload? _posterUpload() {
    final bytes = _posterBytes;
    if (bytes == null) return null;
    return EventPosterUpload(
      bytes: bytes,
      contentType: (_posterName ?? '').toLowerCase().endsWith('.png')
          ? 'image/png'
          : 'image/jpeg',
    );
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Hapus kegiatan?'),
        content: Text(
          'Kegiatan "${widget.event.title}" dan seluruh data kehadirannya akan dihapus permanen.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Batal'),
          ),
          FilledButton(
            key: const ValueKey('confirm-delete-event-button'),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFD92D20),
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await context.read<EditEventCubit>().deleteEvent(widget.event.id);
    }
  }

  void _onStateChanged(BuildContext context, EditEventState state) {
    switch (state) {
      case EditEventSuccess():
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Perubahan kegiatan berhasil disimpan.'),
          ),
        );
        Navigator.of(context).pop(true);
        break;
      case EditEventDeleted():
        Navigator.of(context).pop(true);
        break;
      case EditEventFailure(:final message):
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(message)));
        break;
      case EditEventInitial() || EditEventSubmitting() || EditEventDeleting():
        break;
    }
  }

  String _timeLabel(EventTimeRange range) =>
      '${range.start.format(context)}–${range.end.format(context)}${range.endsNextDay ? ' (+1)' : ''}';

  static String _locationLabel(EventLocationSelection location) =>
      '${location.latitude.toStringAsFixed(6)}, ${location.longitude.toStringAsFixed(6)}';
}
