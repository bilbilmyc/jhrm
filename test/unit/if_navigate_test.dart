// Slice 46: 修真 IF 链 wiring bug fix.
//
// Pre-fix bug: if_screen.dart:173 called onNavigate?.call(segment),
// passing the FROM segment instead of the user's chosen IfChoice.
// WorldView._onIfNavigate then ignored the argument and fell back to
// closing the IF screen. Every修真 multi-step IF chain (道侣,
// ambient IFs, 修真小品, 飞升 decision branches) was unreachable.
//
// Tests: 4 IfScreen-level wiring guards (regression protection) + 1
// WorldView integration test (the headline user-facing fix).

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jhrm/content/content_loader.dart';
import 'package:jhrm/content/if_screen.dart';
import 'package:jhrm/content/if_segment.dart';
import 'package:jhrm/state/game_state.dart';
import 'package:jhrm/world/world_view.dart';

void main() {
  group('IfScreen navigation wiring (slice 46)', () {
    testWidgets('choice with goto fires onNavigate(IfChoice)',
        (tester) async {
      // The fix: onNavigate must receive the IfChoice the user tapped,
      // not the IfSegment the choice was rendered from. WorldView
      // needs the choice.goto to look up the next segment.
      final seg = const IfSegment(
        id: 'src',
        title: '源段',
        next: [
          IfChoice(choice: '继续', goto: 'next-seg'),
        ],
      );
      IfChoice? captured;
      await tester.pumpWidget(MaterialApp(
        home: IfScreen(
          state: GameState.fresh(),
          segment: seg,
          onExit: () {},
          onNavigate: (c) => captured = c,
        ),
      ));

      await tester.tap(find.text('继续'));
      await tester.pump();

      expect(captured, isNotNull,
          reason: 'onNavigate must fire when choice has goto');
      expect(captured, isA<IfChoice>(),
          reason: 'onNavigate argument must be the IfChoice, not IfSegment');
      expect(captured!.goto, 'next-seg');
    });

    testWidgets('choice with no goto fires onExit, not onNavigate',
        (tester) async {
      // Regression guard: terminal choices (goto == null) must still
      // close the IF. The fix must not route them through onNavigate.
      final seg = const IfSegment(
        id: 'src',
        title: '源段',
        next: [
          IfChoice(choice: '就此别过'),
        ],
      );
      var exitCount = 0;
      var navCount = 0;
      await tester.pumpWidget(MaterialApp(
        home: IfScreen(
          state: GameState.fresh(),
          segment: seg,
          onExit: () => exitCount++,
          onNavigate: (_) => navCount++,
        ),
      ));

      await tester.tap(find.text('就此别过'));
      await tester.pump();

      expect(exitCount, 1, reason: 'onExit must fire for terminal choice');
      expect(navCount, 0,
          reason: 'onNavigate must not fire when goto is null');
    });

    testWidgets('choice with action: tribulation fires onTribulationChoice',
        (tester) async {
      // Regression guard: tribulation action must route to
      // onTribulationChoice, not onNavigate. WorldView's
      // _onTribulationChoice runs TribulationEngine.
      final seg = const IfSegment(
        id: 'src',
        title: '源段',
        next: [
          IfChoice(choice: '渡劫', action: 'tribulation'),
        ],
      );
      IfChoice? captured;
      var navCount = 0;
      await tester.pumpWidget(MaterialApp(
        home: IfScreen(
          state: GameState.fresh(),
          segment: seg,
          onExit: () {},
          onNavigate: (_) => navCount++,
          onTribulationChoice: (c) => captured = c,
        ),
      ));

      await tester.tap(find.text('渡劫'));
      await tester.pump();

      expect(captured, isNotNull,
          reason: 'onTribulationChoice must fire for tribulation action');
      expect(captured!.action, 'tribulation');
      expect(navCount, 0,
          reason: 'onNavigate must not fire for tribulation action');
    });

    testWidgets('choice with action: ascend fires onAscendChoice',
        (tester) async {
      // Regression guard: ascend action (force-ascend) must route to
      // onAscendChoice, not onNavigate. WorldView's _onAscendChoice
      // runs TribulationEngine.forceAscend.
      final seg = const IfSegment(
        id: 'src',
        title: '源段',
        next: [
          IfChoice(choice: '飞升', action: 'ascend'),
        ],
      );
      IfChoice? captured;
      var navCount = 0;
      await tester.pumpWidget(MaterialApp(
        home: IfScreen(
          state: GameState.fresh(),
          segment: seg,
          onExit: () {},
          onNavigate: (_) => navCount++,
          onAscendChoice: (c) => captured = c,
        ),
      ));

      await tester.tap(find.text('飞升'));
      await tester.pump();

      expect(captured, isNotNull,
          reason: 'onAscendChoice must fire for ascend action');
      expect(captured!.action, 'ascend');
      expect(navCount, 0,
          reason: 'onNavigate must not fire for ascend action');
    });
  });

  group('WorldView integration (slice 46)', () {
    testWidgets('修真 multi-step IF chain advances via goto (A → B)',
        (tester) async {
      // The headline user-facing fix: tapping a node, then tapping a
      // choice with goto, must advance the IF to the target segment.
      // Pre-fix, the IF closed and the player returned to the map
      // after every goto choice.
      final loader = ContentLoader.fromString('''
---
id: chan-A
title: A 起点
trigger:
  location: 山门
next:
  - choice: "去 B"
    goto: chan-B
    heart_delta:
      swordDao: 1
---
A 正文 — 修真起点。
---
id: chan-B
title: B 中段
trigger:
  location: chan-b
---
B 正文 — 修真中段。
''');
      final state = GameState.fresh();
      await tester.pumpWidget(
        MaterialApp(home: WorldView(state: state, contentLoader: loader)),
      );

      // Tap 山门 node — A is the first segment for that location.
      await tester.tap(find.text('山门'));
      await tester.pumpAndSettle();
      expect(find.textContaining('A 正文'), findsAtLeastNWidgets(1),
          reason: 'tapping 山门 must open A');

      // Tap "去 B" — should advance to B 正文 (was the bug: it closed IF).
      await tester.tap(find.text('去 B'));
      await tester.pumpAndSettle();
      expect(find.textContaining('B 正文'), findsAtLeastNWidgets(1),
          reason: 'tapping goto choice must advance to B');
      expect(find.textContaining('A 正文'), findsNothing,
          reason: 'A 正文 should not still be on screen');

      // Heart delta from A→B choice should be applied.
      expect(state.player.heartVector.values.fold<int>(0, (a, b) => a + b), 1,
          reason: 'A→B choice bumped swordDao by 1');
    });
  });
}
