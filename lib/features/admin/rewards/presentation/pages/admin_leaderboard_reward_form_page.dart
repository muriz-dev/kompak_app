import 'dart:typed_data';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../../core/di/injection.dart';
import '../../../../../core/routes/app_router.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../providers/domain/entities/admin_point_shop_product.dart';
import '../../../providers/domain/entities/admin_provider.dart';
import '../../domain/entities/admin_leaderboard_reward.dart';
import '../bloc/admin_leaderboard_reward_form_cubit.dart';
import '../bloc/admin_leaderboard_reward_form_state.dart';

@RoutePage()
class AdminLeaderboardRewardFormPage extends StatelessWidget {
  const AdminLeaderboardRewardFormPage({
    required this.position,
    this.reward,
    super.key,
  });

  final int position;
  final AdminLeaderboardReward? reward;

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => getIt<AdminLeaderboardRewardFormCubit>()..loadProviders(),
    child: _AdminLeaderboardRewardFormView(position: position, reward: reward),
  );
}

class _AdminLeaderboardRewardFormView extends StatefulWidget {
  const _AdminLeaderboardRewardFormView({
    required this.position,
    required this.reward,
  });

  final int position;
  final AdminLeaderboardReward? reward;

  @override
  State<_AdminLeaderboardRewardFormView> createState() =>
      _AdminLeaderboardRewardFormViewState();
}

