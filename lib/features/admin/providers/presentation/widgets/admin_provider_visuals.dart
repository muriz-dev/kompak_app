import 'package:flutter/material.dart';

import '../../domain/entities/admin_provider.dart';

class AdminProviderStatusChip extends StatelessWidget {
  const AdminProviderStatusChip({super.key, required this.status});

  final AdminProviderStatus status;

  @override
  Widget build(BuildContext context) {
    final (color, label, icon) = switch (status) {
      AdminProviderStatus.verified => (
        const Color(0xFF12B76A),
        'Verified',
        Icons.check_circle_rounded,
      ),
      AdminProviderStatus.pending => (const Color(0xFFF79009), 'Pending', null),
      AdminProviderStatus.rejected => (
        const Color(0xFFF04438),
        'Ditolak',
        Icons.cancel_rounded,
      ),
      AdminProviderStatus.inactive => (
        const Color(0xFF8D9199),
        'Nonaktif',
        Icons.pause_circle_filled_rounded,
      ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: Colors.white),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class AdminProviderLogo extends StatelessWidget {
  const AdminProviderLogo({
    super.key,
    required this.name,
    required this.logoUrl,
    this.size = 56,
    this.backgroundColor = const Color(0xFFE7F8F0),
  });

  final String name;
  final String? logoUrl;
  final double size;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    final url = logoUrl;
    return ClipRRect(
      borderRadius: BorderRadius.circular(9),
      child: SizedBox.square(
        dimension: size,
        child: url != null && url.isNotEmpty
            ? Image.network(
                url,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => _fallback(),
              )
            : _fallback(),
      ),
    );
  }

  Widget _fallback() => ColoredBox(
    color: backgroundColor,
    child: const Center(
      child: Icon(
        Icons.storefront_outlined,
        color: Color(0xFF12B76A),
        size: 30,
      ),
    ),
  );
}

class AdminProviderStorePhoto extends StatelessWidget {
  const AdminProviderStorePhoto({
    super.key,
    required this.photoUrl,
    required this.name,
    this.height = 160,
  });

  final String? photoUrl;
  final String name;
  final double height;

  @override
  Widget build(BuildContext context) {
    final url = photoUrl;
    return ClipRRect(
      borderRadius: BorderRadius.circular(9),
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: url != null && url.isNotEmpty
            ? Image.network(
                url,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => _fallback(),
              )
            : _fallback(),
      ),
    );
  }

  Widget _fallback() => ColoredBox(
    color: const Color(0xFFE5EEFF),
    child: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.store_mall_directory_outlined,
            size: 46,
            color: Color(0xFF2563EB),
          ),
          const SizedBox(height: 8),
          Text(
            name,
            style: const TextStyle(
              color: Color(0xFF5F6672),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    ),
  );
}
