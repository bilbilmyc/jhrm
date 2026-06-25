// TribulationEngine: 渡劫 IF outcome (decisions.md #13).
// Formula: success = 50% + 寿元%×20% + 道心最强 path×10% + forceSuccess 100%
// Outcome: success → 升 筑基 1/9 + ending recorded
//          fail → 跌回 炼气 1/9 + 寿元 = 50% 上限

import 'dart:math';

import '../state/enums.dart';
import '../state/game_state.dart';

enum TribulationResult { success, failure }

class TribulationEngine {
  TribulationEngine(this.state, {Random? rng}) : _rng = rng ?? Random();
  final GameState state;
  final Random _rng;

  static const double baseRate = 0.50;
  static const double lifespanBonusCap = 0.20;
  static const double heartAlignmentBonus = 0.10;

  /// Pre-roll calculation. Exposed for testing.
  double computeSuccessRate() {
    if (state.forceSuccess) return 1.0;
    final lifespanRatio = state.player.lifespanMax == 0
        ? 0.0
        : state.player.lifespan / state.player.lifespanMax;
    final lifespanBonus = (lifespanRatio * lifespanBonusCap).clamp(0.0, lifespanBonusCap);
    final topHeart = state.player.heartVector.values.fold<int>(0, (a, b) => a + b);
    final heartBonus = topHeart > 0 ? heartAlignmentBonus : 0.0;
    return (baseRate + lifespanBonus + heartBonus).clamp(0.0, 1.0);
  }

  TribulationResult resolve() {
    final rate = computeSuccessRate();
    final roll = _rng.nextDouble();
    if (roll < rate || state.forceSuccess) {
      _applySuccess();
      return TribulationResult.success;
    } else {
      _applyFailure();
      return TribulationResult.failure;
    }
  }

  void _applySuccess() {
    // 升到 筑基 1/9
    state.player.realm = Realm.zhuJi;
    state.player.layer = 1;
    // 寿元上限扩展到新位面标准
    state.player.lifespan = 2400; // 筑基 200 年 = 2400 月
    state.player.lifespanMax = 2400;
    // 记录 ending
    final topPath = _topHeartPath();
    state.ending = 'ascended-${topPath.name}';
    state.notifyListeners();
  }

  void _applyFailure() {
    // 跌回 炼气 1/9
    state.player.realm = Realm.lianQi;
    state.player.layer = 1;
    // 寿元 = 50% 上限 (decisions.md #2)
    final half = GameState.closureLifespanMaxLianQi ~/ 2;
    state.player.lifespan = half;
    state.player.lifespanMax = GameState.closureLifespanMaxLianQi;
    state.notifyListeners();
  }

  HeartPath _topHeartPath() {
    final entries = state.player.heartVector.entries.toList();
    entries.sort((a, b) => b.value.compareTo(a.value));
    return entries.first.key;
  }
}
