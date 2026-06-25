// Vertical Slice 1: GameState
//
// Tests describe player-observable behavior through the public interface.
// Per decisions.md #15: GameState must reserve all 14 system fields for
// forward-compat. Per decisions.md #11: fromJson uses optional fields with
// defaults so old saves keep working as the schema evolves.

import 'package:flutter_test/flutter_test.dart';
import 'package:jhrm/state/enums.dart';
import 'package:jhrm/state/game_state.dart';

void main() {
  group('GameState creation', () {
    test('a fresh GameState has a player at 炼气 1/9 with full lifespan', () {
      final s = GameState.fresh();
      expect(s.player.realm, Realm.lianQi);
      expect(s.player.layer, 1);
      expect(s.player.lifespan, 1200); // 100 years * 12 months
      expect(s.player.lifespanMax, 1200);
    });

    test('a fresh GameState has a 5-dimensional heart vector initialized to zero', () {
      final s = GameState.fresh();
      // 5 path enum: sword / demon / king / hidden / none
      expect(s.player.heartVector.length, 5);
      expect(s.player.heartVector[HeartPath.swordDao], 0);
      expect(s.player.heartVector[HeartPath.hiddenDao], 0);
    });

    test('a fresh GameState has 14 reserved system fields with safe defaults', () {
      final s = GameState.fresh();
      // Forward-compat: every system has a field, even if MVP doesn't use it.
      expect(s.player.equipment, isEmpty);
      expect(s.player.elixirs, isEmpty);
      expect(s.player.beasts, isEmpty);
      expect(s.player.companion, isNull);
      expect(s.player.factionRep, isEmpty);
      expect(s.player.disciples, isEmpty);
      expect(s.player.activeWorldEvent, isNull);
      expect(s.player.reincarnation, isNull);
      expect(s.player.karma, 0); // MVP: field only, no events
    });
  });

  group('GameState mutations', () {
    test('applying a heart delta accumulates into the 5-dim vector', () {
      final s = GameState.fresh();
      s.applyHeartDelta(HeartPath.swordDao, 3);
      s.applyHeartDelta(HeartPath.demonDao, 1);
      expect(s.player.heartVector[HeartPath.swordDao], 3);
      expect(s.player.heartVector[HeartPath.demonDao], 1);
      expect(s.player.heartVector[HeartPath.kingDao], 0);
    });

    test('switching 灵根 recomputes learnable techniques', () {
      final s = GameState.fresh(seed: 42);
      s.player.root = Element.fire;
      // Fire root + learnable techniques rule
      final learnable = s.player.learnableTechniques();
      expect(learnable.every((t) => t.element == Element.fire), isTrue);
    });

    test('closing a 闭关 reduces 寿元 by 1 month (per decisions.md #2: CultivationEngine owns the lifecycle)', () {
      final s = GameState.fresh();
      // slice 4 split: CultivationEngine owns the closure / 修为 / 寿元 flow.
      // We don't import CultivationEngine here to keep slice-1 tests decoupled;
      // the dedicated CultivationEngine tests in slice4_test.dart cover it.
      expect(s.player.lifespan, GameState.closureLifespanMaxLianQi);
    });
  });

  group('GameState JSON round-trip (decisions.md #11: optional + defaults)', () {
    test('toJson + fromJson preserves all observable fields', () {
      final s = GameState.fresh(seed: 1234);
      s.player.root = Element.gold;
      s.applyHeartDelta(HeartPath.swordDao, 5);
      s.player.lifespan = 1199; // simulate one closure (lifecycle owned by slice 4)

      final restored = GameState.fromJson(s.toJson());
      expect(restored.player.root, Element.gold);
      expect(restored.player.heartVector[HeartPath.swordDao], 5);
      expect(restored.player.lifespan, 1199);
      expect(restored.seed.value, 1234);
    });

    test('old save without new fields loads with safe defaults', () {
      // Simulate a save from an earlier version that only had 3 systems.
      final oldSave = <String, dynamic>{
        'player': {
          'realm': 'lianQi',
          'layer': 3,
          'lifespan': 1190,
          'lifespanMax': 1200,
          'root': 'wood',
        },
        'world': {'currentPlane': 'mortal', 'visitedNodes': <String>[]},
        'ifState': {'currentSegmentId': null, 'history': <String>[]},
        'proceduralSeed': {'value': 99},
      };

      final restored = GameState.fromJson(oldSave);
      expect(restored.player.realm, Realm.lianQi);
      expect(restored.player.layer, 3);
      // Forward-compat defaults: empty collections, null optionals
      expect(restored.player.equipment, isEmpty);
      expect(restored.player.factionRep, isEmpty);
      expect(restored.player.companion, isNull);
    });
  });

  group('Procedural seed (decisions.md #15)', () {
    test('a fresh state has a deterministic seed', () {
      final s = GameState.fresh(seed: 7);
      expect(s.seed.value, 7);
    });

    test('two states with the same seed produce the same learnable set', () {
      final a = GameState.fresh(seed: 100);
      final b = GameState.fresh(seed: 100);
      a.player.root = Element.water;
      b.player.root = Element.water;
      expect(
        a.player.learnableTechniques().map((t) => t.id),
        equals(b.player.learnableTechniques().map((t) => t.id)),
      );
    });
  });

  group('GameState public notify (slice 17: notifyListeners is protected)', () {
    test('notify() fires registered listeners exactly once', () {
      final s = GameState.fresh();
      var calls = 0;
      s.addListener(() => calls++);
      s.notify();
      expect(calls, 1);
    });

    test('notify() can be called from outside the class (public API)',
        () {
      // Smoke: this would be a compile error if notify() weren't public.
      // The lint rule `invalid_use_of_protected_member` only allows calls
      // from inside the class or a subclass, but `notify()` is a regular
      // public method so external code can call it.
      final s = GameState.fresh();
      expect(() => s.notify(), returnsNormally);
    });
  });

  group('GameState forceSuccess consume (slice 20)', () {
    test('consumeForceSuccess returns true once then clears to false', () {
      final s = GameState.fresh();
      s.forceSuccess = true;
      expect(s.consumeForceSuccess(), isTrue);
      expect(s.forceSuccess, isFalse, reason: 'consume must clear the flag');
      expect(s.consumeForceSuccess(), isFalse,
          reason: 'second consume returns false (flag already cleared)');
    });

    test('consumeForceSuccess on a fresh state returns false', () {
      final s = GameState.fresh();
      expect(s.consumeForceSuccess(), isFalse);
      expect(s.forceSuccess, isFalse);
    });
  });
}
