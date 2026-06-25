// WorldView: top-level 凡界 screen with list + 2D map tabs.
// Per slice 2: tap node records selection.
// Per slice 8: tap node opens the first matching IF segment on top.
// Per slice 9: status bar + 闭关 button + 渡劫 auto-trigger.

import 'package:flutter/material.dart';

import '../content/content_loader.dart';
import '../content/if_screen.dart';
import '../content/if_segment.dart';
import '../engine/cultivation_engine.dart';
import '../engine/tribulation_engine.dart';
import '../save/save_service.dart';
import '../state/enums.dart';
import '../state/game_state.dart';
import '../ui/status_bar.dart';
import 'mini_map.dart';
import 'node_registry.dart';

class WorldView extends StatefulWidget {
  const WorldView({
    super.key,
    required this.state,
    this.saveService,
    this.contentLoader,
  });
  final GameState state;
  final SaveService? saveService;
  final ContentLoader? contentLoader;

  @override
  State<WorldView> createState() => _WorldViewState();
}

class _WorldViewState extends State<WorldView> {
  int _tab = 0;
  IfSegment? _activeSegment;
  bool _tribulationInProgress = false;
  TribulationResult? _tribulationResult;

  void _onNodeTapped(String nodeName) {
    final loader = widget.contentLoader;
    if (loader == null) return;
    final seg = loader.firstForLocation(nodeName);
    if (seg == null) return;
    setState(() => _activeSegment = seg);
  }

  void _exitIf() {
    setState(() => _activeSegment = null);
    if (widget.saveService != null) {
      widget.saveService!.save(widget.state);
    }
  }

  void _onCultivate() {
    if (_tribulationInProgress) return;
    final engine = CultivationEngine(widget.state);
    engine.startClosure();
    engine.completeClosure();
    _checkTribulation();
  }

  void _checkTribulation() {
    final p = widget.state.player;
    if (p.layer >= 9 && p.cultivationXp >= CultivationEngine.cultivationXpMax) {
      setState(() => _tribulationInProgress = true);
      final result = TribulationEngine(widget.state).resolve();
      setState(() {
        _tribulationInProgress = false;
        _tribulationResult = result;
        // Consume the trigger: clear xp so the next closure accumulates
        // 0->100 again (or stays at 0 after a success that bumped layer).
        if (result == TribulationResult.success) {
          // Already reset by the engine.
        } else {
          p.cultivationXp = 0;
        }
      });
      if (widget.saveService != null) {
        widget.saveService!.save(widget.state);
      }
    }
  }

  void _dismissTribulation() {
    setState(() => _tribulationResult = null);
  }

  @override
  Widget build(BuildContext context) {
    if (_activeSegment != null) {
      return IfScreen(
        state: widget.state,
        segment: _activeSegment!,
        onExit: _exitIf,
      );
    }
    if (_tribulationResult != null) {
      return _TribulationResultView(
        result: _tribulationResult!,
        state: widget.state,
        onDismiss: _dismissTribulation,
        onRestart: () {
          _dismissTribulation();
          // Reset state for a fresh playthrough after ascension / fallback.
          widget.state.player.realm = Realm.lianQi;
          widget.state.player.layer = 1;
          widget.state.player.lifespan = GameState.closureLifespanMaxLianQi;
          widget.state.player.lifespanMax = GameState.closureLifespanMaxLianQi;
          widget.state.player.cultivationXp = 0;
          widget.state.ending = null;
          widget.state.notifyListeners();
        },
      );
    }
    final nodes = NodeRegistry.mortalNodes;
    return Scaffold(
      appBar: AppBar(
        title: const Text('凡界'),
        actions: [
          IconButton(
            key: const Key('cultivate-button'),
            icon: const Icon(Icons.self_improvement),
            tooltip: '闭关',
            onPressed: _onCultivate,
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Row(
            children: [
              _tabBar('列表', 0),
              _tabBar('地图', 1),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          StatusBar(state: widget.state),
          Expanded(
            child: _tab == 0
                ? SingleChildScrollView(
                    child: Column(
                      children: [
                        for (final n in nodes)
                          Column(
                            children: [
                              ListTile(
                                title: Text(n.name),
                                subtitle: Text('灵根: ${n.element.displayName}'),
                                trailing: widget.state.world.selectedNodeId == n.id
                                    ? const Icon(Icons.check)
                                    : null,
                                onTap: () {
                                  widget.state.world.selectedNodeId = n.id;
                                  widget.state.notifyListeners();
                                  _onNodeTapped(n.name);
                                },
                              ),
                              const Divider(height: 1),
                            ],
                          ),
                      ],
                    ),
                  )
                : MiniMap(
                    state: widget.state,
                    nodes: nodes,
                    onNodeTapped: _onNodeTapped,
                  ),
          ),
        ],
      ),
    );
  }

  Widget _tabBar(String label, int idx) {
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _tab = idx),
        child: Container(
          height: 48,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                width: 2,
                color: _tab == idx ? Colors.amber : Colors.transparent,
              ),
            ),
          ),
          child: Text(label),
        ),
      ),
    );
  }
}

class _TribulationResultView extends StatelessWidget {
  const _TribulationResultView({
    required this.result,
    required this.state,
    required this.onDismiss,
    required this.onRestart,
  });
  final TribulationResult result;
  final GameState state;
  final VoidCallback onDismiss;
  final VoidCallback onRestart;

  @override
  Widget build(BuildContext context) {
    final isSuccess = result == TribulationResult.success;
    final title = isSuccess ? '飞升成功' : '渡劫失败';
    final body = isSuccess
        ? '你已渡过天劫，晋升${state.player.realm.displayName}。\n道心：${state.ending ?? "无"}'
        : '天劫之下，你跌回凡尘。寿元大减，但道心仍在。';
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(title, style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 16),
            Text(body, textAlign: TextAlign.center),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                if (isSuccess)
                  ElevatedButton(
                    onPressed: onRestart,
                    child: const Text('再次踏入修真路'),
                  )
                else
                  ElevatedButton(
                    onPressed: onDismiss,
                    child: const Text('继续'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
