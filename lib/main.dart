// App entry. Slices 1-7 wired in:
// - SaveService loads on launch (or fresh state if no save)
// - WorldView is the main screen

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import 'content/content_loader.dart';
import 'save/save_service.dart';
import 'state/game_state.dart';
import 'ui/character_creation.dart';
import 'ui/gold_finger_overlay.dart';
import 'world/world_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final dir = await getApplicationDocumentsDirectory();
  final saveDir = Directory('${dir.path}/saves');
  final saveService = SaveService(directory: saveDir);
  final loaded = await saveService.load();
  final state = loaded ?? GameState.fresh();
  // ContentLoader reads from the project root's content/凡界/ directory.
  // On real devices this would ship as a Flutter asset (rootBundle).
  final contentLoader = ContentLoader.fromDirectory(Directory('content/凡界'));
  runApp(JhrmApp(
    state: state,
    saveService: saveService,
    contentLoader: contentLoader,
    enableGoldFinger: kDebugMode,
  ));
}

class JhrmApp extends StatefulWidget {
  const JhrmApp({
    super.key,
    required this.state,
    required this.saveService,
    required this.contentLoader,
    this.enableGoldFinger = false,
  });
  final GameState state;
  final SaveService saveService;
  final ContentLoader contentLoader;
  final bool enableGoldFinger;

  @override
  State<JhrmApp> createState() => _JhrmAppState();
}

class _JhrmAppState extends State<JhrmApp> {
  @override
  Widget build(BuildContext context) {
    final home = widget.state.characterCreated
        ? WorldView(
            state: widget.state,
            saveService: widget.saveService,
            contentLoader: widget.contentLoader,
          )
        : CharacterCreation(
            state: widget.state,
            onDone: () => setState(() {}),
          );
    return MaterialApp(
      title: '修真',
      theme: ThemeData(
        colorSchemeSeed: Colors.amber,
        useMaterial3: true,
      ),
      home: GoldFingerOverlay(state: widget.state, child: home),
    );
  }
}
