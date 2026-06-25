// WorldView: top-level 凡界 screen with list + 2D map tabs.
// Per slice 2: tap node records selection.
// Per slice 8: tap node opens the first matching IF segment on top.

import 'package:flutter/material.dart';

import '../content/content_loader.dart';
import '../content/if_screen.dart';
import '../content/if_segment.dart';
import '../save/save_service.dart';
import '../state/game_state.dart';
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

  void _onNodeTapped(String nodeName) {
    final loader = widget.contentLoader;
    if (loader == null) {
      // No content loader wired: fall back to selection only.
      return;
    }
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

  @override
  Widget build(BuildContext context) {
    if (_activeSegment != null) {
      return IfScreen(
        state: widget.state,
        segment: _activeSegment!,
        onExit: _exitIf,
      );
    }
    final nodes = NodeRegistry.mortalNodes;
    return Scaffold(
      appBar: AppBar(
        title: const Text('凡界'),
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
      body: _tab == 0
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
