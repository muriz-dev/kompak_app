import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/routes/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/session/session_cubit.dart';
import '../../domain/entities/store_data.dart';
import '../bloc/redeem_cubit.dart';
import '../widgets/reward_redemption_dialog.dart';
import '../widgets/reward_visuals.dart';

@RoutePage()
class RedeemConfirmationPage extends StatelessWidget {
  const RedeemConfirmationPage({
    super.key,
    required this.item,
    required this.availablePoints,
  });

  final StoreItem item;
  final int availablePoints;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<RedeemCubit>(),
      child: _RedeemConfirmationView(
        item: item,
        availablePoints: availablePoints,
      ),
    );
  }
}

class _RedeemConfirmationView extends StatelessWidget {
  const _RedeemConfirmationView({
    required this.item,
    required this.availablePoints,
  });

  final StoreItem item;
  final int availablePoints;

  @override
  Widget build(BuildContext context) {
    final remainingPoints = availablePoints - item.points;
    final canRedeem = remainingPoints >= 0 && item.stock > 0;

    return BlocConsumer<RedeemCubit, RedeemState>(
      listener: (context, state) async {
        if (state is RedeemFailed) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(state.message)));
          return;
        }
        if (state is! RedeemSucceeded) return;

        context.read<SessionCubit>().updateBalance(state.redemption.balance);

        final action = await showDialog<RedemptionDialogAction>(
          context: context,
          barrierDismissible: false,
          builder: (_) => RewardRedemptionDialog(
            redemption: state.redemption,
            createdNow: true,
          ),
        );
        if (!context.mounted) return;

        switch (action) {
          case RedemptionDialogAction.home:
            context.router.replaceAll([
              MainRoute(children: [const HomeRoute()]),
            ]);
          case RedemptionDialogAction.history:
            context.router.replaceAll([
              MainRoute(children: [const StoreRoute()]),
              const PointHistoryRoute(),
            ]);
          case RedemptionDialogAction.close:
          case null:
            context.router.maybePop(true);
        }
      },
      builder: (context, state) {
        final isSubmitting = state is RedeemSubmitting;
        return Scaffold(
          backgroundColor: KompakColors.surface,
          appBar: AppBar(
            backgroundColor: KompakColors.surface,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              tooltip: 'Kembali',
              icon: const Icon(
                Icons.chevron_left,
                color: KompakColors.ink,
                size: 28,
              ),
              onPressed: isSubmitting ? null : () => context.router.maybePop(),
            ),
            title: const Text(
              'Konfirmasi Penukaran',
              style: TextStyle(
                color: KompakColors.ink,
                fontWeight: FontWeight.w600,
                fontSize: 20,
              ),
            ),
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _RewardSummary(item: item),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _PointsSummary(
                        label: 'Poin Anda',
                        points: availablePoints,
                        color: KompakColors.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _PointsSummary(
                        label: 'Sisa Poin',
                        points: remainingPoints.clamp(0, availablePoints),
                        color: canRedeem
                            ? KompakColors.success
                            : KompakColors.error,
                      ),
                    ),
                  ],
                ),
                if (!canRedeem) ...[
                  const SizedBox(height: 10),
                  Text(
                    item.stock <= 0
                        ? 'Hadiah ini sudah habis.'
                        : 'Poin Anda belum cukup untuk hadiah ini.',
                    style: const TextStyle(
                      color: KompakColors.error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
                const SizedBox(height: 18),
                const Text(
                  'Lokasi Pengambilan',
                  style: TextStyle(
                    color: KompakColors.ink,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 8),
                _PickupLocation(provider: item.provider),
                const SizedBox(height: 14),
                _PickupMap(provider: item.provider),
                const SizedBox(height: 16),
                _TermsCard(item: item),
              ],
            ),
          ),
          bottomNavigationBar: _ConfirmationActions(
            enabled: canRedeem && !isSubmitting,
            isSubmitting: isSubmitting,
            onConfirm: () => context.read<RedeemCubit>().redeem(item),
            onCancel: () => context.router.maybePop(),
          ),
        );
      },
    );
  }
}

class _RewardSummary extends StatelessWidget {
  const _RewardSummary({required this.item});

  final StoreItem item;

