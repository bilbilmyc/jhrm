// Slice 16: BreakthroughView widget tests.
// Verifies: success/fail title, body references player realm+layer, dismiss
// callback fires. Implementation in lib/ui/breakthrough_view.dart already
// exists — these tests are written test-first to pin behavior.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jhrm/state/game_state.dart';
import 'package:jhrm/ui/breakthrough_view.dart';

void main() {
  group('BreakthroughView (slice 16)', () {
    testWidgets('shows success title and body referencing realm+layer',
        (tester) async {
      final s = GameState.fresh();
      // 炼气 3 层 — exercises the body interpolation: '${realm}第 ${layer} 层'
      s.player.layer = 3;
      await tester.pumpWidget(
        MaterialApp(
          home: BreakthroughView(
            success: true,
            state: s,
            onDismiss: () {},
          ),
        ),
      );

      expect(find.text('突 破 成 功'), findsOneWidget);
      // Body should reflect realm name + layer number, not be the failure
      // boilerplate.
      expect(find.textContaining('炼气'), findsAtLeastNWidgets(1));
      expect(find.textContaining('第 3 层'), findsOneWidget);
      expect(find.textContaining('突破受阻'), findsNothing);
    });

    testWidgets('shows failure title and body when success=false',
        (tester) async {
      final s = GameState.fresh();
      await tester.pumpWidget(
        MaterialApp(
          home: BreakthroughView(
            success: false,
            state: s,
            onDismiss: () {},
          ),
        ),
      );

      expect(find.text('突 破 失 败'), findsOneWidget);
      expect(find.textContaining('突破受阻'), findsOneWidget);
      expect(find.text('突 破 成 功'), findsNothing);
    });

    testWidgets('tapping 继 续 invokes onDismiss exactly once',
        (tester) async {
      final s = GameState.fresh();
      var dismissCount = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: BreakthroughView(
            success: true,
            state: s,
            onDismiss: () => dismissCount++,
          ),
        ),
      );

      await tester.tap(find.text('继 续'));
      await tester.pumpAndSettle();

      expect(dismissCount, 1);
    });
  });
}
