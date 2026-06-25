// CharacterCreation: first-launch flow for choosing 灵根.
// Per decisions.md / slice 11: 5 elements (金/木/水/火/土).
// Player picks one, taps "踏入修真", then onDone is called and the
// game routes to WorldView.

import 'package:flutter/material.dart';

import '../state/enums.dart';
import '../state/game_state.dart';

class CharacterCreation extends StatefulWidget {
  const CharacterCreation({super.key, required this.state, required this.onDone});
  final GameState state;
  final VoidCallback onDone;

  @override
  State<CharacterCreation> createState() => _CharacterCreationState();
}

class _CharacterCreationState extends State<CharacterCreation> {
  Element? _picked;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('踏入修真')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 8),
            Text('请选择灵根', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 4),
            const Text('灵根决定你能学的功法。'),
            const SizedBox(height: 24),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                for (final e in _rootElements)
                  ChoiceChip(
                    label: Text(e.displayName, style: const TextStyle(fontSize: 18)),
                    selected: _picked == e,
                    onSelected: (_) {
                      setState(() => _picked = e);
                      widget.state.player.root = e;
                      widget.state.notifyListeners();
                    },
                  ),
              ],
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: _picked == null
                  ? null
                  : () {
                      widget.state.characterCreated = true;
                      widget.state.notifyListeners();
                      widget.onDone();
                    },
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text('踏入修真', style: TextStyle(fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static const List<Element> _rootElements = [
    Element.gold,
    Element.wood,
    Element.water,
    Element.fire,
    Element.earth,
  ];
}
