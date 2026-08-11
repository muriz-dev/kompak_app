import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/store_data.dart';

class RewardImage extends StatelessWidget {
  const RewardImage({
    super.key,
    required this.item,
    required this.height,
    this.borderRadius = BorderRadius.zero,
  });

  final StoreItem item;
  final double height;
  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) {
    final fallback = Container(
      height: height,
      width: double.infinity,
      color: KompakColors.primarySurface,
      alignment: Alignment.center,
      child: Icon(
        _iconFor(item.imageUrlOrIcon),
        size: 44,
        color: KompakColors.primary,
      ),
    );

    return ClipRRect(
      borderRadius: borderRadius,
      child: item.itemType == ItemType.image
          ? Image.network(
              item.imageUrlOrIcon,
              height: height,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => fallback,
            )
          : fallback,
    );
  }
}

class ProviderLogo extends StatelessWidget {
  const ProviderLogo({
    super.key,
    required this.provider,
    this.size = 32,
    this.showBorder = true,
  });

  final RewardProvider provider;
  final double size;
  final bool showBorder;

  @override
  Widget build(BuildContext context) {
    final logoUrl = provider.logoUrl;
    return Container(
      width: size,
      height: size,
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: showBorder
            ? Border.all(color: KompakColors.success, width: 2)
            : null,
      ),
      child: ClipOval(
        child: logoUrl != null && logoUrl.isNotEmpty
            ? Image.network(
                logoUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => const _ProviderLogoFallback(),
              )
            : const _ProviderLogoFallback(),
      ),
    );
  }
}

class _ProviderLogoFallback extends StatelessWidget {
  const _ProviderLogoFallback();

  @override
  Widget build(BuildContext context) => const ColoredBox(
    color: KompakColors.successSurface,
    child: Center(
      child: Icon(
        Icons.storefront_outlined,
        color: KompakColors.success,
        size: 18,
      ),
    ),
  );
}

IconData _iconFor(String iconName) => switch (iconName) {
  'delete_outline' => Icons.delete_outline,
  'bolt' => Icons.bolt,
  'confirmation_number_outlined' => Icons.confirmation_number_outlined,
  'redeem_outlined' => Icons.redeem_outlined,
  'handyman_outlined' => Icons.handyman_outlined,
  _ => Icons.card_giftcard,
};
