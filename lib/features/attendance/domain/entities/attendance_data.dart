class AttendanceStats {
  final int totalEventsAttended;
  final int potentialPoints;

  AttendanceStats({
    required this.totalEventsAttended,
    required this.potentialPoints,
  });
}

class OngoingEvent {
  final String id;
  final String title;
  final String imageUrl;
  final String tag;
  final String timeRemaining;
  final int participantCount;
  final int points;

  OngoingEvent({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.tag,
    required this.timeRemaining,
    required this.participantCount,
    required this.points,
  });
}

class UpcomingEventItem {
  final String id;
  final String month;
  final String date;
  final String title;
  final String location;
  final int points;

  UpcomingEventItem({
    required this.id,
    required this.month,
    required this.date,
    required this.title,
    required this.location,
    required this.points,
  });
}
