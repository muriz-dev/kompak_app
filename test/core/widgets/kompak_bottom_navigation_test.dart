import 'dart:ui' show Tristate;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kompak_app/core/widgets/kompak_bottom_navigation.dart';

void main() {
  Widget buildNavigation({bool disableAnimations = false}) {
    var currentIndex = 0;
    return MaterialApp(
      home: MediaQuery(
        data: MediaQueryData(disableAnimations: disableAnimations),
        child: StatefulBuilder(
          builder: (context, setState) {
            return Scaffold(
              bottomNavigationBar: KompakBottomNavigation(
                currentIndex: currentIndex,
                onSelected: (index) => setState(() => currentIndex = index),
              ),
            );
          },
        ),
      ),
    );
  }

  testWidgets('crossfades and scales selection between tabs', (tester) async {
    await tester.pumpWidget(buildNavigation());

    final homeIndicator = find.byKey(const ValueKey('bottom-nav-indicator-0'));
    final storeIndicator = find.byKey(const ValueKey('bottom-nav-indicator-2'));
    final homeScale = find.byKey(
      const ValueKey('bottom-nav-indicator-scale-0'),
    );
    final storeScale = find.byKey(
      const ValueKey('bottom-nav-indicator-scale-2'),
    );
    expect(tester.widget<Opacity>(homeIndicator).opacity, 1);
    expect(tester.widget<Opacity>(storeIndicator).opacity, 0);
    expect(_scaleOf(tester, homeScale), 1);
    expect(_scaleOf(tester, storeScale), closeTo(0.90, 0.001));

    await tester.tap(find.byKey(const ValueKey('bottom-nav-item-2')));
    await tester.pump();
    expect(
      tester
          .widget<KompakBottomNavigation>(find.byType(KompakBottomNavigation))
          .currentIndex,
      2,
    );
    await tester.pump(const Duration(milliseconds: 60));

    final outgoingOpacity = tester.widget<Opacity>(homeIndicator).opacity;
    final incomingOpacity = tester.widget<Opacity>(storeIndicator).opacity;
    expect(outgoingOpacity, inExclusiveRange(0, 1));
    expect(incomingOpacity, inExclusiveRange(0, 1));
    expect(_scaleOf(tester, homeScale), inExclusiveRange(0.90, 1));
    expect(_scaleOf(tester, storeScale), inExclusiveRange(0.90, 1));

    await tester.pumpAndSettle();
    expect(tester.widget<Opacity>(homeIndicator).opacity, 0);
    expect(tester.widget<Opacity>(storeIndicator).opacity, 1);
    expect(_scaleOf(tester, homeScale), closeTo(0.90, 0.001));
    expect(_scaleOf(tester, storeScale), 1);

    final selectedSemantics = tester.getSemantics(find.text('Toko'));
    expect(selectedSemantics.flagsCollection.isSelected, Tristate.isTrue);
  });

  testWidgets('honors reduced-motion preference', (tester) async {
    await tester.pumpWidget(buildNavigation(disableAnimations: true));

    final homeIndicator = find.byKey(const ValueKey('bottom-nav-indicator-0'));
    final leaderboardIndicator = find.byKey(
      const ValueKey('bottom-nav-indicator-3'),
    );

    await tester.tap(find.byKey(const ValueKey('bottom-nav-item-3')));
    await tester.pumpAndSettle();

    expect(tester.widget<Opacity>(homeIndicator).opacity, 0);
    expect(tester.widget<Opacity>(leaderboardIndicator).opacity, 1);
    expect(tester.hasRunningAnimations, isFalse);
  });

  testWidgets('uses press compression without an ink ripple', (tester) async {
    await tester.pumpWidget(buildNavigation());

    final homeItem = find.byKey(const ValueKey('bottom-nav-item-0'));
    final pressScale = find.byKey(const ValueKey('bottom-nav-press-scale-0'));
    final inkWell = tester.widget<InkWell>(homeItem);

    expect(inkWell.splashFactory, same(NoSplash.splashFactory));
    expect(tester.widget<AnimatedScale>(pressScale).scale, 1);

    final gesture = await tester.startGesture(tester.getCenter(homeItem));
    await tester.pump();
    expect(tester.widget<AnimatedScale>(pressScale).scale, 0.96);

    await gesture.up();
    await tester.pumpAndSettle();
    expect(tester.widget<AnimatedScale>(pressScale).scale, 1);
  });
}

double _scaleOf(WidgetTester tester, Finder finder) {
  return tester.widget<Transform>(finder).transform.entry(0, 0);
}
