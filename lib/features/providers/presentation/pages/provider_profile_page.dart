import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/routes/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/session/session_cubit.dart';
import '../../domain/entities/provider_account.dart';

@RoutePage()
class ProviderProfilePage extends StatelessWidget {
  const ProviderProfilePage({required this.account, super.key});
  final ProviderAccount account;

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.white,
    appBar: AppBar(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      centerTitle: true,
      title: const Text(
        'Detail Provider',
        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
      ),
    ),
    body: ListView(
      padding: const EdgeInsets.fromLTRB(22, 12, 22, 140),
      children: [
        _ProviderHero(account: account),
        const SizedBox(height: 18),
        _InformationCard(account: account),
        const SizedBox(height: 18),
        Row(
          children: [
            Expanded(
              child: _ProfileStat(
                label: 'POIN TRANSAKSI',
                value: NumberFormat.decimalPattern(
                  'id_ID',
                ).format(account.stats.completedPoints),
                color: KompakColors.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ProfileStat(
                label: 'PRODUK AKTIF',
                value: '${account.stats.activeProducts}',
                color: KompakColors.success,
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: SizedBox(
            height: 190,
            child: FlutterMap(
              options: MapOptions(
                initialCenter: LatLng(account.latitude, account.longitude),
                initialZoom: 15,
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
                      point: LatLng(account.latitude, account.longitude),
                      width: 44,
                      height: 44,
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
        const SizedBox(height: 22),
        const Text(
          'Produk Provider',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        if (account.products.where((item) => item.isActive).isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: KompakColors.softSurface,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Text(
              'Belum ada produk aktif.',
              textAlign: TextAlign.center,
              style: TextStyle(color: KompakColors.mutedInk),
            ),
          )
        else
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: .85,
            children: account.products
                .where((item) => item.isActive)
                .map((product) => _ProfileProduct(product: product))
                .toList(growable: false),
          ),
      ],
    ),
    bottomNavigationBar: SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 10, 24, 10),
        color: Colors.white,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FilledButton.icon(
              onPressed: () =>
                  context.router.root.replaceAll([const MainRoute()]),
              icon: const Icon(Icons.home_outlined),
              label: const Text('Beralih ke Akun Warga'),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
                backgroundColor: KompakColors.primary,
              ),
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: () => context.read<SessionCubit>().logout(),
              icon: const Icon(Icons.logout_rounded),
              label: const Text('Log out'),
              style: TextButton.styleFrom(foregroundColor: KompakColors.error),
            ),
          ],
        ),
      ),
    ),
  );
}

class _ProviderHero extends StatelessWidget {
  const _ProviderHero({required this.account});
  final ProviderAccount account;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Container(
        width: 116,
        height: 116,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: KompakColors.primarySurface,
          border: Border.all(color: KompakColors.success, width: 3),
        ),
        child: account.logoUrl == null
            ? const Icon(
                Icons.storefront_rounded,
                color: KompakColors.primary,
                size: 48,
              )
            : Image.network(account.logoUrl!, fit: BoxFit.cover),
      ),
      const SizedBox(height: 12),
      Text(
        account.name,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
      ),
      const SizedBox(height: 5),
      Text(
        account.address,
        textAlign: TextAlign.center,
        style: const TextStyle(color: KompakColors.mutedInk),
      ),
    ],
  );
}

class _InformationCard extends StatelessWidget {
  const _InformationCard({required this.account});
  final ProviderAccount account;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      border: Border.all(color: KompakColors.outline),
      borderRadius: BorderRadius.circular(16),
    ),
    child: Column(
      children: [
        _row(Icons.verified_outlined, 'Status', 'Terverifikasi'),
        _row(Icons.person_outline, 'Pemilik', account.owner.name),
        _row(Icons.phone_outlined, 'Kontak', account.owner.phoneNumber),
        _row(
          Icons.calendar_today_outlined,
          'Bergabung',
          _indonesianDate(account.createdAt),
          last: true,
        ),
      ],
    ),
  );

  Widget _row(IconData icon, String label, String value, {bool last = false}) =>
      Padding(
        padding: EdgeInsets.only(bottom: last ? 0 : 14),
        child: Row(
          children: [
            Icon(icon, size: 20, color: KompakColors.primary),
            const SizedBox(width: 12),
            Text(label, style: const TextStyle(color: KompakColors.mutedInk)),
            const Spacer(),
            Flexible(
              child: Text(
                value,
                textAlign: TextAlign.end,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      );
}

class _ProfileStat extends StatelessWidget {
  const _ProfileStat({
    required this.label,
    required this.value,
    required this.color,
  });
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    height: 105,
    padding: const EdgeInsets.all(15),
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(16),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 11)),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 23,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    ),
  );
}

class _ProfileProduct extends StatelessWidget {
  const _ProfileProduct({required this.product});
  final ProviderProduct product;

  @override
  Widget build(BuildContext context) => Container(
    clipBehavior: Clip.antiAlias,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: KompakColors.outline),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Container(
            width: double.infinity,
            color: KompakColors.primarySurface,
            child: product.imageUrl == null
                ? const Icon(
                    Icons.card_giftcard_rounded,
                    color: KompakColors.primary,
                  )
                : Image.network(product.imageUrl!, fit: BoxFit.cover),
          ),
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
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              Text(
                '${product.pointsRequired} Poin',
                style: const TextStyle(
                  color: KompakColors.warning,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

String _indonesianDate(DateTime date) {
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
  return '${date.day} ${months[date.month - 1]} ${date.year}';
}
