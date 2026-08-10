import 'package:equatable/equatable.dart';

import 'admin_event.dart';

class AdminEventAttendee extends Equatable {
  const AdminEventAttendee({
    required this.id,
    required this.name,
    this.email,
    this.phoneNumber,
  });

  factory AdminEventAttendee.fromJson(Map<String, dynamic> json) =>
      AdminEventAttendee(
        id: json['id'] as String,
        name: json['name'] as String,
        email: json['email'] as String?,
        phoneNumber: json['phoneNumber'] as String?,
      );

  final String id;
  final String name;
  final String? email;
  final String? phoneNumber;

  String get secondaryLabel {
    final phone = phoneNumber?.trim();
    if (phone != null && phone.isNotEmpty) return phone;
    final mail = email?.trim();
    if (mail != null && mail.isNotEmpty) return mail;
    return 'Warga';
  }

  @override
  List<Object?> get props => [id, name, email, phoneNumber];
}

class AdminEventAttendance extends Equatable {
  const AdminEventAttendance({
    required this.id,
    required this.attendee,
    required this.verifiedAt,
    required this.awardedPoints,
    this.activityDescription,
    this.activityPhotoUrl,
  });

  factory AdminEventAttendance.fromJson(Map<String, dynamic> json) {
    final transaction = json['eventTransaction'];
    return AdminEventAttendance(
      id: json['id'] as String,
      attendee: AdminEventAttendee.fromJson(
        Map<String, dynamic>.from(json['user'] as Map),
      ),
      verifiedAt: AdminEvent.parseDate(json['verifiedAt']),
      awardedPoints: transaction is Map
          ? ((transaction['points'] as num?)?.toInt() ?? 0)
          : 0,
      activityDescription: json['activityDescription'] as String?,
      activityPhotoUrl: json['activityPhotoUrl'] as String?,
    );
  }

  final String id;
  final AdminEventAttendee attendee;
  final DateTime verifiedAt;
  final int awardedPoints;
  final String? activityDescription;
  final String? activityPhotoUrl;

  bool get hasDocumentation {
    final url = activityPhotoUrl?.trim();
    return url != null && url.isNotEmpty;
  }

  @override
  List<Object?> get props => [
    id,
    attendee,
    verifiedAt,
    awardedPoints,
    activityDescription,
    activityPhotoUrl,
  ];
}

class AdminEventDocumentation extends Equatable {
  const AdminEventDocumentation({
    required this.id,
    required this.url,
    required this.contributorName,
    required this.contributorLabel,
    this.description,
  });

  factory AdminEventDocumentation.fromAttendance(
    AdminEventAttendance attendance,
  ) => AdminEventDocumentation(
    id: attendance.id,
    url: attendance.activityPhotoUrl!,
    contributorName: attendance.attendee.name,
    contributorLabel: attendance.attendee.secondaryLabel,
    description: attendance.activityDescription,
  );

  factory AdminEventDocumentation.fromBanner(AdminEvent event) =>
      AdminEventDocumentation(
        id: 'event-banner',
        url: event.bannerUrl!.trim(),
        contributorName: 'Poster Kegiatan',
        contributorLabel: 'Dokumentasi bawaan',
      );

  final String id;
  final String url;
  final String contributorName;
  final String contributorLabel;
  final String? description;

  @override
  List<Object?> get props => [
    id,
    url,
    contributorName,
    contributorLabel,
    description,
  ];
}

class AdminEventOverview extends Equatable {
  const AdminEventOverview({
    required this.event,
    required this.attendances,
    required this.activeCitizenCount,
  });

  final AdminEvent event;
  final List<AdminEventAttendance> attendances;
  final int activeCitizenCount;

  int get attendanceCount => attendances.length;

  int get distributedPoints => attendances.fold(
    0,
    (total, attendance) => total + attendance.awardedPoints,
  );

  double get attendanceRate => activeCitizenCount <= 0
      ? 0
      : (attendanceCount / activeCitizenCount).clamp(0, 1);

  List<AdminEventDocumentation> get documentation {
    final attendanceDocumentation = attendances
        .where((attendance) => attendance.hasDocumentation)
        .map(AdminEventDocumentation.fromAttendance)
        .toList(growable: false);
    if (attendanceDocumentation.isNotEmpty) return attendanceDocumentation;

    final banner = event.bannerUrl?.trim();
    if (banner != null && banner.isNotEmpty) {
      return [AdminEventDocumentation.fromBanner(event)];
    }

    return const [];
  }

  @override
  List<Object> get props => [event, attendances, activeCitizenCount];
}
