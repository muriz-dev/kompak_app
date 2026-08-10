import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kompak_app/features/home/domain/entities/home_data.dart';
import 'package:kompak_app/features/home/presentation/pages/home_page.dart';

void main() {
  final userSummary = UserSummary(name: 'Olivia Rhye', points: 90);
  final activities = [
    UpcomingActivity(
      id: 'activity-1',
      title: 'Rapat Triwulan RT',
      date: DateTime(2026, 11, 15, 19, 30),
      tag: 'PENTING',
    ),
  ];
  final announcements = [
    Announcement(
      id: 'announcement-1',
      title: 'Penyesuaian Jadwal Keamanan Malam',
      author: 'Oleh: Sekretaris RT 04',
      description: 'Sehubungan dengan perbaikan gerbang utama.',
      tag: 'Mendesak',
      imageUrl: '',
    ),
  ];

  Widget buildDashboard({
    VoidCallback? onNotificationTap,
    VoidCallback? onProfileTap,
    VoidCallback? onRedeemTap,
    VoidCallback? onViewAllActivities,
    ValueChanged<UpcomingActivity>? onActivityReminder,
    ValueChanged<UpcomingActivity>? onActivityTap,
    VoidCallback? onAnnouncementTap,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: HomeDashboardView(
          userSummary: userSummary,
          activities: activities,
          announcements: announcements,
          onNotificationTap: onNotificationTap ?? () {},
          onProfileTap: onProfileTap ?? () {},
          onRedeemTap: onRedeemTap ?? () {},
          onViewAllActivities: onViewAllActivities ?? () {},
          onActivityReminder: onActivityReminder ?? (_) {},
          onActivityTap: onActivityTap ?? (_) {},
          onAnnouncementTap: onAnnouncementTap ?? () {},
        ),
      ),
    );
  }

  testWidgets('shows the approved resident dashboard hierarchy', (
    tester,
  ) async {
    await tester.pumpWidget(buildDashboard());

    expect(find.text('Selamat Siang, Olivia Rhye!'), findsOneWidget);
    expect(find.text('90'), findsOneWidget);
    expect(find.text('OR'), findsOneWidget);
    expect(find.text('Tukarkan Poin ke Toko Poin'), findsOneWidget);
    expect(find.text('Kegiatan Mendatang'), findsOneWidget);
    expect(find.text('Rapat Triwulan RT'), findsOneWidget);
    expect(find.text('Pengumuman Terbaru'), findsOneWidget);
    expect(find.text('Buka pratinjau admin'), findsNothing);
  });

  testWidgets('connects dashboard actions', (tester) async {
    var notificationTapped = false;
    var profileTapped = false;
    var redeemTapped = false;
    var viewAllTapped = false;
    UpcomingActivity? remindedActivity;
    UpcomingActivity? openedActivity;
    var announcementTapped = false;

    await tester.pumpWidget(
      buildDashboard(
        onNotificationTap: () => notificationTapped = true,
        onProfileTap: () => profileTapped = true,
        onRedeemTap: () => redeemTapped = true,
        onViewAllActivities: () => viewAllTapped = true,
        onActivityReminder: (activity) => remindedActivity = activity,
        onActivityTap: (activity) => openedActivity = activity,
        onAnnouncementTap: () => announcementTapped = true,
      ),
    );

    tester
        .widget<InkWell>(find.byKey(const ValueKey('home-notification-button')))
        .onTap
        ?.call();
    tester
        .widget<InkWell>(find.byKey(const ValueKey('home-profile-button')))
        .onTap
        ?.call();
    tester
        .widget<InkWell>(find.byKey(const ValueKey('home-activity-activity-1')))
        .onTap
        ?.call();
    tester
        .widget<FilledButton>(
          find.byKey(const ValueKey('home-redeem-points-button')),
        )
        .onPressed
        ?.call();
    tester
        .widget<TextButton>(
          find.byKey(const ValueKey('home-view-all-activities')),
        )
        .onPressed
        ?.call();
    tester
        .widget<OutlinedButton>(
          find.byKey(const ValueKey('home-reminder-activity-1')),
        )
        .onPressed
        ?.call();
    tester
        .widget<InkWell>(
          find.byKey(const ValueKey('home-announcement-announcement-1')),
        )
        .onTap
        ?.call();

    expect(notificationTapped, isTrue);
    expect(profileTapped, isTrue);
    expect(redeemTapped, isTrue);
    expect(viewAllTapped, isTrue);
    expect(remindedActivity, same(activities.first));
    expect(openedActivity, same(activities.first));
    expect(announcementTapped, isTrue);
  });

  testWidgets('fits the dashboard on a narrow phone', (tester) async {
    tester.view.physicalSize = const Size(320, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(buildDashboard());

    expect(find.text('Selamat Siang, Olivia Rhye!'), findsOneWidget);
    expect(find.text('90'), findsOneWidget);
  });
}
