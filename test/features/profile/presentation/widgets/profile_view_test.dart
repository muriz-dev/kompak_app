import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kompak_app/features/profile/presentation/widgets/profile_view.dart';

void main() {
  Widget buildView({
    VoidCallback? onForgotPassword,
    VoidCallback? onHelpPhoneTap,
    VoidCallback? onLogout,
    ValueChanged<int>? onNavigationSelected,
  }) {
    return MaterialApp(
      home: ProfileView(
        data: ProfileViewData.placeholder,
        onBack: () {},
        onForgotPassword: onForgotPassword ?? () {},
        onHelpPhoneTap: onHelpPhoneTap ?? () {},
        onLogout: onLogout ?? () {},
        onNavigationSelected: onNavigationSelected ?? (_) {},
      ),
    );
  }

  testWidgets('shows the profile information and fixed navigation', (
    tester,
  ) async {
    await tester.pumpWidget(buildView());

    expect(find.text('Profile Anda'), findsOneWidget);
    expect(find.text('Handoyo'), findsOneWidget);
    expect(find.text('Nomor Telepon'), findsOneWidget);
    expect(find.text('Tanggal Lahir'), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Absensi'), findsOneWidget);
    expect(find.text('Toko'), findsOneWidget);
    expect(find.text('Peringkat'), findsOneWidget);
  });

  testWidgets('shows achievements, help, and account actions', (tester) async {
    var forgotPasswordTapped = false;
    var helpTapped = false;
    var logoutTapped = false;

    await tester.pumpWidget(
      buildView(
        onForgotPassword: () => forgotPasswordTapped = true,
        onHelpPhoneTap: () => helpTapped = true,
        onLogout: () => logoutTapped = true,
      ),
    );

    final forgotPasswordButton = tester.widget<TextButton>(
      find.byKey(const ValueKey('profile-forgot-password-button')),
    );
    forgotPasswordButton.onPressed?.call();
    expect(forgotPasswordTapped, isTrue);

    final helpPhoneButton = tester.widget<InkWell>(
      find.byKey(const ValueKey('profile-help-phone')),
    );
    helpPhoneButton.onTap?.call();
    expect(helpTapped, isTrue);
    expect(find.text('Pencapaian'), findsOneWidget);

    final logoutButton = tester.widget<TextButton>(
      find.byKey(const ValueKey('profile-logout-button')),
    );
    logoutButton.onPressed?.call();
    expect(logoutTapped, isTrue);
  });

  testWidgets('fits the profile layout on a narrow phone', (tester) async {
    tester.view.physicalSize = const Size(320, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(buildView());

    expect(find.text('Profile Anda'), findsOneWidget);
    expect(find.text('Pencapaian'), findsOneWidget);
    expect(find.text('Peringkat'), findsOneWidget);
  });
}
