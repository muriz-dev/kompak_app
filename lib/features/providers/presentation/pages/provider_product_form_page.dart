import 'dart:typed_data';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/provider_account.dart';
import '../bloc/provider_product_form_cubit.dart';

@RoutePage()
class ProviderProductFormPage extends StatelessWidget {
  const ProviderProductFormPage({
    required this.providerId,
    this.product,
    super.key,
  });

  final String providerId;
  final ProviderProduct? product;

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => getIt<ProviderProductFormCubit>(),
    child: _ProviderProductFormView(providerId: providerId, product: product),
  );
}

class _ProviderProductFormView extends StatefulWidget {
  const _ProviderProductFormView({required this.providerId, this.product});
  final String providerId;
  final ProviderProduct? product;

  @override
  State<_ProviderProductFormView> createState() =>
      _ProviderProductFormViewState();
}

class _ProviderProductFormViewState extends State<_ProviderProductFormView> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _description = TextEditingController();
  final _points = TextEditingController();
  final _stock = TextEditingController();
  final _picker = ImagePicker();

  ProviderProductType? _type;
  Uint8List? _imageBytes;
  String? _imageType;

  @override
  void initState() {
    super.initState();
    final product = widget.product;
    if (product != null) {
      _name.text = product.name;
      _description.text = product.description;
      _points.text = '${product.pointsRequired}';
      _stock.text = '${product.stock}';
      _type = product.type;
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    _points.dispose();
    _stock.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProviderProductFormCubit, ProviderProductFormState>(
      listener: (context, state) {
        if (state case ProviderProductFormFailure(:final message)) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(message)));
        }
      },
      builder: (context, state) {
        final busy = state is ProviderProductFormSubmitting;
        return PopScope(
          canPop: !busy,
          child: Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.transparent,
              centerTitle: true,
              title: Text(
                widget.product == null ? 'Tambah Produk' : 'Edit Produk',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            body: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(22, 18, 22, 154),
                children: [
                  _ProductFormCard(
                    title: 'Foto Produk',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        InkWell(
                          key: const ValueKey('provider-product-image'),
                          onTap: busy ? null : _pickImage,
                          borderRadius: BorderRadius.circular(14),
                          child: Container(
                            height: 178,
                            clipBehavior: Clip.antiAlias,
                            decoration: BoxDecoration(
                              color: KompakColors.primarySurface,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: KompakColors.primaryBorder,
                              ),
                            ),
                            child: _imageBytes != null
                                ? Image.memory(_imageBytes!, fit: BoxFit.cover)
                                : widget.product?.imageUrl != null
                                ? Image.network(
                                    widget.product!.imageUrl!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, _, _) =>
                                        const _UploadProduct(),
                                  )
                                : const _UploadProduct(),
                          ),
                        ),
                        const SizedBox(height: 7),
                        const Text(
                          'Format JPG atau PNG, maksimal 5MB.',
                          style: TextStyle(
                            color: KompakColors.mutedInk,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  _ProductFormCard(
                    title: 'Detail Produk',
                    child: Column(
                      children: [
                        TextFormField(
                          key: const ValueKey('provider-product-name'),
                          controller: _name,
                          validator: _required('Nama produk wajib diisi.'),
                          decoration: _input(
                            'Nama Produk',
                            'Masukkan nama produk',
                          ),
                        ),
                        const SizedBox(height: 14),
                        DropdownButtonFormField<ProviderProductType>(
                          key: const ValueKey('provider-product-type'),
                          initialValue: _type,
                          validator: (value) =>
                              value == null ? 'Pilih kategori.' : null,
                          items: ProviderProductType.values
                              .map(
                                (type) => DropdownMenuItem(
                                  value: type,
                                  child: Text(type.label),
                                ),
                              )
                              .toList(growable: false),
                          onChanged: busy
                              ? null
                              : (value) => setState(() => _type = value),
                          decoration: _input('Kategori', 'Pilih kategori'),
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          key: const ValueKey('provider-product-description'),
                          controller: _description,
                          minLines: 3,
                          maxLines: 5,
                          maxLength: 5000,
                          validator: _required('Deskripsi produk wajib diisi.'),
                          decoration: _input(
                            'Deskripsi',
                            'Jelaskan produk atau layanan',
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  _ProductFormCard(
                    title: 'Harga Poin & Stok',
                    child: Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            key: const ValueKey('provider-product-points'),
                            controller: _points,
                            keyboardType: TextInputType.number,
                            validator: _nonNegative(
                              'Masukkan poin yang valid.',
                            ),
                            decoration: _input('Alokasi Poin', '0'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            key: const ValueKey('provider-product-stock'),
                            controller: _stock,
                            keyboardType: TextInputType.number,
                            validator: _nonNegative(
                              'Masukkan stok yang valid.',
                            ),
                            decoration: _input('Stok', '0'),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (widget.product?.isActive == true) ...[
                    const SizedBox(height: 12),
                    const Text(
                      'Perubahan pada produk aktif akan dikirim kembali untuk verifikasi admin.',
                      style: TextStyle(
                        color: KompakColors.warning,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            bottomNavigationBar: SafeArea(
              top: false,
              child: Container(
                padding: const EdgeInsets.fromLTRB(24, 10, 24, 10),
                color: Colors.white,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FilledButton(
                      key: const ValueKey('provider-product-save'),
                      onPressed: busy ? null : _save,
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(50),
                        backgroundColor: KompakColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: busy
                          ? const SizedBox.square(
                              dimension: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              widget.product == null
                                  ? 'Tambahkan Produk'
                                  : 'Simpan Perubahan',
                            ),
                    ),
                    if (widget.product != null) ...[
                      const SizedBox(height: 8),
                      FilledButton(
                        key: const ValueKey('provider-product-delete'),
                        onPressed: busy ? null : _confirmDelete,
                        style: FilledButton.styleFrom(
                          minimumSize: const Size.fromHeight(46),
                          backgroundColor: KompakColors.errorSurface,
                          foregroundColor: KompakColors.error,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Hapus Produk'),
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

  Future<void> _pickImage() async {
    final image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1800,
      imageQuality: 88,
    );
    if (image == null) return;
    final bytes = await image.readAsBytes();
    if (bytes.length > 5 * 1024 * 1024 || !mounted) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ukuran gambar maksimal 5MB.')),
        );
      }
      return;
    }
    setState(() {
      _imageBytes = bytes;
      _imageType =
          image.mimeType ??
          (image.name.toLowerCase().endsWith('.png')
              ? 'image/png'
              : 'image/jpeg');
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final success = await context.read<ProviderProductFormCubit>().save(
      providerId: widget.providerId,
      product: widget.product,
      draft: ProviderProductDraft(
        name: _name.text,
        description: _description.text,
        pointsRequired: int.parse(_points.text),
        stock: int.parse(_stock.text),
        type: _type!,
        imageUrl: widget.product?.imageUrl,
        imageUpload: _imageBytes == null
            ? null
            : ProviderImageUpload(
                bytes: _imageBytes!,
                contentType: _imageType!,
              ),
      ),
    );
    if (success && mounted) context.router.maybePop(true);
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Hapus produk?'),
        content: Text(
          '${widget.product!.name} akan dihapus dari provider Anda.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: FilledButton.styleFrom(backgroundColor: KompakColors.error),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    final success = await context.read<ProviderProductFormCubit>().delete(
      widget.product!.id,
    );
    if (success && mounted) context.router.maybePop(true);
  }
}

class _ProductFormCard extends StatelessWidget {
  const _ProductFormCard({required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: const Color(0xFFE8E9EC)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 16),
        child,
      ],
    ),
  );
}

class _UploadProduct extends StatelessWidget {
  const _UploadProduct();
  @override
  Widget build(BuildContext context) => const Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Icon(Icons.cloud_upload_outlined, size: 40, color: KompakColors.primary),
      SizedBox(height: 7),
      Text('Unggah Foto Produk', style: TextStyle(color: KompakColors.primary)),
    ],
  );
}

InputDecoration _input(String label, String hint) => InputDecoration(
  labelText: label,
  hintText: hint,
  filled: true,
  fillColor: const Color(0xFFF6F7F9),
  border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: BorderSide.none,
  ),
  enabledBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: const BorderSide(color: Color(0xFFE7E8EB)),
  ),
  focusedBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: const BorderSide(color: KompakColors.primary),
  ),
);

String? Function(String?) _required(String message) =>
    (value) => value == null || value.trim().isEmpty ? message : null;

String? Function(String?) _nonNegative(String message) => (value) {
  final parsed = int.tryParse(value ?? '');
  return parsed == null || parsed < 0 ? message : null;
};
