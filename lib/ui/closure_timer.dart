// ClosureTimer: 30s 修真 countdown ring (per decisions.md #8 + #12).
// Tap the 闭关 button → overlay shows a 30s timer → on complete, fires
// CultivationEngine.completeClosure + 寿元 扣除 + 可能触发 突破.

import 'package:flutter/material.dart';

import '../engine/cultivation_engine.dart';
import '../state/game_state.dart';
import 'theme.dart';

class ClosureTimer extends StatefulWidget {
  const ClosureTimer({
    super.key,
    required this.state,
    required this.onComplete,
  });
  final GameState state;
  final VoidCallback onComplete;

  @override
  State<ClosureTimer> createState() => _ClosureTimerState();
}

class _ClosureTimerState extends State<ClosureTimer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _running = false;

  // 炼气期 30s per 闭 (per ADR-0007). 其他境界 TODO 筑基+.
  static const int _secondsLianQi = 30;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: _secondsLianQi),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _start() {
    if (_running) return;
    setState(() => _running = true);
    _controller.forward(from: 0).whenComplete(() {
      if (!mounted) return;
      final engine = CultivationEngine(widget.state);
      engine.completeClosure();
      widget.onComplete();
      setState(() => _running = false);
    });
  }

  void _cancel() {
    _controller.stop();
    setState(() => _running = false);
  }

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      key: const Key('cultivate-fab'),
      backgroundColor: _running ? XianxiaTheme.cinnabarRed : XianxiaTheme.inkBlack,
      foregroundColor: XianxiaTheme.paperWhite,
      onPressed: _running ? _cancel : _start,
      icon: _running ? const Icon(Icons.stop) : const Icon(Icons.self_improvement),
      label: _running
          ? AnimatedBuilder(
              animation: _controller,
              builder: (_, _) {
                final remaining = (_secondsLianQi * (1 - _controller.value)).ceil();
                return Text('闭关中 $remaining s');
              },
            )
          : const Text('闭关'),
    );
  }
}

/// A separate top-level helper: a 30s circular progress ring overlay that
/// appears when a 闭关 is in progress, so the player can see time without
/// having to look at the FAB.
class ClosureOverlay extends StatelessWidget {
  const ClosureOverlay({
    super.key,
    required this.state,
    required this.controller,
  });
  final GameState state;
  final AnimationController controller;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 24,
      top: 80,
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, _) {
          return SizedBox(
            width: 64,
            height: 64,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox.expand(
                  child: CircularProgressIndicator(
                    value: controller.value,
                    strokeWidth: 5,
                    backgroundColor: XianxiaTheme.shadowBrown,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      XianxiaTheme.goldLeaf,
                    ),
                  ),
                ),
                Text(
                  '${(30 * (1 - controller.value)).ceil()}',
                  style: const TextStyle(
                    color: XianxiaTheme.paperWhite,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
