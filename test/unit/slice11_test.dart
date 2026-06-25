// Slice 11: 角色创建 (character creation flow).

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jhrm/state/enums.dart' as domain;
import 'package:jhrm/state/game_state.dart';
import 'package:jhrm/ui/character_creation.dart';

void main() {
  group('CharacterCreation (slice 11)', () {
    testWidgets('shows the 5 basic elements (金/木/水/火/土)', (tester) async {
      final s = GameState.fresh();
      await tester.pumpWidget(
        MaterialApp(home: CharacterCreation(state: s, onDone: () {})),
      );
      expect(find.text('金'), findsOneWidget);
      expect(find.text('木'), findsOneWidget);
      expect(find.text('水'), findsOneWidget);
      expect(find.text('火'), findsOneWidget);
      expect(find.text('土'), findsOneWidget);
    });

    testWidgets('tapping an element + confirming sets root and marks created',
        (tester) async {
      final s = GameState.fresh();
      bool done = false;
      await tester.pumpWidget(
        MaterialApp(home: CharacterCreation(state: s, onDone: () => done = true)),
      );
      await tester.tap(find.text('金'));
      await tester.pump();
      expect(s.player.root, domain.Element.gold);
      await tester.tap(find.widgetWithText(ElevatedButton, '踏 入 修 真'));
      await tester.pumpAndSettle();
      expect(done, isTrue);
      expect(s.characterCreated, isTrue);
    });
  });
}
