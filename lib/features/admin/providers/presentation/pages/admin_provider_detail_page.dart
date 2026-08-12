import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';

import '../../../../../core/config/app_config.dart';
import '../../../../../core/di/injection.dart';
import '../../../../../core/routes/app_router.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../domain/entities/admin_provider.dart';
import '../bloc/admin_provider_detail_cubit.dart';
import '../bloc/admin_provider_detail_state.dart';
import '../widgets/admin_provider_visuals.dart';

@RoutePage()
class AdminProviderDetailPage extends StatelessWidget {
  const AdminProviderDetailPage({
    @PathParam('providerId') required this.providerId,
    super.key,
  });

  final String providerId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<AdminProviderDetailCubit>()..load(providerId),
      child: _AdminProviderDetailView(providerId: providerId),
    );
  }
}

class _AdminProviderDetailView extends StatelessWidget {
  const _AdminProviderDetailView({required this.providerId});

  final String providerId;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AdminProviderDetailCubit, AdminProviderDetailState>(
      listenWhen: (previous, current) =>
          current is AdminProviderDetailLoaded &&
          current.actionError != null &&
          (previous is! AdminProviderDetailLoaded ||
              previous.actionError != current.actionError),
      listener: (context, state) {
        if (state case AdminProviderDetailLoaded(actionError: final error?)) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(error)));
        }
      },
      builder: (context, state) {
        final provider = state is AdminProviderDetailLoaded
            ? state.detail.provider
            : null;
        final title = provider?.status == AdminProviderStatus.pending
            ? 'Verifikasi Provider'
            : 'Detail Provider';

        return Scaffold(
          backgroundColor: const Color(0xFFFEFFFF),
          appBar: AppBar(
            backgroundColor: const Color(0xFFFEFFFF),
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              onPressed: () => context.router.maybePop(),
              icon: const Icon(Icons.chevron_left_rounded, size: 28),
            ),
            title: Text(
              title,
              style: const TextStyle(
                color: Color(0xFF2F3236),
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            centerTitle: true,
          ),
          body: switch (state) {
            AdminProviderDetailLoaded() => _ProviderDetailContent(state: state),
            AdminProviderDetailFailure() => _DetailFailure(
              message: state.message,
              onRetry: () =>
                  context.read<AdminProviderDetailCubit>().load(providerId),
            ),
            _ => const Center(child: CircularProgressIndicator()),
          },
        );
      },
    );
  }
}

class _ProviderDetailContent extends StatelessWidget {
  const _ProviderDetailContent({required this.state});

  final AdminProviderDetailLoaded state;

