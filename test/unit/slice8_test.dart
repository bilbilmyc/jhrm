// Slice 8: wire node tap → IfScreen. Plus: file-based ContentLoader +
// Chinese heart_delta key forward-compat (per decisions.md #11).

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jhrm/content/content_loader.dart';
import 'package:jhrm/content/if_segment.dart';
import 'package:jhrm/state/enums.dart';
import 'package:jhrm/state/game_state.dart';
import 'package:jhrm/world/world_view.dart';

void main() {
  group('IfChoice Chinese heart_delta keys (forward compat)', () {
    test('"剑道" maps to HeartPath.swordDao', () {
      final seg = IfSegment.fromJson({
        'id': 'x',
        'next': [
          {
            'choice': 'a',
            'goto': 'b',
            'heart_delta': {'剑道': 3, '王道': 1}
          }
        ]
      });
      expect(seg.next[0].heartDelta[HeartPath.swordDao], 3);
      expect(seg.next[0].heartDelta[HeartPath.kingDao], 1);
    });
  });

  group('ContentLoader.fromDirectory (slice 8)', () {
    test('loads all .md files in a directory tree', () {
      // Use the project's own content/凡界/ as the test fixture.
      final dir = Directory('content/凡界');
      if (!dir.existsSync()) {
        // Skip when running outside the project root.
        return;
      }
      final loader = ContentLoader.fromDirectory(dir);
      final ids = loader.all().map((s) => s.id).toSet();
      // 12 content files exist; verify some expected ids are present.
      expect(ids, contains('shanmen-first-meeting'));
      expect(ids, contains('lianqi-9-to-zhuji-tribulation'));
    });
  });

  group('WorldView tap → IfScreen (slice 8)', () {
    testWidgets('tapping a node navigates to IfScreen with that node first segment', (tester) async {
      // Inject a tiny in-memory loader so the test is hermetic.
      final loader = ContentLoader.fromString('''
---
id: shanmen-test
title: 山门测试
trigger:
  location: 山门
next:
  - choice: "请教"
    goto: shanmen-train
    heart_delta:
      swordDao: 1
---
山门正文。
''');
      final state = GameState.fresh();
      await tester.pumpWidget(
        MaterialApp(home: WorldView(state: state, contentLoader: loader)),
      );
      // Switch to list tab (default) and tap 山门 node
      await tester.tap(find.text('山门'));
      await tester.pumpAndSettle();
      // The IfScreen for shanmen-test is now on top
      expect(find.text('山门测试'), findsOneWidget);
    });
  });
}
