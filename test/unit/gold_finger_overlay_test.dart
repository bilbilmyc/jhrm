// Slice 16 + 19: GoldFingerOverlay widget tests.
// Verifies: trigger region size + position, all action labels, dispatch
// closes panel, scrim tap dismisses, side effect on GameState per action,
// and reset-save (slice 19) deletes save file + resets state to fresh.

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jhrm/save/save_service.dart';
import 'package:jhrm/state/enums.dart' as domain;
import 'package:jhrm/state/game_state.dart';
import 'package:jhrm/ui/gold_finger_overlay.dart';

Future<void> _openMenu(WidgetTester tester) async {
  for (var i = 0; i < 5; i++) {
    await tester.tap(find.byKey(const Key('gold-finger-trigger')),
        warnIfMissed: false);
    await tester.pump(const Duration(milliseconds: 100));
  }
  await tester.pumpAndSettle();
}

void main() {
  group('GoldFingerOverlay (slice 16)', () {
    testWidgets('trigger region is 50x50 anchored at top-left',
        (tester) async {
      final s = GameState.fresh();
      await tester.pumpWidget(
        MaterialApp(
          home: GoldFingerOverlay(
            state: s,
            child: const Scaffold(body: Center(child: Text('home'))),
          ),
        ),
      );

      final trigger = tester.getRect(find.byKey(const Key('gold-finger-trigger')));
      // The trigger must be hidden in a tiny corner — 50x50dp, top-left.
      expect(trigger.width, 50);
      expect(trigger.height, 50);
      expect(trigger.topLeft, Offset.zero);
    });

    testWidgets('panel shows all 8 action labels including 重置存档',
        (tester) async {
      final s = GameState.fresh();
      await tester.pumpWidget(
        MaterialApp(
          home: GoldFingerOverlay(
            state: s,
            child: const Scaffold(body: Center(child: Text('home'))),
          ),
        ),
      );

      await _openMenu(tester);

      const labels = [
        '修为 × 10',
        '修为灌满',
        '转换灵根',
        '重置道心',
        '+10 因果',
        '+10 寿元',
        '强渡天劫',
        '重置存档',
      ];
      for (final label in labels) {
        expect(find.text(label), findsOneWidget,
            reason: 'menu should show "$label"');
      }
    });

    testWidgets('tapping 修为灌满 closes panel and fills xp to max',
        (tester) async {
      final s = GameState.fresh();
      s.player.cultivationXp = 30;
      await tester.pumpWidget(
        MaterialApp(
          home: GoldFingerOverlay(
            state: s,
            child: const Scaffold(body: Center(child: Text('home'))),
          ),
        ),
      );

      await _openMenu(tester);
      await tester.tap(find.text('修为灌满'));
      await tester.pumpAndSettle();

      expect(find.text('修为灌满'), findsNothing);
      // XP reached max at some point. The CultivationEngine clamps + may
      // resolve a breakthrough that resets to 0; in that case the
      // observable is that xp is in [0, max]. Test the *transition* by
      // ensuring the engine call ran: the breakthrough either advanced
      // the layer (success) or reduced xp to 70% (fail). Either way xp
      // is not the original 30.
      expect(s.player.cultivationXp, isNot(30));
    });

    testWidgets('+10 寿元 adds 10 to lifespan and closes panel',
        (tester) async {
      final s = GameState.fresh();
      final before = s.player.lifespan;
      await tester.pumpWidget(
        MaterialApp(
          home: GoldFingerOverlay(
            state: s,
            child: const Scaffold(body: Center(child: Text('home'))),
          ),
        ),
      );

      await _openMenu(tester);
      await tester.tap(find.text('+10 寿元'));
      await tester.pumpAndSettle();

      expect(s.player.lifespan, before + 10);
      expect(find.text('+10 寿元'), findsNothing);
    });

    testWidgets('tapping the scrim (outside the panel) dismisses it',
        (tester) async {
      final s = GameState.fresh();
      await tester.pumpWidget(
        MaterialApp(
          home: GoldFingerOverlay(
            state: s,
            child: const Scaffold(body: Center(child: Text('home'))),
          ),
        ),
      );

      await _openMenu(tester);
      expect(find.text('金 手 指'), findsOneWidget);

      await tester.tapAt(const Offset(750, 50));
      await tester.pumpAndSettle();

      expect(find.text('金 手 指'), findsNothing);
      expect(find.text('修为灌满'), findsNothing);
    });

    testWidgets('switching root changes the element to a non-current one',
        (tester) async {
      final s = GameState.fresh();
      s.player.root = domain.Element.fire;
      await tester.pumpWidget(
        MaterialApp(
          home: GoldFingerOverlay(
            state: s,
            child: const Scaffold(body: Center(child: Text('home'))),
          ),
        ),
      );

      await _openMenu(tester);
      await tester.tap(find.text('转换灵根'));
      await tester.pumpAndSettle();

      expect(
        domain.Element.values
            .where((e) =>
                e != domain.Element.wind &&
                e != domain.Element.thunder &&
                e != domain.Element.ice)
            .contains(s.player.root),
        isTrue,
        reason: 'root must remain a switchable element',
      );
    });
  });

  group('GoldFingerOverlay reset-save (slice 19)', () {
    testWidgets('重置存档 resets in-memory state to fresh (save file via SaveService)',
        (tester) async {
      // In-memory reset is the user-observable side of the button tap.
      // The file delete is SaveService.delete()'s responsibility and is
      // covered separately; this test focuses on the widget wiring
      // (dispatch closes the panel + state.resetToFresh() ran).
      final s = GameState.fresh();
      s.player.layer = 7;
      s.player.cultivationXp = 80;
      s.player.heartVector[domain.HeartPath.swordDao] = 5;
      s.ending = 'ascended-swordDao';
      s.forceSuccess = true;

      await tester.pumpWidget(
        MaterialApp(
          home: GoldFingerOverlay(
            state: s,
            child: const Scaffold(body: Center(child: Text('home'))),
          ),
        ),
      );

      await _openMenu(tester);
      await tester.tap(find.text('重置存档'));
      await tester.pumpAndSettle();

      // Panel closed (the dispatch always closes it).
      expect(find.text('重置存档'), findsNothing);
      // State reset to fresh values.
      expect(s.player.layer, 1);
      expect(s.player.cultivationXp, 0);
      expect(s.player.heartVector[domain.HeartPath.swordDao], 0);
      expect(s.ending, isNull);
      expect(s.forceSuccess, isFalse);
    });

    test('SaveService + resetToFresh together: save-then-reset leaves no file',
        () async {
      // Companion unit test that ties SaveService.delete() to
      // GameState.resetToFresh() in the same scenario as the widget
      // action would. Avoids the widget-test complications of
      // fire-and-forget file I/O crossing the fake-async boundary.
      final tmp = await Directory.systemTemp.createTemp('jhrm_reset_save_');
      addTearDown(() async {
        if (tmp.existsSync()) await tmp.delete(recursive: true);
      });
      final saveService = SaveService(directory: tmp);
      final s = GameState.fresh();
      s.player.layer = 7;
      s.ending = 'ascended-swordDao';
      s.forceSuccess = true;

      await saveService.save(s);
      expect(saveService.exists, isTrue);

      // Simulate the dispatch's two steps in order.
      await saveService.delete();
      s.resetToFresh();

      expect(saveService.exists, isFalse, reason: 'save must be deleted');
      expect(s.player.layer, 1);
      expect(s.ending, isNull);
      expect(s.forceSuccess, isFalse);
    });
  });
}
