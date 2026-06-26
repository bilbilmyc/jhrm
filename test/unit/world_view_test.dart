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

      expect(find.text('浮空岛'), findsOneWidget,
          reason: '金丹期 must show 灵界 nodes, not 凡界');
      expect(find.text('灵 界'), findsOneWidget);
    });
  });

  group('飞升 5-选项 IF (slice 30)', () {
    testWidgets('at 大乘 9/9 + xp 100, world view shows 飞升·五道抉择',
        (tester) async {
      final loader = ContentLoader.fromDirectory(Directory('content/凡界'));
      expect(loader.get('dacheng-ascension'), isNotNull,
          reason: 'precondition: dacheng-ascension must be on disk');

      final state = GameState.fresh();
      state.player.realm = domain.Realm.daCheng;
      state.player.layer = 9;
      state.player.cultivationXp = 100;

      await tester.pumpWidget(
        MaterialApp(home: WorldView(state: state, contentLoader: loader)),
      );

      expect(find.text('飞升·五道抉择'), findsAtLeastNWidgets(1),
          reason: 'auto-routes to 飞升 5-选项 IF at 大乘 9/9 + xp 100');
      for (final opt in [
        '以剑入道，斩断一切',
        '以魔代天，夺而自立',
        '以王承道，修补秩序',
        '以隐避世，飘然远引',
        '破道而立，不立文字',
      ]) {
        expect(find.text(opt), findsOneWidget, reason: '5-选项 must include "$opt"');
      }
    });

    testWidgets('tapping 以剑入道 ascends with 剑道 +5 + ending set',
        (tester) async {
      final loader = ContentLoader.fromDirectory(Directory('content/凡界'));
      final state = GameState.fresh();
      state.player.realm = domain.Realm.daCheng;
      state.player.layer = 9;
      state.player.cultivationXp = 100;

      await tester.pumpWidget(
        MaterialApp(home: WorldView(state: state, contentLoader: loader)),
      );

      await tester.tap(find.text('以剑入道，斩断一切'));
      await tester.pumpAndSettle();

      expect(state.player.heartVector[domain.HeartPath.swordDao], 5,
          reason: 'choice bumps 剑道 by 5');
      expect(state.ending, 'ascended-swordDao',
          reason: 'forceAscend sets ending from dominant 道心');
    });

    testWidgets('with 玉箫, world view shows 道侣 飞升 IF first (slice 43)',
        (tester) async {
      final loader = ContentLoader.fromDirectory(Directory('content/凡界'));
      expect(loader.get('dacheng-companion-ascension'), isNotNull,
          reason: 'precondition: 道侣飞升 IF on disk');

      final state = GameState.fresh();
      state.player.realm = domain.Realm.daCheng;
      state.player.layer = 9;
      state.player.cultivationXp = 100;
      state.player.daoCompanion = '玉箫';

      await tester.pumpWidget(
        MaterialApp(home: WorldView(state: state, contentLoader: loader)),
      );

      // With companion, the 道侣-ascension IF takes priority.
      expect(find.text('飞升·道侣'), findsAtLeastNWidgets(1),
          reason: 'with 道侣, world view routes to 道侣-ascension IF first');
      // 3 options for 玉箫's choice.
      for (final opt in [
        '「我随你。」',
        '「你留此界。」',
        '「道消于此，我独行。」',
      ]) {
        expect(find.text(opt), findsOneWidget);
      }
    });
  });

  group('World view save UI (slice 35)', () {
    // Implementation is in world_view (PopupMenuButton with 保存/重置
    // items). Widget tests for the popup menu are flaky in the test
    // framework's fake-async zone (the save() Future crosses to real
    // I/O). The end-to-end save+reset behavior is covered by the
    // gold_finger_overlay_test "SaveService + resetToFresh" companion
    // test. Manual UI verification happens in slice 38 (flutter run).
  });

  group('Tribulation result view — mid-realm success (regression)', () {
    testWidgets(
        'mid-realm success action button does NOT reset realm back to 炼气',
        (tester) async {
      // Pre-fix bug: _TribulationResultView showed "再次踏入修真路" +
      // onRestart for both mid-realm success and ascension success. The
      // ascension path is intercepted by the ending IF (state.ending
      // takes priority), but mid-realm success fell through to this
      // view — and tapping the restart button yanked the player from
      // 筑基 1/9 back to 炼气 1/9.
      //
      // Post-fix: the view's only action button is "继续" + onDismiss,
      // which closes the result view and returns the player to the
      // world map at their new realm.
      final loader = ContentLoader.fromDirectory(Directory('content/凡界'));
      expect(loader.get('lianqi-9-to-zhuji-tribulation'), isNotNull,
          reason: 'precondition: 炼气→筑基 tribulation IF on disk');

      final state = GameState.fresh();
      state.player.realm = domain.Realm.lianQi;
      state.player.layer = 9;
      state.player.cultivationXp = 100;
      // Bypass RNG so the test is deterministic regardless of seed.
      state.forceSuccess = true;

      await tester.pumpWidget(
        MaterialApp(home: WorldView(state: state, contentLoader: loader)),
      );

      // World view auto-routes to the realm-appropriate tribulation IF.
      // Tap the first choice to resolve.
      await tester.tap(find.text('默念所修功法，以心御雷'));
      await tester.pumpAndSettle();

      // After successful resolution: realm advanced, layer reset, xp 0.
      expect(state.player.realm, domain.Realm.zhuJi,
          reason: 'tribulation success at 炼气 9/9 → 筑基 1/9');
      expect(state.player.layer, 1);
      expect(state.player.cultivationXp, 0);
      expect(state.ending, isNull,
          reason: 'mid-realm success must NOT set state.ending');

      // The result view is on screen with one action button. Tapping it
      // must leave the player at 筑基 — never reset back to 炼气.
      final actionButton = find.byType(ElevatedButton);
      expect(actionButton, findsOneWidget,
          reason: 'result view shows exactly one action button');
      await tester.tap(actionButton);
      await tester.pumpAndSettle();

      expect(state.player.realm, domain.Realm.zhuJi,
          reason: 'action button must not reset realm back to 炼气');
      expect(state.player.layer, 1,
          reason: 'action button must not reset layer');
      expect(state.player.cultivationXp, 0,
          reason: 'action button must not zero cultivationXp');
    });
  });
}
