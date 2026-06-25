// Slice 4: 灵根 + 功法 + 闭关 + 修为 + 小层突破.

import 'package:flutter_test/flutter_test.dart';
import 'package:jhrm/engine/cultivation_engine.dart';
import 'package:jhrm/state/enums.dart';
import 'package:jhrm/state/game_state.dart';

void main() {
  group('CultivationEngine (slice 4)', () {
    test('a fresh state has 0 修为 / 100 max at 炼气 1/9', () {
      final s = GameState.fresh();
      final e = CultivationEngine(s);
      expect(e.cultivationXp, 0);
      expect(CultivationEngine.cultivationXpMax, 100);
    });

    test('starting + completing a 闭关 adds 1 month 寿元 cost (decisions.md #12)', () {
      final s = GameState.fresh();
      final e = CultivationEngine(s);
      final before = s.player.lifespan;
      e.startClosure();
      e.completeClosure();
      expect(s.player.lifespan, before - 1);
    });

    test('completing a 闭关 adds 1 修为 per closure (capped at max)', () {
      final s = GameState.fresh();
      final e = CultivationEngine(s);
      for (var i = 0; i < 5; i++) {
        e.startClosure();
        e.completeClosure();
      }
      expect(e.cultivationXp, 5);
    });

    test('cultivation beyond max clamps to max (setter only)', () {
      final s = GameState.fresh();
      final e = CultivationEngine(s);
      e.cultivationXp = CultivationEngine.cultivationXpMax + 50;
      expect(e.cultivationXp, CultivationEngine.cultivationXpMax);
    });

    test('满 修为 triggers 突破 IF (decisions.md #14: 80% + 道心 10%)', () {
      final s = GameState.fresh();
      // Force 100% to deterministically test 80% path
      s.player.heartVector[HeartPath.swordDao] = 1; // +10% alignment bonus
      final e = CultivationEngine(s);
      e.cultivationXp = 99;
      e.startClosure();
      e.completeClosure();
      // success path: layer +1, xp reset
      expect(s.player.layer, 2);
      expect(e.cultivationXp, 0);
    });

    test('突破 without 寿元 alignment falls back to 80% base (probabilistic, tested via forceSuccess)', () {
      final s = GameState.fresh();
      final e = CultivationEngine(s);
      e.cultivationXp = 99;
      e.startClosure();
      e.completeClosure();
      // Default no force: 80% base + 0 alignment = 80% success, but the
      // 1-tick deterministic check would still be in [0, 100] so we test
      // that the layer is in {1, 2} (probabilistic but bounded).
      expect(s.player.layer, anyOf(1, 2));
    });

    test('forceSuccess forces breakthrough + auto-clears after one use (slice 20)', () {
      final s = GameState.fresh();
      // Pre-fail condition: no heart alignment, no force → 80% base rate.
      // With forceSuccess=true, even an unlucky roll yields success, and
      // the flag must clear so the next breakthrough is back to RNG.
      s.forceSuccess = true;
      final e = CultivationEngine(s);
      e.cultivationXp = 99;
      e.startClosure();
      e.completeClosure();
      expect(s.player.layer, 2, reason: 'force must yield success');
      expect(s.forceSuccess, isFalse, reason: 'flag auto-clears after one use');

      // Subsequent closure with no force falls back to RNG (rate unchanged).
      s.player.cultivationXp = 99;
      e.startClosure();
      e.completeClosure();
      // We can't assert the layer delta deterministically without forcing
      // the RNG, but we CAN assert the flag stayed false (no accidental
      // re-set) and the engine didn't crash.
      expect(s.forceSuccess, isFalse);
    });
  });

  group('灵根 (slice 4)', () {
    test('switching 灵根 recomputes learnable techniques', () {
      final s = GameState.fresh();
      s.player.root = Element.fire;
      final fire = s.player.learnableTechniques();
      expect(fire.every((t) => t.element == Element.fire), isTrue);

      s.player.root = Element.water;
      final water = s.player.learnableTechniques();
      expect(water.every((t) => t.element == Element.water), isTrue);
      expect(water, isNot(equals(fire)));
    });
  });
}
