import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kompak_app/features/admin/events/presentation/pages/create_event_page.dart';

void main() {
  Widget buildPage() {
    return const MaterialApp(home: CreateEventPage());
  }

  testWidgets('shows the create event form from the approved reference', (
    tester,
  ) async {
    await tester.pumpWidget(buildPage());

    expect(find.text('Buat Kegiatan Baru'), findsOneWidget);
    expect(find.text('POSTER KEGIATAN'), findsOneWidget);
    expect(find.text('Klik untuk unggah poster'), findsOneWidget);
    expect(find.text('Nama Kegiatan'), findsOneWidget);
    expect(find.text('Kategori'), findsOneWidget);
    expect(find.text('Simpan & Publikasi'), findsOneWidget);
  });

  testWidgets('shows specific validation guidance before publishing', (
    tester,
  ) async {
    await tester.pumpWidget(buildPage());

    await tester.tap(find.text('Simpan & Publikasi'));
    await tester.pump();

    expect(find.text('Masukkan nama kegiatan.'), findsOneWidget);
    expect(find.text('Pilih kategori kegiatan.'), findsOneWidget);
    expect(find.text('Jelaskan detail kegiatan.'), findsOneWidget);
    expect(find.text('Pilih tanggal kegiatan.'), findsOneWidget);
    expect(find.text('Pilih waktu kegiatan.'), findsOneWidget);
    expect(find.text('Masukkan lokasi kegiatan.'), findsOneWidget);
    expect(
      find.text('Lengkapi data kegiatan yang masih kosong.'),
      findsOneWidget,
    );
  });

  testWidgets('allows attendance requirements to be toggled', (tester) async {
    await tester.pumpWidget(buildPage());

    final switches = find.byType(Switch);
    await tester.ensureVisible(switches.first);
    await tester.tap(switches.first);
    await tester.pump();

    expect(tester.widget<Switch>(switches.first).value, isTrue);
  });

  testWidgets('shows success modal and resets the form for another event', (
    tester,
  ) async {
    await tester.pumpWidget(buildPage());

    final scrollView = find.descendant(
      of: find.byType(SingleChildScrollView),
      matching: find.byType(Scrollable),
    ).first;
    final nameField = find.byKey(const ValueKey('event-name-field'));
    final categoryField = find.byKey(const ValueKey('event-category-field'));
    final detailField = find.byKey(const ValueKey('event-detail-field'));
    final dateField = find.byKey(const ValueKey('event-date-field'));
    final timeField = find.byKey(const ValueKey('event-time-field'));
    final locationField = find.byKey(const ValueKey('event-location-field'));

    await tester.enterText(nameField, 'Kerja Bakti Minggu');

    await tester.scrollUntilVisible(categoryField, 180, scrollable: scrollView);
    await tester.tap(categoryField);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Kerja Bakti').last);
    await tester.pumpAndSettle();

    await tester.enterText(detailField, 'Bawa alat kebersihan masing-masing.');

    await tester.scrollUntilVisible(dateField, 180, scrollable: scrollView);
    await tester.tap(dateField);
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(timeField, 120, scrollable: scrollView);
    await tester.tap(timeField);
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    await tester.enterText(locationField, 'Balai Warga RT 004');
    await tester.tap(find.text('Simpan & Publikasi'));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();

    expect(find.text('Kegiatan Berhasil Dibuat!'), findsOneWidget);
    expect(find.text('Lihat Daftar'), findsOneWidget);
    expect(find.text('Buat Lagi'), findsOneWidget);

    await tester.tap(find.text('Buat Lagi'));
    await tester.pumpAndSettle();

    expect(find.text('Kegiatan Berhasil Dibuat!'), findsNothing);
    expect(tester.widget<TextFormField>(nameField).controller?.text, isEmpty);
  });
}
