// Slice 3: IF segment loader, IfScreen, choice navigation, heart delta.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jhrm/content/content_loader.dart';
import 'package:jhrm/content/if_segment.dart';
import 'package:jhrm/content/if_template.dart';
import 'package:jhrm/content/if_screen.dart';
import 'package:jhrm/state/enums.dart';
import 'package:jhrm/state/game_state.dart';

const _sampleText = '''---
id: meeting-elder
title: 山门老者
trigger:
  location: shan-men
next:
  - choice: "请教修炼"
    goto: training-01
    heart_delta:
      swordDao: 1
  - choice: "打声招呼"
    goto: exit-01
    heart_delta: {}
---
你来到山门，见一老者端坐于松下。
他看了你一眼，{{#if isFire}}火光映照。{{/if}}
''';

void main() {
  group('ContentLoader (slice 3)', () {
    test('parses a single .md segment with frontmatter and body', () {
      final loader = ContentLoader.fromString(_sampleText);
      final seg = loader.get('meeting-elder');
      expect(seg, isNotNull);
      expect(seg!.title, '山门老者');
      expect(seg.trigger.location, 'shan-men');
      expect(seg.next.length, 2);
      expect(seg.next[0].choice, '请教修炼');
      expect(seg.next[0].goto, 'training-01');
      expect(seg.next[0].heartDelta[HeartPath.swordDao], 1);
      expect(seg.body.contains('你来到山门'), isTrue);
    });

    test('returns null for unknown segment id', () {
      final loader = ContentLoader.fromString(_sampleText);
      expect(loader.get('nope'), isNull);
    });
  });

  group('IfTemplate (decisions.md #10: minimal Mustache)', () {
    test('replaces {{var}} placeholders', () {
      final out = renderIfTemplate('道心: {{value}}', {'value': 42});
      expect(out, '道心: 42');
    });

    test('renders {{#if}}...{{/if}} block when truthy', () {
      final out = renderIfTemplate(
        'a {{#if x}}yes{{/if}} b',
        {'x': true},
      );
      expect(out, 'a yes b');
    });

    test('omits {{#if}}...{{/if}} block when falsy', () {
      final out = renderIfTemplate(
        'a {{#if x}}yes{{/if}} b',
        {'x': false},
      );
      expect(out, 'a  b');
    });
  });

  group('IfScreen widget (slice 3)', () {
    testWidgets('renders body and choice buttons, applies heart delta on tap', (tester) async {
      final loader = ContentLoader.fromString(_sampleText);
      final seg = loader.get('meeting-elder')!;
      final state = GameState.fresh();

      await tester.pumpWidget(
        MaterialApp(home: IfScreen(state: state, segment: seg, onExit: () {})),
      );

      expect(find.textContaining('山门老者'), findsAtLeastNWidgets(1));
      expect(find.text('请教修炼'), findsOneWidget);
      expect(find.text('打声招呼'), findsOneWidget);

      await tester.tap(find.text('请教修炼'));
      await tester.pump();
      expect(state.player.heartVector.values.fold<int>(0, (a, b) => a + b), 1);
    });
  });
}
