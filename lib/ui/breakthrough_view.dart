// BreakthroughView: brief celebration / 跌境 screen shown after a
// 小层 breakthrough resolves (success or fail).

import 'package:flutter/material.dart';

import '../state/game_state.dart';
import 'theme.dart';

class BreakthroughView extends StatelessWidget {
  const BreakthroughView({
    super.key,
    required this.success,
    required this.state,
    required this.onDismiss,
  });
  final bool success;
  final GameState state;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final title = success ? '突 破 成 功' : '突 破 失 败';
    final ink = success ? XianxiaTheme.goldLeaf : XianxiaTheme.cinnabarRed;
    final body = success
        ? '丹田内灵气翻涌，${state.player.realm.displayName}第 ${state.player.layer} 层！'
        : '突破受阻，灵气溃散，修为减半。';
    return Material(
      color: Colors.black87,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                success ? Icons.auto_awesome : Icons.warning_amber,
                size: 96,
                color: ink,
              ),
              const SizedBox(height: 24),
              Text(
                title,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w600,
                  color: ink,
                  letterSpacing: 12,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                body,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 17,
                  height: 1.9,
                  color: XianxiaTheme.scrollTan,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 48),
              ElevatedButton(
                onPressed: onDismiss,
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                  child: Text('继 续', style: TextStyle(letterSpacing: 8)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
