// WorldView: top-level 凡界 screen with list + 2D map tabs.
// Per slice 2: tap node records selection in GameState.

import 'package:flutter/material.dart';

import '../save/save_service.dart';
import '../state/game_state.dart';
import 'mini_map.dart';
import 'node_registry.dart';

class WorldView extends StatefulWidget {
  const WorldView({super.key, required this.state, this.saveService});
  final GameState state;
  final SaveService? saveService;

  @override
  State<WorldView> createState() => _WorldViewState();
}

class _WorldViewState extends State<WorldView> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
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
                          onTap: () async {
                            widget.state.world.selectedNodeId = n.id;
                            widget.state.notifyListeners();
                            if (widget.saveService != null) {
                              await widget.saveService!.save(widget.state);
                            }
                          },
                        ),
                        const Divider(height: 1),
                      ],
                    ),
                ],
              ),
            )
          : MiniMap(state: widget.state, nodes: nodes),
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
