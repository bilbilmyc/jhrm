// IfSegment: one IF segment with trigger, requires, body, and choices.
// Per decisions.md #11: fromJson uses optional + defaults for forward compat.

import '../state/enums.dart';

class IfTrigger {
  const IfTrigger({this.location});
  final String? location;

  Map<String, dynamic> toJson() => {'location': location};
  factory IfTrigger.fromJson(Map<String, dynamic> j) =>
      IfTrigger(location: j['location'] as String?);
}

class IfChoice {
  const IfChoice({
    required this.choice,
    this.goto,
    this.action = 'goto',
    this.heartDelta = const {},
    this.karmaDelta = 0,
    this.companion,
  });
  final String choice;
  final String? goto;

  /// 'goto' (default, follow `goto`) or 'tribulation' (fire TribulationEngine
  /// then return to caller for outcome rendering).
  final String action;
  final Map<HeartPath, int> heartDelta;

  /// 因果 (karma) change applied to the player when this choice is taken.
  /// Positive = 善, negative = 恶. Range typically -10..+10.
  final int karmaDelta;

  /// If non-null, the player takes this 道侣 on this choice. v0.1
  /// mechanism — the IF defines who the candidate is; this just records
  /// the player's commitment.
  final String? companion;

  Map<String, dynamic> toJson() => {
        'choice': choice,
        'goto': goto,
        'action': action,
        'heart_delta': {for (final e in heartDelta.entries) e.key.name: e.value},
        'karma_delta': karmaDelta,
      };

  factory IfChoice.fromJson(Map<String, dynamic> j) {
    final hd = j['heart_delta'] as Map<String, dynamic>?;
    final map = <HeartPath, int>{};
    if (hd != null) {
      hd.forEach((k, v) {
        HeartPath? resolved;
        for (final p in HeartPath.values) {
          if (p.name == k || p.displayName == k) {
            resolved = p;
            break;
          }
        }
        if (resolved != null) {
          map[resolved] = (v as num).toInt();
        }
      });
    }
    return IfChoice(
      choice: j['choice'] as String,
      goto: j['goto'] as String?,
      action: (j['action'] as String?) ?? 'goto',
      heartDelta: map,
      karmaDelta: (j['karma_delta'] as num?)?.toInt() ?? 0,
      companion: j['companion'] as String?,
    );
  }
}

class IfSegment {
  const IfSegment({
    required this.id,
    this.title = '',
    this.trigger = const IfTrigger(),
    this.requires = const {},
    this.next = const [],
    this.body = '',
  });

  final String id;
  final String title;
  final IfTrigger trigger;
  final Map<String, dynamic> requires;
  final List<IfChoice> next;
  final String body;

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'trigger': trigger.toJson(),
        'requires': requires,
        'next': next.map((c) => c.toJson()).toList(),
        'body': body,
      };

  factory IfSegment.fromJson(Map<String, dynamic> j) => IfSegment(
        id: j['id'] as String,
        title: (j['title'] as String?) ?? '',
        trigger: j['trigger'] is Map<String, dynamic>
            ? IfTrigger.fromJson(j['trigger'] as Map<String, dynamic>)
            : const IfTrigger(),
        requires: (j['requires'] as Map<String, dynamic>?) ?? const {},
        next: ((j['next'] as List?) ?? const [])
            .map((c) => IfChoice.fromJson(c as Map<String, dynamic>))
            .toList(),
        body: (j['body'] as String?) ?? '',
      );
}
