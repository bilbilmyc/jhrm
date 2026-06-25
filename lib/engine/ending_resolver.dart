// EndingResolver: maps a GameState's dominant 道心 to a 飞升 ending ID.
//
// Triggered after TribulationEngine.resolve() returns success at 大乘 9/9.
// Each HeartPath maps to one ending segment id. Ties resolve to the first
// HeartPath in enum iteration order (swordDao → demonDao → kingDao →
// hiddenDao → noneDao).
//
// All-zero fallback: if the player ascended without engaging any heart
// path, we return 散仙 (hiddenDao) — the "walked away without choosing"
// reading of the path.

import '../state/enums.dart';
import '../state/game_state.dart';

class EndingResolver {
  EndingResolver._();

  static const Map<HeartPath, String> _byPath = {
    HeartPath.swordDao: 'ending-jian-xian',
    HeartPath.demonDao: 'ending-mo-zun',
    HeartPath.kingDao: 'ending-sheng-wang',
    HeartPath.hiddenDao: 'ending-san-xian',
    HeartPath.noneDao: 'ending-tiandi-ke',
  };

  /// Returns the segment id of the ending that matches the player's
  /// dominant heart path. If all paths are 0, returns 散仙 (隐道).
  static String pick(GameState state) {
    final entries = state.player.heartVector.entries.toList();
    entries.sort((a, b) => b.value.compareTo(a.value));
    final top = entries.first;
    if (top.value <= 0) {
      // No choice made: fall back to 散仙.
      return _byPath[HeartPath.hiddenDao]!;
    }
    return _byPath[top.key]!;
  }
}
