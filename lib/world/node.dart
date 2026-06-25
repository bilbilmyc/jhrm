// Node: 1 凡界 location (per decisions.md #7).
//
// Fields live in Dart (id/coords/element/ifSegments). Description text
// lives in content/凡界/<node>/description.md and is loaded by the
// ContentLoader in a later slice.

import '../state/enums.dart';

class Node {
  const Node({
    required this.id,
    required this.name,
    required this.x,
    required this.y,
    required this.element,
    required this.ifSegmentIds,
  });

  final String id;
  final String name;
  final double x; // 0..1 in MVP (scaled to canvas size at render time)
  final double y;
  final Element element;
  final List<String> ifSegmentIds;
}
