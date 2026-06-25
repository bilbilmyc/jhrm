// MiniMap: 2D node visualization. Per slice 2: nodes render at
// (x, y) with no overlap, each is tappable to record selection.

import 'package:flutter/material.dart';

import '../state/game_state.dart';
import 'node.dart';

class MiniMap extends StatelessWidget {
  const MiniMap({super.key, required this.state, required this.nodes});
  final GameState state;
  final List<Node> nodes;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final h = constraints.maxHeight;
        return Stack(
          children: [
            for (final n in nodes)
              Positioned(
                left: n.x * w - 16,
                top: n.y * h - 16,
                child: GestureDetector(
                  key: Key('map-node-${n.id}'),
                  onTap: () {
                    state.world.selectedNodeId = n.id;
                    state.notifyListeners();
                  },
                  child: Container(
                    width: 32,
                    height: 32,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: state.world.selectedNodeId == n.id
                          ? Colors.amber
                          : Colors.brown.shade300,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.black54),
                    ),
                    child: Text(
                      n.name.characters.first,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
