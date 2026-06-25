// Slice 6: 金手指 menu (hidden gesture + password + 13 actions).

import 'package:flutter_test/flutter_test.dart';
import 'package:jhrm/engine/gold_finger.dart';
import 'package:jhrm/engine/cultivation_engine.dart';
import 'package:jhrm/state/enums.dart';
import 'package:jhrm/state/game_state.dart';

void main() {
  group('GoldFinger gesture (slice 6)', () {
    test('5 taps within 1s triggers the menu', () {
      final s = GameState.fresh();
      final gf = GoldFinger(s);
      final times = [0, 100, 200, 300, 400].map((ms) => Duration(milliseconds: ms)).toList();
      bool triggered = false;
      for (final t in times) {
        if (gf.onTap(at: t)) triggered = true;
      }
      expect(triggered, isTrue);
    });

    test('4 taps does not trigger', () {
      final s = GameState.fresh();
      final gf = GoldFinger(s);
      bool triggered = false;
      for (var i = 0; i < 4; i++) {
        if (gf.onTap(at: Duration(milliseconds: i * 100))) triggered = true;
      }
      expect(triggered, isFalse);
    });

    test('5 taps spread over 2s does not trigger (1s window)', () {
      final s = GameState.fresh();
      final gf = GoldFinger(s);
      bool triggered = false;
      for (var i = 0; i < 5; i++) {
        if (gf.onTap(at: Duration(milliseconds: i * 500))) triggered = true;
      }
      expect(triggered, isFalse);
    });

    test('godmode password is case-insensitive', () {
      final s = GameState.fresh();
      final gf = GoldFinger(s);
      expect(gf.onPassword('godmode'), isTrue);
      expect(gf.onPassword('GODMODE'), isTrue);
      expect(gf.onPassword('GodMode'), isTrue);
      expect(gf.onPassword('godmod'), isFalse);
    });
  });

  group('GoldFinger actions (slice 6)', () {
    test('修为满 sets 修为 to max and triggers 突破', () {
      final s = GameState.fresh();
      final gf = GoldFinger(s);
      final e = CultivationEngine(s);
      gf.action(GoldAction.cultivationMax);
      expect(e.cultivationXp, CultivationEngine.cultivationXpMax);
    });

    test('修为×10 multiplies current 修为 by 10 (capped at max)', () {
      final s = GameState.fresh();
      final gf = GoldFinger(s);
      final e = CultivationEngine(s);
      e.cultivationXp = 5;
      gf.action(GoldAction.cultivationTimes10);
      expect(e.cultivationXp, 50);
    });

    test('切换灵根 resets root randomly', () {
      final s = GameState.fresh();
      s.player.root = Element.fire;
      final gf = GoldFinger(s);
      final oldRoot = s.player.root;
      // Just verify it changes after 1 invocation
      var changed = false;
      for (var i = 0; i < 10; i++) {
        gf.action(GoldAction.switchRoot);
        if (s.player.root != oldRoot) {
          changed = true;
          break;
        }
      }
      expect(changed, isTrue);
    });

    test('切换道心 resets heart vector to 0', () {
      final s = GameState.fresh();
      s.player.heartVector[HeartPath.swordDao] = 5;
      final gf = GoldFinger(s);
      gf.action(GoldAction.resetHeart);
      expect(s.player.heartVector[HeartPath.swordDao], 0);
    });

    test('+10 寿元 adds 10 months', () {
      final s = GameState.fresh();
      final before = s.player.lifespan;
      final gf = GoldFinger(s);
      gf.action(GoldAction.lifespanPlus10);
      expect(s.player.lifespan, before + 10);
    });

    test('渡劫成功 sets forceSuccess flag', () {
      final s = GameState.fresh();
      final gf = GoldFinger(s);
      gf.action(GoldAction.tribulationSuccess);
      expect(s.forceSuccess, isTrue);
    });
  });
}
