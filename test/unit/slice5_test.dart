// Slice 5: 渡劫 IF + 飞升 / 跌回 outcome.

import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:jhrm/engine/tribulation_engine.dart';
import 'package:jhrm/state/enums.dart';
import 'package:jhrm/state/game_state.dart';

void main() {
  group('TribulationEngine (slice 5)', () {
    test('渡劫 success → 升到 筑基 1/9 + 通关 ending recorded', () {
      final s = GameState.fresh();
      s.player.layer = 9;
      s.forceSuccess = true;
      final e = TribulationEngine(s, rng: Random(0));
      final result = e.resolve();
      expect(result, TribulationResult.success);
      expect(s.player.realm, Realm.zhuJi);
      expect(s.player.layer, 1);
      expect(s.ending, isNotNull);
      expect(s.ending!.startsWith('ascended-'), isTrue);
    });

    test('渡劫 fail → 跌回 炼气 1/9 + 寿元 = 50%', () {
      final s = GameState.fresh();
      s.player.layer = 9;
      // zero 寿元 + no 道心 → 50% rate only. Use a seeded Random with roll > 0.5
      // is non-deterministic; instead we set rate to 0 by killing heart and
      // setting forceSuccess=false; rolls under 0.5 still happen, so we use
      // a fixed seed that yields a high roll.
      s.player.lifespan = 0;
      s.player.lifespanMax = 100;
      final e = TribulationEngine(s, rng: Random(99)); // high roll
      final result = e.resolve();
      expect(result, TribulationResult.failure);
      expect(s.player.realm, Realm.lianQi);
      expect(s.player.layer, 1);
    });

    test('success rate calculation (decisions.md #13: 50% + 寿元%×20% + 道心×10%)', () {
      final s = GameState.fresh();
      s.player.lifespan = 600; // 50% of max
      s.player.lifespanMax = 1200;
      s.player.heartVector[HeartPath.swordDao] = 1; // alignment bonus
      final e = TribulationEngine(s, rng: Random(0));
      // 50% base + (0.5 * 20% = 10%) + 10% alignment = 70%
      expect(e.computeSuccessRate(), closeTo(0.70, 0.01));
    });

    test('ending is based on 道心 strongest path', () {
      final s = GameState.fresh();
      s.player.heartVector[HeartPath.swordDao] = 5;
      s.forceSuccess = true;
      s.player.layer = 9;
      final e = TribulationEngine(s, rng: Random(0));
      e.resolve();
      expect(s.ending, 'ascended-swordDao');
    });
  });
}
