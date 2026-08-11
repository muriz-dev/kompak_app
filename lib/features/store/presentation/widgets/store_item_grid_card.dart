import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/store_data.dart';
import 'reward_visuals.dart';

class StoreItemGridCard extends StatelessWidget {
  const StoreItemGridCard({
    super.key,
    required this.item,
    required this.onRedeem,
  });

  final StoreItem item;
  final VoidCallback onRedeem;

  @override
  Widget build(BuildContext context) {
    final available = item.stock > 0;
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE8EAEE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RewardImage(
            item: item,
            height: 112,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(11)),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 9),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ProviderLogo(
                        provider: item.provider,
                        size: 25,
                        showBorder: false,
                      ),
                      const SizedBox(width: 7),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: KompakColors.ink,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Row(
                              children: [
                                const Icon(
                                  Icons.stars_rounded,
                                  color: KompakColors.warning,
                                  size: 13,
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  '${item.points}',
                                  style: const TextStyle(
                                    color: KompakColors.warning,
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
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    height: 36,
                    child: ElevatedButton(
                      onPressed: available ? onRedeem : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: KompakColors.success,
                        disabledBackgroundColor: KompakColors.outline,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(7),
                        ),
                      ),
                      child: Text(
                        available ? 'Tukar' : 'Habis',
                        style: const TextStyle(
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
        ],
      ),
    );
  }
}
