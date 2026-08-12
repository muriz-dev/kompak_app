import 'dart:async';
import 'dart:typed_data';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/routes/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../admin/events/domain/entities/event_location_selection.dart';
import '../../../admin/events/presentation/pages/event_location_picker_page.dart';
import '../../../auth/presentation/session/session_cubit.dart';
import '../../../auth/presentation/session/session_state.dart';
import '../../domain/entities/provider_account.dart';
import '../bloc/provider_cubit.dart';

@RoutePage()
class ProviderEntryPage extends StatelessWidget {
  const ProviderEntryPage({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => getIt<ProviderCubit>()..load(),
    child: const _ProviderEntryView(),
  );
}

class _ProviderEntryView extends StatelessWidget {
  const _ProviderEntryView();

  @override
  Widget build(BuildContext context) =>
      BlocConsumer<ProviderCubit, ProviderState>(
        listener: (context, state) {
          if (state case ProviderFormFailure(:final message)) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(SnackBar(content: Text(message)));
          }
        },
        builder: (context, state) {
          final visible = switch (state) {
            ProviderSubmitting(:final previous) => previous,
            ProviderFormFailure(:final previous) => previous,
            _ => state,
          };
          final submitting = state is ProviderSubmitting;
          return switch (visible) {
            ProviderNotRegistered() => ProviderRegistrationView(
              submitting: submitting,
              onSubmit: context.read<ProviderCubit>().submitRegistration,
            ),
            ProviderAwaitingReview(:final account) => ProviderReviewView(
              account: account,
              submitting: submitting,
              onResubmit: context.read<ProviderCubit>().submitRegistration,
            ),
            ProviderReady() => ProviderDashboardView(
              state: visible,
              onRefresh: context.read<ProviderCubit>().refresh,
              onSearch: context.read<ProviderCubit>().search,
            ),
            ProviderFailure(:final message) => _ProviderFailureView(
              message: message,
              onRetry: context.read<ProviderCubit>().load,
            ),
            _ => const Scaffold(
              backgroundColor: Colors.white,
              body: Center(child: CircularProgressIndicator()),
            ),
          };
        },
      );
}

class ProviderRegistrationView extends StatefulWidget {
  const ProviderRegistrationView({
    required this.submitting,
    required this.onSubmit,
    this.account,
    super.key,
  });

  final bool submitting;
  final ProviderAccount? account;
  final Future<bool> Function(ProviderRegistrationDraft draft) onSubmit;

  @override
  State<ProviderRegistrationView> createState() =>
      _ProviderRegistrationViewState();
}

