import 'package:flutter/material.dart';
import '../../domain/entities/store_data.dart';

class StoreItemGridCard extends StatelessWidget {
  final StoreItem item;
  final VoidCallback onRedeem;

  const StoreItemGridCard({super.key, required this.item, required this.onRedeem});

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'delete_outline':
        return Icons.delete_outline;
      case 'bolt':
        return Icons.bolt;
      default:
        return Icons.card_giftcard;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image / Icon Section
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: item.itemType == ItemType.icon ? const Color(0xFFEFF6FF) : Colors.transparent,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: item.itemType == ItemType.icon
                    ? Center(
                        child: Icon(
                          _getIconData(item.imageUrlOrIcon),
                          size: 40,
                          color: const Color(0xFF2563EB),
                        ),
                      )
                    : Image.network(
                        item.imageUrlOrIcon,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: double.infinity,
                          color: Colors.grey.shade300,
                          child: const Icon(Icons.image, color: Colors.grey),
                        ),
                      ),
              ),
            ),
          ),
          // Content Section
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.stars, color: Colors.orange, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      '${item.points}',
                      style: const TextStyle(
                        color: Colors.orange,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 32,
                  child: ElevatedButton(
                    onPressed: onRedeem,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981), // Green
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      elevation: 0,
                    ),
                    child: const Text('Tukar', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
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
