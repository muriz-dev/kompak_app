import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kompak_app/core/theme/app_theme.dart';
import 'package:kompak_app/features/admin/events/domain/entities/admin_event.dart';
import 'package:kompak_app/features/admin/events/domain/entities/admin_event_overview.dart';
import 'package:kompak_app/features/admin/events/domain/entities/create_admin_event_request.dart';
import 'package:kompak_app/features/admin/events/domain/entities/update_admin_event_request.dart';
import 'package:kompak_app/features/admin/events/domain/repositories/admin_events_repository.dart';
import 'package:kompak_app/features/admin/events/presentation/bloc/admin_event_detail_cubit.dart';
import 'package:kompak_app/features/admin/events/presentation/bloc/edit_event_cubit.dart';
import 'package:kompak_app/features/admin/events/presentation/pages/admin_event_detail_page.dart';
import 'package:kompak_app/features/admin/events/presentation/pages/edit_event_page.dart';

void main() {
  testWidgets('renders Figma-aligned API metrics and opens photo details', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 1000);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    final repository = _FakeRepository();

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: BlocProvider(
          create: (_) =>
              AdminEventDetailCubit(repository)..loadEvent('event-1'),
          child: AdminEventDetailView(
            eventId: 'event-1',
            onBack: () {},
            onEdit: (_) async => false,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Detail Kegiatan'), findsOneWidget);
    expect(find.text('Kerja Bakti Blok B'), findsOneWidget);
    expect(find.text('+90'), findsOneWidget);
    expect(find.text('2/4'), findsOneWidget);
    expect(find.text('50%'), findsOneWidget);
    expect(find.text('Olivia Rhye'), findsOneWidget);
    expect(find.text('08123456789'), findsOneWidget);

    final pointsCard = find.byKey(
      const ValueKey('metric-card-surface-Point Terdistribusi'),
    );
    final participationCard = find.byKey(
      const ValueKey('metric-card-surface-Total Partisipasi'),
    );
    expect(tester.getSize(pointsCard).height, 112);
    expect(
      tester.getSize(pointsCard).width,
      tester.getSize(participationCard).width,
    );
    expect(
      (tester.widget<Container>(pointsCard).decoration! as BoxDecoration).color,
      KompakColors.primary,
    );
    expect(
      (tester.widget<Container>(participationCard).decoration! as BoxDecoration)
          .color,
      KompakColors.success,
    );
    expect(
      tester.widget<Text>(find.text('Point Terdistribusi')).style?.color,
      Colors.white,
    );
    expect(
      tester.widget<Text>(find.text('50%')).style?.color,
      KompakColors.success,
    );

    final manualButton = find.byKey(const ValueKey('manual-attendance-button'));
    final massButton = find.byKey(const ValueKey('mass-attendance-button'));
    expect(
      tester.getTopLeft(manualButton).dy,
      lessThan(tester.getTopLeft(massButton).dy),
    );
    expect(
      tester.getSize(manualButton).width,
      tester.getSize(massButton).width,
    );

    await tester.tap(find.byKey(const ValueKey('documentation-attendance-1')));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('documentation-page-view')),
      findsOneWidget,
    );
    expect(find.text('Membersihkan taman bersama.'), findsOneWidget);
    expect(find.text('olivia@test.com'), findsNothing);

    await tester.tap(find.byKey(const ValueKey('close-documentation-viewer')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('documentation-page-view')), findsNothing);
  });

  testWidgets('prefills edit data and submits the full update contract', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 1000);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    final repository = _FakeRepository();

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: FilledButton(
                onPressed: () => Navigator.of(context).push<void>(
                  MaterialPageRoute(
                    builder: (_) => BlocProvider(
                      create: (_) => EditEventCubit(repository),
                      child: EditEventView(event: repository.event),
                    ),
                  ),
                ),
                child: const Text('Open edit'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open edit'));
    await tester.pumpAndSettle();

    expect(find.text('Edit Kegiatan'), findsOneWidget);
    expect(
      tester
          .widget<TextFormField>(
            find.byKey(const ValueKey('edit-event-name-field')),
          )
          .controller
          ?.text,
      'Kerja Bakti Blok B',
    );
    expect(
      tester
          .widget<TextFormField>(
            find.byKey(const ValueKey('edit-event-points-field')),
          )
          .controller
          ?.text,
      '50',
    );

    await tester.tap(find.byKey(const ValueKey('save-event-changes-button')));
    await tester.pumpAndSettle();

    expect(repository.updateRequest?.title, 'Kerja Bakti Blok B');
    expect(
      repository.updateRequest?.existingBannerUrl,
      'https://assets.test/poster.jpg',
    );
    expect(find.text('Open edit'), findsOneWidget);
  });

  testWidgets('uses the event banner when attendance has no documentation', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 1000);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    final repository = _FakeRepository(includeDocumentation: false);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: BlocProvider(
          create: (_) =>
              AdminEventDetailCubit(repository)..loadEvent('event-1'),
          child: AdminEventDetailView(
            eventId: 'event-1',
            onBack: () {},
            onEdit: (_) async => false,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('documentation-event-banner')),
      findsOneWidget,
    );
    expect(find.text('1 Foto'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('documentation-event-banner')));
    await tester.pumpAndSettle();

    expect(find.text('Poster Kegiatan'), findsOneWidget);
    expect(find.text('Dokumentasi bawaan'), findsOneWidget);
  });
}

