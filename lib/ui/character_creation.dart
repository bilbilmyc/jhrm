// CharacterCreation: 修真感风格. Five 灵根 chips + 踏入修真 confirm.

import 'package:flutter/material.dart';

import '../state/enums.dart' as domain;
import '../state/game_state.dart';
import 'theme.dart';

class CharacterCreation extends StatefulWidget {
  const CharacterCreation({super.key, required this.state, required this.onDone});
  final GameState state;
  final VoidCallback onDone;

  @override
  State<CharacterCreation> createState() => _CharacterCreationState();
}

class _CharacterCreationState extends State<CharacterCreation> {
  domain.Element? _picked;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('踏入修真')),
      body: XianxiaTheme.scrollBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 16),
                const Text(
                  '请选灵根',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                    color: XianxiaTheme.inkBlack,
                    letterSpacing: 8,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  '灵根决定你能学的功法',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: XianxiaTheme.shadowBrown,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 32),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  alignment: WrapAlignment.center,
                  children: [
                    for (final e in _rootElements)
                      _elementCard(e),
                  ],
                ),
                const Spacer(),
                XianxiaTheme.sealDivider(),
                ElevatedButton(
                  onPressed: _picked == null
                      ? null
                      : () {
                          widget.state.characterCreated = true;
                          widget.state.notify();
                          widget.onDone();
                        },
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Text('踏 入 修 真',
                        style: TextStyle(
                          fontSize: 18,
                          letterSpacing: 8,
                        )),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _elementCard(domain.Element e) {
    final color = XianxiaTheme.elementColor[e.displayName] ?? XianxiaTheme.goldLeaf;
    final selected = _picked == e;
    return GestureDetector(
      onTap: () {
        setState(() => _picked = e);
        widget.state.player.root = e;
        widget.state.notify();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 96,
        height: 110,
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.15) : XianxiaTheme.paperWhite,
          border: Border.all(
            color: selected ? color : XianxiaTheme.shadowBrown,
            width: selected ? 2 : 0.5,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              e.displayName,
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '灵根',
              style: TextStyle(
                fontSize: 11,
                color: color,
                letterSpacing: 4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static const List<domain.Element> _rootElements = [
    domain.Element.gold,
    domain.Element.wood,
    domain.Element.water,
    domain.Element.fire,
    domain.Element.earth,
  ];
}
