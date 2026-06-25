// World: which plane and which nodes have been visited.

import 'enums.dart';

class World {
  World({this.currentPlane = Plane.mortal, Set<String>? visitedNodes, this.selectedNodeId})
      : visitedNodes = visitedNodes ?? <String>{};

  Plane currentPlane;
  Set<String> visitedNodes;
  String? selectedNodeId;

  Map<String, dynamic> toJson() => {
        'currentPlane': currentPlane.name,
        'visitedNodes': visitedNodes.toList(),
        'selectedNodeId': selectedNodeId,
      };

  factory World.fromJson(Map<String, dynamic> j) => World(
        currentPlane: Plane.fromName(j['currentPlane'] as String),
        visitedNodes: ((j['visitedNodes'] as List?) ?? const [])
            .map((e) => e as String)
            .toSet(),
        selectedNodeId: j['selectedNodeId'] as String?,
      );
}