class _FakeRepository implements AdminEventsRepository {
  _FakeRepository({this.includeDocumentation = true});

  final bool includeDocumentation;
  UpdateAdminEventRequest? updateRequest;
  bool deleted = false;

  final event = AdminEvent(
    id: 'event-1',
    createdBy: 'admin-1',
    title: 'Kerja Bakti Blok B',
    description: 'Bersihkan taman bersama.',
    eventDate: DateTime(2026, 8, 12, 7),
    attendanceStartTime: DateTime(2026, 8, 12, 7),
    attendanceEndTime: DateTime(2026, 8, 12, 9),
    rewardPoints: 50,
    latitude: -6.2,
    longitude: 106.8,
    radiusMeters: 50,
    status: AdminEventRecordStatus.published,
    bannerUrl: 'https://assets.test/poster.jpg',
  );

  late final overview = AdminEventOverview(
    event: event,
    activeCitizenCount: 4,
    attendances: [
      AdminEventAttendance(
        id: 'attendance-1',
        attendee: const AdminEventAttendee(
          id: 'citizen-1',
          name: 'Olivia Rhye',
          phoneNumber: '08123456789',
          email: 'olivia@test.com',
        ),
        verifiedAt: DateTime(2026, 8, 12, 7, 15),
        awardedPoints: 50,
        activityPhotoUrl: includeDocumentation
            ? 'https://assets.test/photo-1.jpg'
            : null,
        activityDescription: 'Membersihkan taman bersama.',
      ),
      AdminEventAttendance(
        id: 'attendance-2',
        attendee: const AdminEventAttendee(
          id: 'citizen-2',
          name: 'Budi Santoso',
          phoneNumber: '08120000000',
        ),
        verifiedAt: DateTime(2026, 8, 12, 7, 20),
        awardedPoints: 40,
      ),
    ],
  );

  @override
  Future<AdminEventOverview> getEventOverview(String eventId) async => overview;

  @override
  Future<AdminEvent> updateEvent(
    String eventId,
    UpdateAdminEventRequest request,
  ) async {
    updateRequest = request;
    return event;
  }

  @override
  Future<void> deleteEvent(String eventId) async {
    deleted = true;
  }

  @override
  Future<List<AdminEvent>> getEvents() async => [event];

  @override
  Future<AdminEvent> createEvent(CreateAdminEventRequest request) async =>
      event;

  @override
  Future<AdminEvent> updateEventStatus(
    String eventId,
    AdminEventRecordStatus status,
  ) async => event;
}