  @override
  Widget build(BuildContext context) => Container(
    clipBehavior: Clip.antiAlias,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: const [
        BoxShadow(
          color: Color(0x120A0D12),
          blurRadius: 8,
          offset: Offset(0, 3),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          children: [
            RewardImage(item: item, height: 155),
            if (item.isFeatured)
              Positioned(
                top: 10,
                left: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: KompakColors.success,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'TERPOPULER',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            Positioned(
              top: 10,
              right: 10,
              child: ProviderLogo(provider: item.provider, size: 42),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      item.title,
                      style: const TextStyle(
                        color: KompakColors.ink,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.stars_rounded,
                    color: KompakColors.warning,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${item.points}',
                    style: const TextStyle(
                      color: KompakColors.warning,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              if (item.description.isNotEmpty) ...[
                const SizedBox(height: 5),
                Text(
                  item.description,
                  style: const TextStyle(
                    color: KompakColors.mutedInk,
                    fontSize: 13,
                    height: 1.35,
                  ),
                ),
              ],
              const SizedBox(height: 5),
              Text(
                'Stok ${item.stock}',
                style: const TextStyle(
                  color: KompakColors.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _PointsSummary extends StatelessWidget {
  const _PointsSummary({
    required this.label,
    required this.points,
    required this.color,
  });

  final String label;
  final int points;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    height: 78,
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(10),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
        const Spacer(),
        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: NumberFormat.decimalPattern('id_ID').format(points),
                style: const TextStyle(fontSize: 23),
              ),
              const TextSpan(text: ' Poin', style: TextStyle(fontSize: 11)),
            ],
          ),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    ),
  );
}

class _PickupLocation extends StatelessWidget {
  const _PickupLocation({required this.provider});

  final RewardProvider provider;

  @override
  Widget build(BuildContext context) {
    final photoUrl = provider.storePhotoUrl;
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE8EAEE)),
      ),
      child: Column(
        children: [
          if (photoUrl != null && photoUrl.isNotEmpty)
            Image.network(
              photoUrl,
              width: double.infinity,
              height: 112,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => const _StorePhotoFallback(),
            )
          else
            const _StorePhotoFallback(),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: KompakColors.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.storefront_outlined,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        provider.name,
                        style: const TextStyle(
                          color: KompakColors.ink,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        provider.address,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: KompakColors.mutedInk,
                          fontSize: 11,
                          height: 1.3,
                        ),
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
}

class _StorePhotoFallback extends StatelessWidget {
  const _StorePhotoFallback();

  @override
  Widget build(BuildContext context) => const SizedBox(
    height: 112,
    width: double.infinity,
    child: ColoredBox(
      color: KompakColors.primarySurface,
      child: Center(
        child: Icon(
          Icons.storefront_outlined,
          color: KompakColors.primary,
          size: 42,
        ),
      ),
    ),
  );
}

class _PickupMap extends StatelessWidget {
  const _PickupMap({required this.provider});

  final RewardProvider provider;

  @override
  Widget build(BuildContext context) {
    final point = LatLng(provider.latitude, provider.longitude);
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        height: 160,
        child: Stack(
          children: [
            Positioned.fill(
              child: IgnorePointer(
                child: FlutterMap(
                  options: MapOptions(initialCenter: point, initialZoom: 15.5),
                  children: [
                    TileLayer(
                      urlTemplate: AppConfig.mapTileUrl,
                      userAgentPackageName: AppConfig.mapUserAgentPackageName,
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: point,
                          width: 46,
                          height: 46,
                          child: const Icon(
                            Icons.location_pin,
                            color: KompakColors.primary,
                            size: 44,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const Positioned(
              left: 12,
              bottom: 12,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: KompakColors.success,
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                  child: Icon(
                    Icons.map_outlined,
                    color: Colors.white,
                    size: 21,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TermsCard extends StatelessWidget {
  const _TermsCard({required this.item});

  final StoreItem item;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: KompakColors.success,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.info_outline, color: Colors.white, size: 20),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Syarat & Ketentuan',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Penukaran tidak dapat dibatalkan setelah dikonfirmasi. QR berlaku ${item.validityDays} hari dan ditunjukkan kepada ${item.provider.name}. Poin dikembalikan otomatis bila penukaran kedaluwarsa atau ditolak.',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _ConfirmationActions extends StatelessWidget {
  const _ConfirmationActions({
    required this.enabled,
    required this.isSubmitting,
    required this.onConfirm,
    required this.onCancel,
  });

  final bool enabled;
  final bool isSubmitting;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
    decoration: const BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      boxShadow: [
        BoxShadow(
          color: Color(0x120A0D12),
          blurRadius: 8,
          offset: Offset(0, -3),
        ),
      ],
    ),
    child: SafeArea(
      top: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton(
              onPressed: enabled ? onConfirm : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: KompakColors.primary,
                disabledBackgroundColor: KompakColors.primaryDisabled,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Konfirmasi Penukaran'),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: TextButton(
              onPressed: isSubmitting ? null : onCancel,
              style: TextButton.styleFrom(
                backgroundColor: KompakColors.errorSurface,
                foregroundColor: KompakColors.error,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Batalkan Penukaran'),
            ),
          ),
        ],
      ),
    ),
  );
}