class _AdminLeaderboardRewardFormViewState
    extends State<_AdminLeaderboardRewardFormView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _imagePicker = ImagePicker();

  String? _providerId;
  AdminPointShopProductType? _type;
  AdminPointShopProduct? _selectedProduct;
  Uint8List? _imageBytes;
  String? _imageContentType;
  String? _imageUrl;
  String? _imageError;
  late bool _manualMode;

  @override
  void initState() {
    super.initState();
    final reward = widget.reward;
    _manualMode = reward == null;
    if (reward != null) {
      _providerId = reward.providerId;
      _type = reward.type;
      _nameController.text = reward.name;
      _descriptionController.text = reward.description;
      _imageUrl = reward.imageUrl;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<
      AdminLeaderboardRewardFormCubit,
      AdminLeaderboardRewardFormState
    >(
      listener: _onState,
      builder: (context, state) {
        final ready = state is AdminLeaderboardRewardFormReady ? state : null;
        final busy = ready?.submitting == true;
        return PopScope(
          canPop: !busy,
          child: Scaffold(
            backgroundColor: const Color(0xFFFEFFFF),
            appBar: AppBar(
              backgroundColor: const Color(0xFFFEFFFF),
              surfaceTintColor: Colors.transparent,
              leading: IconButton(
                onPressed: busy ? null : () => context.router.maybePop(),
                icon: const Icon(Icons.chevron_left_rounded, size: 28),
              ),
              title: const Text(
                'Edit Hadiah',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
              centerTitle: true,
            ),
            body: switch (state) {
              AdminLeaderboardRewardFormReady() => Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 150),
                  children: [
                    if (_manualMode)
                      _buildManualForm(state.providers)
                    else
                      _buildSelectedReward(),
                    const SizedBox(height: 20),
                    _ChangeModeCard(
                      manualMode: _manualMode,
                      onPressed: _manualMode
                          ? _pickFromPointShop
                          : _switchToManual,
                    ),
                  ],
                ),
              ),
              AdminLeaderboardRewardFormFailure() => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(state.message, textAlign: TextAlign.center),
                ),
              ),
              _ => const Center(child: CircularProgressIndicator()),
            },
            bottomNavigationBar: ready == null
                ? null
                : SafeArea(
                    top: false,
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(34, 10, 34, 10),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Color(0x14000000),
                            blurRadius: 16,
                            offset: Offset(0, -4),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          FilledButton(
                            key: const ValueKey('save-leaderboard-reward'),
                            onPressed: busy ? null : _save,
                            style: FilledButton.styleFrom(
                              minimumSize: const Size.fromHeight(42),
                              backgroundColor: KompakColors.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: busy
                                ? const SizedBox.square(
                                    dimension: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text('Simpan Perubahan'),
                          ),
                          if (widget.reward != null) ...[
                            const SizedBox(height: 8),
                            FilledButton(
                              key: const ValueKey('delete-leaderboard-reward'),
                              onPressed: busy ? null : _confirmArchive,
                              style: FilledButton.styleFrom(
                                minimumSize: const Size.fromHeight(42),
                                backgroundColor: KompakColors.errorSurface,
                                foregroundColor: KompakColors.error,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text('Hapus Hadiah'),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
          ),
        );
      },
    );
  }

  Widget _buildManualForm(List<AdminProviderSummary> providers) => Column(
    children: [
      _FormCard(
        title: 'Foto Produk',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            InkWell(
              onTap: _pickImage,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                height: 174,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E4E5), width: 2),
                ),
                child: _imageBytes != null
                    ? Image.memory(_imageBytes!, fit: BoxFit.cover)
                    : _imageUrl != null
                    ? Image.network(
                        _imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => const _UploadPrompt(),
                      )
                    : const _UploadPrompt(),
              ),
            ),
            const SizedBox(height: 7),
            Text(
              _imageError ??
                  'Format yang disarankan: JPG, PNG. Ukuran maksimal 5MB.',
              style: TextStyle(
                color: _imageError == null
                    ? const Color(0xFFB0B2B3)
                    : KompakColors.error,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 20),
      _FormCard(
        title: 'Detail Produk',
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              key: const ValueKey('leaderboard-provider-field'),
              initialValue: providers.any((item) => item.id == _providerId)
                  ? _providerId
                  : null,
              items: providers
                  .map(
                    (provider) => DropdownMenuItem(
                      value: provider.id,
                      child: Text(
                        provider.name,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  )
                  .toList(growable: false),
              onChanged: (value) => setState(() => _providerId = value),
              validator: (value) => value == null
                  ? 'Pilih provider hadiah terlebih dahulu.'
                  : null,
              decoration: _inputDecoration(
                label: 'Nama Provider',
                hint: 'Pilih Provider',
              ),
            ),
            const SizedBox(height: 14),
            TextFormField(
              key: const ValueKey('leaderboard-name-field'),
              controller: _nameController,
              validator: (value) => value == null || value.trim().isEmpty
                  ? 'Nama produk wajib diisi.'
                  : null,
              decoration: _inputDecoration(
                label: 'Nama Produk',
                hint: 'Masukkan Nama Produk',
              ),
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<AdminPointShopProductType>(
              key: const ValueKey('leaderboard-category-field'),
              initialValue: _type,
              items: AdminPointShopProductType.values
                  .map(
                    (type) =>
                        DropdownMenuItem(value: type, child: Text(type.label)),
                  )
                  .toList(growable: false),
              onChanged: (value) => setState(() => _type = value),
              validator: (value) => value == null ? 'Pilih kategori.' : null,
              decoration: _inputDecoration(
                label: 'Kategori',
                hint: 'Pilih Kategori',
              ),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _descriptionController,
              maxLines: 3,
              maxLength: 5000,
              decoration: _inputDecoration(
                label: 'Deskripsi',
                hint: 'Tambahkan detail hadiah',
              ),
            ),
          ],
        ),
      ),
    ],
  );

  Widget _buildSelectedReward() {
    final product = _selectedProduct;
    final reward = widget.reward;
    final name = product?.name ?? reward!.name;
    final stock = product?.stock ?? reward!.stock;
    final imageUrl = product?.imageUrl ?? reward?.imageUrl;
    final type = product?.type ?? reward!.type;
    final providerName = reward?.provider.name;

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFF1F1F2)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 160,
            child: imageUrl != null && imageUrl.isNotEmpty
                ? Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => _rewardFallback(type),
                  )
                : _rewardFallback(type),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: KompakColors.successSurface,
                  child: const Icon(
                    Icons.storefront_outlined,
                    color: KompakColors.success,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (providerName?.isNotEmpty == true)
                        Text(
                          providerName!,
                          style: const TextStyle(
                            color: Color(0xFF8D9199),
                            fontSize: 12,
                          ),
                        ),
                      Text(
                        'Stock: $stock',
                        style: const TextStyle(color: Color(0xFFB0B2B3)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _rewardFallback(AdminPointShopProductType type) => ColoredBox(
    color: KompakColors.primarySurface,
    child: Center(
      child: Icon(
        type == AdminPointShopProductType.voucher
            ? Icons.confirmation_number_outlined
            : Icons.redeem_outlined,
        color: KompakColors.primary,
        size: 48,
      ),
    ),
  );

  InputDecoration _inputDecoration({
    required String label,
    required String hint,
  }) => InputDecoration(
    labelText: label,
    hintText: hint,
    filled: true,
    fillColor: const Color(0xFFF1F1F2),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide.none,
    ),
  );

  Future<void> _pickFromPointShop() async {
    final selected = await context.router.push<AdminPointShopProduct>(
      const AdminLeaderboardRewardPickerRoute(),
    );
    if (selected == null || !mounted) return;
    setState(() {
      _selectedProduct = selected;
      _providerId = selected.providerId;
      _type = selected.type;
      _nameController.text = selected.name;
      _descriptionController.text = selected.description;
      _imageUrl = selected.imageUrl;
      _imageBytes = null;
      _imageContentType = null;
      _manualMode = false;
    });
  }

  void _switchToManual() {
    final product = _selectedProduct;
    if (product != null) {
      _providerId = product.providerId;
      _type = product.type;
      _nameController.text = product.name;
      _descriptionController.text = product.description;
      _imageUrl = product.imageUrl;
    }
    setState(() => _manualMode = true);
  }

  Future<void> _pickImage() async {
    final file = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 90,
    );
    if (file == null) return;
    final bytes = await file.readAsBytes();
    if (bytes.length > 5 * 1024 * 1024) {
      setState(() => _imageError = 'Ukuran foto maksimal 5MB.');
      return;
    }
    final extension = file.name.split('.').last.toLowerCase();
    if (!{'jpg', 'jpeg', 'png'}.contains(extension)) {
      setState(() => _imageError = 'Gunakan foto JPG atau PNG.');
      return;
    }
    setState(() {
      _imageBytes = bytes;
      _imageContentType = extension == 'png' ? 'image/png' : 'image/jpeg';
      _imageError = null;
    });
  }

  void _save() {
    AdminLeaderboardRewardDraft draft;
    final product = _selectedProduct;
    final existingReward = widget.reward;
    if (!_manualMode && product != null) {
      draft = AdminLeaderboardRewardDraft.fromProduct(product, widget.position);
    } else if (!_manualMode && existingReward != null) {
      draft = AdminLeaderboardRewardDraft(
        providerId: existingReward.providerId,
        name: existingReward.name,
        description: existingReward.description,
        type: existingReward.type,
        position: widget.position,
        stock: existingReward.stock,
        imageUrl: existingReward.imageUrl,
      );
    } else {
      if (_formKey.currentState?.validate() != true) return;
      draft = AdminLeaderboardRewardDraft(
        providerId: _providerId!,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        type: _type!,
        position: widget.position,
        imageUrl: _imageUrl,
        imageUpload: _imageBytes == null
            ? null
            : AdminRewardImageUpload(
                bytes: _imageBytes!,
                contentType: _imageContentType!,
              ),
      );
    }
    context.read<AdminLeaderboardRewardFormCubit>().save(
      draft,
      rewardId: widget.reward?.id,
    );
  }

  Future<void> _confirmArchive() async {
    final reward = widget.reward;
    if (reward == null) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Hapus hadiah peringkat?'),
        content: const Text(
          'Hadiah akan dinonaktifkan. Riwayat pemberian hadiah sebelumnya tetap tersimpan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: FilledButton.styleFrom(backgroundColor: KompakColors.error),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      context.read<AdminLeaderboardRewardFormCubit>().archive(reward.id);
    }
  }

  Future<void> _onState(
    BuildContext context,
    AdminLeaderboardRewardFormState state,
  ) async {
    if (state case AdminLeaderboardRewardFormReady(error: final error?)) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(error)));
      return;
    }
    if (state is AdminLeaderboardRewardFormReady &&
        (state.completed || state.deleted)) {
      final deleted = state.deleted;
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => AlertDialog(
          icon: Icon(
            deleted ? Icons.delete_outline_rounded : Icons.check_circle_rounded,
            size: 52,
            color: deleted ? KompakColors.error : KompakColors.success,
          ),
          title: Text(deleted ? 'Hadiah Dihapus' : 'Hadiah Tersimpan'),
          content: Text(
            deleted
                ? 'Hadiah tidak lagi digunakan untuk peringkat ${widget.position}.'
                : 'Hadiah peringkat ${widget.position} berhasil diperbarui.',
            textAlign: TextAlign.center,
          ),
          actions: [
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Selesai'),
            ),
          ],
        ),
      );
      if (context.mounted) context.router.maybePop(true);
    }
  }
}

