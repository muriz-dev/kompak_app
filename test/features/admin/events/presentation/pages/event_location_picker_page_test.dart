import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kompak_app/core/theme/app_theme.dart';
import 'package:kompak_app/features/admin/events/data/services/event_location_service.dart';
import 'package:kompak_app/features/admin/events/domain/entities/event_location_selection.dart';
import 'package:kompak_app/features/admin/events/presentation/pages/event_location_picker_page.dart';

void main() {
  testWidgets('uses the current location and returns the confirmed pin', (
    tester,
  ) async {
    const currentLocation = EventLocationSelection(
      latitude: -6.175392,
      longitude: 106.827153,
    );
    final service = _FakeLocationService(location: currentLocation);
    EventLocationSelection? result;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: FilledButton(
                onPressed: () async {
                  result = await Navigator.of(context)
                      .push<EventLocationSelection>(
                        MaterialPageRoute(
                          builder: (_) => EventLocationPickerPage(
                            initialLatitude:
                                EventLocationSelection.jakarta.latitude,
                            initialLongitude:
                                EventLocationSelection.jakarta.longitude,
                            locationService: service,
                          ),
                        ),
                      );
                },
                child: const Text('Buka pemilih'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Buka pemilih'));
    await tester.pumpAndSettle();

    expect(find.text('Pilih Lokasi'), findsOneWidget);
    expect(find.text('-6.200000, 106.816666'), findsOneWidget);

    await tester.tap(
      find.byKey(const ValueKey('event-current-location-button')),
    );
    await tester.pumpAndSettle();

    expect(find.text('-6.175392, 106.827153'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('confirm-event-location')));
    await tester.pumpAndSettle();

    expect(result, currentLocation);
  });

  testWidgets(
    'offers settings when location permission is permanently denied',
    (tester) async {
      final service = _FakeLocationService(
        failure: EventLocationFailure.permissionDeniedForever,
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: EventLocationPickerPage(locationService: service),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(
        find.byKey(const ValueKey('event-current-location-button')),
      );
      await tester.pumpAndSettle();

      expect(
        find.text('Izinkan akses lokasi melalui pengaturan aplikasi.'),
        findsOneWidget,
      );
      await tester.tap(find.text('Pengaturan'));
      await tester.pump();

      expect(
        service.openSettingsFailure,
        EventLocationFailure.permissionDeniedForever,
      );
    },
  );
}

class _FakeLocationService implements EventLocationService {
  _FakeLocationService({this.location, this.failure});

  final EventLocationSelection? location;
  final EventLocationFailure? failure;
  EventLocationFailure? openSettingsFailure;

  @override
  Future<EventLocationSelection> getCurrentLocation() async {
    if (failure case final failure?) {
      throw EventLocationException(failure);
    }
    return location!;
  }

  @override
  Future<bool> openSettings(EventLocationFailure failure) async {
    openSettingsFailure = failure;
    return true;
  }
}
