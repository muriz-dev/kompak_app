import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kompak_app/features/attendance/presentation/widgets/attendance_check_in_form_dialog.dart';

void main() {
  testWidgets('collects optional note before opening the face scanner', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            return ElevatedButton(
              onPressed: () => showAttendanceCheckInFormDialog(context),
              child: const Text('Open'),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    expect(find.text('Lampirkan Foto Kegiatan (Opsional)'), findsOneWidget);
    expect(find.text('Scan Wajah Sekarang'), findsOneWidget);

    await tester.enterText(
      find.byType(TextField),
      'Kegiatan berjalan dengan baik.',
    );
    await tester.tap(find.byKey(const ValueKey('attendance-scan-now-button')));
    await tester.pumpAndSettle();

    expect(find.text('Lengkapi Absensi'), findsNothing);
  });
}
