# 因果 (Karma) 设计

> **Date**: 2026-06-25
> **Status**: PARTIAL (per `docs/decisions.md` 决定 #3：MVP 字段保留，事件 / 渡劫 modifier / NPC 态度全部 noop，标 `// TODO 筑基+`)
> **Unlock**: 全游戏可用, 炼气 1/9 起
> **ADR ref**: ADR-0003 (hand-written core), CONTEXT.md (因果 term)

---

## 1. MVP vs Full

| | MVP | Full |
|---|---|---|
| 因果值 | numeric (+/-) | -100 ~ +100 修真 ladder |
| 事件 | 5-10 触发 | 50+ 事件 |
| NPC 态度 | 简化为善/恶两类 | per-NPC affinity |
| 渡劫 bonus | 无 | 善 +20% / 恶 -20% |
| IF 段 gates | 无 | 需 ≥ X / ≤ -Y 才能触发 |
| 善恶史 | 无 | 历史 log |

---

## 2. 数据模型

```dart
class Karma {
  int value;                       // -100 ~ +100
  List<KarmaEvent> events;         // 历史事件
  Map<String, int> npcAffinity;    // per-NPC 因果
  KarmaTier tier;                  // 大善/小善/中性/小恶/大恶
}

enum KarmaTier {
  大善,    // ≥ 50
  小善,    // 0 ~ 49
  中性,    // 0
  小恶,    // -49 ~ 0
  大恶,    // ≤ -50
}

class KarmaEvent {
  String id;
  String description;              // 古风短句
  int delta;                       // +/- value
  DateTime timestamp;              // 修真 ladder time
  KarmaType type;                  // 善 / 恶 / 中性
  String? relatedNpc;              // 涉及 NPC ID (optional)
}
```

---

## 3. 修真 ladder tier 划分

| Tier | 阈值 | 描述 |
|---|---|---|
| 大善 | value ≥ 50 | 德高望重, NPC 主动助, 渡劫 +20% |
| 小善 | 0 < value < 50 | 与人为善, NPC 友好 |
| 中性 | value = 0 | 中立 |
| 小恶 | -50 < value < 0 | 偶有戒心 |
| 大恶 | value ≤ -50 | 恶名远扬, NPC 主动敌, 渡劫 -20% |

### 3.1 因果值修真 ladder (per ADR-0005 stat ladder)

因果值 修真 ladder (类比 stat ladder) — 但更平缓:
- 每升 1 layer: ±5 上限 (中)
- 每跨 1 境界: ±20 上限

| 境界 | 因果范围 |
|---|---|
| 炼气 | -50 ~ +50 |
| 筑基 | -100 ~ +100 |
| 金丹 | -150 ~ +150 |
| 元婴 | -200 ~ +200 |
| 化神 | -250 ~ +250 |
| 大乘 | -300 ~ +300 |

---

## 4. 事件表（50+ 个）

### 4.1 善行 (positive)

| ID | 描述 | Δ |
|---|---|---|
| save-drowning-villager | 救溺水村民 | +5 |
| give-money-beggar | 给乞丐银两 | +2 |
| keep-promise | 完成承诺 | +3 |
| help-young-cultivator | 指点后辈 | +3 |
| return-lost-item | 归还失物 | +2 |
| donate-to-temple | 捐香火钱 | +3 |
| free-captive-beast | 放生被捕灵兽 | +5 |
| heal-injured | 救治伤者 | +4 |
| protect-weak | 庇护弱者 | +5 |
| respect-elder | 敬重长者 | +2 |
| avenge-injustice | 替冤者报仇 | +8 |
| spare-defeated-enemy | 饶恕败者 | +5 |
| donate-pills | 赠丹救人 | +10 |
| teach-public-skill | 公开授法 | +8 |
| sacrifice-self | 舍身救人 | +20 |

### 4.2 恶行 (negative)

| ID | 描述 | Δ |
|---|---|---|
| kill-innocent | 杀无辜 | -10 |
| steal-treasure | 偷法宝 | -5 |
| deceive-trusting | 骗信任者 | -3 |
| break-promise | 毁约 | -5 |
| betray-mentor | 背叛师门 | -15 |
| burn-village | 屠村 | -20 |
| desecrate-temple | 毁庙 | -10 |
| rob-beggar | 抢乞丐 | -3 |
| poison-rival | 毒害同道 | -8 |
| enslave-beast | 奴役灵兽 | -5 |
| frame-innocent | 冤枉无辜 | -8 |
| extort-weak | 敲诈弱者 | -5 |
| sabotage-rival | 暗算同道 | -8 |
| defile-corpse | 辱尸 | -10 |
| mass-murder | 大规模杀戮 | -30 |

### 4.3 中性 (记录但不改值)

| ID | 描述 |
|---|---|
| observe-conflict | 旁观冲突 |
| accept-gift | 接受赠礼 |
| refuse-bribe | 拒收贿赂 |
| ignore-beggar | 视而不见 |
| ... | ... |

---

## 5. NPC 态度

### 5.1 Base affinity

每个 NPC 有 base affinity (-50 ~ +50):
- 善 NPC (e.g. 老者): +30
- 中 NPC (e.g. 商人): 0
- 恶 NPC (e.g. 魔修): -30

### 5.2 Karma modifier

```
npcFinalAffinity = npcBase + karmaValue / 5
```

### 5.3 Attitude tier

| Final Affinity | 态度 | 表现 |
|---|---|---|
| ≥ 50 | 挚友 | 主动助, 送宝, 救命 |
| 0 ~ 49 | 友好 | 友好对话, 交易优惠 |
| -49 ~ 0 | 警惕 | 普通对话 |
| ≤ -50 | 敌对 | 主动敌, 不交易 |

### 5.4 Per-NPC 偏离

NPC 可有 "personality offset":
- 例: 老者 (base +30) 实际态度阈值: ≥ 30 = 挚友 (instead of 50)
- 例: 魔修 (base -30) 因果 ≥ 0 也可能敌对

---

## 6. 渡劫 bonus

```
tribulationBaseSuccess = 50%
+ karmaModifier (per 修真 ladder tier):
  - 大善 (≥ 50): +20%
  - 小善: +5%
  - 中性: 0%
  - 小恶: -5%
  - 大恶 (≤ -50): -20%
+ techniqueModifier (默念 功法)
+ elementModifier
= final success %
```

---

## 7. IF 段 gates

### 7.1 因果-gated IF 段

```yaml
---
id: ancient-ruin
title: 上古遗府
trigger:
  location: 灵草谷
  random: 0.2
requires:
  realm: 筑基期
  karma: { min: 30 }    # 需 大善/小善
next:
  - choice: "进入"
    goto: ruin-enter
    effect:
      karma: +5
    flavor: 守门傀儡见你善名远扬，恭敬让开。
---
```

### 7.2 恶向 IF 段

```yaml
---
id: demon-path
title: 魔道秘法
trigger:
  location: 古修遗府
  first_visit: false
requires:
  realm: 金丹期
  karma: { max: -20 }   # 需 小恶/大恶
next:
  - choice: "修炼"
    goto: demon-train
    effect:
      karma: -5
    heart_delta: { 魔道: +3 }
    flavor: 黑气缭绕，你感受到力量的代价。
---
```

---

## 8. 触发方式

### 8.1 IF 段选择 (主方式)

IF 段 choice 触发 `effect.karma: ±N`.

### 8.2 战斗

- 杀敌: 0 (unless enemy 因果 known)
- 杀善 NPC: -10
- 杀恶 NPC: +3

### 8.3 修真 ladder 积累

- 长时间闭关: 中性
- 修真 ladder 跨境界: 中性 (但 +5 一次性 bonus per 境界)
- 渡劫成功: +5
- 渡劫失败: -2

---

## 9. 修真 ladder tier visualization

```
[因果] 当前: 小善 (value +25)

  ←─── 大恶 ─── 小恶 ── 中性 ── 小善 ───→ 大善 ───→
        -50            0              50

  [位置: ●] (value +25)
```

### 9.2 事件历史

滚动列表:
```
+5  [炼气 3] 救溺水村民于 灵草谷
+3  [炼气 5] 完成对 老修士 的承诺
-2  [炼气 6] 拒绝帮 乞丐
...
```

---

## 10. 跟其他系统的交互

| 系统 | 交互 |
|---|---|
| 灵根 | 不直接 |
| 功法 | 部分 功法要求 因果 tier |
| 装备 | 商店/坊市 价格 受 因果 影响 (善 = 优惠) |
| 灵兽 | 善向 灵兽 好感度 + |
| 道心 | 善/恶 + 道心方向影响 NPC |
| 渡劫 | success bonus (善+20%/恶-20%) |
| 寿元 | 不直接 |
| 战斗 | 杀善/恶 NPC 影响 |
| IF 段 | gates 触发 |

---

## 11. 数据 + 内容规模

- 事件: 50+ 个
- NPC base affinity: 30+ 个手写 (每个 NPC)
- IF 段 因果 gates: 10+ 段
- 因果历史 UI: scrolling list widget
- 修真 ladder tier 计算: stateless function
- 工作量: 1-2 周 (其中 IF 段写作为主)
