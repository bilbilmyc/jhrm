// IfScreen: renders an IfSegment (body + choice buttons) and applies
// heart_delta on choice tap. Navigates to next segment or back to map.

import 'package:flutter/material.dart';

import '../state/enums.dart' as domain;
import '../state/game_state.dart';
import 'if_segment.dart';
import 'if_template.dart';

class IfScreen extends StatelessWidget {
  const IfScreen({
    super.key,
    required this.state,
    required this.segment,
    required this.onExit,
    this.onNavigate,
  });

  final GameState state;
  final IfSegment segment;
  final VoidCallback onExit;
  final ValueChanged<IfSegment>? onNavigate;

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
      appBar: AppBar(
        title: Text(segment.title.isNotEmpty ? segment.title : segment.id),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: onExit,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: SingleChildScrollView(child: Text(body)),
            ),
            const SizedBox(height: 12),
            for (final c in segment.next)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: ElevatedButton(
                  onPressed: () {
                    _applyChoice(c);
                    onNavigate?.call(segment);
                  },
                  child: Text(c.choice),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