  @override
  Widget build(BuildContext context) {
    final detail = state.detail;
    final provider = detail.provider;
    final activeProducts = detail.products
        .where((product) => product.status == 'ACTIVE')
        .toList(growable: false);

    return RefreshIndicator(
      onRefresh: context.read<AdminProviderDetailCubit>().refresh,
      child: ListView(
        key: const ValueKey('admin-provider-detail-scroll'),
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
        children: [
          _ProviderIdentityCard(provider: provider),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _MetricCard(
                  color: KompakColors.primary,
                  label: 'Transaksi Point',
                  value: NumberFormat.decimalPattern(
                    'id_ID',
                  ).format(detail.stats.completedPoints),
                  unit: 'Points',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _MetricCard(
                  color: KompakColors.success,
                  label: 'Produk Aktif',
                  value: '${detail.stats.activeProducts}',
                  unit: 'Produk',
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _ProviderMap(provider: provider),
          if (provider.status == AdminProviderStatus.verified) ...[
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: () => context.router.push(
                AdminPointShopRoute(
                  providerId: provider.id,
                  providerName: provider.name,
                ),
              ),
              icon: const Icon(Icons.storefront_outlined),
              label: const Text('Kelola Produk Toko Poin'),
              style: OutlinedButton.styleFrom(
                foregroundColor: KompakColors.success,
                side: const BorderSide(color: KompakColors.success),
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
          if (provider.status == AdminProviderStatus.verified &&
              activeProducts.isNotEmpty) ...[
            const SizedBox(height: 24),
            const Text(
              'Produk Provider',
              style: TextStyle(
                color: Color(0xFF2F3236),
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.9,
              ),
              itemCount: activeProducts.length,
              itemBuilder: (_, index) =>
                  _ProviderProductCard(product: activeProducts[index]),
            ),
          ],
          const SizedBox(height: 24),
          _ProviderActions(provider: provider, updating: state.updating),
        ],
      ),
    );
  }
}

class _ProviderIdentityCard extends StatelessWidget {
  const _ProviderIdentityCard({required this.provider});

  final AdminProviderSummary provider;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFF1F1F2)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AdminProviderStorePhoto(
            photoUrl: provider.storePhotoUrl,
            name: provider.name,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              AdminProviderLogo(
                name: provider.name,
                logoUrl: provider.logoUrl,
                size: 56,
                backgroundColor: KompakColors.primary,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      provider.name,
                      style: const TextStyle(
                        color: Color(0xFF2F3236),
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      provider.address,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF8D9199),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(height: 1, color: Color(0xFFF1F1F2)),
          ),
          const Text(
            'Status',
            style: TextStyle(color: Color(0xFF8D9199), fontSize: 13),
          ),
          const SizedBox(height: 5),
          Align(
            alignment: Alignment.centerLeft,
            child: AdminProviderStatusChip(status: provider.status),
          ),
          const SizedBox(height: 14),
          _InfoRow(
            label: 'Kontak',
            icon: Icons.phone_outlined,
            value: provider.owner?.phoneNumber.isNotEmpty == true
                ? provider.owner!.phoneNumber
                : 'Tidak tersedia',
          ),
          const SizedBox(height: 12),
          _InfoRow(
            label: 'Bergabung',
            icon: Icons.calendar_today_outlined,
            value: _joinedLabel(provider.createdAt),
          ),
        ],
      ),
    );
  }

