import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kompak_app/core/widgets/user_avatar.dart';

void main() {
  test('builds initials from the first and last name parts', () {
    expect(initialsForName('Olivia Rhye'), 'OR');
    expect(initialsForName(' Ahmad '), 'A');
    expect(initialsForName(''), '?');
  });

  testWidgets('renders the generated initials', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: UserAvatar(name: 'Olivia Rhye', size: 48)),
    );

    expect(find.text('OR'), findsOneWidget);
  });
}
