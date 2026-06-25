// GoldFinger: hidden developer menu (per docs/design/gold-finger.md +
// ADR-0002). Triggers: 5-tap top-left within 1s, or 'godmode' password.
// 13 actions in 4 categories. Debug build only — release noops.
//
// In Flutter the tap detector needs a real widget to attach to; this class
// is the pure-logic core (timer, password, action dispatch). The widget
// overlay arrives in a later UI polish pass.

import 'dart:math';

import 'cultivation_engine.dart';
import '../state/enums.dart';
import '../state/game_state.dart';

enum GoldAction {
  cultivationTimes10,
  cultivationTimes100,
  cultivationMax,
  skipToNext,
  switchRoot,
  resetHeart,
  karmaPlus10,
  lifespanPlus10,
  tribulationSuccess,
  resetSave, // file-level: handled by SaveService in slice 7
  exit,
}

class GoldFinger {
  GoldFinger(this.state, {Random? rng}) : _rng = rng ?? Random();
  final GameState state;
  final Random _rng;

  static const int _tapThreshold = 5;
  static const Duration _tapWindow = Duration(seconds: 1);

  final List<Duration> _taps = [];
  static const String _password = 'godmode';

  /// Returns true iff the tap completed a 5-tap-in-1s trigger.
  /// `at` is the time elapsed since the first tap (Duration).
  bool onTap({Duration at = Duration.zero}) {
    _taps.add(at);
    _taps.removeWhere((x) => (at - x).compareTo(_tapWindow) > 0);
    if (_taps.length >= _tapThreshold) {
      _taps.clear();
      return true;
    }
    return false;
  }

  /// Returns true iff the typed word matches the password.
  bool onPassword(String word) {
    if (word.toLowerCase() == _password) {
      _taps.clear();
      return true;
    }
    return false;
  }

  void action(GoldAction a) {
    switch (a) {
      case GoldAction.cultivationTimes10:
      case GoldAction.cultivationTimes100:
        final factor = a == GoldAction.cultivationTimes10 ? 10 : 100;
        final e = CultivationEngine(state);
        e.cultivationXp = e.cultivationXp * factor;
        break;
      case GoldAction.cultivationMax:
        final e = CultivationEngine(state);
        e.cultivationXp = CultivationEngine.cultivationXpMax;
        break;
      case GoldAction.skipToNext:
        // Stub: real impl needs IF engine context (slice 3 hook).
        break;
      case GoldAction.switchRoot:
        final choices = Element.values
            .where((e) => e != Element.wind && e != Element.thunder && e != Element.ice)
            .toList();
        state.player.root = choices[_rng.nextInt(choices.length)];
        break;
      case GoldAction.resetHeart:
        for (final p in state.player.heartVector.keys.toList()) {
          state.player.heartVector[p] = 0;
        }
        break;
      case GoldAction.karmaPlus10:
        state.player.karma += 10;
        break;
      case GoldAction.lifespanPlus10:
        state.player.lifespan += 10;
        break;
      case GoldAction.tribulationSuccess:
        state.forceSuccess = true;
        break;
      case GoldAction.resetSave:
        // Owned by SaveService; the menu widget wires it.
        break;
      case GoldAction.exit:
        break;
    }
    state.notifyListeners();
  }
}
