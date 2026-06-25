// IfScreen: 修真感排版. Body is 古风 paragraph; choices are ink-on-paper
// buttons; back button is a corner ornament. If a choice has
// `action: tribulation`, the caller is notified via `onTribulationChoice`
// so it can run the engine and show the outcome screen.

import 'package:flutter/material.dart';

import '../state/enums.dart' as domain;
import '../state/game_state.dart';
import '../ui/theme.dart';
import 'if_segment.dart';
import 'if_template.dart';

class IfScreen extends StatelessWidget {
  const IfScreen({
    super.key,
    required this.state,
    required this.segment,
    required this.onExit,
    this.onNavigate,
    this.onTribulationChoice,
  });

  final GameState state;
  final IfSegment segment;
  final VoidCallback onExit;
  final ValueChanged<IfSegment>? onNavigate;
  final ValueChanged<IfChoice>? onTribulationChoice;

  void _applyChoice(IfChoice c) {
    for (final e in c.heartDelta.entries) {
      state.applyHeartDelta(e.key, e.value);
    }
    state.ifState.history.add(segment.id);
    state.notifyListeners();
  }

  @override
  Widget build(BuildContext context) {
    final ctx = {
      'root': state.player.root.name,
      'layer': state.player.layer,
      'isFire': state.player.root == domain.Element.fire,
    };
    final body = renderIfTemplate(segment.body, ctx);

    return Scaffold(
      backgroundColor: XianxiaTheme.scrollTan,
      appBar: AppBar(
        title: Text(segment.title.isNotEmpty ? segment.title : segment.id),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: onExit,
        ),
      ),
      body: XianxiaTheme.scrollBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: XianxiaTheme.paperWhite.withOpacity(0.85),
                        border: Border.all(
                          color: XianxiaTheme.shadowBrown,
                          width: 0.5,
                        ),
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            segment.title,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 4,
                              color: XianxiaTheme.inkBlack,
                            ),
                          ),
                          XianxiaTheme.sealDivider(),
                          Text(
                            body,
                            style: const TextStyle(
                              fontSize: 17,
                              height: 1.9,
                              color: XianxiaTheme.inkBlack,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                if (segment.next.isEmpty)
                  Center(
                    child: Column(
                      children: [
                        const Text(
                          '（终）',
                          style: TextStyle(
                            color: XianxiaTheme.cinnabarRed,
                            fontSize: 18,
                            letterSpacing: 8,
                          ),
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton(
                          onPressed: onExit,
                          child: const Text('返回凡界',
                              style: TextStyle(letterSpacing: 4)),
                        ),
                      ],
                    ),
                  )
                else
                  for (final c in segment.next)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: OutlinedButton(
                        onPressed: () {
                          _applyChoice(c);
                          if (c.action == 'tribulation') {
                            onTribulationChoice?.call(c);
                          } else if (c.goto == null) {
                            // Choice with no target: end the story here.
                            onExit();
                          } else {
                            onNavigate?.call(segment);
                          }
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: XianxiaTheme.inkBlack,
                          side: const BorderSide(
                            color: XianxiaTheme.shadowBrown,
                            width: 0.5,
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                          alignment: Alignment.centerLeft,
                        ),
                        child: Text(
                          c.choice,
                          style: const TextStyle(
                            fontSize: 15,
                            height: 1.4,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
