import 'dart:typed_data';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../widgets/event_form_widgets.dart';
import '../widgets/event_success_dialog.dart';

@RoutePage()
class CreateEventPage extends StatefulWidget {
  const CreateEventPage({super.key});

  @override
  State<CreateEventPage> createState() => _CreateEventPageState();
}

class _CreateEventPageState extends State<CreateEventPage> {
  static const _categories = [
    'Kerja Bakti',
    'Rapat Warga',
    'Kesehatan',
    'Keamanan',
    'Sosial',
    'Lainnya',
  ];

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _detailController = TextEditingController();
  final _dateController = TextEditingController();
  final _timeController = TextEditingController();
  final _locationController = TextEditingController();
  final _pointsController = TextEditingController(text: '0');
  final _scrollController = ScrollController();
  final _imagePicker = ImagePicker();

  String? _category;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  Uint8List? _posterBytes;
  String? _posterName;
  String? _posterError;
  bool _faceRecognition = false;
  bool _requiresPhoto = false;
  bool _isPublishing = false;

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
    return Scaffold(
      backgroundColor: Colors.white,
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
                  padding: const EdgeInsets.fromLTRB(24, 10, 24, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'POSTER KEGIATAN',
                        style: TextStyle(
                          color: eventFormInk,
                          fontSize: 14,
                          letterSpacing: 0.2,
                          fontWeight: FontWeight.w700,
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
                      const SizedBox(height: 28),
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
            _buildPublishBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return SizedBox(
      height: 68,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: 16),
              child: IconButton(
                tooltip: 'Kembali',
                onPressed: () => context.router.maybePop(),
                iconSize: 30,
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
                fontSize: 21,
                fontWeight: FontWeight.w700,
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
        const SizedBox(height: 20),
        EventFieldLabel(
          label: 'Kategori',
          child: DropdownButtonFormField<String>(
            key: const ValueKey('event-category-field'),
            initialValue: _category,
            isExpanded: true,
            icon: const Icon(Icons.keyboard_arrow_down_rounded),
            decoration: eventInputDecoration(hintText: 'Pilih Kategori'),
            items: _categories
                .map(
                  (category) =>
                      DropdownMenuItem(value: category, child: Text(category)),
                )
                .toList(),
            onChanged: (value) => setState(() => _category = value),
            validator: (value) =>
                value == null ? 'Pilih kategori kegiatan.' : null,
          ),
        ),
        const SizedBox(height: 20),
        EventFieldLabel(
          label: 'Detail Kegiatan',
          child: TextFormField(
            key: const ValueKey('event-detail-field'),
            controller: _detailController,
            minLines: 4,
            maxLines: 6,
            textCapitalization: TextCapitalization.sentences,
            decoration: eventInputDecoration(
              hintText:
                  'Jelaskan detail kegiatan, perlengkapan yang dibawa, dll…',
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
                  onTap: _selectTime,
                  decoration: eventInputDecoration(hintText: '--:-- --'),
                  validator: (_) =>
                      _selectedTime == null ? 'Pilih waktu kegiatan.' : null,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        EventFieldLabel(
          label: 'Lokasi',
          child: TextFormField(
            key: const ValueKey('event-location-field'),
            controller: _locationController,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.next,
            decoration: eventInputDecoration(
              hintText: 'Masukkan lokasi kegiatan',
              prefixIcon: const Icon(
                Icons.location_on_outlined,
                color: eventFormMuted,
              ),
            ),
            validator: (value) => value == null || value.trim().isEmpty
                ? 'Masukkan lokasi kegiatan.'
                : null,
          ),
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
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.auto_awesome, size: 18, color: eventFormBlue),
                SizedBox(width: 4),
                Text(
                  'Reward',
                  style: TextStyle(
                    color: eventFormBlue,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
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
        const SizedBox(height: 24),
        const Divider(color: Color(0xFFE2E7E4)),
        const SizedBox(height: 20),
        EventToggleRow(
          title: 'Face Recognition',
          description: 'Verifikasi kehadiran dengan wajah',
          value: _faceRecognition,
          onChanged: (value) => setState(() => _faceRecognition = value),
        ),
        const SizedBox(height: 20),
        EventToggleRow(
          title: 'Wajib Lampiran Foto',
          description: 'Warga harus unggah bukti foto',
          value: _requiresPhoto,
          onChanged: (value) => setState(() => _requiresPhoto = value),
        ),
      ],
    );
  }

  Widget _buildPublishBar() {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFF0F1F3))),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 14, 24, 16),
        child: SizedBox(
          width: double.infinity,
          height: 54,
          child: FilledButton(
            onPressed: _isPublishing ? null : _validateForPublish,
            style: FilledButton.styleFrom(
              backgroundColor: eventFormBlue,
              foregroundColor: Colors.white,
              disabledBackgroundColor: const Color(0xFFAFC3F4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: _isPublishing
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
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
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

  Future<void> _selectTime() async {
    final selected = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    if (selected == null || !mounted) return;

    setState(() {
      _selectedTime = selected;
      _timeController.text = selected.format(context);
    });
  }

  Future<void> _validateForPublish() async {
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

    setState(() => _isPublishing = true);
    await Future<void>.delayed(const Duration(milliseconds: 450));
    if (!mounted) return;
    setState(() => _isPublishing = false);

    final action = await showDialog<EventSuccessAction>(
      context: context,
      barrierDismissible: false,
      barrierColor: const Color(0xBF24282E),
      builder: (context) => const EventSuccessDialog(),
    );
    if (!mounted) return;

    switch (action) {
      case EventSuccessAction.viewList:
        await context.router.maybePop();
        break;
      case EventSuccessAction.createAnother:
        _resetForm();
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
      _category = null;
      _selectedDate = null;
      _selectedTime = null;
      _posterBytes = null;
      _posterName = null;
      _posterError = null;
      _faceRecognition = false;
      _requiresPhoto = false;
    });
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
    );
  }
}
