// Slice 7: SaveService (1 slot, JSON file, auto-save hooks).

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:jhrm/save/save_service.dart';
import 'package:jhrm/state/enums.dart';
import 'package:jhrm/state/game_state.dart';

void main() {
  group('SaveService (slice 7)', () {
    test('save then load round-trips the GameState', () async {
      final tmp = Directory.systemTemp.createTempSync('jhrm_save_test_');
      try {
        final svc = SaveService(directory: tmp);
        final s = GameState.fresh(seed: 42);
        s.player.root = Element.gold;
        s.applyHeartDelta(HeartPath.swordDao, 3);

        await svc.save(s);
        expect(tmp.listSync().where((e) => e.path.endsWith('.json')), isNotEmpty);

        final loaded = await svc.load();
        expect(loaded, isNotNull);
        expect(loaded!.player.root, Element.gold);
        expect(loaded.player.heartVector[HeartPath.swordDao], 3);
        expect(loaded.seed.value, 42);
      } finally {
        tmp.deleteSync(recursive: true);
      }
    });

    test('load returns null when no save file exists', () async {
      final tmp = Directory.systemTemp.createTempSync('jhrm_empty_');
      try {
        final svc = SaveService(directory: tmp);
        final loaded = await svc.load();
        expect(loaded, isNull);
      } finally {
        tmp.deleteSync(recursive: true);
      }
    });

    test('delete removes the save file', () async {
      final tmp = Directory.systemTemp.createTempSync('jhrm_del_');
      try {
        final svc = SaveService(directory: tmp);
        final s = GameState.fresh();
        await svc.save(s);
        await svc.delete();
        final loaded = await svc.load();
        expect(loaded, isNull);
      } finally {
        tmp.deleteSync(recursive: true);
      }
    });

    test('load tolerates a corrupted save file (returns null)', () async {
      final tmp = Directory.systemTemp.createTempSync('jhrm_bad_');
      try {
        File('${tmp.path}/save.json').writeAsStringSync('{ not json');
        final svc = SaveService(directory: tmp);
        final loaded = await svc.load();
        expect(loaded, isNull);
      } finally {
        tmp.deleteSync(recursive: true);
      }
    });
  });
}
