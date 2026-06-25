# MVP PRD — 凡界修真 v0.1

> **Status**: Draft (待 review)
> **Date**: 2026-06-25
> **Source**: 由 14 个 design 决定 + 4 个细化讨论固化
> **Scope**: 仅 MVP。后续子系统（装备/丹药/灵兽/道侣/...）后续单独 PRD。

---

## Problem Statement

开发者想玩一款**移动端修真文字游戏**——传统仙侠风格，单人玩，有金手指作开发调试工具。已通过 18+ 个设计决定把项目方向定下来（见 `CONTEXT.md` + `docs/adr/0001-0008.md`），但**还没写过一行代码**。

要进入实现阶段，需要一份**最小可玩切片**作为第一个里程碑——能玩、能测、能迭代。本 PRD 描述这个 MVP。

---

## Solution

MVP = **凡界 + 炼气期 + 3 系统 + 1 Boss IF + 金手指 + 1 存档槽**。

玩家打开 App → 进入凡界（~10 节点）→ 看状态 → 选节点 → 读 IF 段、做选择（积累道心）→ 闭关（30s/次）→ 修为满 → 触发小层突破 IF → 升层 → 重复 9 次 → 炼气 9/9 → 触发渡劫 IF → 飞升到筑基（success）或 跌回炼气 1/9（fail）→ 自动存档。

预计工作量 1-2 个月。游戏循环跑通后可继续扩展到灵界（筑基+金丹）+ 仙界 + 神界。

---

## User Stories

### 基础移动 / 启动

1. As a player, I want to launch the app and see the 凡界 main view, so that I can start my cultivation journey.
2. As a player, I want to see my current state (境界, 层, 修为进度, 灵根, 道心), so that I know where I am.
3. As a player, I want the app to remember my progress across launches, so that I don't lose it.

### 移动与地图

4. As a player, I want to see the ~10 nodes of 凡界 as a list with small SVG icons, so that I can browse locations.
5. As a player, I want to toggle to a 2D mini-map view of the same nodes, so that I can visualize the world.
6. As a player, I want to tap a node to travel there, so that I can explore.
7. As a player, I want travel to be instant (no time cost), so that I can focus on cultivation, not navigation.

### 事件与 IF

8. As a player, I want to read IF segments when I arrive at a node, so that I can experience the story.
9. As a player, I want each IF segment to be a Markdown file with YAML frontmatter (triggers / choices / conditions), so that content is git-friendly and writable.
10. As a player, I want IF choices to lead to other IF segments or back to the map, so that the story branches.
11. As a player, I want to make a choice by tapping, so that the interaction is mobile-native.
12. As a player, I want to see my 道心 trend update after key IF choices, so that I can see my path forming.

### 灵根

13. As a player, I want to choose my 灵根 at character creation (from 金/木/水/火/土), so that I can define my elemental affinity.
14. As a player, I want 灵根 to limit which 功法 I can learn, so that my choice has consequences.
15. As a player, I want to see my 灵根 displayed in the status view, so that I can reference it.

### 功法

16. As a player, I want to learn 功法 from a simplified skill tree (3-5 techniques) at certain nodes, so that I can build my character.
17. As a player, I want to see which 功法 I've learned, so that I can track my progress.

### 道心

18. As a player, I want my IF choices to accumulate 道心 (a 2D vector towards 剑道/魔道/王道/无道), so that my path matters.
19. As a player, I want to see my 道心 as a compass / indicator in the status view, so that I can see my direction.

### 闭关与修为

20. As a player, I want to "闭关" (start a cultivation session), so that I can accumulate 修为.
21. As a player, I want each 闭关 to take 30 seconds (per 修真 ladder at 炼气), so that the timing is right.
22. As a player, I want to see 修为 bar fill in real-time during 闭关, so that I can see progress.
23. As a player, I want to be able to cancel 闭关 mid-way (or wait it out), so that I have control.

### 突破

24. As a player, I want 修为 bar full → triggers a 突破, so that the progression happens automatically.
25. As a player, I want a small IF segment at 小层 突破 (e.g. 炼气 1 → 2), so that the progression has narrative.
26. As a player, I want the small IF to have success/failure outcomes, so that there's a small risk.

### 渡劫 (大境界突破)

27. As a player, I want 炼气 9/9 to trigger a 渡劫 IF segment, so that I can attempt to advance to 筑基.
28. As a player, I want the 渡劫 IF to have multiple choices that affect outcome, so that my decisions matter.
29. As a player, I want 渡劫 success → advance to 筑基 1/9, so that the journey continues.
30. As a player, I want 渡劫 failure → drop back to 炼气 1/9 with 修为 halved, so that there's consequence but no game over.

### 战斗 (B 模式：小怪单选 + Boss IF)