  String _joinedLabel(DateTime date) {
    const months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    if (date.millisecondsSinceEpoch == 0) return 'Tidak tersedia';
    return 'Sejak ${months[date.month - 1]} ${date.year}';
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.icon,
    required this.value,
  });

  final String label;
  final IconData icon;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Color(0xFF8D9199), fontSize: 13),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Icon(icon, color: KompakColors.primary, size: 18),
            const SizedBox(width: 7),
            Expanded(
              child: Text(
                value,
                style: const TextStyle(color: Color(0xFF2F3236), fontSize: 13),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.color,
    required this.label,
    required this.value,
    required this.unit,
  });

  final Color color;
  final String label;
  final String value;
  final String unit;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 112,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: value,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 27,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  TextSpan(
                    text: ' $unit',
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProviderMap extends StatelessWidget {
  const _ProviderMap({required this.provider});

  final AdminProviderSummary provider;

  @override
  Widget build(BuildContext context) {
    final point = LatLng(provider.latitude, provider.longitude);
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        height: 150,
        child: FlutterMap(
          options: MapOptions(
            initialCenter: point,
            initialZoom: 14,
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.none,
            ),
          ),
          children: [
            TileLayer(
              urlTemplate: AppConfig.mapTileUrl,
              userAgentPackageName: AppConfig.mapUserAgentPackageName,
            ),
            MarkerLayer(
              markers: [
                Marker(
                  point: point,
                  width: 44,
                  height: 44,
                  child: Container(
                    decoration: BoxDecoration(
                      color: KompakColors.success,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x33000000),
                          blurRadius: 8,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.location_on_outlined,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ProviderProductCard extends StatelessWidget {
  const _ProviderProductCard({required this.product});

  final AdminProviderProduct product;

  @override
  Widget build(BuildContext context) {
    final imageUrl = product.imageUrl;
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFF1F1F2)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: imageUrl != null && imageUrl.isNotEmpty
                ? Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => _productFallback(),
                  )
                : _productFallback(),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF2F3236),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(
                      Icons.stars_rounded,
                      color: Color(0xFFF79009),
                      size: 15,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      NumberFormat.decimalPattern(
                        'id_ID',
                      ).format(product.pointsRequired),
                      style: const TextStyle(
                        color: Color(0xFFF79009),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _productFallback() => const ColoredBox(
    color: Color(0xFFE5EEFF),
    child: Center(
      child: Icon(
        Icons.card_giftcard_rounded,
        color: KompakColors.primary,
        size: 40,
      ),
    ),
  );
}

class _ProviderActions extends StatelessWidget {
  const _ProviderActions({required this.provider, required this.updating});

  final AdminProviderSummary provider;
  final bool updating;

  @override
  Widget build(BuildContext context) {
    return switch (provider.status) {
      AdminProviderStatus.pending => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _ActionButton(
            key: const ValueKey('verify-provider-button'),
            label: 'Verifikasi sekarang',
            color: KompakColors.success,
            loading: updating,
            onPressed: () => _confirmStatus(
              context,
              AdminProviderStatus.verified,
              title: 'Verifikasi provider?',
              message:
                  '${provider.name} akan dapat menawarkan produk setelah diverifikasi.',
              successMessage: 'Provider berhasil diverifikasi.',
            ),
          ),
          const SizedBox(height: 10),
          _ActionButton(
            key: const ValueKey('reject-provider-button'),
            label: 'Tolak Provider',
            color: KompakColors.errorSurface,
            foregroundColor: KompakColors.error,
            loading: updating,
            onPressed: () => _confirmStatus(
              context,
              AdminProviderStatus.rejected,
              title: 'Tolak provider?',
              message: 'Pendaftaran ${provider.name} akan ditolak.',
              successMessage: 'Pendaftaran provider ditolak.',
              popAfterSuccess: true,
            ),
          ),
        ],
      ),
      AdminProviderStatus.verified => _ActionButton(
        key: const ValueKey('archive-provider-button'),
        label: 'Hapus Provider',
        color: KompakColors.errorSurface,
        foregroundColor: KompakColors.error,
        loading: updating,
        onPressed: () => _confirmStatus(
          context,
          AdminProviderStatus.inactive,
          title: 'Nonaktifkan provider?',
          message:
              '${provider.name} akan dihapus dari katalog aktif. Riwayat transaksi tetap tersimpan.',
          successMessage: 'Provider berhasil dinonaktifkan.',
          popAfterSuccess: true,
        ),
      ),
      AdminProviderStatus.rejected => _ActionButton(
        label: 'Verifikasi Provider',
        color: KompakColors.primary,
        loading: updating,
        onPressed: () => _confirmStatus(
          context,
          AdminProviderStatus.verified,
          title: 'Verifikasi provider?',
          message: '${provider.name} akan diaktifkan sebagai provider.',
          successMessage: 'Provider berhasil diverifikasi.',
        ),
      ),
      AdminProviderStatus.inactive => _ActionButton(
        label: 'Aktifkan Kembali',
        color: KompakColors.primary,
        loading: updating,
        onPressed: () => _confirmStatus(
          context,
          AdminProviderStatus.verified,
          title: 'Aktifkan provider?',
          message:
              '${provider.name} akan kembali tampil sebagai provider aktif.',
          successMessage: 'Provider berhasil diaktifkan.',
        ),
      ),
    };
  }

  Future<void> _confirmStatus(
    BuildContext context,
    AdminProviderStatus status, {
    required String title,
    required String message,
    required String successMessage,
    bool popAfterSuccess = false,
  }) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Konfirmasi'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    final success = await context.read<AdminProviderDetailCubit>().updateStatus(
      status,
    );
    if (!context.mounted || !success) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(successMessage)));
    if (popAfterSuccess) await context.router.maybePop();
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    super.key,
    required this.label,
    required this.color,
    required this.loading,
    required this.onPressed,
    this.foregroundColor = Colors.white,
  });

  final String label;
  final Color color;
  final Color foregroundColor;
  final bool loading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 46,
      child: FilledButton(
        onPressed: loading ? null : onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: color,
          foregroundColor: foregroundColor,
          disabledBackgroundColor: color.withValues(alpha: 0.55),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: loading
            ? SizedBox.square(
                dimension: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: foregroundColor,
                ),
              )
            : Text(label, style: const TextStyle(fontSize: 16)),
      ),
    );
  }
}

class _DetailFailure extends StatelessWidget {
  const _DetailFailure({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_rounded, size: 44),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(onPressed: onRetry, child: const Text('Coba Lagi')),
          ],
        ),
      ),
    );
  }
}
