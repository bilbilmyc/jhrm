// GoldFingerOverlay: invisible 50x50 trigger in top-left + 5-tap-in-1s
// detection + modal menu with 8 actions.
//
// Per docs/design/gold-finger.md + ADR-0002:
// - 5 taps within 1s opens the menu
// - Menu items dispatch to GoldFinger.action(...)
// - Tapping outside dismisses
// - Hidden in normal UI (no visible affordance)

import 'dart:math';

import 'package:flutter/material.dart';

import '../engine/gold_finger.dart';
import '../state/game_state.dart';

class GoldFingerOverlay extends StatefulWidget {
  const GoldFingerOverlay({super.key, required this.state, required this.child});
  final GameState state;
  final Widget child;

  @override
  State<GoldFingerOverlay> createState() => _GoldFingerOverlayState();
}

class _GoldFingerOverlayState extends State<GoldFingerOverlay> {
  late final GoldFinger _gf = GoldFinger(widget.state, rng: Random(0));
  bool _open = false;

  void _onTap() {
    if (_gf.onTap()) {
      setState(() => _open = true);
    }
  }

  void _dispatch(GoldAction a) {
    _gf.action(a);
    setState(() => _open = false);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        // Invisible trigger: 50x50 in the top-left corner.
        Positioned(
          left: 0,
          top: 0,
          width: 50,
          height: 50,
          child: GestureDetector(
            key: const Key('gold-finger-trigger'),
            behavior: HitTestBehavior.opaque,
            onTap: _onTap,
            child: const SizedBox.shrink(),
          ),
        ),
        if (_open)
          Positioned.fill(
            child: GestureDetector(
              onTap: () => setState(() => _open = false),
              child: Container(
                color: Colors.black54,
                alignment: Alignment.center,
                child: GestureDetector(
                  onTap: () {}, // absorb taps inside the panel
                  child: Container(
                    width: 280,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text('金手指',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        for (final m in _menuItems())
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: ElevatedButton(
                              onPressed: () => _dispatch(m),
                              child: Text(_labelFor(m)),
                            ),
                          ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: () => setState(() => _open = false),
                          child: const Text('关闭'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  List<GoldAction> _menuItems() => const [
        GoldAction.cultivationTimes10,
        GoldAction.cultivationMax,
        GoldAction.switchRoot,
        GoldAction.resetHeart,
        GoldAction.karmaPlus10,
        GoldAction.lifespanPlus10,
        GoldAction.tribulationSuccess,
      ];

  String _labelFor(GoldAction a) {
    switch (a) {
      case GoldAction.cultivationTimes10:
        return '修为×10';
      case GoldAction.cultivationMax:
        return '修为满';
      case GoldAction.switchRoot:
        return '切换灵根';
      case GoldAction.resetHeart:
        return '切换道心';
      case GoldAction.karmaPlus10:
        return '+10 因果';
      case GoldAction.lifespanPlus10:
        return '+10 寿元';
      case GoldAction.tribulationSuccess:
        return '渡劫成功';
      default:
        return a.name;
    }
  }
}
