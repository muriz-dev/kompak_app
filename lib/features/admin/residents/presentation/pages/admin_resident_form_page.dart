import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../../core/di/injection.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../domain/entities/resident.dart';
import '../bloc/admin_resident_form_cubit.dart';
import '../bloc/admin_resident_form_state.dart';

@RoutePage()
class AdminResidentFormPage extends StatelessWidget {
  const AdminResidentFormPage({this.resident, super.key});

  final Resident? resident;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<AdminResidentFormCubit>(),
      child: AdminResidentFormView(
        resident: resident,
        onComplete: () => Navigator.of(context).pop(true),
      ),
    );
  }
}

class AdminResidentFormView extends StatefulWidget {
  const AdminResidentFormView({
    required this.onComplete,
    this.resident,
    this.imagePicker,
    super.key,
  });

  final Resident? resident;
  final VoidCallback onComplete;
  final ImagePicker? imagePicker;

  @override
  State<AdminResidentFormView> createState() => _AdminResidentFormViewState();
}

class _AdminResidentFormViewState extends State<AdminResidentFormView> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _birthDate = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();

  late final ImagePicker _picker;
  XFile? _faceImage;
  bool _obscurePassword = true;

  bool get _editing => widget.resident != null;

  @override
  void initState() {
    super.initState();
    _picker = widget.imagePicker ?? ImagePicker();
    final resident = widget.resident;
    if (resident != null) {
      _name.text = resident.name;
      _phone.text = resident.phoneNumber;
      _birthDate.text = resident.birthDate.length >= 10
          ? resident.birthDate.substring(0, 10)
          : resident.birthDate;
      _email.text = resident.email;
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _birthDate.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AdminResidentFormCubit, AdminResidentFormState>(
      listener: (context, state) {
        if (state is AdminResidentFormSuccess) {
          widget.onComplete();
        } else if (state case AdminResidentFormFailure(:final message)) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(message)));
        }
      },
      builder: (context, state) {
        final submitting = state is AdminResidentFormSubmitting;
        return PopScope(
          canPop: !submitting,
          child: Scaffold(
            backgroundColor: KompakColors.surface,
            appBar: AppBar(
              backgroundColor: KompakColors.surface,
              surfaceTintColor: Colors.transparent,
              centerTitle: true,
              title: Text(
                _editing ? 'Edit Data Warga' : 'Tambah Warga',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            body: Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: ListView(
                key: const ValueKey('admin-resident-form-scroll'),
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 140),
                children: [
                  Text(
                    _editing
                        ? 'Perbarui informasi yang digunakan untuk identitas akun warga.'
                        : 'Buat akun warga aktif. Foto wajah diperlukan untuk verifikasi presensi.',
                    style: const TextStyle(
                      color: KompakColors.mutedInk,
                      fontSize: 14,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const _FormSectionTitle('Informasi Pribadi'),
                  const SizedBox(height: 12),
                  TextFormField(
                    key: const ValueKey('resident-name-field'),
                    controller: _name,
                    enabled: !submitting,
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.next,
                    validator: (value) => (value?.trim().length ?? 0) < 2
                        ? 'Nama minimal 2 karakter.'
                        : null,
                    decoration: _inputDecoration(
                      label: 'Nama Lengkap',
                      hint: 'Masukkan nama lengkap',
                      icon: Icons.person_outline_rounded,
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    key: const ValueKey('resident-phone-field'),
                    controller: _phone,
                    enabled: !submitting,
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.next,
                    validator: (value) {
                      final compact = (value ?? '').replaceAll(
                        RegExp(r'[\s()-]'),
                        '',
                      );
                      return RegExp(r'^(08|\+?628)\d{7,11}$').hasMatch(compact)
                          ? null
                          : 'Masukkan nomor Indonesia yang valid.';
                    },
                    decoration: _inputDecoration(
                      label: 'Nomor Telepon',
                      hint: 'Contoh: 081234567890',
                      icon: Icons.phone_outlined,
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    key: const ValueKey('resident-birth-date-field'),
                    controller: _birthDate,
                    enabled: !submitting,
                    readOnly: true,
                    onTap: submitting ? null : _selectBirthDate,
                    validator: (value) =>
                        (value ?? '').isEmpty ? 'Pilih tanggal lahir.' : null,
                    decoration:
                        _inputDecoration(
                          label: 'Tanggal Lahir',
                          hint: 'Pilih tanggal lahir',
                          icon: Icons.calendar_today_outlined,
                        ).copyWith(
                          suffixIcon: const Icon(Icons.chevron_right_rounded),
                        ),
                  ),
                  const SizedBox(height: 24),
                  const _FormSectionTitle('Informasi Akun'),
                  const SizedBox(height: 12),
                  TextFormField(
                    key: const ValueKey('resident-email-field'),
                    controller: _email,
                    enabled: !submitting,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: _editing
                        ? TextInputAction.done
                        : TextInputAction.next,
                    autocorrect: false,
                    validator: (value) =>
                        RegExp(
                          r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                        ).hasMatch(value?.trim() ?? '')
                        ? null
                        : 'Masukkan email yang valid.',
                    decoration: _inputDecoration(
                      label: 'Email',
                      hint: 'nama@email.com',
                      icon: Icons.email_outlined,
                    ),
                  ),
                  if (!_editing) ...[
                    const SizedBox(height: 14),
                    TextFormField(
                      key: const ValueKey('resident-password-field'),
                      controller: _password,
                      enabled: !submitting,
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.done,
                      validator: (value) => (value?.length ?? 0) < 6
                          ? 'Kata sandi minimal 6 karakter.'
                          : null,
                      decoration:
                          _inputDecoration(
                            label: 'Kata Sandi Sementara',
                            hint: 'Minimal 6 karakter',
                            icon: Icons.lock_outline_rounded,
                          ).copyWith(
                            suffixIcon: IconButton(
                              tooltip: _obscurePassword
                                  ? 'Tampilkan kata sandi'
                                  : 'Sembunyikan kata sandi',
                              onPressed: submitting
                                  ? null
                                  : () => setState(
                                      () =>
                                          _obscurePassword = !_obscurePassword,
                                    ),
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                              ),
                            ),
                          ),
                    ),
                    const SizedBox(height: 24),
                    const _FormSectionTitle('Data Wajah'),
                    const SizedBox(height: 12),
                    _FaceCaptureField(
                      image: _faceImage,
                      enabled: !submitting,
                      onTap: _captureFace,
                    ),
                  ],
                ],
              ),
            ),
            bottomNavigationBar: SafeArea(
              top: false,
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 12),
                decoration: const BoxDecoration(
                  color: KompakColors.surface,
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x12000000),
                      offset: Offset(0, -3),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: FilledButton(
                  key: const ValueKey('save-resident-button'),
                  onPressed: submitting ? null : _save,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: submitting
                      ? const SizedBox.square(
                          dimension: 21,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.4,
                            color: Colors.white,
                          ),
                        )
                      : Text(_editing ? 'Simpan Perubahan' : 'Tambahkan Warga'),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _selectBirthDate() async {
    final now = DateTime.now();
    final current = DateTime.tryParse(_birthDate.text);
    final selected = await showDatePicker(
      context: context,
      initialDate: current ?? DateTime(now.year - 25),
      firstDate: DateTime(1900),
      lastDate: DateTime(
        now.year,
        now.month,
        now.day,
      ).subtract(const Duration(days: 1)),
      helpText: 'Pilih tanggal lahir',
    );
    if (selected == null || !mounted) return;
    setState(() {
      _birthDate.text =
          '${selected.year.toString().padLeft(4, '0')}-${selected.month.toString().padLeft(2, '0')}-${selected.day.toString().padLeft(2, '0')}';
    });
  }

  Future<void> _captureFace() async {
    final image = await _picker.pickImage(
      source: ImageSource.camera,
      preferredCameraDevice: CameraDevice.front,
      maxWidth: 1600,
      imageQuality: 90,
    );
    if (image == null) return;
    final size = await image.length();
    if (!mounted) return;
    if (size > 10 * 1024 * 1024) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ukuran foto wajah maksimal 10MB.')),
      );
      return;
    }
    setState(() => _faceImage = image);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_editing && _faceImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ambil foto wajah warga sebelum menyimpan.'),
        ),
      );
      return;
    }

    await context.read<AdminResidentFormCubit>().save(
      resident: widget.resident,
      name: _name.text,
      phoneNumber: _phone.text,
      birthDate: _birthDate.text,
      email: _email.text,
      password: _editing ? null : _password.text,
      faceImagePath: _faceImage?.path,
    );
  }
}