class _ProviderRegistrationViewState extends State<ProviderRegistrationView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _picker = ImagePicker();

  EventLocationSelection? _location;
  Uint8List? _logoBytes;
  String? _logoContentType;
  bool _agreed = false;

  @override
  void initState() {
    super.initState();
    final account = widget.account;
    if (account != null) {
      _nameController.text = account.name;
      _addressController.text = account.address;
      _location = EventLocationSelection(
        latitude: account.latitude,
        longitude: account.longitude,
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionCubit>().state;
    final user = session is SessionActive ? session.user : null;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _providerAppBar('Daftar Provider'),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(22, 18, 22, 132),
          children: [
            _SectionCard(
              title: 'Profil Provider',
              child: Column(
                children: [
                  InkWell(
                    key: const ValueKey('provider-logo-picker'),
                    onTap: widget.submitting ? null : _pickLogo,
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      width: 112,
                      height: 112,
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                        color: KompakColors.primarySurface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: KompakColors.primaryBorder),
                      ),
                      child: _logoBytes != null
                          ? Image.memory(_logoBytes!, fit: BoxFit.cover)
                          : widget.account?.logoUrl != null
                          ? Image.network(
                              widget.account!.logoUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => const _UploadLogo(),
                            )
                          : const _UploadLogo(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'PROFILE PROVIDER',
                    style: TextStyle(
                      color: KompakColors.primary,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'JPG atau PNG, maksimal 5MB',
                    style: TextStyle(
                      color: KompakColors.mutedInk,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            _SectionCard(
              title: 'Informasi Usaha',
              child: Column(
                children: [
                  _readOnlyField('Nama Pemilik', user?.name ?? '-'),
                  const SizedBox(height: 14),
                  _readOnlyField('Nomor WhatsApp', user?.phoneNumber ?? '-'),
                  const SizedBox(height: 14),
                  TextFormField(
                    key: const ValueKey('provider-business-name'),
                    controller: _nameController,
                    validator: _required('Nama usaha wajib diisi.'),
                    decoration: _decoration(
                      label: 'Nama Usaha / Brand',
                      hint: 'Contoh: Warung Berkah',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            _SectionCard(
              title: 'Lokasi Usaha',
              child: Column(
                children: [
                  TextFormField(
                    key: const ValueKey('provider-address'),
                    controller: _addressController,
                    minLines: 2,
                    maxLines: 3,
                    validator: _required('Alamat usaha wajib diisi.'),
                    decoration: _decoration(
                      label: 'Alamat Lengkap',
                      hint: 'Masukkan alamat tempat usaha',
                    ),
                  ),
                  const SizedBox(height: 14),
                  OutlinedButton.icon(
                    key: const ValueKey('provider-location-picker'),
                    onPressed: widget.submitting ? null : _pickLocation,
                    icon: const Icon(Icons.location_on_outlined),
                    label: Text(
                      _location == null
                          ? 'Pilih Lokasi di Peta'
                          : '${_location!.latitude.toStringAsFixed(6)}, '
                                '${_location!.longitude.toStringAsFixed(6)}',
                    ),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(52),
                      alignment: Alignment.centerLeft,
                      side: const BorderSide(color: KompakColors.outline),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            CheckboxListTile(
              key: const ValueKey('provider-terms'),
              value: _agreed,
              onChanged: widget.submitting
                  ? null
                  : (value) => setState(() => _agreed = value ?? false),
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              activeColor: KompakColors.primary,
              title: const Text(
                'Saya menyetujui syarat dan ketentuan pendaftaran provider.',
                style: TextStyle(fontSize: 13, height: 1.35),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _BottomAction(
        label: widget.account == null ? 'Daftar Sekarang' : 'Kirim Ulang',
        busy: widget.submitting,
        onPressed: _submit,
      ),
    );
  }

  Future<void> _pickLogo() async {
    final image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1600,
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
      _logoBytes = bytes;
      _logoContentType = image.mimeType ?? _mimeFromName(image.name);
    });
  }

  Future<void> _pickLocation() async {
    final selection = await Navigator.of(context).push<EventLocationSelection>(
      MaterialPageRoute(
        builder: (_) => EventLocationPickerPage(
          initialLatitude: _location?.latitude,
          initialLongitude: _location?.longitude,
          title: 'Pilih Lokasi Usaha',
          showRadiusControl: false,
        ),
      ),
    );
    if (selection != null && mounted) setState(() => _location = selection);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_location == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih lokasi usaha terlebih dahulu.')),
      );
      return;
    }
    if (!_agreed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Setujui syarat dan ketentuan dahulu.')),
      );
      return;
    }
    await widget.onSubmit(
      ProviderRegistrationDraft(
        name: _nameController.text,
        address: _addressController.text,
        latitude: _location!.latitude,
        longitude: _location!.longitude,
        logoUrl: widget.account?.logoUrl,
        logoUpload: _logoBytes == null
            ? null
            : ProviderImageUpload(
                bytes: _logoBytes!,
                contentType: _logoContentType!,
              ),
      ),
    );
  }
}

class ProviderReviewView extends StatefulWidget {
  const ProviderReviewView({
    required this.account,
    required this.submitting,
    required this.onResubmit,
    super.key,
  });

  final ProviderAccount account;
  final bool submitting;
  final Future<bool> Function(ProviderRegistrationDraft draft) onResubmit;

  @override
  State<ProviderReviewView> createState() => _ProviderReviewViewState();
}

class _ProviderReviewViewState extends State<ProviderReviewView> {
  bool _editing = false;

  @override
  Widget build(BuildContext context) {
    if (_editing) {
      return ProviderRegistrationView(
        account: widget.account,
        submitting: widget.submitting,
        onSubmit: widget.onResubmit,
      );
    }
    final rejected = widget.account.status == ProviderStatus.rejected;
    final inactive = widget.account.status == ProviderStatus.inactive;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _providerAppBar('Status Provider'),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              Container(
                width: 116,
                height: 116,
                decoration: BoxDecoration(
                  color: rejected || inactive
                      ? KompakColors.errorSurface
                      : KompakColors.success,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  inactive
                      ? Icons.lock_outline_rounded
                      : rejected
                      ? Icons.priority_high_rounded
                      : Icons.check_rounded,
                  color: rejected || inactive
                      ? KompakColors.error
                      : Colors.white,
                  size: 66,
                ),
              ),
              const SizedBox(height: 34),
              Text(
                inactive
                    ? 'Akun Provider Dinonaktifkan'
                    : rejected
                    ? 'Pendaftaran Perlu Diperbaiki'
                    : 'Pendaftaran Masih Diverifikasi',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: KompakColors.primary,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                inactive
                    ? 'Akun ${widget.account.name} sedang tidak aktif. Hubungi admin KOMPAK untuk informasi lebih lanjut.'
                    : rejected
                    ? 'Periksa kembali data ${widget.account.name}, lalu kirim ulang untuk diverifikasi admin.'
                    : 'Data ${widget.account.name} telah diterima dan sedang diperiksa oleh admin KOMPAK.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: KompakColors.mutedInk,
                  fontSize: 15,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 36),
              FilledButton(
                onPressed: rejected
                    ? () => setState(() => _editing = true)
                    : () => context.router.replaceAll([const MainRoute()]),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  backgroundColor: KompakColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  rejected ? 'Perbaiki Pendaftaran' : 'Kembali ke Akun Warga',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ProviderDashboardView extends StatefulWidget {
  const ProviderDashboardView({
    required this.state,
    required this.onRefresh,
    required this.onSearch,
    super.key,
  });

  final ProviderReady state;
  final Future<void> Function() onRefresh;
  final Future<void> Function(String) onSearch;

  @override
  State<ProviderDashboardView> createState() => _ProviderDashboardViewState();
}

class _ProviderDashboardViewState extends State<ProviderDashboardView> {
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final account = widget.state.account;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: widget.onRefresh,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(22, 18, 22, 110),
            children: [
              Row(
                children: [
                  Expanded(
                    child: SvgPicture.asset(
                      'assets/images/brand_logo_blue.svg',
                      height: 48,
                      alignment: Alignment.centerLeft,
                    ),
                  ),
                  IconButton.filled(
                    onPressed: () {},
                    icon: const Icon(Icons.notifications_none_rounded),
                    style: IconButton.styleFrom(
                      backgroundColor: KompakColors.primary,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: () => context.router.push(
                      ProviderProfileRoute(account: account),
                    ),
                    child: _ProviderLogo(account: account, size: 46),
                  ),
                ],
              ),
              const SizedBox(height: 38),
              Text(
                'Halo, ${account.name}',
                style: const TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.w700,
                  color: KompakColors.ink,
                ),
              ),
              const SizedBox(height: 5),
              const Text(
                'Kelola produk dan kontribusi usaha Anda.',
                style: TextStyle(color: KompakColors.mutedInk, fontSize: 14),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      color: KompakColors.primary,
                      icon: Icons.stars_rounded,
                      label: 'TRANSAKSI POIN',
                      value: NumberFormat.decimalPattern(
                        'id_ID',
                      ).format(account.stats.completedPoints),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      color: KompakColors.success,
                      icon: Icons.inventory_2_outlined,
                      label: 'PRODUK AKTIF',
                      value: '${account.stats.activeProducts}',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 26),
              TextField(
                key: const ValueKey('provider-product-search'),
                onChanged: (value) {
                  _debounce?.cancel();
                  _debounce = Timer(
                    const Duration(milliseconds: 350),
                    () => widget.onSearch(value),
                  );
                },
                decoration: _decoration(label: '', hint: 'Cari produk')
                    .copyWith(
                      prefixIcon: const Icon(Icons.search_rounded),
                      suffixIcon: const Icon(Icons.tune_rounded),
                    ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Produk Anda',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                  ),
                  Text(
                    '${widget.state.products.length} produk',
                    style: const TextStyle(color: KompakColors.mutedInk),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              if (widget.state.loadingProducts)
                const Center(child: CircularProgressIndicator())
              else if (widget.state.products.isEmpty)
                _EmptyProducts(
                  onAdd: () => _openProductForm(context, account.id),
                )
              else
                ...widget.state.products.map(
                  (product) => Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: _ProductCard(
                      product: product,
                      onEdit: () => _openProductForm(
                        context,
                        account.id,
                        product: product,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        key: const ValueKey('provider-add-product'),
        onPressed: () => _openProductForm(context, account.id),
        backgroundColor: KompakColors.success,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add_rounded),
      ),
    );
  }

  Future<void> _openProductForm(
    BuildContext context,
    String providerId, {
    ProviderProduct? product,
  }) async {
    final changed = await context.router.push<bool>(
      ProviderProductFormRoute(providerId: providerId, product: product),
    );
    if (changed == true) await widget.onRefresh();
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({required this.product, required this.onEdit});
  final ProviderProduct product;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: KompakColors.outline),
    ),
    child: Row(
      children: [
        Container(
          width: 88,
          height: 88,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: KompakColors.primarySurface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: product.imageUrl == null
              ? const Icon(
                  Icons.card_giftcard_rounded,
                  color: KompakColors.primary,
                  size: 36,
                )
              : Image.network(
                  product.imageUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => const Icon(Icons.image_outlined),
                ),
        ),
        const SizedBox(width: 13),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: product.isActive
                      ? KompakColors.success
                      : KompakColors.warningSurface,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  product.isActive ? 'ACTIVE' : 'PENDING',
                  style: TextStyle(
                    color: product.isActive
                        ? Colors.white
                        : KompakColors.warning,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 7),
              Text(
                product.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                '${product.pointsRequired} Poin  •  Stok ${product.stock}',
                style: const TextStyle(
                  color: KompakColors.mutedInk,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 7),
              InkWell(
                onTap: onEdit,
                child: const Text(
                  'Edit Produk',
                  style: TextStyle(
                    color: KompakColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _EmptyProducts extends StatelessWidget {
  const _EmptyProducts({required this.onAdd});
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onAdd,
    borderRadius: BorderRadius.circular(16),
    child: Container(
      height: 210,
      decoration: BoxDecoration(
        color: KompakColors.softSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: KompakColors.primaryBorder),
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.add_business_rounded,
            size: 46,
            color: KompakColors.primary,
          ),
          SizedBox(height: 12),
          Text(
            'Belum ada produk',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          SizedBox(height: 5),
          Text(
            'Tambahkan produk pertama Anda',
            style: TextStyle(color: KompakColors.mutedInk),
          ),
        ],
      ),
    ),
  );
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.color,
    required this.icon,
    required this.label,
    required this.value,
  });
  final Color color;
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Container(
    height: 132,
    padding: const EdgeInsets.all(15),
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(18),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.white),
        const Spacer(),
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 11)),
        const SizedBox(height: 3),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    ),
  );
}

class _ProviderFailureView extends StatelessWidget {
  const _ProviderFailureView({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: _providerAppBar('Provider'),
    body: Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.storefront_outlined, size: 52),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 18),
            FilledButton(onPressed: onRetry, child: const Text('Coba Lagi')),
          ],
        ),
      ),
    ),
  );
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: const Color(0xFFE8E9EC)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
        ),
        const SizedBox(height: 16),
        child,
      ],
    ),
  );
}

class _BottomAction extends StatelessWidget {
  const _BottomAction({
    required this.label,
    required this.busy,
    required this.onPressed,
  });
  final String label;
  final bool busy;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => SafeArea(
    top: false,
    child: Container(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 12),
      color: Colors.white,
      child: FilledButton(
        key: const ValueKey('provider-submit'),
        onPressed: busy ? null : onPressed,
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
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
            : Text(label),
      ),
    ),
  );
}

class _ProviderLogo extends StatelessWidget {
  const _ProviderLogo({required this.account, required this.size});
  final ProviderAccount account;
  final double size;

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    clipBehavior: Clip.antiAlias,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: KompakColors.primarySurface,
      border: Border.all(color: KompakColors.success, width: 3),
    ),
    child: account.logoUrl == null
        ? Center(
            child: Text(
              account.name.isEmpty ? '?' : account.name[0].toUpperCase(),
              style: const TextStyle(
                color: KompakColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          )
        : Image.network(
            account.logoUrl!,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => const Icon(Icons.storefront_outlined),
          ),
  );
}

class _UploadLogo extends StatelessWidget {
  const _UploadLogo();
  @override
  Widget build(BuildContext context) => const Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Icon(Icons.add_a_photo_outlined, color: KompakColors.primary, size: 30),
      SizedBox(height: 5),
      Text(
        'Tambah Logo',
        style: TextStyle(color: KompakColors.primary, fontSize: 11),
      ),
    ],
  );
}

PreferredSizeWidget _providerAppBar(String title) => AppBar(
  backgroundColor: Colors.white,
  surfaceTintColor: Colors.transparent,
  centerTitle: true,
  title: Text(
    title,
    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
  ),
);

Widget _readOnlyField(String label, String value) => InputDecorator(
  decoration: _decoration(label: label, hint: ''),
  child: Text(value, style: const TextStyle(color: KompakColors.mutedInk)),
);

InputDecoration _decoration({required String label, required String hint}) =>
    InputDecoration(
      labelText: label.isEmpty ? null : label,
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
        borderSide: const BorderSide(color: KompakColors.primary, width: 1.5),
      ),
    );

String? Function(String?) _required(String message) =>
    (value) => value == null || value.trim().isEmpty ? message : null;

String _mimeFromName(String name) =>
    name.toLowerCase().endsWith('.png') ? 'image/png' : 'image/jpeg';
