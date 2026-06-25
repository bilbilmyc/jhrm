// IfState: current IF segment + history of segments visited.

class IfState {
  IfState({this.currentSegmentId, List<String>? history})
      : history = history ?? <String>[];

  String? currentSegmentId;
  List<String> history;

  Map<String, dynamic> toJson() => {
        'currentSegmentId': currentSegmentId,
        'history': history,
      };

  factory IfState.fromJson(Map<String, dynamic> j) => IfState(
        currentSegmentId: j['currentSegmentId'] as String?,
        history: ((j['history'] as List?) ?? const [])
            .map((e) => e as String)
            .toList(),
      );
}
