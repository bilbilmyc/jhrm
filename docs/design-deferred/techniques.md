# 功法 (Techniques) 设计

> **Date**: 2026-06-25
> **Status**: IN MVP (per `docs/decisions.md` 决定 #15：MVP 字段保留 5 path enum + 单选 1 功法 + 5 维道心 alignment。详细技能树 / 修真 / 数据规模 延后筑基+ 落实后补写)
> **Unlock**: 全游戏可用，无境界门（特定功法可能在某些境界才显示）
> **ADR ref**: ADR-0003 (14 系统), CONTEXT.md (功法 term)

---

## 1. MVP vs Full

| | MVP (slice 4) | Full (post-MVP) |
|---|---|---|
| 技能树 | 1 简化 | 3 棵（剑 / 法 / 体）|
| 功法数 | 3-5 | 每棵 5-8 = 15-24 个 |
| 修炼 (mastery) | 简化为"学了能用" | 学后可"修炼" 提升 |
| 学习点 | 1-2 个 | 多个 (藏书阁/坊市/师门) |
| 道心联动 | 无 | 部分功法需特定 道心 |

---

## 2. 数据模型

```dart
enum TechniqueType { 剑, 法, 体 }
enum Tier { 凡, 灵, 宝, 灵宝, 仙 }  // 修真 ladder 配套

class Technique {
  String id;                       // 唯一 ID
  String name;                     // 古风名 (e.g. "玄清剑典")
  TechniqueType type;              // 剑 / 法 / 体
  Element element;                 // 金/木/水/火/土/风/雷/冰/无
  Tier tier;                       // 凡-仙
  String description;              // 古风描述
  List<TechniqueEffect> effects;   // 战斗效果
  LearnRequirement learn;          // 学习要求
  String learnNodeId;              // 在哪学
  String learnIfId;                // 学习 IF
  bool requiresMastery;            // 是否可"修炼"
}

class TechniqueEffect {
  Element? againstElement;         // 对某元素 +伤害
  int damageBonus;                 // 战斗伤害加成
  int defenseBonus;                // 战斗减伤
  String? specialEffect;           // 特殊 (e.g. "破甲", "连击")
}

class LearnRequirement {
  Element? rootElement;            // 需 灵根 元素
  HeartTrend? heartTrend;          // 需特定 道心趋势
  Realm? minRealm;                 // 最低境界
  int minLayer;                    // 最低层
  List<String> prerequisiteTechs;  // 需先学其他功法
}
```

---

## 3. 技能树（3 棵 × 5-8 个）

### 剑 (Sword)
- 玄清剑典 — 凡 — 金 — 基础剑法
- 流光剑诀 — 凡 — 风 — 速度型
- 玄铁剑法 — 灵 — 金 — 攻击型
- 寒霜剑意 — 灵 — 冰 — 控制型
- 紫电惊虹 — 宝 — 雷 — 高伤害
- 玄天剑典 — 灵宝 — 无 — 终极剑术

### 法 (Magic)
- 灵草辨识 — 凡 — 木 — 辅助
- 灵火诀 — 凡 — 火 — 攻击
- 玄水凝冰 — 灵 — 水 — 控制
- 雷云咒 — 灵 — 雷 — 范围
- 五行符箓 — 宝 — 无 — 通用
- 玄天法典 — 灵宝 — 无 — 终极法术

### 体 (Body)
- 基础吐纳 — 凡 — 无 — 入门
- 灵龟息法 — 灵 — 水 — 防御
- 玄铁体术 — 灵 — 金 — 攻击
- 御风诀 — 宝 — 风 — 闪避
- 玄天体术 — 灵宝 — 无 — 终极体术

---

## 4. 学习流程

```
玩家 reach learnNode (e.g. 藏书阁)
  ↓
触发 learnIf (e.g. "读竹简")
  ↓
玩家 make choice:
  ├── [学] → check LearnRequirement
  │     ├── Pass → add to player.learnedTechniques
  │     └── Fail → IF continues with "你与此道无缘"
  └── [不学] → back to map
```

### 学习 IF 段示例

```yaml
---
id: learn-xuanqing-sword
title: 玄清剑典
trigger:
  location: 藏书阁
  first_visit: true
requires:
  realm: 炼气期
next:
  - choice: "研读"
    goto: learn-success
    condition:
      root_element: 金
    result:
      learn: xuanqing-jian-dian
      heart_delta: { 剑道: +1 }
    flavor: 你翻开竹简，金色剑意自字里行间跃出。
  - choice: "放下竹简离开"
    goto: exit
    heart_delta: { 无道: +1 }
---
```

---

## 5. 修炼 (Mastery)

### 5.1 修真 ladder 时长

| 境界 | 单次 修炼 时长 | 提升 mastery 等级 |
|---|---|---|
| 炼气 | 30 秒 | +1 |
| 筑基 | 2 分钟 | +1 |
| 金丹 | 5 分钟 | +1 |
| 元婴 | 10 分钟 | +1 |
| 化神 | 20 分钟 | +1 |
| 大乘 | 30 分钟 | +1 |

每次 mastery +1, 效果 +10%. Mastery 满 10 = 100% bonus.

### 5.2 修炼 mode

玩家在主屏可以进入"修炼"模式（特殊 闭关）：
- 选 1 个已学 功法
- 修真 ladder 时长 timer
- timer 完 → mastery +1
- 期间可被中断（紧急事件触发）

---

## 6. 战斗使用

### 6.1 单选 1 个 功法（per slice 4）

```
遇敌 (妖兽)
  ↓
玩家选 1 个已学 功法 (from learnedTechniques)
  ↓
伤害计算:
  base_damage = player.境界.base_damage
  + technique.damageBonus * (1 + mastery/10)
  + element_bonus (if technique.element == enemy.weakness)
  - technique.defenseBonus
  ↓
文字结算
```

### 6.2 元素克制

```
金克木  木克土  土克水  水克火  火克金
风 → 平   雷 → 平   冰 → 平
```

被克方: +50% 伤害
克制方: -20% 伤害

### 6.3 战斗 IF 段 (per ADR/slice 4)

小怪: 单选 → 文字结算
Boss IF: 多选择 (可换 功法, 可逃, 可谈判)

---

## 7. UI

### 7.1 功法列表

```
[我的功法]

剑
  ├─ 玄清剑典 [凡·金]  mastery 3/10
  ├─ 流光剑诀 [凡·风]  mastery 0/10
  └─ ...

法
  ├─ 灵草辨识 [凡·木]  mastery 1/10
  └─ ...

体
  └─ 基础吐纳 [凡·无]  mastery 5/10
```

### 7.2 详情

每功法可点开看:
- 名称 + 描述
- 元素 + 类型
- 当前 mastery
- 效果列表
- 学习要求 (if locked)
- [修炼] 按钮 (启动 修真 ladder timer)

---

## 8. 跟其他系统的交互

| 系统 | 交互 |
|---|---|
| 灵根 | 学习要求 (root_element); 元素匹配 bonus |
| 道心 | 部分功法需要特定 道心趋势才能学; 学了之后给 道心_delta |
| 战斗 | 1 选 1, 修真 ladder 修真感 |
| 渡劫 | 渡劫 IF 段可选择默念哪本 功法 |
| 寿元 | 不直接交互 |
| 因果 | 不直接交互 |
| 装备 | 元素匹配 bonus 叠加 |
| 灵兽 | 灵兽元素 + 主人 功法 元素 = 战斗 bonus |

---

## 9. 数据 + 内容规模

- 功法数: 15-24 个手写
- 学习 IF 段: 每功法 1 段 = 15-24 个
- 战斗 IF 段: 修真 ladder 上 6 段 + Boss IF 1 段 (slice 5)
- 总 IF 段: ~20-30 个
- 工作量: 1-2 周
