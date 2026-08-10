import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kompak_app/features/home/presentation/widgets/profile_mode_sheet.dart';

void main() {
  Widget buildSheet({required bool canAccessAdmin}) {
    return MaterialApp(
      home: Scaffold(
        body: ProfileModeSheet(
          name: 'Olivia Rhye',
          email: 'olivia@example.com',
          canAccessAdmin: canAccessAdmin,
          onOpenProfile: () {},
          onOpenSettings: () {},
          onSwitchAdmin: () {},
          onSwitchProvider: () {},
          onLogout: () {},
        ),
      ),
    );
  }

  testWidgets('shows the admin mode switch for an admin account', (
    tester,
  ) async {
    await tester.pumpWidget(buildSheet(canAccessAdmin: true));

    expect(find.text('Akun Warga'), findsOneWidget);
    expect(find.text('Beralih ke Admin'), findsOneWidget);
    expect(find.text('Beralih ke akun UMKM'), findsOneWidget);
    expect(find.text('Log out'), findsOneWidget);
  });

  testWidgets('does not expose admin mode to a citizen account', (
    tester,
  ) async {
    await tester.pumpWidget(buildSheet(canAccessAdmin: false));

    expect(find.text('Beralih ke Admin'), findsNothing);
    expect(find.text('Beralih ke akun UMKM'), findsOneWidget);
  });
}
