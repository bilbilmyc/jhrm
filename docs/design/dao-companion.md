# 道侣 (Dao Companion) 设计

> **Date**: 2026-06-25
> **Status**: DEFERRED to 元婴+ (per `docs/decisions.md` 决定 #15：字段保留 forward-compat，候选/关系线/好感度 延后实现)
> **Unlock**: 元婴期

---

## 1. 概述

道侣是可攻略的 NPC，每个有独立关系线。系统手写 5-8 个候选道侣，每个有独立性格、灵根、道心和完整关系线。元婴期解锁。关系等级 0-100，达到阈值触发里程碑与 IF 段。

---

## 2. 数据模型

```dart
class DaoCompanion {
  String id;
  String name;                  // 古风名
  Gender gender;
  int age;                      // 外表年龄
  String personality;           // 性格描述
  HeartPath heartPath;          // 道心方向
  Element element;              // 元素
  List<String> affinityTags;    // 偏好标签（剑修、善人、老成）
  List<String> aversionTags;    // 厌恶标签（魔道、欺骗）
  List<RelationshipMilestone> milestones;
  String portraitId;            // SVG 头像文件
}

class RelationshipMilestone {
  int affinityThreshold;        // 触发此里程碑的好感度
  String milestoneType;         // 初识 / 接触 / 好感 / 暧昧 / 定情 / 成道侣
  String triggerIfId;           // 触发的 IF 段
  HeartDelta heartDelta;
  KarmaDelta karmaDelta;
  List<Effect> effects;
}

class CompanionState {
  String companionId;
  int affinity;                 // 0-100
  List<String> unlockedMilestones;
  bool isBonded;
  List<String> gifts;           // 送过的礼物
}
```

---

## 3. 候选道侣（5-8 个手写）

| ID | 名字 | 性格 | 道心 | 元素 | 关系线主题 |
|---|---|---|---|---|---|
| lu-xiaoyan | 陆小燕 | 活泼 | 剑道 | 金 | 同门师妹，剑修天才 |
| shen-yueru | 沈月如 | 温婉 | 王道 | 水 | 世家千金，温良恭俭 |
| qing-yue | 青月 | 冷峻 | 无道 | 冰 | 神秘剑客，来历不明 |
| xie-wuhen | 邪无痕 | 邪魅 | 魔道 | 火 | 魔宗少主，相爱相杀 |
| lin-shuang | 林霜 | 刚烈 | 王道 | 土 | 同门师姐，外冷内热 |
| fang-qing | 芳卿 | 古灵 | 隐道 | 风 | 妖族公主，与众不同 |

5-8 个候选是合理范围，太多容易稀释。

---

## 4. 关系线结构

每道侣约 10 个 IF 段 / 关系线：

```
[初识] (affinity 0)
  → [接触] (10)
  → [好感] (30)
  → [暧昧] (50)
  → [定情] (70)
  → [成道侣] (90)
  → [结局] (大乘 9 修真)
```

每段约 200-500 字 + 2-4 个选项。

---

## 5. 好感度增长

### 5.1 IF 段选择

道侣 IF 段选择「善待她」类选项通常 +10 ~ +30 好感度。

### 5.2 礼物系统

可送法宝、丹药、灵草、灵兽：
- 元素匹配：+20 好感度
- 道心匹配：+30 好感度
- 不匹配：0 或 -10

### 5.3 共同战斗

同战斗一场 +5 好感度。

### 5.4 闭关双修

闭关 + 道侣：道侣好感 +20，闭关速度 +10%。

### 5.5 因果影响

- 大善 + 王道道侣：好感度增长 +50%
- 魔道 + 王道道侣：好感度增长 -30%

---

## 6. 好感度阈值与里程碑

| 阈值 | 里程碑 | 触发 |
|---|---|---|
| 0 | 初识 | 第一次见面 |
| 10 | 接触 | 第一次互动 |
| 30 | 好感 | 多次互动 |
| 50 | 暧昧 | 关键选择触发 |
| 70 | 定情 | 求婚类 IF 段 |
| 90 | 成道侣 | 道侣缔结 IF 段 |
| 100 | 至死不渝 | 大乘期专属 IF 段 |

---

## 7. 修真 ladder 影响

- 元婴期：道侣首次可遇
- 好感度 90+：触发定情 IF 段
- 大乘期：触发成道侣 IF 段
- 飞升 IF：根据好感度与道心影响最终结局

---

## 8. 战斗加成

- 协同战斗：+5% 伤害
- 治疗道侣：+5% 防御
- 道侣濒死：玩家伤害 +10%（情感爆发）

---

## 9. UI

**道侣列表页**：
- 名字 + 道心方向 + 元素
- 好感度 bar
- 历史里程碑
- 「接触」按钮触发对应 IF 段

**道侣详情页**：
- 立绘（SVG 头像）
- 性格描述
- 关系阶段
- 可送礼物列表
- 已触发里程碑
- 按钮：[交谈] [送礼] [共同战斗] [求道]

---

## 10. 跟其他系统交互

| 系统 | 交互 |
|---|---|
| 因果 | 道侣影响因果值与道心方向 |
| 战斗 | 道侣协同战斗加成 |
| 功法 | 双方功法可互相借鉴 |
| 装备 | 可送装备作为礼物 |
| 灵兽 | 可送灵兽作为礼物 |
| 渡劫 | 道侣可在渡劫 IF 段互动 |
| 声望 | 派系影响道侣态度 |

---

## 11. 数据规模

- 候选道侣：5-8 个
- IF 段：约 50 段（5-8 道侣 × 6-10 段）
- SVG 头像：5-8 个
- 工作量：1-2 月
