// ProceduralSeed: deterministic seed for all procedural generation
// (techniques, treasures, beasts). Per ADR-0003, the seed MUST be
// saved so reloading produces the same procedurally-generated items.

class ProceduralSeed {
  ProceduralSeed(this.value);
  final int value;

  Map<String, dynamic> toJson() => {'value': value};
  factory ProceduralSeed.fromJson(Map<String, dynamic> j) =>
      ProceduralSeed((j['value'] as num).toInt());
}
