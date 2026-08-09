import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kompak_app/features/auth/presentation/widgets/face_scanner_overlay.dart';

Widget _scanner({bool reduceMotion = false}) {
  return MaterialApp(
    home: MediaQuery(
      data: MediaQueryData(disableAnimations: reduceMotion),
      child: const Center(
        child: SizedBox(
          width: 342,
          height: 440,
          child: FaceScannerOverlay(child: ColoredBox(color: Colors.black)),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('centers an animated face guide over the preview', (
    tester,
  ) async {
    await tester.pumpWidget(_scanner());

    expect(find.bySemanticsLabel('Area pemindaian wajah'), findsOneWidget);
    final guide = find.byKey(const ValueKey('face-scanner-guide'));
    expect(guide, findsOneWidget);
    expect(tester.getSize(guide).width, moreOrLessEquals(212, epsilon: 1));
    expect(tester.getSize(guide).height, moreOrLessEquals(282, epsilon: 1));

    final line = find.byKey(const ValueKey('face-scanner-line'));
    final initialPosition = tester.getTopLeft(line);
    await tester.pump(const Duration(milliseconds: 450));
    final movedPosition = tester.getTopLeft(line);

    expect(movedPosition.dy, isNot(initialPosition.dy));
  });

  testWidgets('keeps the scan line still when reduced motion is enabled', (
    tester,
  ) async {
    await tester.pumpWidget(_scanner(reduceMotion: true));

    final line = find.byKey(const ValueKey('face-scanner-line'));
    final initialPosition = tester.getTopLeft(line);
    await tester.pump(const Duration(seconds: 2));

    expect(tester.getTopLeft(line), initialPosition);
  });
}
