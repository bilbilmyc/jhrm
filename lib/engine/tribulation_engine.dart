// TribulationEngine: 渡劫 IF outcome (decisions.md #13).
//
// Formula: success = 50% + 寿元%×20% + 道心最强 path×10% + forceSuccess 100%
// Outcomes:
//   success mid-realm (炼气→筑基, 筑基→金丹, 金丹→元婴, 元婴→化神,
//                       化神→大乘) → 升 next_realm 1/9 + 寿元 → 新上限
//   success at 大乘 9/9 → ascension: ending set via EndingResolver
//   failure → 跌回 current_realm 1/9 + 寿元 = 50% 上限
//
// Per-realm lifespan max (in months) doubles each realm:
//   炼气=1200 (100y), 筑基=2400 (200y), 金丹=4800 (400y),
//   元婴=9600 (800y), 化神=19200 (1600y), 大乘=38400 (3200y).

import 'dart:math';

import '../state/enums.dart';
import '../state/game_state.dart';
import 'ending_resolver.dart';

enum TribulationResult { success, failure }

class TribulationEngine {
  TribulationEngine(this.state, {Random? rng}) : _rng = rng ?? Random();
  final GameState state;
  final Random _rng;

  static const double baseRate = 0.50;
  static const double lifespanBonusCap = 0.20;
  static const double heartAlignmentBonus = 0.10;

  /// Returns the next realm in the 6-realm chain, or null for 大乘
  /// (which means ascension, not another realm).
  static Realm? nextRealm(Realm current) {
    switch (current) {
      case Realm.lianQi:
        return Realm.zhuJi;
      case Realm.zhuJi:
        return Realm.jinDan;
      case Realm.jinDan:
        return Realm.yuanYing;
      case Realm.yuanYing:
        return Realm.huaShen;
      case Realm.huaShen:
        return Realm.daCheng;
      case Realm.daCheng:
        return null; // ascension
    }
  }

  /// Returns the max 寿元 in months for a realm. The lifespan doubles
  /// per realm — keeps the "灵气越浓 寿元越长" intuition while staying
  /// representable in an int32 (大乘 = 38400 months = 3200 years).
  static int lifespanFor(Realm realm) {
    switch (realm) {
      case Realm.lianQi:
        return 1200;
      case Realm.zhuJi:
        return 2400;
      case Realm.jinDan:
        return 4800;
      case Realm.yuanYing:
        return 9600;
      case Realm.huaShen:
        return 19200;
      case Realm.daCheng:
        return 38400;
    }
  }

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
    // Force is consumed unconditionally — see cultivation_engine note.
    final force = state.consumeForceSuccess();
    if (roll < rate || force) {
      _applySuccess();
      return TribulationResult.success;
    } else {
      _applyFailure();
      return TribulationResult.failure;
    }
  }

  void _applySuccess() {
    final next = nextRealm(state.player.realm);
    if (next == null) {
      // 大乘 9/9 → ascension. The world_view checks state.ending to show
      // the canonical ending IF (slice 24). Layer stays at 9 — the game
      // is over from here; restart resets to 炼气 1/9.
      final endingId = EndingResolver.pick(state);
      // EndingResolver returns an IF segment id; we store the
      // 道心-flavoured marker for backwards-compat with existing tests
      // and any future stats / achievements.
      state.ending = 'ascended-${_topHeartPath().name}';
      // Touch endingId so the analyzer doesn't flag it unused — the
      // marker above is what persistence cares about; the resolver's
      // segment id is the source of truth for *which* prose the
      // world_view shows. The 1:1 mapping by 主导 道心 is the contract.
      assert(endingId.startsWith('ending-'),
          'EndingResolver contract: every heart path maps to an ending- segment');
      state.notify();
      return;
    }
    // Mid-realm advance: bump to next realm 1/9 with new lifespan.
    state.player.realm = next;
    state.player.layer = 1;
    final newMax = lifespanFor(next);
    state.player.lifespan = newMax;
    state.player.lifespanMax = newMax;
    state.player.cultivationXp = 0;
    state.notify();
  }

  void _applyFailure() {
    // Drop within the same realm (not all the way back to 炼气) — the
    // 修真 convention is "跌回 1/9 in current realm" not "lose everything".
    state.player.realm = state.player.realm;
    state.player.layer = 1;
    // 寿元 = 50% 上限 (decisions.md #2)
    final half = state.player.lifespanMax ~/ 2;
    state.player.lifespan = half;
    state.notify();
  }

  /// Forces ascension at 大乘 — the 5-选项 IF has already applied the
  /// player's heart_delta, this just sets the ending marker and notifies.
  /// Precondition: state.player.realm == daCheng.
  void forceAscend() {
    if (state.player.realm != Realm.daCheng) {
      throw StateError(
        'forceAscend called at realm ${state.player.realm.displayName}, '
        'expected 大乘期',
      );
    }
    state.ending = 'ascended-${_topHeartPath().name}';
    state.notify();
  }

  HeartPath _topHeartPath() {
    final entries = state.player.heartVector.entries.toList();
    entries.sort((a, b) => b.value.compareTo(a.value));
    return entries.first.key;
  }
}