31. As a player, I want to encounter 妖兽 at certain nodes, so that there's variety.
32. As a player, I want to fight 妖兽 by picking 1 功法 (single skill pick), so that combat is quick.
33. As a player, I want combat outcome to depend on 功法 choice + my current 境界, so that there's meaning.
34. As the MVP, I want the 渡劫 itself to BE the Boss IF (no separate boss encounters), so that the MVP is focused.

### 金手指 (核心特性)

35. As the developer, I want to tap top-left corner 5 times to access the gold finger menu, so that I have a hidden dev tool.
36. As the developer, I want to type "godmode" as an alternate password, so that I have a second access.
37. As the developer, I want the gold finger menu to include: 修为×N / 修为满, 跳到下一章, 切换灵根, 切换道心, 一键装备, 一键丹药, 一键灵兽 (no-op for MVP), 渡劫成功, 重置存档.
38. As the developer, I want the gold finger menu to be hidden in normal UI (not visible), so that it doesn't break the game's fiction.

### 存档

39. As a player, I want the game to auto-save at: 离开位面, 闭关结束, 战斗结束, IF 选完选项, 渡劫结束.
40. As a player, I want to load the save on app launch, so that I resume where I was.
41. As the MVP, I want a single save slot (no multi-slot UI), so that the MVP is minimal.

### 内容 (开发侧)

42. As the developer, I want IF segments to live as `.md` files in `content/凡界/`, so that I can author them in any editor.
43. As the developer, I want a simple YAML frontmatter schema for IF segments, so that the loader can parse them.
44. As the developer, I want to use git for content versioning, so that I can track changes.

### 视觉

45. As a player, I want SVG icons for plane and node visualization, so that the UI has visual interest (per "纯文字 + 一点 SVG" 约束).
46. As a player, I want 古风 language in the UI (not modern), so that the game has 修真 atmosphere.

---

## Implementation Decisions

### 平台与架构
- **平台**: Flutter (Dart) — 双端 (iOS + Android)，见 ADR-0001
- **架构**: 3 层
  - **UI 层**: Flutter widgets
  - **游戏逻辑层**: Dart 纯函数/类
  - **内容层**: `.md` 文件 + YAML frontmatter，加载器解析
- **状态管理**: 单一 `GameState` 对象（含 `Player`, `World`, `IfState`, `ProceduralSeed`），用 ChangeNotifier/Provider
- **持久化**: JSON 序列化 + Flutter `shared_preferences` / `path_provider`，存档到本地文件

### 内容格式
- **路径**: `content/凡界/<node-id>/<event-id>.md`
- **IF 段 frontmatter**:
  ```yaml
  ---
  id: meeting-old-man-01
  trigger:
    location: 山门
  requires:
    realm: 炼气期
    min_layer: 1
  next:
    - choice: "请教修炼"
      goto: training-01
      heart_delta: { 剑道: +1 }
    - choice: "打声招呼离开"
      goto: exit-01
      heart_delta: {}
  ---
  ```
- **加载器**: 启动时扫描 `content/` 目录，解析所有 `.md`，构建 `Map<id, IfSegment>` 索引

### 灵根 (5 种)
- 金 / 木 / 水 / 火 / 土（5 种，简化自经典的 8-10 种）
- 灵根在 character creation 时随机选，玩家可重选 1 次
- 灵根决定哪些 功法 可学（如 火灵根 → 火系功法）

### 功法 (3-5 个)
- MVP 用 1 个简化技能树，3-5 个 功法
- 功法有：id, 名称, 元素, 描述, 是否可学（基于 灵根）
- 学习点：特定 node 触发学习 IF

### 道心 (4 个 path, 2D vector)
- MVP 用 4 个 path: 剑道 / 魔道 / 王道 / 无道
- 道心是 2D vector (x = 善恶, y = 剑/魔) — 简化版
- 每次 IF 选择的 `heart_delta` 累积
- MVP 不影响 ending（飞升 IF 还没写），但会被记录到存档

### 修为 / 闭关 / 突破
- 1 闭关 = 30 秒（修真 ladder at 炼气，见 ADR-0007）
- 修为条满 → 触发 小层突破 IF
- 突破成功 → 层+1, 修为 reset
- 突破失败 → 修为-30%（小层失败代价）

### 渡劫 (1 个 IF 段)
- 1 个 渡劫 IF 段: `content/凡界/渡劫/炼气-9-到-筑基.md`
- 4-6 个 choices, 每个 leads to success / fail outcome
- 成功 → 筑基 1/9 (但 MVP 不展开筑基内容；显示"飞升成功"画面)
- 失败 → 跌回 炼气 1/9, 修为 = 50%

### 战斗 (MVP 简化)
- 遇敌 → 选 1 个 功法 → 文字结算
- 不实现 HP bar (MVP 简化)
- 渡劫本身就是 Boss IF（不另设 boss 遇敌）

