// SaveService: 1-slot JSON save (per docs/issues/mvp-slice-7.md +
// decisions.md #11: optional fields + defaults → forward-compat).
//
// File layout: <directory>/save.json.
// MVP uses a single slot; multi-slot is post-MVP.
//
// In production `directory` comes from path_provider's
// getApplicationDocumentsDirectory(); tests pass a temp dir.

import 'dart:convert';
import 'dart:io';

import '../state/game_state.dart';

class SaveService {
  SaveService({required this.directory});
  final Directory directory;

  static const String _fileName = 'save.json';

  File get _file => File('${directory.path}/$_fileName');

  Future<void> save(GameState s) async {
    if (!directory.existsSync()) {
      directory.createSync(recursive: true);
    }
    await _file.writeAsString(jsonEncode(s.toJson()));
  }

  Future<GameState?> load() async {
    if (!_file.existsSync()) return null;
    try {
      final raw = await _file.readAsString();
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return GameState.fromJson(json);
    } catch (_) {
      return null;
    }
  }

  Future<void> delete() async {
    if (_file.existsSync()) {
      await _file.delete();
    }
  }

  bool get exists => _file.existsSync();
}
