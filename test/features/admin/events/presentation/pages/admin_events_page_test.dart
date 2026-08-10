import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kompak_app/core/theme/app_theme.dart';
import 'package:kompak_app/features/admin/events/presentation/pages/admin_events_page.dart';

void main() {
  Future<void> pumpPage(
    WidgetTester tester, {
    VoidCallback? onBack,
    VoidCallback? onCreateEvent,
    Size size = const Size(390, 1000),
  }) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = size;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: AdminEventsView(
          onBack: onBack ?? () {},
          onCreateEvent: onCreateEvent ?? () {},
        ),
      ),
    );
  }

  testWidgets('shows the Figma-aligned event list and create action', (
    tester,
  ) async {
    await pumpPage(tester);

    expect(find.text('Daftar Kegiatan'), findsOneWidget);
    expect(find.text('Cari nama kegiatan'), findsOneWidget);
    expect(find.text('Filter'), findsOneWidget);
    expect(find.text('Buat Kegiatan'), findsOneWidget);
    expect(find.text('Kerja Bakti Blok B'), findsOneWidget);
    expect(find.text('Kerja Bakti Blok A'), findsOneWidget);
    expect(find.text('Rapat Bulanan RT'), findsOneWidget);
    expect(find.text('Penyemprotan Disinfektan'), findsOneWidget);
    expect(find.text('Belum Mulai'), findsOneWidget);
    expect(find.text('Berlangsung'), findsOneWidget);
    expect(find.text('Selesai'), findsNWidgets(2));
    expect(find.text('0 Warga'), findsOneWidget);
    expect(find.text('+4,200 Pts'), findsOneWidget);
  });

  testWidgets('opens event creation from the list', (tester) async {
    var createTapped = false;
    await pumpPage(tester, onCreateEvent: () => createTapped = true);

    await tester.tap(find.byKey(const ValueKey('create-event-button')));

    expect(createTapped, isTrue);
  });

  testWidgets('searches and filters the event list', (tester) async {
    await pumpPage(tester);

    await tester.enterText(
      find.byKey(const ValueKey('event-search-field')),
      'rapat',
    );
    await tester.pump();

    expect(find.text('Rapat Bulanan RT'), findsOneWidget);
    expect(find.text('Kerja Bakti Blok B'), findsNothing);

    await tester.enterText(
      find.byKey(const ValueKey('event-search-field')),
      '',
    );
    await tester.tap(find.byKey(const ValueKey('event-filter-button')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Selesai').last);
    await tester.pumpAndSettle();

    expect(find.text('Rapat Bulanan RT'), findsOneWidget);
    expect(find.text('Penyemprotan Disinfektan'), findsOneWidget);
    expect(find.text('Kerja Bakti Blok B'), findsNothing);
  });

  testWidgets('paginates through additional events', (tester) async {
    await pumpPage(tester);

    expect(find.text('Kerja Bakti Blok B'), findsOneWidget);
    expect(find.text('Posyandu Balita'), findsNothing);

    await tester.tap(find.byKey(const ValueKey('admin-events-next-page')));
    await tester.pump();

    expect(find.text('Kerja Bakti Blok B'), findsNothing);
    expect(find.text('Posyandu Balita'), findsOneWidget);
    expect(find.text('Ronda Malam Bersama'), findsOneWidget);
  });

  testWidgets('fits the event list on a narrow phone', (tester) async {
    await pumpPage(tester, size: const Size(320, 720));

    expect(find.text('Daftar Kegiatan'), findsOneWidget);
    expect(find.text('Buat Kegiatan'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.drag(
      find.byKey(const ValueKey('admin-events-scroll')),
      const Offset(0, -900),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });
}
