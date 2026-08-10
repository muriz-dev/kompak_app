class UserSummary {
  final String name;
  final int points;

  UserSummary({required this.name, required this.points});
}

class UpcomingActivity {
  final String id;
  final String title;
  final DateTime date;
  final String tag;
  final bool isImportant;

  UpcomingActivity({
    required this.id,
    required this.title,
    required this.date,
    required this.tag,
    this.isImportant = false,
  });
}

class Announcement {
  final String id;
  final String title;
  final String author;
  final String description;
  final String tag;
  final String imageUrl;

  Announcement({
    required this.id,
    required this.title,
    required this.author,
    required this.description,
    required this.tag,
    required this.imageUrl,
  });
}
