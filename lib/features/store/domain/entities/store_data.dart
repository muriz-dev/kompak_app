enum ItemType { icon, image }

class StoreStats {
  final int totalPoints;

  StoreStats({required this.totalPoints});
}

class StoreCategory {
  final String id;
  final String name;

  StoreCategory({required this.id, required this.name});
}

class StoreItem {
  final String id;
  final String title;
  final String description;
  final String imageUrlOrIcon; // Can be a URL or an IconData reference (mapped later)
  final int points;
  final bool isFeatured;
  final ItemType itemType;

  StoreItem({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrlOrIcon,
    required this.points,
    this.isFeatured = false,
    required this.itemType,
  });
}
