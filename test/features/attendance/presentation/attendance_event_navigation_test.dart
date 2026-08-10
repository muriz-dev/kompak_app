import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kompak_app/features/attendance/domain/entities/attendance_data.dart';
import 'package:kompak_app/features/attendance/presentation/widgets/ongoing_event_card.dart';
import 'package:kompak_app/features/attendance/presentation/widgets/upcoming_event_list_tile.dart';

void main() {
  testWidgets('opens ongoing event details from the explicit action', (
    tester,
  ) async {
    var detailOpenCount = 0;
    var checkInOpenCount = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: OngoingEventCard(
            event: OngoingEvent(
              id: 'ongoing-1',
              title: 'Kerja Bakti',
              imageUrl: '',
              tag: 'BERLANGSUNG',
              timeRemaining: 'Berakhir dlm 1 jam',
              participantCount: 0,
              points: 50,
            ),
            onDetailTap: () => detailOpenCount += 1,
            onCheckInTap: () => checkInOpenCount += 1,
          ),
        ),
      ),
    );

    await tester.tap(find.text('Lihat Detail'));

    expect(detailOpenCount, 1);
    expect(checkInOpenCount, 0);
  });

  testWidgets('keeps ongoing check-in separate from detail navigation', (
    tester,
  ) async {
    var detailOpenCount = 0;
    var checkInOpenCount = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: OngoingEventCard(
            event: OngoingEvent(
              id: 'ongoing-1',
              title: 'Kerja Bakti',
              imageUrl: '',
              tag: 'BERLANGSUNG',
              timeRemaining: 'Berakhir dlm 1 jam',
              participantCount: 0,
              points: 50,
            ),
            onDetailTap: () => detailOpenCount += 1,
            onCheckInTap: () => checkInOpenCount += 1,
          ),
        ),
      ),
    );

    await tester.tap(find.text('Absensi Sekarang'));

    expect(checkInOpenCount, 1);
    expect(detailOpenCount, 0);
  });

  testWidgets('keeps the upcoming event detail action available', (
    tester,
  ) async {
    var detailOpenCount = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: UpcomingEventListTile(
            event: UpcomingEventItem(
              id: 'upcoming-1',
              month: 'NOV',
              date: '15',
              title: 'Rapat Warga',
              location: '-6.200000, 106.800000',
              points: 40,
            ),
            onDetailTap: () => detailOpenCount += 1,
          ),
        ),
      ),
    );

    await tester.tap(find.text('Detail'));

    expect(detailOpenCount, 1);
  });
}
