// App entry. Slice 2 wires WorldView into the root.

import 'package:flutter/material.dart';

import 'state/game_state.dart';
import 'world/world_view.dart';

void main() {
  runApp(const JhrmApp());
}

class JhrmApp extends StatefulWidget {
  const JhrmApp({super.key});

  @override
  State<JhrmApp> createState() => _JhrmAppState();
}

class _JhrmAppState extends State<JhrmApp> {
  final _state = GameState.fresh();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '修真',
      theme: ThemeData(
        colorSchemeSeed: Colors.amber,
        useMaterial3: true,
      ),
      home: WorldView(state: _state),
    );
  }
}
