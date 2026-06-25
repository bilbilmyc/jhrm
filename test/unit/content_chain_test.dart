// Slice 18: IF goto chain resolution.
//
// Walks every segment in content/凡界/ and asserts that every choice's
// `goto` either is null (chain ends gracefully) or resolves to a real
// segment id. Stubs added in this slice make every chain resolvable.

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:jhrm/content/content_loader.dart';

void main() {
  group('IF goto chain (slice 18)', () {
    test('every choice.goto in content/凡界/ resolves to a loaded segment',
        () {
      // The project root is the cwd when `flutter test` runs.
      final dir = Directory('content/凡界');
      expect(dir.existsSync(), isTrue,
          reason: 'content/凡界/ must exist relative to project root');
      final loader = ContentLoader.fromDirectory(dir);

      final ids = loader.all().map((s) => s.id).toSet();
      expect(ids, isNotEmpty, reason: 'expected content to load');

      final broken = <String>[];
      for (final seg in loader.all()) {
        for (final c in seg.next) {
          if (c.goto == null) continue; // null = end of chain
          if (!ids.contains(c.goto)) {
            broken.add('${seg.id} -> ${c.goto}');
          }
        }
      }

      expect(
        broken,
        isEmpty,
        reason:
            'Broken gotos (segment.choices.goto → id not in loader):\n  ${broken.join("\n  ")}',
      );
    });
  });
}
