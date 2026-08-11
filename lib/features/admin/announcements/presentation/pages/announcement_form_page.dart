import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/di/injection.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../announcements/domain/entities/community_announcement.dart';
import '../bloc/announcement_form_cubit.dart';
import '../bloc/announcement_form_state.dart';
import '../widgets/announcement_success_dialog.dart';

@RoutePage()
class AnnouncementFormPage extends StatelessWidget {
  const AnnouncementFormPage({this.announcement, super.key});

  final CommunityAnnouncement? announcement;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<AnnouncementFormCubit>(),
      child: AnnouncementFormView(
        announcement: announcement,
        onBack: () => context.router.maybePop(),
        onComplete: () => Navigator.of(context).pop(true),
      ),
    );
  }
}

class AnnouncementFormView extends StatefulWidget {
  const AnnouncementFormView({
    required this.onBack,
    required this.onComplete,
    this.announcement,
    super.key,
  });

  final CommunityAnnouncement? announcement;
  final VoidCallback onBack;
  final VoidCallback onComplete;

  @override
  State<AnnouncementFormView> createState() => _AnnouncementFormViewState();
}

class _AnnouncementFormViewState extends State<AnnouncementFormView> {
  static const _ink = Color(0xFF2F3236);
  static const _field = Color(0xFFF1F1F2);
  static const _fieldBorder = Color(0xFFD3D5D8);
  static const _hint = Color(0xFFB0B2B3);
  static const _error = Color(0xFFF04438);

  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _successDialogVisible = false;

  bool get _editing => widget.announcement != null;