class _FormCard extends StatelessWidget {
  const _FormCard({required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(color: const Color(0xFFF1F1F2)),
      borderRadius: BorderRadius.circular(12),
      boxShadow: const [
        BoxShadow(
          color: Color(0x0D000000),
          blurRadius: 2,
          offset: Offset(0, 1),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(title, style: const TextStyle(fontSize: 18)),
        const SizedBox(height: 12),
        child,
      ],
    ),
  );
}

class _UploadPrompt extends StatelessWidget {
  const _UploadPrompt();

  @override
  Widget build(BuildContext context) => const Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Icon(
        Icons.add_photo_alternate_outlined,
        size: 30,
        color: Color(0xFFB0B2B3),
      ),
      SizedBox(height: 7),
      Text(
        'Klik untuk unggah poster',
        style: TextStyle(fontWeight: FontWeight.w600),
      ),
      SizedBox(height: 3),
      Text(
        'Format JPG/PNG, Max 5MB',
        style: TextStyle(color: Color(0xFFB0B2B3), fontSize: 10),
      ),
    ],
  );
}

class _ChangeModeCard extends StatelessWidget {
  const _ChangeModeCard({required this.manualMode, required this.onPressed});
  final bool manualMode;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => _FormCard(
    title: 'Perubahan Hadiah',
    child: FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: KompakColors.success,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(manualMode ? 'Ambil Hadiah dari Toko' : 'Edit Hadiah Manual'),
    ),
  );
}
