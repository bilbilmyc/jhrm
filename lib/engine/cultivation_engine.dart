// CultivationEngine: 30s 闭关 → 修为 +1 → 满触发 突破 IF.
// Per decisions.md #12: 30s 闭 = 1 月寿元. MVP only 炼气 9 层.
// Per decisions.md #14: 突破 success 80% + 道心 alignment 10% + force.
// Per decisions.md #8: wall-clock timer, no pause on background.
//
// 修为 lives on Player (not on the engine) so any number of engine
// instances (gold-finger, UI, persistence) all read/write the same value.

import 'dart:math';

import '../state/game_state.dart';

class CultivationEngine {
  CultivationEngine(this.state, {Random? rng}) : _rng = rng ?? Random();
  final GameState state;
  final Random _rng;

  static const int cultivationXpMax = 100;
  static const int lifespanCostPerClosure = 1;
  static const int xpPerClosure = 1;

  // Probability parameters (decisions.md #14).
  static const double baseBreakthroughRate = 0.80;
  static const double heartAlignmentBonus = 0.10;

  int get cultivationXp => state.player.cultivationXp;
  set cultivationXp(int v) =>
      state.player.cultivationXp = v.clamp(0, cultivationXpMax);

  void startClosure() {
    state.startClosure();
  }

  void completeClosure() {
    state.completeClosure();
    // 修为 +1
    state.player.cultivationXp =
        (state.player.cultivationXp + xpPerClosure).clamp(0, cultivationXpMax);
    // 寿元 -1 月 (decisions.md #12)
    state.player.lifespan =
        (state.player.lifespan - lifespanCostPerClosure).clamp(0, 1 << 30);
    // 寿元耗尽 → 跌境界 (decisions.md #2)
    if (state.player.lifespan <= 0 && state.player.layer > 1) {
      state.player.layer -= 1;
      state.player.lifespan = GameState.closureLifespanMaxLianQi ~/ 2;
    }
    // 满 修为 → 突破 IF
    if (state.player.cultivationXp >= cultivationXpMax) {
      _resolveBreakthrough();
    }
    state.notify();
  }

  void _resolveBreakthrough() {
    final rate = _currentBreakthroughRate();
    final roll = _rng.nextDouble();
    // Force is consumed unconditionally so a high roll (which would
    // short-circuit an `||` and skip the consume) still clears the flag.
    final force = state.consumeForceSuccess();
    if (roll < rate || force) {
      // success
      state.player.layer = (state.player.layer + 1).clamp(1, 9);
      state.player.cultivationXp = 0;
    } else {
      // fail: -30% 修为, 寿元 -1 月 (decisions.md #14)
      state.player.cultivationXp =
          (state.player.cultivationXp * 0.70).floor();
      state.player.lifespan =
          (state.player.lifespan - 1).clamp(0, 1 << 30);
    }
  }

  double _currentBreakthroughRate() {
    final top = state.player.heartVector.values.fold<int>(0, (a, b) => a + b);
    if (top <= 0) return baseBreakthroughRate;
    return (baseBreakthroughRate + heartAlignmentBonus).clamp(0.0, 1.0);
  }
}