### 金手指
- 触发: 5-tap top-left 角 OR 输入 "godmode" 密码
- 菜单: 修为×N/满, 跳章, 切换灵根, 切换道心, 渡劫成功, 重置存档
- 正常 UI 中**不**显示任何入口（per ADR-0002）

### 存档
- 1 个存档槽（per MVP）
- 自动存档时机: 闭关结束, 突破完成, 渡劫结束, IF 选完
- 存档内容: `GameState` JSON 序列化
- 路径: app's local storage

---

## Testing Decisions

### 测试 seams
1. **E2E 集成测试**（highest seam）— 启动 App → 走完一次 MVP happy path（炼气 1→9 → 渡劫 success → 筑基画面）
2. **游戏逻辑单元测试**（supporting）— 修为 economy, 突破 state machine, 灵根 generation, 道心 vector 累加, 功法 learnability, IF loader

### 测试原则
- **只测外部行为**（observable game state），不测内部实现
- **关键边界**:
  - 修为满触发突破
  - 渡劫 success 升到筑基 / fail 跌回 1 层
  - 灵根不匹配时 功法 不可学
  - 道心 vector 累加正确
  - 金手指 修为满 真的填满修为条
  - 存档加载恢复状态正确

### 参考测试结构
- `test/unit/` — 单元测试
- `test/integration/` — E2E 测试
- `integration_test/` — Flutter 官方 E2E 框架

---

## Out of Scope

以下**明确不在 MVP 内**，对应 v0.2 / v0.3+：

- **程序化系统**: 装备 / 丹药 / 灵兽 (筑基/金丹 解锁，per ADR-0003)
- **其他位面**: 灵界 / 仙界 / 神界 (per ADR-0006, 1-2-2-1 映射)
- **其他境界**: 筑基 / 金丹 / 元婴 / 化神 / 大乘 (per ADR-0006)
- **跨境界 stat ladder**: 修真 ladder (×1.5/×2/...) 只在跨境界时生效，MVP 不跨境界 (per ADR-0005)
- **闭关时长 ladder**: 后期 (筑基 2min → 大乘 30min) 不在 MVP (per ADR-0007)
- **v0.2+ 系统**: 道侣 / 声望 / 弟子 / 世界事件 / 转世/夺舍/轮回
- **飞升 IF 段**: 4-6 个 ending 由道心决定 (per ADR-0008) — 大乘期才解锁
- **多存档槽**: 多存档 + 手/自动 (MVP 用 1 存档槽)
- **位面切换**: 大境界突破触发位面切换 (MVP 不跨位面)
- **PWA / Web**: MVP 只 Flutter 原生 (per ADR-0001)
- **App Store 上架**: 个人玩不上架

---

## Further Notes

### MVP 后的扩展路径

按 ADR-0004 / ADR-0006，MVP 之后的扩张**渐进**：

1. **MVP+ 1** (1-2 月): 加 灵界（筑基+金丹）+ 装备/丹药 程序化 + 筑基/金丹 闭关时长 ladder
2. **MVP+ 2** (1-2 月): 加 灵兽 程序化 + 灵界更多节点
3. **v0.1 完整** (3-4 月): 加 仙界（元婴+化神）+ v0.2 系统（道侣/声望/弟子）
4. **v0.2** (1-2 月): 加 神界（大乘）+ 飞升 IF 段 + 4-6 endings

### MVP 必须从一开始支持全 14 个 systems 的数据模型

per ADR-0004 后果：MVP 的 `GameState` 必须预留所有 14 个系统的字段（即使 v0.1 不实现），避免以后重写。例：MVP 的 `Player` 类应有 `equipment: List<Treasure>`, `elixirs: List<Elixir>`, `beasts: List<SpiritBeast>` 字段（空列表），等筑基+再填。

### 跨 ADR 的引用

- ADR-0001 (Flutter) — 平台
- ADR-0002 (金手指) — 隐藏手势/密语 + 4 类全功能
- ADR-0003 (14 系统三层 scope) — MVP 是 3/14
- ADR-0004 (MVP 故意做小) — MVP = 凡界 + 炼气
- ADR-0005 (stat ladder) — MVP 不跨境界
- ADR-0006 (1-2-2-1 映射) — MVP = 凡界 = 炼气
- ADR-0007 (闭关 ladder) — MVP 30s/闭
- ADR-0008 (飞升 ending) — MVP 不含飞升 IF

### 工作量估计

- 1-2 月单人完成
- 内容写作: ~30-50 个 .md IF 段
- 代码: ~3-5K Dart LOC
- 测试: ~500-1000 LOC Dart test

---

**确认签字**: 开发者
**下一步**: 通过 to-issues 拆 vertical slices 发到 issue tracker
