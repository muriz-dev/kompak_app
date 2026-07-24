import 'package:flutter/material.dart';
import '../../domain/entities/store_data.dart';

class CategoryChips extends StatelessWidget {
  final List<StoreCategory> categories;
  final String activeCategoryId;
  final Function(String) onCategorySelected;

  const CategoryChips({
    super.key,
    required this.categories,
    required this.activeCategoryId,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isActive = category.id == activeCategoryId;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(category.name),
              selected: isActive,
              onSelected: (_) => onCategorySelected(category.id),
              selectedColor: const Color(0xFF10B981), // Green
              backgroundColor: const Color(0xFFECFDF5), // Light Green / Gray
              labelStyle: TextStyle(
                color: isActive ? Colors.white : Colors.grey.shade700,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
              side: BorderSide.none,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              showCheckmark: false,
            ),
          );
        },
      ),
    );
  }
}