  @override
  void initState() {
    super.initState();
    final announcement = widget.announcement;
    if (announcement != null) {
      _titleController.text = announcement.title;
      _descriptionController.text = announcement.description;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AnnouncementFormCubit, AnnouncementFormState>(
      listener: (context, state) {
        if (state is AnnouncementFormSuccess) {
          if (state.deleted || _editing) {
            widget.onComplete();
          } else {
            _showCreateSuccessDialog();
          }
        } else if (state is AnnouncementFormFailure) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      builder: (context, state) {
        final submitting = state is AnnouncementFormSubmitting;
        final deleting = state is AnnouncementFormDeleting;
        final busy = submitting || deleting;
        final locked = busy || state is AnnouncementFormSuccess;
        return PopScope(
          canPop: !locked,
          child: Scaffold(
            backgroundColor: const Color(0xFFFEFFFF),
            body: SafeArea(
              child: Column(
                children: [
                  _FormHeader(
                    title: _editing
                        ? 'Detail Pengumuman'
                        : 'Buat Pengumuman Baru',
                    onBack: locked ? null : widget.onBack,
                  ),
                  Expanded(
                    child: Form(
                      key: _formKey,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      child: SingleChildScrollView(
                        key: const ValueKey('announcement-form-scroll'),
                        padding: const EdgeInsets.fromLTRB(24, 4, 24, 24),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(17),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: _field),
                          ),
                          child: Column(
                            children: [
                              _FieldLabel(
                                label: 'Judul Pengumuman',
                                child: TextFormField(
                                  key: const ValueKey(
                                    'announcement-title-field',
                                  ),
                                  controller: _titleController,
                                  enabled: !locked,
                                  textCapitalization:
                                      TextCapitalization.sentences,
                                  textInputAction: TextInputAction.next,
                                  onChanged: (_) => setState(() {}),
                                  decoration: _inputDecoration(
                                    hintText: 'Contoh: Kerja Bakti Minggu',
                                    filled: _titleController.text.isEmpty,
                                  ),
                                  validator: (value) {
                                    final title = value?.trim() ?? '';
                                    if (title.isEmpty) {
                                      return 'Masukkan judul pengumuman.';
                                    }
                                    if (title.length < 5) {
                                      return 'Judul minimal 5 karakter.';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(height: 16),
                              _FieldLabel(
                                label: 'Detail Pengumuman',
                                child: TextFormField(
                                  key: const ValueKey(
                                    'announcement-description-field',
                                  ),
                                  controller: _descriptionController,
                                  enabled: !locked,
                                  minLines: 5,
                                  maxLines: 9,
                                  textCapitalization:
                                      TextCapitalization.sentences,
                                  onChanged: (_) => setState(() {}),
                                  decoration: _inputDecoration(
                                    hintText:
                                        'Jelaskan isi pengumuman secara lengkap...',
                                    filled: _descriptionController.text.isEmpty,
                                  ),
                                  validator: (value) {
                                    final description = value?.trim() ?? '';
                                    if (description.isEmpty) {
                                      return 'Masukkan detail pengumuman.';
                                    }
                                    if (description.length < 10) {
                                      return 'Detail minimal 10 karakter.';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  _ActionBar(
                    editing: _editing,
                    locked: locked,
                    submitting: submitting,
                    deleting: deleting,
                    onSubmit: _submit,
                    onDelete: _editing ? _confirmDelete : null,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  InputDecoration _inputDecoration({
    required String hintText,
    required bool filled,
  }) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: filled ? Colors.transparent : _fieldBorder),
    );
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(color: _hint, fontSize: 14),
      filled: true,
      fillColor: filled ? _field : Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
      enabledBorder: border,
      disabledBorder: border,
      focusedBorder: border.copyWith(
        borderSide: const BorderSide(color: KompakColors.primary, width: 1.4),
      ),
      errorBorder: border.copyWith(borderSide: const BorderSide(color: _error)),
      focusedErrorBorder: border.copyWith(
        borderSide: const BorderSide(color: _error, width: 1.4),
      ),
      errorStyle: const TextStyle(fontSize: 11),
    );
  }

  void _submit() {
    if (_formKey.currentState?.validate() != true) return;
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();
    final cubit = context.read<AnnouncementFormCubit>();
    final announcement = widget.announcement;
    if (announcement == null) {
      cubit.create(title: title, description: description);
    } else {
      cubit.update(
        announcementId: announcement.id,
        title: title,
        description: description,
      );
    }
  }

  Future<void> _showCreateSuccessDialog() async {
    if (_successDialogVisible || !mounted) return;
    _successDialogVisible = true;
    final action = await showDialog<AnnouncementSuccessAction>(
      context: context,
      barrierDismissible: false,
      barrierColor: const Color(0xBF24282E),
      builder: (context) => const AnnouncementSuccessDialog(),
    );
    _successDialogVisible = false;
    if (!mounted) return;

    switch (action) {
      case AnnouncementSuccessAction.viewList:
        widget.onComplete();
        break;
      case AnnouncementSuccessAction.createAnother:
        _resetForm();
        context.read<AnnouncementFormCubit>().reset();
        break;
      case null:
        break;
    }
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    _titleController.clear();
    _descriptionController.clear();
    FocusScope.of(context).unfocus();
    setState(() {});
  }

  Future<void> _confirmDelete() async {
    final announcement = widget.announcement;
    if (announcement == null) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus pengumuman?'),
        content: Text(
          'Pengumuman “${announcement.title}” akan dihapus permanen.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Batal'),
          ),
          FilledButton(
            key: const ValueKey('confirm-delete-announcement'),
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(backgroundColor: _error),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      context.read<AnnouncementFormCubit>().delete(announcement.id);
    }
  }
}

class _FormHeader extends StatelessWidget {
  const _FormHeader({required this.title, required this.onBack});

  final String title;
  final VoidCallback? onBack;

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
                color: _AnnouncementFormViewState._ink,
                icon: const Icon(Icons.chevron_left_rounded),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 64),
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: _AnnouncementFormViewState._ink,
                fontSize: 20,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: _AnnouncementFormViewState._ink,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        child,
      ],
    );
  }
}

class _ActionBar extends StatelessWidget {
  const _ActionBar({
    required this.editing,
    required this.locked,
    required this.submitting,
    required this.deleting,
    required this.onSubmit,
    required this.onDelete,
  });

  final bool editing;
  final bool locked;
  final bool submitting;
  final bool deleting;
  final VoidCallback onSubmit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: double.infinity,
              height: 42,
              child: FilledButton(
                key: const ValueKey('submit-announcement'),
                onPressed: locked ? null : onSubmit,
                style: FilledButton.styleFrom(
                  backgroundColor: KompakColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: submitting
                    ? const SizedBox.square(
                        dimension: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        editing ? 'Simpan Perubahan' : 'Simpan & Publikasi',
                        style: const TextStyle(fontSize: 16),
                      ),
              ),
            ),
            if (editing) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 42,
                child: TextButton(
                  key: const ValueKey('delete-announcement'),
                  onPressed: locked ? null : onDelete,
                  style: TextButton.styleFrom(
                    foregroundColor: _AnnouncementFormViewState._error,
                    backgroundColor: const Color(0xFFFEECEB),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: deleting
                      ? const SizedBox.square(
                          dimension: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text(
                          'Hapus',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
