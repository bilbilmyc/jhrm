// GoldFingerOverlay: 修真风格. Same 5-tap trigger, but the menu is
// styled as a 符箓 (talisman) panel with ink-and-gold colors.

import 'dart:math';

import 'package:flutter/material.dart';

import '../engine/gold_finger.dart';
import '../state/game_state.dart';
import 'theme.dart';

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
        if (_open) _talismanPanel(),
      ],
    );
  }

  Widget _talismanPanel() {
    return Positioned.fill(
      child: GestureDetector(
        onTap: () => setState(() => _open = false),
        child: Container(
          color: Colors.black54,
          alignment: Alignment.center,
          child: GestureDetector(
            onTap: () {},
            child: Container(
              width: 300,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: XianxiaTheme.paperWhite,
                border: Border.all(color: XianxiaTheme.cinnabarRed, width: 2),
                borderRadius: BorderRadius.circular(2),
                boxShadow: const [
                  BoxShadow(
                    color: XianxiaTheme.cinnabarRed,
                    blurRadius: 0,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    decoration: BoxDecoration(
                      color: XianxiaTheme.cinnabarRed,
                      borderRadius: BorderRadius.circular(1),
                    ),
                    child: const Text(
                      '金 手 指',
                      style: TextStyle(
                        color: XianxiaTheme.paperWhite,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 8,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  XianxiaTheme.sealDivider(),
                  for (final a in _menuItems())
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 3),
                      child: SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () => _dispatch(a),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: XianxiaTheme.inkBlack,
                            side: const BorderSide(
                              color: XianxiaTheme.shadowBrown,
                              width: 0.5,
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            alignment: Alignment.centerLeft,
                          ),
                          child: Text(
                            _labelFor(a),
                            style: const TextStyle(
                              fontSize: 14,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => setState(() => _open = false),
                    child: const Text('关闭',
                        style: TextStyle(
                          color: XianxiaTheme.shadowBrown,
                          letterSpacing: 2,
                        )),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
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
        return '修为 × 10';
      case GoldAction.cultivationMax:
        return '修为灌满';
      case GoldAction.switchRoot:
        return '转换灵根';
      case GoldAction.resetHeart:
        return '重置道心';
      case GoldAction.karmaPlus10:
        return '+10 因果';
      case GoldAction.lifespanPlus10:
        return '+10 寿元';
      case GoldAction.tribulationSuccess:
        return '强渡天劫';
      default:
        return a.name;
    }
  }
}
