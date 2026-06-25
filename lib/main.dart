// App entry. Slices 1-7 wired in:
// - SaveService loads on launch (or fresh state if no save)
// - WorldView is the main screen

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import 'content/content_loader.dart';
import 'save/save_service.dart';
import 'state/game_state.dart';
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
  ));
}

class JhrmApp extends StatelessWidget {
  const JhrmApp({
    super.key,
    required this.state,
    required this.saveService,
    required this.contentLoader,
  });
  final GameState state;
  final SaveService saveService;
  final ContentLoader contentLoader;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '修真',
      theme: ThemeData(
        colorSchemeSeed: Colors.amber,
        useMaterial3: true,
      ),
      home: WorldView(
        state: state,
        saveService: saveService,
        contentLoader: contentLoader,
      ),
    );
  }
}
