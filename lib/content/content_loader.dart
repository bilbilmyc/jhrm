// ContentLoader: parses .md files with YAML frontmatter into IfSegment map.
// MVP: in-memory only. File-system loader arrives in slice 7.

import 'package:yaml/yaml.dart';

import 'if_segment.dart';

class ContentLoader {
  ContentLoader._(this._byId);
  final Map<String, IfSegment> _byId;

  /// Parse a single string containing one or more .md segments.
  /// In production the AppAssetLoader reads from content/凡界/<node>/*.md.
  factory ContentLoader.fromString(String source) {
    final byId = <String, IfSegment>{};
    final parts = source.split(RegExp(r'^---\s*$', multiLine: true));
    // Files start with `---\n<yaml>\n---\n<body>`. Splitting on `---` gives
    // ['', '<yaml>', '<body>', '', '<yaml>', '<body>', ...]
    for (var i = 1; i + 1 < parts.length; i += 2) {
      final yamlStr = parts[i];
      final body = parts[i + 1].trim();
      final raw = loadYaml(yamlStr);
      if (raw == null) continue;
      final json = _yamlToJson(raw) as Map<String, dynamic>;
      json['body'] = body;
      try {
        final seg = IfSegment.fromJson(json);
        byId[seg.id] = seg;
      } catch (_) {
        // Skip malformed segments silently for MVP.
      }
    }
    return ContentLoader._(byId);
  }

  IfSegment? get(String id) => _byId[id];
  Iterable<IfSegment> all() => _byId.values;
  int get length => _byId.length;

  /// Convert yaml package's recursive YamlMap/YamlList into plain Map/List.
  /// Necessary because IfSegment.fromJson expects Map<String, dynamic>.
  static dynamic _yamlToJson(dynamic v) {
    if (v is YamlMap) {
      return {for (final e in v.entries) e.key as String: _yamlToJson(e.value)};
    }
    if (v is YamlList) {
      return v.map(_yamlToJson).toList();
    }
    return v;
  }
}
