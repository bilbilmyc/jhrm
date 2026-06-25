// MiniMap: 修真风 2D map. Background = 山水 scroll; nodes = colored
// glyph discs with element ring.

import 'package:flutter/material.dart';

import '../state/game_state.dart';
import '../ui/theme.dart';
import 'node.dart';

class MiniMap extends StatelessWidget {
  const MiniMap({
    super.key,
    required this.state,
    required this.nodes,
    this.onNodeTapped,
  });
  final GameState state;
  final List<Node> nodes;
  final ValueChanged<String>? onNodeTapped;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final h = constraints.maxHeight;
        return Stack(
          children: [
            // 山影 — three soft circles at the bottom for depth
            Positioned(
              left: w * 0.05,
              bottom: -h * 0.1,
              child: _mountain(h * 0.5, w * 0.5, XianxiaTheme.shadowBrown.withValues(alpha: 0.18)),
            ),
            Positioned(
              right: w * 0.05,
              bottom: -h * 0.15,
              child: _mountain(h * 0.55, w * 0.55, XianxiaTheme.shadowBrown.withValues(alpha: 0.14)),
            ),
            for (final n in nodes)
              Positioned(
                left: n.x * w - 22,
                top: n.y * h - 22,
                child: GestureDetector(
                  key: Key('map-node-${n.id}'),
                  onTap: () {
                    state.world.selectedNodeId = n.id;
                    state.notify();
                    onNodeTapped?.call(n.name);
                  },
                  child: _mapNode(n),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _mountain(double h, double w, Color color) {
    return Container(
      width: w,
      height: h,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _mapNode(Node n) {
    final selected = state.world.selectedNodeId == n.id;
    final color = XianxiaTheme.elementColor[n.element.displayName] ??
        XianxiaTheme.goldLeaf;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 44,
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? color : XianxiaTheme.paperWhite,
            border: Border.all(
              color: color,
              width: selected ? 2.5 : 1.2,
            ),
            shape: BoxShape.circle,
            boxShadow: selected
                ? [BoxShadow(color: color.withValues(alpha: 0.4), blurRadius: 6, spreadRadius: 2)]
                : null,
          ),
          child: Text(
            n.element.displayName,
            style: TextStyle(
              color: selected ? XianxiaTheme.paperWhite : color,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 2),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
          color: XianxiaTheme.paperWhite.withValues(alpha: 0.8),
          child: Text(
            n.name,
            style: const TextStyle(
              fontSize: 9,
              color: XianxiaTheme.inkBlack,
              letterSpacing: 1,
            ),
          ),
        ),
      ],
    );
  }
}
