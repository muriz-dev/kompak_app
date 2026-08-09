import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kompak_app/core/theme/app_theme.dart';
import 'package:kompak_app/features/auth/presentation/widgets/registration_success_dialog.dart';

void main() {
  testWidgets('matches the success dialog content and action', (tester) async {
    var loginTapped = false;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: RegistrationSuccessDialog(onLogin: () => loginTapped = true),
        ),
      ),
    );

    expect(find.text('Berhasil Terdaftar'), findsOneWidget);
    expect(
      find.text(
        'Data wajah Anda telah berhasil\n'
        'diverifikasi dan disimpan dalam sistem\n'
        'KOMPAK.',
      ),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('registration-success-icon')),
      findsOneWidget,
    );
    expect(find.byIcon(Icons.check_rounded), findsOneWidget);

    await tester.tap(
      find.byKey(const ValueKey('registration-success-login-button')),
    );
    expect(loginTapped, isTrue);
  });
}
