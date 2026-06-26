// Slice 5: 渡劫 IF + 飞升 / 跌回 outcome.

import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:jhrm/engine/tribulation_engine.dart';
import 'package:jhrm/state/enums.dart';
import 'package:jhrm/state/game_state.dart';

void main() {
  group('TribulationEngine (slice 5)', () {
    test('渡劫 success at 炼气 9/9 → 升到 筑基 1/9 (no ending, mid-realm)',
        () {
      // Slice 29 contract: 炼气 9/9 success advances to 筑基 1/9, no
      // ending recorded. Ending only fires at 大乘 9/9.
      final s = GameState.fresh();
      s.player.layer = 9;
      s.forceSuccess = true;
      final e = TribulationEngine(s, rng: Random(0));
      final result = e.resolve();
      expect(result, TribulationResult.success);
      expect(s.player.realm, Realm.zhuJi);
      expect(s.player.layer, 1);
      expect(s.ending, isNull,
          reason: 'ending is set only at 大乘 9/9 (ascension), not on mid-realm advances');
    });

    test('渡劫 fail → 跌回 current_realm 1/9 + 寿元 = 50% (slice 29)', () {
      // New contract: failure drops within the same realm, not all the
      // way back to 炼气. At 炼气 9/9 with this seed the failure path
      // still resets to 炼气 1/9 because that's the current realm.
      final s = GameState.fresh();
      s.player.layer = 9;
      s.player.lifespan = 0;
      s.player.lifespanMax = 100;
      final e = TribulationEngine(s, rng: Random(99));
      final result = e.resolve();
      expect(result, TribulationResult.failure);
      expect(s.player.realm, Realm.lianQi,
          reason: 'failure drops to current realm 1/9');
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

    test('ending is based on 道心 strongest path (slice 29: requires 大乘 9/9)', () {
      final s = GameState.fresh();
      s.player.realm = Realm.daCheng;
      s.player.layer = 9;
      s.player.heartVector[HeartPath.swordDao] = 5;
      s.forceSuccess = true;
      final e = TribulationEngine(s, rng: Random(0));
      e.resolve();
      expect(s.ending, 'ascended-swordDao',
          reason: '大乘 9/9 success = ascension, ending records dominant 道心');
    });

    test('forceSuccess forces ascension + auto-clears (slice 20, 大乘 9/9)', () {
      final s = GameState.fresh();
      s.player.realm = Realm.daCheng;
      s.player.layer = 9;
      s.forceSuccess = true;
      final e = TribulationEngine(s, rng: Random(0));
      e.resolve();
      expect(s.forceSuccess, isFalse,
          reason: 'flag must clear after one consumption so the next '
              'tribulation is back to RNG');
    });

    test('success at 化神 9/9 advances to 大乘 1/9 + new lifespan (slice 29)', () {
      final s = GameState.fresh();
      s.player.realm = Realm.huaShen;
      s.player.layer = 9;
      s.player.lifespan = 19200;
      s.player.lifespanMax = 19200;
      s.forceSuccess = true;
      final e = TribulationEngine(s);
      expect(e.resolve(), TribulationResult.success);
      expect(s.player.realm, Realm.daCheng,
          reason: 'next realm in the 6-realm chain');
      expect(s.player.layer, 1, reason: 'fresh start in the new realm');
      expect(s.player.lifespan, TribulationEngine.lifespanFor(Realm.daCheng));
      expect(s.player.lifespanMax, TribulationEngine.lifespanFor(Realm.daCheng));
      expect(s.ending, isNull,
          reason: 'ending only set on 大乘→飞升, not on mid-realm advances');
    });

    test('success at 大乘 9/9 sets ending via EndingResolver (slice 29)', () {
      final s = GameState.fresh();
      s.player.realm = Realm.daCheng;
      s.player.layer = 9;
      s.player.heartVector[HeartPath.swordDao] = 7;
      s.forceSuccess = true;
      final e = TribulationEngine(s);
      expect(e.resolve(), TribulationResult.success);
      expect(s.ending, 'ascended-swordDao',
          reason: '大乘 9/9 success = ascension, ending records dominant 道心');
    });

    test('failure at 化神 9/9 drops to 化神 1/9 (not back to 炼气) (slice 29)', () {
      final s = GameState.fresh();
      s.player.realm = Realm.huaShen;
      s.player.layer = 9;
      // Zero lifespan forces rate = 0.5; with seed(99) the roll is high
      // → failure. (Full-lifespan at 化神 would give rate = 0.7, making
      // failure RNG-dependent.)
      s.player.lifespan = 0;
      s.player.lifespanMax = 19200;
      final e = TribulationEngine(s, rng: Random(99));
      expect(e.resolve(), TribulationResult.failure);
      expect(s.player.realm, Realm.huaShen,
          reason: 'failure drops within the same realm, not all the way down');
      expect(s.player.layer, 1);
    });
  });
}
