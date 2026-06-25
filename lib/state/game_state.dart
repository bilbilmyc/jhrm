// GameState: top-level game state per CONTEXT.md + decisions.md #15.
//
// Composition: Player + World + IfState + ProceduralSeed. All 14 systems
// are reachable via `player`. JSON serialization preserves forward-compat
// (decisions.md #11): unknown / missing fields fall back to defaults.

import 'package:flutter/foundation.dart';

import 'enums.dart';
import 'if_state.dart';
import 'player.dart';
import 'procedural_seed.dart';
import 'world.dart';

class GameState extends ChangeNotifier {
  GameState({
    required this.player,
    required this.world,
    required this.ifState,
    required this.seed,
  });

  final Player player;
  final World world;
  final IfState ifState;
  final ProceduralSeed seed;

  /// Gold-finger flag: forces 100% success on next breakthrough / tribulation.
  /// Cleared after one use so gold-finger doesn't permanently break balance.
  bool forceSuccess = false;

  /// Recorded on ascension (decisions.md #5: 飞升 success = 通关).
  /// null while playing. Format: 'ascended-<heartPathName>' (e.g. ascended-swordDao).
  String? ending;

  /// 30s 闭关 = 1 month 寿元 (decisions.md #12, MVP only)
  static const int closureLifespanCost = 1;
  static const int closureLifespanMaxLianQi = 1200; // 100 years * 12

  factory GameState.fresh({int seed = 1}) => GameState(
        player: Player(
          realm: Realm.lianQi,
          layer: 1,
          lifespan: closureLifespanMaxLianQi,
          lifespanMax: closureLifespanMaxLianQi,
          root: Element.fire,
        ),
        world: World(),
        ifState: IfState(),
        seed: ProceduralSeed(seed),
      );

  // === Lifecycle hooks for engines / UI ===

  /// 闭关 in progress; tracked here so multiple subsystems can observe.
  /// CultivationEngine is the owner of all 修为 / 寿元 / 突破 transitions.
  bool _isClosing = false;
  bool get isClosing => _isClosing;

  void startClosure() {
    _isClosing = true;
  }

  void completeClosure() {
    if (!_isClosing) return;
    _isClosing = false;
    notifyListeners();
  }

  void applyHeartDelta(HeartPath path, int delta) {
    final current = player.heartVector[path] ?? 0;
    player.heartVector[path] = current + delta;
    notifyListeners();
  }

  // === JSON round-trip (decisions.md #11) ===

  Map<String, dynamic> toJson() => {
        'player': player.toJson(),
        'world': world.toJson(),
        'ifState': ifState.toJson(),
        'proceduralSeed': seed.toJson(),
      };

  factory GameState.fromJson(Map<String, dynamic> j) {
    return GameState(
      player: Player.fromJson(j['player'] as Map<String, dynamic>),
      world: World.fromJson(j['world'] as Map<String, dynamic>),
      ifState: IfState.fromJson(j['ifState'] as Map<String, dynamic>),
      seed: ProceduralSeed.fromJson(j['proceduralSeed'] as Map<String, dynamic>),
    );
  }
}
