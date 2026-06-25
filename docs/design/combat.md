# 战斗 (Combat) 系统设计

> **Date**: 2026-06-25
> **Status**: DEFERRED to 筑基+ (per `docs/decisions.md` 决定 #6：MVP 战斗 = 单次选功法 + 文字结算；HP bar / 回合 / 撤退 / 元素克制 / 数据规模 全部延后)
> **Type**: 文字战斗 (no real-time, no HP bar in MVP)
> **ADR ref**: Combat (小怪单选 + Boss IF) confirmed in earlier grilling

---

## 1. 战斗种类

| 类型 | 触发 | 流程 | 范围 |
|---|---|---|---|
| **小怪战斗** | 野外随机遭遇 | 单选 1 功法 → 文字结算 | MVP |
| **Boss 战斗** | 渡劫台（渡劫）/ 特定节点 IF | 多选择 IF 段 | MVP（仅渡劫）|
| **NPC 对决** | 因果-gated 段 | 文字 + 选 功法 / 谈判 | 筑基+ |

**MVP**: 小怪战斗（简化）+ 渡劫（Boss IF）。

---

## 2. 数据模型

```dart
class Combatant {
  String id;                  // "player" or enemy id
  String name;
  int layer;                  // 当前层 (1-9)
  Realm realm;                // 当前境界
  CombatStats stats;
  List<Technique> techniques; // 已学功法
  List<Treasure> equipment;   // 已装备
  SpiritBeast? beast;         // 主动 beast (金丹+)
  int currentHp;
  int maxHp;
  int karma;
  HeartVector heart;
}

class CombatStats {
  int baseDamage;
  int baseDefense;
  Element element;            // 玩家灵根元素
}

class CombatEncounter {
  String id;
  String location;
  Combatant enemy;
  CombatDifficulty difficulty;
  List<LootDrop> drops;
  bool isBoss;
}
```

---

## 3. 基础属性（修真 ladder per ADR-0005）

```
baseStat = 10 × pow(1.05, layer - 1) × statLadder(realm)
```

`statLadder` 倍率：

| 境界 | 倍率 |
|---|---|
| 炼气 | 1 |
| 筑基 | 1.5 |
| 金丹 | 3 |
| 元婴 | 9 |
| 化神 | 45 |
| 大乘 | 450 |

**示例**：
- 炼气 1/9 玩家 baseStat = **10**
- 炼气 9/9 玩家 baseStat ≈ **14**
- 筑基 1/9 玩家 baseStat = **15**
- 金丹 1/9 玩家 baseStat = **30**
- 元婴 1/9 玩家 baseStat = **90**
- 大乘 1/9 玩家 baseStat = **4500**

---

## 4. 元素克制

```
金克木   木克土   土克水   水克火   火克金
风/雷/冰 → 平
```

| 关系 | 伤害修正 |
|---|---|
| 你克敌 | +50% 伤害 |
| 敌克你 | -20% 伤害 |
| 平 | 0 |

---

## 5. 小怪战斗

### 5.1 流程

```
野外移动（在 妖兽森林 等节点）
  ↓
触发随机遭遇（30% per 移动）
  ↓
显示敌：名称、元素、危险度
  ↓
[选 1 功法 from learnedTechniques]
  ↓
伤害计算 → 文字结算 → 掉落 → 回到地图
```

### 5.2 伤害公式

```
playerDamage = baseDamage
             + technique.damageBonus × (1 + mastery / 10)
             + weaponDamage
             + elementMatchBonus(playerTech.element, enemy.element)
             + beastDamage × (beast.loyalty / 100)
             + karmaModifier

enemyDamage = enemy.baseDamage
            + elementMatchBonus(enemy.element, player.element)
            - armorDefense

胜负判定:
  if (playerDamage > enemyDamage × 2)    → instant kill
  if (playerDamage > enemyDamage)        → win
  if (|diff| < 20%)                       → 50/50
  if (playerDamage < enemyDamage)        → retreat option
```

### 5.3 文字结算模板

```
你以 [功法名] 击向 [敌名]！

[你元素] 遇 [敌元素]，[克 / 被克 / 平]。
你 [造成 X 伤害 / 大破 / 略伤敌]。

[回合 2/3]
[敌] 反扑，[造成 Y 伤害 / 略伤 / 失手]。

[回合 3/3]
[胜 / 败 / 僵]！

[胜] 你将 [敌] 击退。获得：[掉落]
[败] 你且战且退, 退回原地。
[僵] 你摆脱 [敌], 退回原地。
```

### 5.4 掉落

| 物品 | 概率 |
|---|---|
| 灵石 | 100%（5-50 上限 per 境界）|
| 装备（筑基+） | 30%（tier per 境界）|
| 丹药（筑基+） | 20% |
| 灵兽（金丹+） | 5% |
| 功法（rare） | 1% |

---

## 6. Boss 战斗（渡劫 IF）

### 6.1 渡劫作为 Boss

渡劫 IF 段（per slice 5）：
- 4-6 个 choice
- 每个 choice 是 1 个功法 / 道心 / 因果 决策
- outcome（success / fail）

### 6.2 渡劫 IF choice 类型

- "默念 功法 [X]" → technique 元素与天劫元素相克
- "叩问 本心" → 道心方向决定天劫态度
- "强运 修为 硬抗" → high variance
- "散去 部分修为 求全" → 保证不 fail，但扣修为

### 6.3 渡劫 成功 概率

```
tribulationSuccess = base 50%
                   + karmaModifier (善 +20% / 恶 -20%)
                   + techniqueMatch (+/- 10% per element)
                   + heartAlignment (+/- 10% per 道心)
                   + forceSuccess (金手指) = 100%
```

### 6.4 渡劫 outcome（per ADR-0008 + slice 5）

- success → state.境界 = 筑基 1/9
- fail → state.境界 = 炼气 1/9, 修为 = 50%
- 无 Game Over

---

## 7. 因果 / 道心 modifier

### 7.1 因果

- 大善 / 大恶：±5% damage
- 善 NPC：因善名而主动助（特定 IF 段）

### 7.2 道心

- 道心方向匹配技能类型 → damage +10%（e.g. 剑道 → 剑类 damage +10%）
- 反向道心 → damage -5%

---

## 8. 触发机制

### 8.1 随机遭遇

- 野外节点：30% per 移动
- 固定节点：fixed encounter（特定 IF 段触发）

### 8.2 节点类型

- 妖兽森林：随机小怪 + Boss 候选
- 灵草谷：低概率遇妖
- 古修遗府：因果-gated 段
- 山门 / 集市 / 坊市：无战斗

---

## 9. UI

### 9.1 遭遇界面

```
[遭遇 妖兽！]

火鬃狐  [火]
危险度: 中

[选择 1 个 功法]
  ├─ 玄清剑典 [金]   元素克制
  ├─ 灵火诀   [火]   同元素
  └─ 灵草辨识 [木]   (辅助)

[逃]  (撤退)
```

### 9.2 战斗过程

```
火鬃狐 血 60/100
你  血 100/100

[回合 1]
你 出招 (玄清剑典)  → 造成 25 伤害
火鬃狐 反扑 (撕咬)    → 造成 12 伤害

[回合 2]
...
```

### 9.3 战斗结算

```
你以 玄清剑典 击向 火鬃狐。
金 遇 火，金克火。

你造成大破。
火鬃狐 撕咬，你略伤。

[你胜！获得: 灵石 ×15, 破损 玄铁剑 ×1]
```

---

## 10. MVP 测试

> **Status**: DEFERRED to 筑基+。Per `docs/decisions.md` 决定 #6：MVP 战斗 = 单次选功法 + 文字结算。combat 系统整套（HP bar / 回合 / 撤退 / loot）延后到筑基+实现。渡劫 IF 段走 IF 段系统，不走 combat 系统。
>
> 原 §10 的占位符（"the-bug"）已清理。详细测试用例待 combat 系统在筑基+ 阶段落实后补写。

---

## 11. 与其他系统交互

| 系统 | 交互 |
|---|---|
| 灵根 | 元素匹配 bonus |
| 功法 | 1 选 1，伤害 = base + bonus |
| 装备 | weaponDamage / armorDefense |
| 灵兽 | beastDamage × (loyalty / 100) |
| 道心 | direction match +10% |
| 因果 | 大善/大恶 ±5% |
| 渡劫 | choice → success probability |

---

## 12. 数据规模

- 妖兽类型: ~10 种 (手写, per ADR-0005)
- 元素: 8 种
- 危险度: easy / medium / hard / boss
- 修真 ladder 上限: 6 境界 (per ADR-0006)
- 工作量: 数据 + UI + 测试 = 2 周

> **Status**: DEFERRED to 筑基+。Per `docs/decisions.md` 决定 #6：MVP 战斗 = 单次选功法 + 文字结算。本文档整套设计（HP bar / 回合 / 撤退 / 元素克制 / 数据规模）延后实现，作为 v0.2+ 蓝图保留。
