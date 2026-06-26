# 灵兽 (Spirit Beast) 设计 — 程序化生成

> **Date**: 2026-06-25
> **Status**: DEFERRED to 金丹+ (per `docs/decisions.md` 决定 #15：字段保留 forward-compat，捕获/培养/战斗 延后实现)
> **Unlock**: **金丹** (per ADR-0003)
> **ADR ref**: ADR-0003, CONTEXT.md (灵兽 term)

---

## 1. 概述

灵兽 = 捕获并培养的伙伴生物。**程序化生成**：

```
灵兽 = 形态 + 元素 + 品级
     = (Form) × (Element) × (Tier)
```

每个实例独立，伴随 好感度 培养。

---

## 2. 数据模型

```dart
enum BeastForm {
  蛇, 虎, 鹰, 龟,    // 常见
  鹤, 麟, 凤, 龙,    // 稀有
}

enum Element { 金, 木, 水, 火, 土, 风, 雷, 冰 }
enum Tier { 凡, 灵, 宝, 灵宝, 仙 }  // 修真 ladder

class SpiritBeast {
  String id;
  String name;                 // {Element}{Form}·{Tier}
  BeastForm form;
  Element element;
  Tier tier;
  BeastStats stats;
  int loyalty;                 // 0-100
  int hunger;                  // 0-100 (高=饿)
  String capturedAt;           // 节点 ID
  String capturedAtLocation;   // 哪捕获
  int seedValue;               // 程序化种子
}

class BeastStats {
  int damage;                  // 战斗伤害
  int defense;                 // 战斗减伤
  int speed;                   // 行动顺序
  int cultivationBonus;        // 主人 闭关 +%
  Element? special;            // 特殊能力元素
}
```

---

## 3. 形态 (8 种)

| Form | Tier 倾向 | 风格 | 修真 ladder 解锁 |
|---|---|---|---|
| 蛇 | 凡/灵 | 速攻 | 金丹 |
| 虎 | 凡/灵 | 平衡 | 金丹 |
| 鹰 | 凡/灵/宝 | 速度 | 金丹 |
| 龟 | 灵/宝 | 防御 | 金丹 |
| 鹤 | 灵/宝 | 辅助 | 金丹 |
| 麟 | 宝/灵宝/仙 | 万能 | 元婴 |
| 凤 | 灵宝/仙 | 攻击 | 元婴 |
| 龙 | 灵宝/仙 | 万能 | 元婴 |

修真 ladder 限制 (per ADR-0005): 某些形态只在特定境界可捕获。

---

## 4. Tier 修真 ladder 概率

金丹 (max=宝):
- 凡: 50%
- 灵: 35%
- 宝: 14%
- 灵宝+: 1%

元婴 (max=灵宝):
- 凡: 20%
- 灵: 35%
- 宝: 30%
- 灵宝: 14%
- 仙: 1%

化神+ (max=仙):
- 凡: 5%
- 灵: 20%
- 宝: 30%
- 灵宝: 35%
- 仙: 10%

---

## 5. 捕获流程

```
玩家到 captureNode (e.g. 灵草谷, 妖兽森林)
  ↓
触发 captureIF
  ↓
玩家 make choice:
  ├── [诱捕] → check 灵根 + 修为
  │     ├── Success → beast 加入
  │     └── Fail → beast 逃跑
  ├── [战斗] → combat 段
  │     ├── Win → beast 加入 (loyalty = 30, low)
  │     └── Lose → 撤退 / 受伤
  └── [放弃] → 离开
```

### 捕获 IF 段示例

```yaml
---
id: capture-tiger-mountain
title: 山间虎影
trigger:
  location: 妖兽森林
  first_visit: true
  random: 0.4   # 40% 触发
requires:
  realm: 金丹期
  min_layer: 1
next:
  - choice: "诱捕"
    goto: capture-success
    condition:
      cultivation_xp: 50
    result:
      add_beast:
        form: 虎
        element: random
        tier: 凡
        loyalty: 50
    flavor: 你将灵草置于陷阱，白虎嗅味而来，落入网中。
  - choice: "战斗"
    goto: capture-combat
    flavor: 你拔剑而上。
  - choice: "悄悄离开"
    goto: exit
---
```

---

## 6. 好感度 培养

### 6.1 修真 ladder 时长

每次 "培养" 修真 ladder 时长:
- 炼气/筑基: 30 秒 (但 MVP 灵兽未解锁)
- 金丹: 5 分钟
- 元婴: 10 分钟
- 化神: 20 分钟
- 大乘: 30 分钟

效果: loyalty +10, hunger -20

### 6.2 喂食

给 beast 1 个 丹药 (1 inventory slot):
- 普通 丹药: loyalty +5, hunger -30
- 高品 丹药: loyalty +15, hunger -50

### 6.3 战斗 (战斗中)

兽 参战 → loyalty 自然 +2/战斗 (若赢)

### 6.4 Loyalty 阶段

| Loyalty | 状态 | 表现 |
|---|---|---|
| 0-30 | 抗拒 | 30% 逃跑 mid-combat |
| 31-60 | 服从 | 战斗 80% efficiency |
| 70-89 | 亲近 | 战斗 100% efficiency |
| 90-100 | 羁绊 | 战斗 120%, 解锁 special 技能 |

---

## 7. 战斗使用

### 7.1 1 个 beast 主动

玩家可携带 ≤ 5 只 beast, 但**只 1 只主动参战**。其余在 "备用栏"。

战斗中可 [切换] beast (消耗 1 turn)。

### 7.2 战斗公式

```
teamDamage = playerDamage + beastDamage * (loyalty/100)
teamDefense = playerDefense + beastDefense
```

### 7.3 元素协同

玩家 element + beast element 匹配 = bonus damage +20%

---

## 8. 道心 联动

beast 好感度 增长受道心影响:

| 道心 | 加成 beast |
|---|---|
| 剑道 | 鹰, 虎 loyalty +20% |
| 王道 | 龙, 麟 loyalty +20% |
| 魔道 | 蛇, 凤 loyalty +20% |
| 无道 | 无加成 |

(per "Bonding" — 道心方向与 beast 性格契合)

---

## 9. UI

### 9.1 灵兽栏

```
[我的灵兽]

主动: 火虎·灵  [灵·火]  loyalty 75
       damage +18, defense +12

备用:
  - 冰蛇·凡  [凡·冰]  loyalty 30
  - 风鹰·宝  [宝·风]  loyalty 90
  - (空)
  - (空)
```

### 9.2 详情

- 名称 + tier + 元素 + form
- stats
- loyalty / hunger bar
- 历史 (在哪捕获, 战斗次数)
- [培养] / [喂食] / [切换主动] / [放生]

---

## 10. 跟其他系统的交互

| 系统 | 交互 |
|---|---|
| 灵根 | 元素匹配 bonus (捕获 + 战斗) |
| 战斗 | 1 兽 主动, 修真 ladder 时长培养 |
| 道心 | 联动 loyalty 增长 |
| 装备 | 元素 + 元素 战斗 bonus |
| 功法 | 不直接 |
| 渡劫 | 渡劫 IF 可选择"兽助" |
| 寿元 | 不直接 |
| 因果 | 不直接 |

---

## 11. 数据规模

- 形态: 8 种
- 元素: 8 种
- Tier: 5 种
- 修真 ladder 组合: 8 × 8 × 5 = 320 unique 组合
- 实际玩家遇到 (金丹→大乘): 20-50 个 beast 候选
- 捕获 IF 段: ~10 段
- 喂食 / 培养 公式
- 工作量: 1-2 周
