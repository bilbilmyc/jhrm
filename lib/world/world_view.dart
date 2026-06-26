// WorldView: 修真感 list + 2D map. 节点 cards use element glyph + 灵气 ring.

import 'package:flutter/material.dart';

import '../content/content_loader.dart';
import '../content/if_screen.dart';
import '../content/if_segment.dart';
import '../engine/cultivation_engine.dart';
import '../engine/ending_resolver.dart';
import '../engine/tribulation_engine.dart';
import '../save/save_service.dart';
import '../state/enums.dart' as domain;
import '../state/game_state.dart';
import '../ui/breakthrough_view.dart';
import '../ui/closure_timer.dart';
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

class _WorldViewState extends State<WorldView>
    with SingleTickerProviderStateMixin {
  int _tab = 0;
  IfSegment? _activeSegment;
  TribulationResult? _tribulationResult;

  late final AnimationController _closureController;
  bool _closureRunning = false;
  bool? _breakthroughSuccess;

  @override
  void initState() {
    super.initState();
    _closureController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30),
    );
  }

  @override
  void dispose() {
    _closureController.dispose();
    super.dispose();
  }

  void _onNodeTapped(String nodeName) {
    final node = NodeRegistry.mortalNodes.firstWhere(
      (n) => n.name == nodeName,
      orElse: () => NodeRegistry.mortalNodes.first,
    );
    widget.state.world.selectedNodeId = node.id;
    widget.state.notify();
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

  void _onIfNavigate(IfSegment fromSegment) {
    // Find the last chosen choice and follow its goto. If the goto is null
    // or unknown, exit IF mode (the content is incomplete — return to map).
    // We don't have access to the choice here; pick the latest history
    // entry's outgoing goto by looking at the choice list. Simpler: since
    // each tap already applied heart_delta, treat the navigation as a
    // "the user picked a choice that didn't lead anywhere" — return to map.
    //
    // Per slice 15 audit: 28 gotos in the .md corpus don't resolve. We
    // accept this and fall back to closing the IF screen so the player
    // can continue, instead of leaving them stuck.
    setState(() => _activeSegment = null);
    if (widget.saveService != null) {
      widget.saveService!.save(widget.state);
    }
  }

  void _startClosure() {
    if (_closureRunning) return;
    setState(() => _closureRunning = true);
    _closureController.forward(from: 0).whenComplete(() {
      if (!mounted) return;
      _finishClosure();
    });
  }

  void _cancelClosure() {
    if (!_closureRunning) return;
    _closureController.stop();
    setState(() => _closureRunning = false);
  }

  void _finishClosure() {
    final beforeLayer = widget.state.player.layer;
    final beforeRealm = widget.state.player.realm;
    CultivationEngine(widget.state).completeClosure();
    setState(() {
      _closureRunning = false;
    });
    if (widget.state.player.realm == beforeRealm &&
        widget.state.player.layer > beforeLayer) {
      setState(() => _breakthroughSuccess = true);
    }
    if (widget.saveService != null) {
      widget.saveService!.save(widget.state);
    }
    _checkTribulation();
  }

  void _dismissBreakthrough() {
    setState(() => _breakthroughSuccess = null);
  }

  void _checkTribulation() {
    final p = widget.state.player;
    if (p.layer >= 9 && p.cultivationXp >= CultivationEngine.cultivationXpMax) {
      // Find the 渡劫 IF for this realm. Per-plane tribulation IFs are
      // distinguished by trigger.on_realm; fallback to first 渡劫台 match
      // for legacy content (the 炼气→筑基 IF was authored before this
      // routing was added).
      final seg = _findTribulationFor(p.realm);
      if (seg != null && seg.next.isNotEmpty) {
        setState(() => _activeSegment = seg);
      } else {
        _resolveTribulationDirect();
      }
    }
  }

  IfSegment? _findTribulationFor(domain.Realm realm) {
    final loader = widget.contentLoader;
    if (loader == null) return null;
    final realmName = '${realm.displayName}期';
    for (final s in loader.all()) {
      if (s.trigger.location != '渡劫台') continue;
      // IfTrigger currently has no on_realm field; the new IF segments
      // store it in `requires.realm` (already a Map<String, dynamic>).
      // Legacy IFs (炼气→筑基) only have `location`, no realm hint.
      final reqRealm = s.requires['realm'] as String?;
      if (reqRealm == null) {
        // Legacy: assume 炼气期.
        if (realm == domain.Realm.lianQi) return s;
      } else if (reqRealm == realmName) {
        return s;
      }
    }
    return null;
  }

  void _onTribulationChoice(IfChoice c) {
    // Apply heart_delta was already done by IfScreen; now resolve.
    _resolveTribulationDirect();
  }

  void _onAscendChoice(IfChoice c) {
    // Apply heart_delta was already done by IfScreen; force ascension.
    setState(() {
      _activeSegment = null;
    });
    TribulationEngine(widget.state).forceAscend();
    if (widget.saveService != null) {
      widget.saveService!.save(widget.state);
    }
  }

  void _resolveTribulationDirect() {
    setState(() {
      _activeSegment = null;
    });
    final result = TribulationEngine(widget.state).resolve();
    setState(() {
      _tribulationResult = result;
      if (result == TribulationResult.failure) {
        widget.state.player.cultivationXp = 0;
      }
    });
    if (widget.saveService != null) {
      widget.saveService!.save(widget.state);
    }
  }

  void _dismissTribulation() {
    setState(() => _tribulationResult = null);
  }

  void _exitEnding() {
    // The player read the ending — restart the journey at 炼气 1/9.
    // Reset player fields in place so the existing GameState reference
    // (and its listeners) stays valid.
    setState(() {
      _activeSegment = null;
      _tribulationResult = null;
    });
    widget.state.player.realm = domain.Realm.lianQi;
    widget.state.player.layer = 1;
    widget.state.player.lifespan = GameState.closureLifespanMaxLianQi;
    widget.state.player.lifespanMax = GameState.closureLifespanMaxLianQi;
    widget.state.player.cultivationXp = 0;
    widget.state.ending = null;
    widget.state.notify();
  }

  @override
  Widget build(BuildContext context) {
    // Auto-route to the realm-appropriate tribulation IF whenever the
    // state is ready (layer 9 + xp full). This is idempotent — once the
    // IF is dismissed, the player either ascended (state.ending set) or
    // failed (xp reset) and the precondition is no longer met.
    if (_activeSegment == null &&
        widget.state.ending == null &&
        widget.state.player.layer >= 9 &&
        widget.state.player.cultivationXp >=
            CultivationEngine.cultivationXpMax) {
      _checkTribulation();
    }
    // Ascension: state.ending is set after a successful tribulation at
    // 大乘 9/9. Resolve to a canonical ending IF and show it.
    if (widget.state.ending != null) {
      final endingId = EndingResolver.pick(widget.state);
      final seg = widget.contentLoader?.get(endingId);
      if (seg != null) {
        return IfScreen(
          state: widget.state,
          segment: seg,
          onExit: _exitEnding,
        );
      }
      // Fallback: no content loader or segment missing → show generic view.
    }
    if (_activeSegment != null) {
      return IfScreen(
        state: widget.state,
        segment: _activeSegment!,
        onExit: _exitIf,
        onNavigate: _onIfNavigate,
        onTribulationChoice: _onTribulationChoice,
        onAscendChoice: _onAscendChoice,
      );
    }
    if (_breakthroughSuccess != null) {
      return BreakthroughView(
        success: _breakthroughSuccess!,
        state: widget.state,
        onDismiss: _dismissBreakthrough,
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
          widget.state.notify();
        },
      );
    }
    final nodes = NodeRegistry.nodesFor(widget.state.player.realm);
    final planeName = _planeNameFor(widget.state.player.realm);
    return Scaffold(
      appBar: AppBar(
        title: Text(planeName),
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
      floatingActionButton: _ClosureFab(
        controller: _closureController,
        running: _closureRunning,
        onStart: _startClosure,
        onCancel: _cancelClosure,
      ),
      body: XianxiaTheme.scrollBackground(
        child: Stack(
          children: [
            Column(
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
            if (_closureRunning)
              ClosureOverlay(
                state: widget.state,
                controller: _closureController,
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

  String _planeNameFor(domain.Realm realm) {
    switch (realm) {
      case domain.Realm.lianQi:
      case domain.Realm.zhuJi:
        return '凡 界';
      case domain.Realm.jinDan:
      case domain.Realm.yuanYing:
        return '灵 界';
      case domain.Realm.huaShen:
      case domain.Realm.daCheng:
        return '仙 界';
    }
  }
}

class _ClosureFab extends StatelessWidget {
  const _ClosureFab({
    required this.controller,
    required this.running,
    required this.onStart,
    required this.onCancel,
  });
  final AnimationController controller;
  final bool running;
  final VoidCallback onStart;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      backgroundColor: running ? XianxiaTheme.cinnabarRed : XianxiaTheme.inkBlack,
      foregroundColor: XianxiaTheme.paperWhite,
      onPressed: running ? onCancel : onStart,
      icon: running ? const Icon(Icons.stop) : const Icon(Icons.self_improvement),
      label: running
          ? AnimatedBuilder(
              animation: controller,
              builder: (_, _) {
                final remaining = (30 * (1 - controller.value)).ceil();
                return Text('闭关 $remaining s');
              },
            )
          : const Text('闭 关'),
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
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 96),
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
            color: XianxiaTheme.paperWhite.withValues(alpha: 0.85),
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
                  color: elementColor.withValues(alpha: 0.15),
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
