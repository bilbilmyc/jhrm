# 装备 (Treasure) 设计 — 程序化生成

> **Date**: 2026-06-25
> **Status**: DEFERRED to 筑基+ (per `docs/decisions.md` 决定 #15：字段保留 forward-compat，模板/品级/loot 延后实现)
> **Unlock**: **筑基** (per ADR-0003)
> **ADR ref**: ADR-0003 (programatic layer), CONTEXT.md (法宝 term)

---

## 1. 概述

法宝 = 角色携带的装备。**程序化生成**（per ADR-0003）：

```
法宝 = 模板 + 元素 + 品级
     = (Template) × (Element) × (Tier)
```

每个实例都有独立 ID + 名字 + 数值。

---

## 2. 数据模型

```dart
enum TreasureTemplate {
  剑, 刀, 枪, 锤,    // 武器
  盾, 袍, 甲, 衣,    // 护甲
  环, 印, 镜, 旗,    // 饰品
  符, 珠, 佩          // 备用
}

enum Element { 金, 木, 水, 火, 土, 风, 雷, 冰 }
enum Tier { 凡, 灵, 宝, 灵宝, 仙 }   // 修真 ladder

class Treasure {
  String id;                 // UUID
  String name;               // {Element}{Template}·{Tier}
  TreasureTemplate template;
  Element element;
  Tier tier;
  EquipmentSlot slot;        // 武器/护甲/饰品/备用
  TreasureStats stats;       // 数值
  TreasureEffect? effect;    // 可选特殊
  int seedValue;             // 程序化种子（存档用）
}

class TreasureStats {
  int damage;                // 战斗伤害
  int defense;               // 战斗减伤
  int hpBonus;               // HP 上限加成
  int cultivationBonus;      // 闭关 效率 (%)
}

class TreasureEffect {
  String name;               // 破甲/连击/吸血/反伤/...
  Trigger trigger;           // 触发条件
  int chance;                // 触发概率 (%)
  EffectAction action;       // 触发效果
}
```

---

## 3. 模板列表（15 种）

### 武器 (5)
- 剑 — 平衡
- 刀 — 高伤害 / 低速度
- 枪 — 长距离
- 锤 — 高爆发 / 低速度
- (备用扩展)

### 护甲 (4)
- 盾 — 高防御 / 不能用法术
- 袍 — 法术加成
- 甲 — 物理防御
- 衣 — 平衡

### 饰品 (4)
- 环 — 攻击加成
- 印 — 修为加成
- 镜 — 反弹法术
- 旗 — 范围效果

### 备用 (2)
- 符 — 一次性使用
- 珠 — 储存修为
- 佩 — 装饰 (无效果)

---

## 4. 元素 + 修真 ladder 组合

### 4.1 修真 ladder 上限 (per ADR-0005)

| 境界 | 最高 tier |
|---|---|
| 筑基 | 灵 |
| 金丹 | 宝 |
| 元婴 | 灵宝 |
| 化神+ | 仙 |

### 4.2 Tier 概率 roll (per 境界)

筑基 (max=灵):
- 凡: 70%
- 灵: 30%
- 宝+: 0%

金丹 (max=宝):
- 凡: 40%
- 灵: 45%
- 宝: 14%
- 灵宝+: 1%

元婴 (max=灵宝):
- 凡: 20%
- 灵: 40%
- 宝: 30%
- 灵宝: 9%
- 仙: 1%

化神+ (max=仙):
- 凡: 10%
- 灵: 25%
- 宝: 35%
- 灵宝: 25%
- 仙: 5%

### 4.3 元素匹配 bonus

灵根 element 匹配法宝 element:
- +1 tier (相当于品质提高一级)
- 不匹配: 0 bonus (但仍可用)

---

## 5. 生成规则

```dart
Treasure generateTreasure({
  required Realm playerRealm,
  required Element playerRoot,
  required int luck,           // 0-100
  int? forceTier,              // 调试 / 金手指用
}) {
  final template = random.pick(TreasureTemplate.values);
  final element = random.pick(Element.values);
  final tier = forceTier ?? rollTier(playerRealm, luck);
  final matched = element == playerRoot;
  final effectiveTier = matched ? upgradeTier(tier) : tier;
  
  return Treasure(
    id: uuid(),
    name: '${element.name}${template.name}·${effectiveTier.name}',
    template: template,
    element: element,
    tier: effectiveTier,
    slot: template.slot,
    stats: computeStats(template, effectiveTier),
    seedValue: random.seed,
  );
}
```

### 5.1 Stats 计算

修真 ladder (per ADR-0005):
- 筑基 1/9: base = 10
- 每升 1 layer: × 1.05 (线性)
- 每跨 1 境界: × stat_ladder multiplier

实际公式:
```
base = 10 * pow(1.05, layer-1) * statLadder(realm)
damage = base * template.damageMul
defense = base * template.defenseMul
```

Stat ladder (per ADR-0005):
- 炼气→筑基: × 1.5
- 筑基→金丹: × 2
- 金丹→元婴: × 3
- 元婴→化神: × 5
- 化神→大乘: × 10

---

## 6. 名字生成

| Element | Template | Tier | Name |
|---|---|---|---|
| 火 | 剑 | 凡 | 火剑·凡 |
| 火 | 剑 | 灵 | 火剑·灵 |
| 火 | 剑 | 宝 | 火剑·宝 |
| 金 | 环 | 灵宝 | 金环·灵宝 |
| 冰 | 袍 | 仙 | 冰袍·仙 |

变体 (15% 概率):
- 凡人名: "玄铁剑·凡" / "紫电剑·灵" (按 tier + template 加前缀)
- 修真前缀表: 玄铁/紫电/青锋/朱雀/玄冰/...

---

## 7. 装备槽位

| 槽 | 类型 | 数量 |
|---|---|---|
| 武器 | 武器 template | 1 |
| 护甲 | 护甲 template | 1 |
| 饰品 | 饰品 template | 1 |
| 备用 | 任何 | 1 |

---

## 8. 战斗影响

```
finalDamage = player.baseDamage
            + technique.damageBonus * (1 + mastery/10)
            + weaponDamage
            + elementMatchBonus

finalDefense = player.baseDefense
             + armor.defense
             + defenseBonus
```

---

## 9. 获取方式

| 方式 | 概率/频率 | 来源 |
|---|---|---|
| 战斗掉落 | 30% / combat | 小怪 30%, Boss 100% |
| 商店购买 | 经常 | 坊市 / 集市 |
| IF 段发现 | 偶发 | 上古遗府 / 仙人遗物 |
| 炼丹副产 | 偶发 | 炼丹 5% 副产 |
| 金手指 | 100% | 一键装备最强 |

---

## 10. UI

### 10.1 装备列表

```
[我的法宝]

武器: 火剑·灵  [灵·火]
       damage +25, cultivation +5%

护甲: 冰袍·凡  [凡·冰]
       defense +12

饰品: (空)

备用: 金环·凡  [凡·金]
       (未装备)
```

### 10.2 详情 + 比较

点开看:
- 名称 + tier
- 元素
- stats
- 元素匹配 (灵根 是否匹配)
- 修真 ladder 当前境界 推荐 tier
- [装备] / [卸下] / [卖] / [丢]

---

## 11. 跟其他系统的交互

| 系统 | 交互 |
|---|---|
| 灵根 | 元素匹配 +1 tier |
| 战斗 | stats 直接影响 |
| 灵兽 | 灵兽元素 + 法宝元素 = 战斗 bonus |
| 渡劫 | 渡劫 IF 段可选择"以法宝护体" |
| 功法 | 修真 ladder 上元素 + 法宝元素 = bonus |
| 寿元 | 不直接 |
| 因果 | 不直接 |

---

## 12. 数据规模

- 模板: 15 种 (手写)
- 元素: 8 种
- Tier: 5 种
- 修真 ladder 组合: 15 × 8 × 5 = 600 个 unique 组合
- 实际生成: 玩家玩 1 局 (筑基→大乘) 约遇 50-100 个法宝
- 名字表: ~50 个修真前缀
- 工作量: 1 周
