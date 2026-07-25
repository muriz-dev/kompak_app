import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kompak_app/features/admin/residents/presentation/pages/admin_residents_page.dart';

void main() {
  Widget buildPage() {
    return const MaterialApp(home: AdminResidentsPage());
  }

  testWidgets('shows the admin summary and first placeholder page', (
    tester,
  ) async {
    await tester.pumpWidget(buildPage());

    expect(find.text('Manajemen Warga'), findsOneWidget);
    expect(find.text('Total Warga'), findsOneWidget);
    expect(find.text('482'), findsOneWidget);
    expect(find.text('Budi Pratama'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Dewi Wijaya'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Dewi Wijaya'), findsOneWidget);
    expect(find.text('Nur Aisyah'), findsNothing);
  });

  testWidgets('searches the placeholder resident list', (tester) async {
    await tester.pumpWidget(buildPage());

    await tester.enterText(find.byType(TextField), 'Agus');
    await tester.pump();

    expect(find.text('Agus Mulyadi'), findsOneWidget);
    expect(find.text('Budi Pratama'), findsNothing);
  });

  testWidgets('filters residents by inactive status', (tester) async {
    await tester.pumpWidget(buildPage());

    await tester.ensureVisible(find.text('Filter'));
    await tester.tap(find.text('Filter'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Tidak Aktif').last);
    await tester.pumpAndSettle();

    expect(find.text('Agus Mulyadi'), findsOneWidget);
    expect(find.text('Lina Setiawati'), findsOneWidget);
    expect(find.text('Budi Pratama'), findsNothing);
  });
}
