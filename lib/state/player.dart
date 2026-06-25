// Player: 14 systems (decisions.md #15)
//
// All 14 system fields are reserved even when MVP only uses 6 of them.
// Fields are public for serialization simplicity; invariants live in
// GameState's setters and the corresponding engines.

import 'enums.dart';

/// 功法 (procedural technique stub for MVP)
class Technique {
  const Technique({required this.id, required this.element, required this.tier});
  final String id;
  final Element element;
  final String tier; // 凡 / 灵 / 宝 / 灵宝 / 仙

  Map<String, dynamic> toJson() => {'id': id, 'element': element.name, 'tier': tier};
  factory Technique.fromJson(Map<String, dynamic> j) => Technique(
        id: j['id'] as String,
        element: Element.fromName(j['element'] as String),
        tier: j['tier'] as String,
      );
}

class Player {
  Player({
    required this.realm,
    required this.layer,
    required this.lifespan,
    required this.lifespanMax,
    required this.root,
    Map<HeartPath, int>? heartVector,
    this.equipment = const [],
    this.elixirs = const [],
    this.beasts = const [],
    this.companion,
    this.factionRep = const {},
    this.disciples = const [],
    this.activeWorldEvent,
    this.reincarnation,
    this.karma = 0,
  }) : heartVector = heartVector ??
            <HeartPath, int>{
              HeartPath.swordDao: 0,
              HeartPath.demonDao: 0,
              HeartPath.kingDao: 0,
              HeartPath.hiddenDao: 0,
              HeartPath.noneDao: 0,
            };

  // === MVP-active fields ===
  Realm realm;
  int layer; // 1-9
  int lifespan;
  int lifespanMax;
  Element root;
  Map<HeartPath, int> heartVector; // 5-dim (decisions.md #4)

  // === Forward-compat fields (always present, MVP may not use) ===
  List<Technique> equipment; // 法宝
  List<Technique> elixirs; // 丹药 (reusing Technique shape for MVP)
  List<Technique> beasts; // 灵兽
  Object? companion; // 道侣 (v0.2+)
  Map<String, int> factionRep; // 声望
  List<Technique> disciples; // 弟子
  Object? activeWorldEvent; // 世界事件
  Object? reincarnation; // 转世
  int karma; // 因果 (decisions.md #3: field only, events noop in MVP)

  /// Learnable techniques based on current 灵根.
  /// MVP: 8 hand-written techniques, all 5-tier variants of one element.
  /// Decoupled from `equipment` etc. so 金手指 can switch 灵根 without
  /// dropping learned items.
  List<Technique> learnableTechniques() {
    return const [
      Technique(id: 'fire-strike', element: Element.fire, tier: '凡'),
      Technique(id: 'water-flow', element: Element.water, tier: '凡'),
      Technique(id: 'gold-edge', element: Element.gold, tier: '凡'),
      Technique(id: 'wood-vine', element: Element.wood, tier: '凡'),
      Technique(id: 'earth-shield', element: Element.earth, tier: '凡'),
    ].where((t) => t.element == root).toList();
  }

  Map<String, dynamic> toJson() => {
        'realm': realm.name,
        'layer': layer,
        'lifespan': lifespan,
        'lifespanMax': lifespanMax,
        'root': root.name,
        'heartVector': {for (final e in heartVector.entries) e.key.name: e.value},
        'equipment': equipment.map((t) => t.toJson()).toList(),
        'elixirs': elixirs.map((t) => t.toJson()).toList(),
        'beasts': beasts.map((t) => t.toJson()).toList(),
        'companion': companion,
        'factionRep': factionRep,
        'disciples': disciples.map((t) => t.toJson()).toList(),
        'activeWorldEvent': activeWorldEvent,
        'reincarnation': reincarnation,
        'karma': karma,
      };

  factory Player.fromJson(Map<String, dynamic> j) {
    final hv = j['heartVector'] as Map<String, dynamic>?;
    final heart = <HeartPath, int>{
      HeartPath.swordDao: 0,
      HeartPath.demonDao: 0,
      HeartPath.kingDao: 0,
      HeartPath.hiddenDao: 0,
      HeartPath.noneDao: 0,
    };
    if (hv != null) {
      hv.forEach((k, v) {
        try {
          heart[HeartPath.fromName(k)] = (v as num).toInt();
        } catch (_) {
          // unknown heart path from older save: ignore
        }
      });
    }
    return Player(
      realm: Realm.fromName(j['realm'] as String),
      layer: (j['layer'] as num).toInt(),
      lifespan: (j['lifespan'] as num).toInt(),
      lifespanMax: (j['lifespanMax'] as num).toInt(),
      root: Element.fromName(j['root'] as String),
      heartVector: heart,
      equipment: ((j['equipment'] as List?) ?? const [])
          .map((t) => Technique.fromJson(t as Map<String, dynamic>))
          .toList(),
      elixirs: ((j['elixirs'] as List?) ?? const [])
          .map((t) => Technique.fromJson(t as Map<String, dynamic>))
          .toList(),
      beasts: ((j['beasts'] as List?) ?? const [])
          .map((t) => Technique.fromJson(t as Map<String, dynamic>))
          .toList(),
      companion: j['companion'],
      factionRep: ((j['factionRep'] as Map?) ?? const {}).map(
        (k, v) => MapEntry(k as String, (v as num).toInt()),
      ),
      disciples: ((j['disciples'] as List?) ?? const [])
          .map((t) => Technique.fromJson(t as Map<String, dynamic>))
          .toList(),
      activeWorldEvent: j['activeWorldEvent'],
      reincarnation: j['reincarnation'],
      karma: (j['karma'] as num?)?.toInt() ?? 0,
    );
  }
}
