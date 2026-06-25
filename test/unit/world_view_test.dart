// Vertical Slice 2: World view (list + 2D map) for 凡界.
//
// Per docs/issues/mvp-slice-2.md:
// - 10 凡界 nodes
// - 2 tabs: list view + 2D mini map
// - tap node -> record selection
// - movement is instant (no time cost)
//
// Per decisions.md #7: Node fields live in Dart (id/coord/element/ifSegments);
// description lives in content/凡界/<node>/description.md (loaded later, MVP
// shows a placeholder).

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jhrm/state/enums.dart';
import 'package:jhrm/state/game_state.dart';
import 'package:jhrm/world/node.dart';
import 'package:jhrm/world/node_registry.dart';
import 'package:jhrm/world/world_view.dart';

void main() {
  group('NodeRegistry (slice 2)', () {
    test('exposes exactly 10 凡界 nodes', () {
      expect(NodeRegistry.mortalNodes.length, 10);
    });

    test('every node has a unique id, name, and non-overlapping coords', () {
      final nodes = NodeRegistry.mortalNodes;
      final ids = nodes.map((n) => n.id).toSet();
      expect(ids.length, nodes.length, reason: 'node ids must be unique');
      final positions = nodes.map((n) => '${n.x},${n.y}').toSet();
      expect(positions.length, nodes.length, reason: 'node positions must not overlap');
    });

    test('every node references at least one IF segment', () {
      for (final n in NodeRegistry.mortalNodes) {
        expect(n.ifSegmentIds, isNotEmpty, reason: '${n.id} has no IF segments');
      }
    });
  });

  group('World view (slice 2 widget)', () {
    testWidgets('renders all 10 nodes in the list tab by default', (tester) async {
      final state = GameState.fresh();
      await tester.pumpWidget(
        MaterialApp(home: WorldView(state: state)),
      );
      // First tab is "list"
      for (final n in NodeRegistry.mortalNodes) {
        expect(find.text(n.name), findsOneWidget,
            reason: 'list should show node "${n.name}"');
      }
    });

    testWidgets('tapping a node records selection in GameState', (tester) async {
      final state = GameState.fresh();
      await tester.pumpWidget(
        MaterialApp(home: WorldView(state: state)),
      );
      final firstNode = NodeRegistry.mortalNodes.first;
      await tester.tap(find.text(firstNode.name));
      await tester.pump();
      expect(state.world.selectedNodeId, firstNode.id);
    });

    testWidgets('switching to map tab shows the mini map', (tester) async {
      final state = GameState.fresh();
      await tester.pumpWidget(
        MaterialApp(home: WorldView(state: state)),
      );
      await tester.tap(find.text('地图'));
      await tester.pump();
      // Mini map shows a tap-target per node
      for (final n in NodeRegistry.mortalNodes) {
        expect(
          find.byKey(Key('map-node-${n.id}')),
          findsOneWidget,
          reason: 'mini map should show node "${n.id}"',
        );
      }
    });
  });
}
