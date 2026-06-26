// Slice 45: 道侣 共振 + 因果 mechanic tests.
//
// Verifies the public behavior of IfScreen._applyChoice's two side
// effects added in slices 36 (karma) and 42 (companion resonance):
//   - 道侣 = 玉箫 (隐道) → 隐道 choice +1 (共振)
//   - 道侣 = 玉箫 (隐道) → 魔道 choice -1 (逆冲)
//   - 道侣 = null → no influence
//   - karma_delta applies to state.player.karma
//   - companion field sets state.player.daoCompanion
//
// Tests use a real IfSegment constructed in code (no need to load
// from disk for these focused tests).

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jhrm/content/if_screen.dart';
import 'package:jhrm/content/if_segment.dart';
import 'package:jhrm/state/enums.dart' as domain;
import 'package:jhrm/state/game_state.dart';

IfSegment _makeSegment(List<IfChoice> choices) {
  return IfSegment(
    id: 'test-seg',
    title: '测试段',
    body: '一段测试正文。',
    next: choices,
  );
}

void main() {
  group('道侣 共振 (slice 45)', () {
    testWidgets('玉箫 + 隐道 选项 → 隐道 +2 (choice +1 共振)', (tester) async {
      final s = GameState.fresh();
      s.player.daoCompanion = '玉箫';
      final seg = _makeSegment([
        const IfChoice(
          choice: '修真者选 隐道 选项',
          heartDelta: {domain.HeartPath.hiddenDao: 1},
        ),
      ]);
      await tester.pumpWidget(MaterialApp(
        home: IfScreen(state: s, segment: seg, onExit: () {}),
      ));
      await tester.tap(find.text('修真者选 隐道 选项'));
      await tester.pumpAndSettle();
      // Choice +1 + 共振 +1 = +2 隐道.
      expect(s.player.heartVector[domain.HeartPath.hiddenDao], 2,
          reason: '玉箫 隐道 共振: 1 (choice) + 1 (companion) = 2');
    });

    testWidgets('玉箫 + 魔道 选项 → 魔道 0 (choice +1 - 逆冲 1)', (tester) async {
      final s = GameState.fresh();
      s.player.daoCompanion = '玉箫';
      final seg = _makeSegment([
        const IfChoice(
          choice: '修真者选 魔道 选项',
          heartDelta: {domain.HeartPath.demonDao: 1},
        ),
      ]);
      await tester.pumpWidget(MaterialApp(
        home: IfScreen(state: s, segment: seg, onExit: () {}),
      ));
      await tester.tap(find.text('修真者选 魔道 选项'));
      await tester.pumpAndSettle();
      // 玉箫 魔道 逆冲: 1 (choice) - 1 (companion) = 0.
      // Mechanic: companion's unease softens the chosen path.
      expect(s.player.heartVector[domain.HeartPath.demonDao], 0,
          reason: '玉箫 魔道 逆冲: 1 (choice) - 1 (companion) = 0');
    });

    testWidgets('no 道侣 → no 共振 (baseline)', (tester) async {
      final s = GameState.fresh();
      s.player.daoCompanion = null;
      final seg = _makeSegment([
        const IfChoice(
          choice: '修真者选 隐道 选项',
          heartDelta: {domain.HeartPath.hiddenDao: 1},
        ),
      ]);
      await tester.pumpWidget(MaterialApp(
        home: IfScreen(state: s, segment: seg, onExit: () {}),
      ));
      await tester.tap(find.text('修真者选 隐道 选项'));
      await tester.pumpAndSettle();
      expect(s.player.heartVector[domain.HeartPath.hiddenDao], 1,
          reason: 'no companion → +1 only, no resonance');
    });
  });

  group('因果 mechanic (slice 45)', () {
    testWidgets('karma_delta +5 applies to state.player.karma',
        (tester) async {
      final s = GameState.fresh();
      final seg = _makeSegment([
        const IfChoice(choice: '救人', karmaDelta: 5),
      ]);
      await tester.pumpWidget(MaterialApp(
        home: IfScreen(state: s, segment: seg, onExit: () {}),
      ));
      await tester.tap(find.text('救人'));
      await tester.pumpAndSettle();
      expect(s.player.karma, 5);
    });

    testWidgets('karma_delta -3 applies negative', (tester) async {
      final s = GameState.fresh();
      s.player.karma = 10;
      final seg = _makeSegment([
        const IfChoice(choice: '见死不救', karmaDelta: -3),
      ]);
      await tester.pumpWidget(MaterialApp(
        home: IfScreen(state: s, segment: seg, onExit: () {}),
      ));
      await tester.tap(find.text('见死不救'));
      await tester.pumpAndSettle();
      expect(s.player.karma, 7);
    });
  });

  group('道侣 选择 mechanic (slice 45)', () {
    testWidgets('choice with companion field sets state.player.daoCompanion',
        (tester) async {
      final s = GameState.fresh();
      final seg = _makeSegment([
        const IfChoice(choice: '选玉箫', companion: '玉箫'),
      ]);
      await tester.pumpWidget(MaterialApp(
        home: IfScreen(state: s, segment: seg, onExit: () {}),
      ));
      await tester.tap(find.text('选玉箫'));
      await tester.pumpAndSettle();
      expect(s.player.daoCompanion, '玉箫');
    });
  });
}
