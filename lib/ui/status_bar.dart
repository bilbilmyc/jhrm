// StatusBar: read-only display of the player state.
// Shows 境界/层, 修为 bar, 寿元, 灵根, 5 道心 vector.

import 'package:flutter/material.dart';

import '../engine/cultivation_engine.dart';
import '../state/enums.dart';
import '../state/game_state.dart';

class StatusBar extends StatelessWidget {
  const StatusBar({super.key, required this.state});
  final GameState state;

  @override
  Widget build(BuildContext context) {
    final p = state.player;
    final xpRatio = CultivationEngine.cultivationXpMax == 0
        ? 0.0
        : p.cultivationXp / CultivationEngine.cultivationXpMax;
    final lifespanRatio = p.lifespanMax == 0
        ? 0.0
        : p.lifespan / p.lifespanMax;

    return Container(
      padding: const EdgeInsets.all(12),
      color: Colors.black.withOpacity(0.05),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${p.realm.displayName} ${p.layer}/9',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 6),
          _bar('修为', xpRatio, '${p.cultivationXp}/${CultivationEngine.cultivationXpMax}'),
          _bar('寿元', lifespanRatio, '${p.lifespan}/${p.lifespanMax} 月'),
          const SizedBox(height: 4),
          Text('灵根: ${p.root.displayName}'),
          const SizedBox(height: 4),
          Wrap(
            spacing: 8,
            children: [
              for (final e in p.heartVector.entries)
                Chip(
                  label: Text('${e.key.displayName} ${e.value}'),
                  visualDensity: VisualDensity.compact,
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _bar(String label, double ratio, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(width: 36, child: Text(label)),
          Expanded(
            child: LinearProgressIndicator(
              value: ratio.clamp(0.0, 1.0),
              minHeight: 6,
            ),
          ),
          const SizedBox(width: 8),
          Text(value, style: const TextStyle(fontSize: 11)),
        ],
      ),
    );
  }
}
