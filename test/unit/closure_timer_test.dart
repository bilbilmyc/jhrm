// Slice 16: ClosureTimer widget tests.
// Verifies: initial 闭关 label, tap → countdown label, full 30s advances
// xp + fires onComplete. Time control via tester.pump(duration) — Flutter's
// test framework uses a fake clock for AnimationController.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jhrm/state/game_state.dart';
import 'package:jhrm/ui/closure_timer.dart';

void main() {
  group('ClosureTimer (slice 16)', () {
    testWidgets('FAB starts with 闭关 label and self_improvement icon',
        (tester) async {
      final s = GameState.fresh();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ClosureTimer(state: s, onComplete: () {}),
          ),
        ),
      );

      expect(find.byKey(const Key('cultivate-fab')), findsOneWidget);
      expect(find.text('闭关'), findsOneWidget);
      expect(find.byIcon(Icons.self_improvement), findsOneWidget);
      expect(find.byIcon(Icons.stop), findsNothing);
    });

    testWidgets('tap starts 闭关 — label becomes countdown + stop icon',
        (tester) async {
      final s = GameState.fresh();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ClosureTimer(state: s, onComplete: () {}),
          ),
        ),
      );

      await tester.tap(find.byKey(const Key('cultivate-fab')));
      await tester.pump(); // one frame: _running set, label rebuilds

      expect(find.text('闭关'), findsNothing);
      expect(find.byIcon(Icons.stop), findsOneWidget);
      // Label is '闭关中 $remaining s' — exact value depends on tick, but
      // '闭关中' prefix + a digit-suffixed s are the public contract.
      expect(find.textContaining('闭关中'), findsOneWidget);
      expect(find.textContaining(' s'), findsOneWidget);
    });

    testWidgets('30s elapse → onComplete fires + 修为 +1 + 寿元 -1',
        (tester) async {
      final s = GameState.fresh();
      final xpBefore = s.player.cultivationXp;
      final lifespanBefore = s.player.lifespan;
      var completeCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ClosureTimer(
              state: s,
              onComplete: () => completeCount++,
            ),
          ),
        ),
      );

      await tester.tap(find.byKey(const Key('cultivate-fab')));
      // pumpAndSettle steps the AnimationController frame-by-frame via the
      // fake Ticker; when the controller reaches 1.0 the whenComplete
      // callback (engine.completeClosure + onComplete) fires.
      await tester.pumpAndSettle();

      expect(completeCount, 1);
      expect(s.player.cultivationXp, xpBefore + 1);
      expect(s.player.lifespan, lifespanBefore - 1);
      // FAB should be back to idle state.
      expect(find.text('闭关'), findsOneWidget);
    });
  });
}
