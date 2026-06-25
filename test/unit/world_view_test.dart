// Vertical Slice 2: World view (list + 2D map) for 凡界.
//
// Per docs/issues/mvp-slice-2.md:
// - 10 凡界 nodes
// - 2 tabs: list view + 2D mini map
// - tap node -> record selection in GameState
// - movement is instant (no time cost)
//
// Per decisions.md #7: Node fields live in Dart (id/coord/element/ifSegments);
// description lives in content/凡界/<node>/description.md (loaded later, MVP
// shows a placeholder).

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jhrm/content/content_loader.dart';
import 'package:jhrm/state/enums.dart' as domain;
import 'package:jhrm/state/game_state.dart';
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
      for (final n in NodeRegistry.mortalNodes) {
        expect(
          find.byKey(Key('map-node-${n.id}')),
          findsOneWidget,
          reason: 'mini map should show node "${n.id}"',
        );
      }
    });
  });

  group('World view ending integration (slice 24)', () {
    testWidgets('when state.ending is set, world view shows the canonical ending IF',
        (tester) async {
      final loader = ContentLoader.fromDirectory(Directory('content/凡界'));
      expect(loader.get('ending-jian-xian'), isNotNull,
          reason: 'precondition: ending-jian-xian must be on disk');

      final state = GameState.fresh();
      state.player.heartVector[domain.HeartPath.swordDao] = 10;
      state.ending = 'ascended-swordDao';

      await tester.pumpWidget(
        MaterialApp(home: WorldView(state: state, contentLoader: loader)),
      );

      // 剑道 dominates → ending-jian-xian. The body text "天道即吾剑"
      // is unique to the 剑仙 segment.
      expect(find.textContaining('天道即吾剑'), findsWidgets,
          reason: 'world view must show the 剑仙 ending IF when state.ending is set');
    });
  });

  group('World view tribulation routing (slice 25)', () {
    testWidgets('at 筑基 9/9 with full xp, world view shows the 筑基→金丹 tribulation IF',
        (tester) async {
      final loader = ContentLoader.fromDirectory(Directory('content/凡界'));
      expect(loader.get('zhuji-9-to-jindan-tribulation'), isNotNull,
          reason: 'precondition: zhuji-9-to-jindan-tribulation must be on disk');

      final state = GameState.fresh();
      // Bump to 筑基 9/9, full xp.
      state.player.realm = domain.Realm.zhuJi;
      state.player.layer = 9;
      state.player.cultivationXp = 100;

      await tester.pumpWidget(
        MaterialApp(home: WorldView(state: state, contentLoader: loader)),
      );

      // Title from the 筑基→金丹 IF is "筑基九层·金丹天劫".
      // (IfScreen renders the title twice — AppBar + body — so we look
      // for at least one match.)
      expect(find.text('筑基九层·金丹天劫'), findsAtLeastNWidgets(1),
          reason: 'must route to the realm-appropriate tribulation IF');
    });
  });

  group('World view plane switching (slice 26)', () {
    test('NodeRegistry returns 8 nodes per post-凡 plane (灵/仙/神)',
        () {
      // 凡界 is 10 (legacy from slice 2); the new planes are 8 each.
      // Per CONTEXT.md: 4 planes × 2 realms each, 6 realms total. Plane
      // boundaries: 凡=炼气/筑基, 灵=金丹/元婴, 仙=化神/大乘, 神=飞升.
      expect(NodeRegistry.spiritNodes.length, 8);
      expect(NodeRegistry.immortalNodes.length, 8);
      expect(NodeRegistry.divineNodes.length, 8);
    });

    test('NodeRegistry.nodesFor maps realms to the right plane', () {
      expect(NodeRegistry.nodesFor(domain.Realm.lianQi), NodeRegistry.mortalNodes);
      expect(NodeRegistry.nodesFor(domain.Realm.zhuJi), NodeRegistry.mortalNodes);
      expect(NodeRegistry.nodesFor(domain.Realm.jinDan), NodeRegistry.spiritNodes);
      expect(NodeRegistry.nodesFor(domain.Realm.yuanYing), NodeRegistry.spiritNodes);
      expect(NodeRegistry.nodesFor(domain.Realm.huaShen), NodeRegistry.immortalNodes);
      expect(NodeRegistry.nodesFor(domain.Realm.daCheng), NodeRegistry.immortalNodes);
    });

    testWidgets('at 金丹期 the world view shows 灵界 nodes + plane name',
        (tester) async {
      final state = GameState.fresh();
      state.player.realm = domain.Realm.jinDan;
      state.player.layer = 1;
      state.player.cultivationXp = 0;

      await tester.pumpWidget(
        MaterialApp(home: WorldView(state: state)),
      );

      // 灵界 has 8 nodes including 浮空岛 (the first spirit node).
      expect(find.text('浮空岛'), findsOneWidget,
          reason: '金丹期 must show 灵界 nodes, not 凡界');
      // App bar shows the plane name.
      expect(find.text('灵 界'), findsOneWidget);
    });
  });
}
