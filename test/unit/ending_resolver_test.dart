// Slice 23: EndingResolver — maps the dominant 道心 to one of 5 ending IDs.
//
// Triggered after TribulationEngine.resolve() returns success at 大乘 9/9.
// Each ending corresponds to one HeartPath enum value. Ties resolve to
// the first enum value (swordDao) since Map ordering isn't guaranteed.

import 'package:flutter_test/flutter_test.dart';
import 'package:jhrm/engine/ending_resolver.dart';
import 'package:jhrm/state/enums.dart';
import 'package:jhrm/state/game_state.dart';

void main() {
  group('EndingResolver (slice 23)', () {
    test('dominant 剑道 → 剑仙', () {
      final s = GameState.fresh();
      s.player.heartVector[HeartPath.swordDao] = 10;
      s.player.heartVector[HeartPath.kingDao] = 2;
      expect(EndingResolver.pick(s), 'ending-jian-xian');
    });

    test('dominant 魔道 → 魔尊', () {
      final s = GameState.fresh();
      s.player.heartVector[HeartPath.demonDao] = 7;
      s.player.heartVector[HeartPath.swordDao] = 3;
      expect(EndingResolver.pick(s), 'ending-mo-zun');
    });

    test('dominant 王道 → 圣王', () {
      final s = GameState.fresh();
      s.player.heartVector[HeartPath.kingDao] = 9;
      s.player.heartVector[HeartPath.hiddenDao] = 1;
      expect(EndingResolver.pick(s), 'ending-sheng-wang');
    });

    test('dominant 隐道 → 散仙', () {
      final s = GameState.fresh();
      s.player.heartVector[HeartPath.hiddenDao] = 6;
      s.player.heartVector[HeartPath.noneDao] = 6;
      // Tie: first in enum iteration order wins. HeartPath.values order
      // is swordDao, demonDao, kingDao, hiddenDao, noneDao, so hiddenDao
      // comes before noneDao → 散仙.
      expect(EndingResolver.pick(s), 'ending-san-xian');
    });

    test('dominant 无道 → 天地客', () {
      final s = GameState.fresh();
      // 4 paths equal, noneDao nudges ahead.
      s.player.heartVector[HeartPath.swordDao] = 2;
      s.player.heartVector[HeartPath.demonDao] = 2;
      s.player.heartVector[HeartPath.kingDao] = 2;
      s.player.heartVector[HeartPath.hiddenDao] = 2;
      s.player.heartVector[HeartPath.noneDao] = 3;
      expect(EndingResolver.pick(s), 'ending-tiandi-ke');
    });

    test('all zero → 散仙 (default to 隐道 when no choice was made)', () {
      // Edge case: player ascended without engaging any heart path. The
      // resolver falls back to 隐道 (hiddenDao) as the "walked away" path.
      final s = GameState.fresh();
      expect(EndingResolver.pick(s), 'ending-san-xian');
    });
  });
}