class _FaceCaptureField extends StatelessWidget {
  const _FaceCaptureField({
    required this.image,
    required this.enabled,
    required this.onTap,
  });

  final XFile? image;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: KompakColors.primarySurface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        key: const ValueKey('resident-face-capture'),
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          height: 180,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            border: Border.all(color: KompakColors.primaryBorder),
            borderRadius: BorderRadius.circular(14),
          ),
          child: image == null
              ? const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add_a_photo_outlined,
                      color: KompakColors.primary,
                      size: 34,
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Ambil Foto Wajah',
                      style: TextStyle(
                        color: KompakColors.primary,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 5),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        'Pastikan wajah terlihat jelas dan pencahayaan cukup.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: KompakColors.mutedInk,
                          fontSize: 12,
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                )
              : Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.file(File(image!.path), fit: BoxFit.cover),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 9),
                        color: const Color(0xB3000000),
                        child: const Text(
                          'Ketuk untuk mengambil ulang',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class _FormSectionTitle extends StatelessWidget {
  const _FormSectionTitle(this.label);
  final String label;

  @override
  Widget build(BuildContext context) => Text(
    label,
    style: const TextStyle(
      color: KompakColors.ink,
      fontSize: 17,
      fontWeight: FontWeight.w700,
    ),
  );
}

InputDecoration _inputDecoration({
  required String label,
  required String hint,
  required IconData icon,
}) => InputDecoration(
  labelText: label,
  hintText: hint,
  prefixIcon: Icon(icon, size: 21),
  filled: true,
  fillColor: KompakColors.softSurface,
  border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: BorderSide.none,
  ),
  enabledBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: BorderSide.none,
  ),
  focusedBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: const BorderSide(color: KompakColors.primary, width: 1.5),
  ),
  errorBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: const BorderSide(color: KompakColors.error),
  ),
);
