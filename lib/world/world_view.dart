// WorldView: 修真感 list + 2D map. 节点 cards use element glyph + 灵气 ring.

import 'package:flutter/material.dart';

import '../content/content_loader.dart';
import '../content/if_screen.dart';
import '../content/if_segment.dart';
import '../engine/cultivation_engine.dart';
import '../engine/tribulation_engine.dart';
import '../save/save_service.dart';
import '../state/enums.dart' as domain;
import '../state/game_state.dart';
import '../ui/status_bar.dart';
import '../ui/theme.dart';
import 'mini_map.dart';
import 'node.dart';
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
    // Always record selection (visible in the card checkmark), even when
    // no IF content exists for that node.
    final node = NodeRegistry.mortalNodes.firstWhere(
      (n) => n.name == nodeName,
      orElse: () => NodeRegistry.mortalNodes.first,
    );
    widget.state.world.selectedNodeId = node.id;
    widget.state.notifyListeners();
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
        if (result == TribulationResult.failure) {
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
          widget.state.player.realm = domain.Realm.lianQi;
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
        title: const Text('凡 界'),
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
          child: Container(
            color: XianxiaTheme.inkBlack,
            child: Row(
              children: [
                _tabBar('列表', 0),
                _tabBar('地图', 1),
              ],
            ),
          ),
        ),
      ),
      body: XianxiaTheme.scrollBackground(
        child: Column(
          children: [
            StatusBar(state: widget.state),
            Expanded(
              child: _tab == 0
                  ? _NodeList(
                      state: widget.state,
                      nodes: nodes,
                      onNodeTapped: _onNodeTapped,
                    )
                  : MiniMap(
                      state: widget.state,
                      nodes: nodes,
                      onNodeTapped: _onNodeTapped,
                    ),
            ),
          ],
        ),
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
                color: _tab == idx ? XianxiaTheme.goldLeaf : Colors.transparent,
              ),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: _tab == idx ? XianxiaTheme.goldLeaf : XianxiaTheme.scrollTan,
              letterSpacing: 4,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}

class _NodeList extends StatelessWidget {
  const _NodeList({
    required this.state,
    required this.nodes,
    required this.onNodeTapped,
  });
  final GameState state;
  final List<Node> nodes;
  final ValueChanged<String> onNodeTapped;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          for (final n in nodes)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: _NodeCard(
                state: state,
                node: n,
                onTap: () => onNodeTapped(n.name),
              ),
            ),
        ],
      ),
    );
  }
}

class _NodeCard extends StatelessWidget {
  const _NodeCard({
    required this.state,
    required this.node,
    required this.onTap,
  });
  final GameState state;
  final Node node;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final selected = state.world.selectedNodeId == node.id;
    final elementColor = XianxiaTheme.elementColor[node.element.displayName] ??
        XianxiaTheme.goldLeaf;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: XianxiaTheme.paperWhite.withOpacity(0.85),
            border: Border.all(
              color: selected ? XianxiaTheme.cinnabarRed : XianxiaTheme.shadowBrown,
              width: selected ? 1.5 : 0.5,
            ),
            borderRadius: BorderRadius.circular(2),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: elementColor.withOpacity(0.15),
                  border: Border.all(color: elementColor, width: 1),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  node.element.displayName,
                  style: TextStyle(
                    color: elementColor,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      node.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: XianxiaTheme.inkBlack,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${node.element.displayName}灵气 · ${node.ifSegmentIds.length} 段事',
                      style: const TextStyle(
                        fontSize: 12,
                        color: XianxiaTheme.shadowBrown,
                      ),
                    ),
                  ],
                ),
              ),
              if (selected)
                const Icon(Icons.check, color: XianxiaTheme.cinnabarRed)
              else
                const Icon(Icons.chevron_right, color: XianxiaTheme.shadowBrown),
            ],
          ),
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
    final title = isSuccess ? '飞 升 成 功' : '渡 劫 失 败';
    final ink = isSuccess ? XianxiaTheme.goldLeaf : XianxiaTheme.cinnabarRed;
    final body = isSuccess
        ? '天劫散去，紫气东来。\n你已渡过天劫，晋升${state.player.realm.displayName}。\n道心归宿：${state.ending ?? "无"}'
        : '雷鸣九霄，你跌回凡尘。\n寿元大减，丹田破碎。\n但道心仍在，他日可再战。';
    return Scaffold(
      backgroundColor: XianxiaTheme.inkBlack,
      appBar: AppBar(
        title: Text(title, style: TextStyle(color: ink, letterSpacing: 6)),
        backgroundColor: XianxiaTheme.inkBlack,
      ),
      body: XianxiaTheme.scrollBackground(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isSuccess ? Icons.auto_awesome : Icons.bolt,
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
                  color: XianxiaTheme.inkBlack,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 48),
              ElevatedButton(
                onPressed: isSuccess ? onRestart : onDismiss,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                  child: Text(
                    isSuccess ? '再 次 踏 入 修 真 路' : '继 续',
                    style: const TextStyle(fontSize: 16, letterSpacing: 6),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
