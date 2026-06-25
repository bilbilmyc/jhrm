// Slice 16: StatusBar widget tests (expansion of slice 9 smoke test).
// Verifies: realm/layer text, element chip name, all 5 heart paths render
// with values, active vs inactive heart styling, lifespan color flip below
// 30%, xp bar ratio. The widget reads GameState.player — no callbacks.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jhrm/state/enums.dart' as domain;
import 'package:jhrm/state/game_state.dart';
import 'package:jhrm/ui/status_bar.dart';
import 'package:jhrm/ui/theme.dart';

void main() {
  group('StatusBar (slice 16)', () {
    testWidgets('shows realm display name and layer in header row',
        (tester) async {
      final s = GameState.fresh();
      s.player.layer = 5;
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: StatusBar(state: s))),
      );

      expect(find.text('炼气'), findsOneWidget);
      expect(find.text('第 5 层'), findsOneWidget);
    });

    testWidgets('element chip shows current 灵根 display name',
        (tester) async {
      final s = GameState.fresh();
      s.player.root = domain.Element.wood; // fresh() defaults to fire
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: StatusBar(state: s))),
      );

      // Element chip shows both '灵根' label + the element name
      expect(find.text('木'), findsOneWidget);
    });

    testWidgets('renders all 5 heart paths with their values',
        (tester) async {
      final s = GameState.fresh();
      s.player.heartVector[domain.HeartPath.swordDao] = 3;
      s.player.heartVector[domain.HeartPath.demonDao] = 0;
      s.player.heartVector[domain.HeartPath.kingDao] = 0;
      s.player.heartVector[domain.HeartPath.hiddenDao] = 0;
      s.player.heartVector[domain.HeartPath.noneDao] = 0;
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: StatusBar(state: s))),
      );

      // Each path renders its display name + its numeric value
      for (final p in domain.HeartPath.values) {
        expect(find.text(p.displayName), findsOneWidget,
            reason: 'heart path ${p.displayName} should render');
      }
      expect(find.text('3'), findsOneWidget); // swordDao value
    });

    testWidgets('active heart chip uses heart color, inactive uses dimmed',
        (tester) async {
      final s = GameState.fresh();
      s.player.heartVector[domain.HeartPath.swordDao] = 5; // active
      // demonDao stays 0 → inactive
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: StatusBar(state: s))),
      );

      // Locate the heart-chip text for each path and read its style color.
      // Active chip → heart color; inactive → scrollTan.
      final activeText = tester.widget<Text>(find.text('剑道'));
      final inactiveText = tester.widget<Text>(find.text('魔道'));

      expect(activeText.style!.color, XianxiaTheme.heartColor['剑道']);
      expect(inactiveText.style!.color, XianxiaTheme.scrollTan);
    });

    testWidgets('lifespan bar flips to cinnabarRed below 30%',
        (tester) async {
      final s = GameState.fresh();
      s.player.lifespan = 300; // 300/1200 = 25%, under 30%
      s.player.cultivationXp = 50; // 50/100 = 50%, well above
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: StatusBar(state: s))),
      );

      // Two bars (xp + lifespan). Identify each by its value.
      final bars = tester.widgetList<LinearProgressIndicator>(
        find.byType(LinearProgressIndicator),
      );
      final byValue = {for (final b in bars) b.value: b};

      final xpBar = byValue[0.5]!;
      final lifespanBar = byValue[0.25]!;

      expect(xpBar.valueColor!.value, XianxiaTheme.goldLeaf);
      expect(lifespanBar.valueColor!.value, XianxiaTheme.cinnabarRed);
    });

    testWidgets('lifespan bar stays jadeGreen at healthy ratio',
        (tester) async {
      final s = GameState.fresh();
      // fresh() leaves lifespan at max → ratio 1.0
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: StatusBar(state: s))),
      );

      final bars = tester.widgetList<LinearProgressIndicator>(
        find.byType(LinearProgressIndicator),
      );
      // One bar at 1.0 (lifespan full), one at 0.0 (xp empty)
      final lifespanBar = bars.firstWhere((b) => b.value == 1.0);
      expect(lifespanBar.valueColor!.value, XianxiaTheme.jadeGreen);
    });
  });
}
