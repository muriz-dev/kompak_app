import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kompak_app/core/theme/app_theme.dart';
import 'package:kompak_app/features/admin/events/domain/entities/admin_event.dart';
import 'package:kompak_app/features/admin/events/domain/entities/create_admin_event_request.dart';
import 'package:kompak_app/features/admin/events/domain/entities/event_location_selection.dart';
import 'package:kompak_app/features/admin/events/domain/repositories/admin_events_repository.dart';
import 'package:kompak_app/features/admin/events/presentation/bloc/create_event_cubit.dart';
import 'package:kompak_app/features/admin/events/presentation/pages/create_event_page.dart';
import 'package:kompak_app/features/admin/events/presentation/widgets/event_success_dialog.dart';

void main() {
  Widget buildPage({
    EventLocationSelection? initialLocation,
    _FakeAdminEventsRepository? repository,
  }) {
    return MaterialApp(
      theme: AppTheme.light,
      home: BlocProvider(
        create: (_) =>
            CreateEventCubit(repository ?? _FakeAdminEventsRepository()),
        child: CreateEventView(initialLocation: initialLocation),
      ),
    );
  }

  testWidgets(
    'matches the create event form content from the Figma reference',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildPage());

      expect(find.text('Buat Kegiatan Baru'), findsOneWidget);
      expect(find.text('POSTER KEGIATAN'), findsOneWidget);
      expect(find.text('Klik untuk unggah poster'), findsOneWidget);
      expect(find.text('Nama Kegiatan'), findsOneWidget);
      expect(find.text('Detail Kegiatan'), findsOneWidget);
      expect(find.text('Tanggal'), findsOneWidget);
      expect(find.text('Waktu'), findsOneWidget);
      expect(find.text('Lokasi'), findsOneWidget);
      expect(find.text('Alokasi Poin'), findsOneWidget);
      expect(find.text('Reward'), findsOneWidget);
      expect(find.byKey(const ValueKey('event-location-map')), findsOneWidget);
      expect(find.text('Simpan & Publikasi'), findsOneWidget);
      expect(find.text('Kategori'), findsNothing);
      expect(find.text('Face Recognition'), findsNothing);
      expect(find.text('Wajib Lampiran Foto'), findsNothing);
      expect(find.byType(Switch), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('shows specific validation guidance before publishing', (
    tester,
  ) async {
    await tester.pumpWidget(buildPage());

    await tester.tap(find.text('Simpan & Publikasi'));
    await tester.pump();

    expect(find.text('Masukkan nama kegiatan.'), findsOneWidget);
    expect(find.text('Jelaskan detail kegiatan.'), findsOneWidget);
    expect(find.text('Pilih tanggal kegiatan.'), findsOneWidget);
    expect(find.text('Pilih waktu kegiatan.'), findsOneWidget);
    expect(find.text('Pilih titik lokasi kegiatan.'), findsOneWidget);
    expect(
      find.text('Lengkapi data kegiatan yang masih kosong.'),
      findsOneWidget,
    );
  });

  testWidgets('uses the Kompak blue theme for date picker actions', (
    tester,
  ) async {
    await tester.pumpWidget(buildPage());

    final dateField = find.byKey(const ValueKey('event-date-field'));
    await tester.ensureVisible(dateField);
    await tester.tap(dateField);
    await tester.pumpAndSettle();

    final okButton = tester.widget<TextButton>(
      find.widgetWithText(TextButton, 'OK'),
    );
    expect(okButton.style?.foregroundColor?.resolve({}), KompakColors.primary);
  });

  testWidgets('shows success modal and resets the form for another event', (
    tester,
  ) async {
    final repository = _FakeAdminEventsRepository();
    await tester.pumpWidget(
      buildPage(
        initialLocation: EventLocationSelection.jakarta,
        repository: repository,
      ),
    );

    final scrollView = find
        .descendant(
          of: find.byType(SingleChildScrollView),
          matching: find.byType(Scrollable),
        )
        .first;
    final nameField = find.byKey(const ValueKey('event-name-field'));
    final detailField = find.byKey(const ValueKey('event-detail-field'));
    final dateField = find.byKey(const ValueKey('event-date-field'));
    final timeField = find.byKey(const ValueKey('event-time-field'));

    await tester.enterText(nameField, 'Kerja Bakti Minggu');
    await tester.enterText(detailField, 'Bawa alat kebersihan masing-masing.');

    await tester.scrollUntilVisible(dateField, 180, scrollable: scrollView);
    await tester.tap(dateField);
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(timeField, 120, scrollable: scrollView);
    await tester.tap(timeField);
    await tester.pumpAndSettle();
    expect(find.text('Waktu Kegiatan'), findsOneWidget);
    expect(find.text('Mulai'), findsOneWidget);
    expect(find.text('Selesai'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('confirm-event-time-range')));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Simpan & Publikasi'));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();

    expect(find.text('Kegiatan Berhasil Dibuat!'), findsOneWidget);
    expect(repository.createRequest?.latitude, -6.2);
    expect(repository.createRequest?.longitude, 106.816666);
    expect(repository.createRequest?.status, AdminEventRecordStatus.published);
    expect(
      repository.createRequest?.attendanceEndTime.isAfter(
        repository.createRequest!.attendanceStartTime,
      ),
      isTrue,
    );
    expect(find.text('Lihat Daftar'), findsOneWidget);
    expect(find.text('Buat Lagi'), findsOneWidget);

    await tester.tap(find.text('Buat Lagi'));
    await tester.pumpAndSettle();

    expect(find.text('Kegiatan Berhasil Dibuat!'), findsNothing);
    expect(tester.widget<TextFormField>(nameField).controller?.text, isEmpty);
  });

  testWidgets('uses the returned status in the success message', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: EventSuccessDialog(status: AdminEventRecordStatus.draft),
        ),
      ),
    );

    expect(
      find.text(
        'Kegiatan Anda telah disimpan sebagai draft dan belum terlihat oleh warga.',
      ),
      findsOneWidget,
    );
    expect(
      find.text(
        'Kegiatan Anda telah dipublikasikan dan dapat dilihat oleh warga.',
      ),
      findsNothing,
    );
  });
}

class _FakeAdminEventsRepository implements AdminEventsRepository {
  CreateAdminEventRequest? createRequest;

  @override
  Future<AdminEvent> createEvent(CreateAdminEventRequest request) async {
    createRequest = request;
    return AdminEvent(
      id: 'event-1',
      createdBy: 'admin-1',
      title: request.title,
      description: request.description,
      eventDate: request.eventDate,
      attendanceStartTime: request.attendanceStartTime,
      attendanceEndTime: request.attendanceEndTime,
      rewardPoints: request.rewardPoints,
      latitude: request.latitude,
      longitude: request.longitude,
      radiusMeters: request.radiusMeters,
      status: request.status,
    );
  }

  @override
  Future<List<AdminEvent>> getEvents() async => [];

  @override
  Future<AdminEvent> updateEventStatus(
    String eventId,
    AdminEventRecordStatus status,
  ) {
    throw UnimplementedError();
  }
}
