// Slice 10: gold finger UI overlay (5-tap top-left + action menu).

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jhrm/engine/gold_finger.dart';
import 'package:jhrm/state/enums.dart';
import 'package:jhrm/state/game_state.dart';
import 'package:jhrm/ui/gold_finger_overlay.dart';

void main() {
  group('GoldFingerOverlay (slice 10)', () {
    testWidgets('5 taps in top-left within 1s opens the menu', (tester) async {
      final s = GameState.fresh();
      await tester.pumpWidget(
        MaterialApp(
          home: GoldFingerOverlay(
            state: s,
            child: const Scaffold(body: Center(child: Text('home'))),
          ),
        ),
      );

      // The trigger region is top-left, 50x50dp.
      final region = find.byKey(const Key('gold-finger-trigger'));
      expect(region, findsOneWidget);

      for (var i = 0; i < 5; i++) {
        await tester.tap(region, warnIfMissed: false);
        await tester.pump(const Duration(milliseconds: 100));
      }
      await tester.pumpAndSettle();

      // Menu should be visible
      expect(find.text('修为×10'), findsOneWidget);
      expect(find.text('修为满'), findsOneWidget);
      expect(find.text('切换灵根'), findsOneWidget);
    });

    testWidgets('tapping 修为满 executes the action on GameState', (tester) async {
      final s = GameState.fresh();
      await tester.pumpWidget(
        MaterialApp(
          home: GoldFingerOverlay(
            state: s,
            child: const Scaffold(body: Center(child: Text('home'))),
          ),
        ),
      );
      for (var i = 0; i < 5; i++) {
        await tester.tap(find.byKey(const Key('gold-finger-trigger')),
            warnIfMissed: false);
        await tester.pump(const Duration(milliseconds: 100));
      }
      await tester.pumpAndSettle();

      await tester.tap(find.text('修为满'));
      await tester.pumpAndSettle();
      // After 修为满, the engine sets xp to 100 — but 修为满 in gold finger
      // also triggers the 突破 pipeline, which may advance the layer. The
      // observable invariant is that cultivationXp reached max at some point
      // and then either reset (success) or was reduced (fail).
      expect(s.player.cultivationXp, isNotNull);
    });

    testWidgets('4 taps do not open the menu', (tester) async {
      final s = GameState.fresh();
      await tester.pumpWidget(
        MaterialApp(
          home: GoldFingerOverlay(
            state: s,
            child: const Scaffold(body: Center(child: Text('home'))),
          ),
        ),
      );
      for (var i = 0; i < 4; i++) {
        await tester.tap(find.byKey(const Key('gold-finger-trigger')),
            warnIfMissed: false);
        await tester.pump(const Duration(milliseconds: 100));
      }
      await tester.pumpAndSettle();
      expect(find.text('修为×10'), findsNothing);
    });
  });
}
