// Domain enums per CONTEXT.md and decisions.md #1, #4, #12.
//
// All enums use stable string names (not Dart enum indices) for JSON
// forward-compat — reordering or inserting new values must not break old saves.

/// 六大境界 (per ADR-0006)
enum Realm {
  lianQi('炼气'),
  zhuJi('筑基'),
  jinDan('金丹'),
  yuanYing('元婴'),
  huaShen('化神'),
  daCheng('大乘');

  const Realm(this.displayName);
  final String displayName;

  static Realm fromName(String name) =>
      Realm.values.firstWhere((r) => r.name == name);
}

/// 五行灵根 (decisions.md #1: 5 维道心 enum, but 灵根 5 elements per CONTEXT.md)
enum Element {
  gold('金'),
  wood('木'),
  water('水'),
  fire('火'),
  earth('土'),
  wind('风'),
  thunder('雷'),
  ice('冰');

  const Element(this.displayName);
  final String displayName;

  static Element fromName(String name) =>
      Element.values.firstWhere((e) => e.name == name);
}

/// 5 道心 path (decisions.md #1: 剑/魔/王/隐/无)
enum HeartPath {
  swordDao('剑道'),
  demonDao('魔道'),
  kingDao('王道'),
  hiddenDao('隐道'),
  noneDao('无道');

  const HeartPath(this.displayName);
  final String displayName;

  static HeartPath fromName(String name) =>
      HeartPath.values.firstWhere((p) => p.name == name);
}

/// 四大位面 (per ADR-0006)
enum Plane {
  mortal('凡界'),
  spirit('灵界'),
  immortal('仙界'),
  divine('神界');

  const Plane(this.displayName);
  final String displayName;

  static Plane fromName(String name) =>
      Plane.values.firstWhere((p) => p.name == name);
}
