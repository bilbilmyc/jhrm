# 设计决定日志（2026-06-25 grilling session）

> 通过 /grilling 一次性得出的 16 个决定。
> 来源：用户与 Claude Fable 5 的多轮问答。

---

## 决定清单

| # | 主题 | 决定 |
|---|---|---|
| 1 | 道心 path 数量 | **5 path enum**（剑/魔/王/隐/无），MVP IF 段先发 4 种 delta。隐道字段从一开始就有。 |
| 2 | 寿元时间压力 | 寿元随闭关消耗（修真 ladder）。寿元耗尽 → 跌回上一层。渡劫失败额外扣寿。飞升成功 → 寿元上限扩到新位面标准。 |
| 3 | 因果 MVP scope | **走法 A**：字段保留（forward-compat），事件 / 渡劫 modifier / NPC 态度全部 noop 标 `// TODO 筑基+`。 |
| 4 | 道心数据结构 | **5 维独立累加** `Map<HeartPath, int>`，每 path 0-100。UI 5 段进度条，最高者高亮。 |
| 5 | 飞升成功后续 | **A. 真正通关** — 显示 ending 记录（"剑仙"等）+ "再次踏入修真路"重玩按钮。state 不再继续。 |
| 6 | MVP 战斗 | **B. 单次选功法 + 文字结算** — combat.md §1-9 整套设计延后筑基+，标 `// TODO 筑基+`。渡劫 IF 段走 IF 段系统不走 combat 系统。 |
| 7 | 节点数据位置 | **C. 混合** — Dart 提供 `nodes` 注册表（id/坐标/元素/关联 IF 段列表），描述走 `content/凡界/<node>/description.md`。 |
| 8 | App 后台运行 | **C. 不暂停** — wall-clock 跑 timer。金手指加 `[闭关立刻完成]` 入口救场。修真 ladder 上寿元随闭关扣除。 |
| 9 | IF 段正文模板 | **完整模板引擎**（含变量替换 + 条件分支）— MVP 工作量从 1-2 月推到 2-3 月。 |
| 10 | 模板语法 | **Mustache 风格** — `{{var}}` `{{#if}}...{{/if}}`。Flutter 端用 `mustache` package。 |
| 11 | 存档跨版本 | **C. 字段全 optional + 默认值** — `fromJson` 用 `?? defaultValue`，schema 演进不破坏旧存档。 |
| 12 | 寿元修真 ladder | 30s/闭 = 1 月寿元 / 上限 100 年（炼气）。其他境界 TODO 筑基+。修真 ladder 表见下。 |
| 13 | 渡劫 success 公式 | `50% + (寿元/上限 × 20%, cap 20%) + 道心最强 path × 10% + forceSuccess 100%`。 |
| 14 | 小层突破公式 | `80% + 道心 alignment 10% + forceSuccess 100%`。失败扣 30% 修为，寿元 -1 月（无论成败）。 |
| 15 | GameState 14 字段 | 全保留 14 系统字段 + 3 子结构（World/IfState/ProceduralSeed）。所有字段用默认值（null/0/[]），fromJson optional 读取。 |
| 16 | v0.2+ 文档 | **未决定（被修真 ladder 修真 ladder bug 中断）** — 候选：A 保留现状 / B 加 `Status: DEFERRED` 头 |

---

## 寿元修真 ladder 表（决定 #12）

| 境界 | 单次闭关时长 | 寿元消耗 | 寿元上限 |
|---|---|---|---|
| 炼气 | 30s | 1 月 | 100 年 |
| 筑基 | 2min | 3 月 | 200 年 |
| 金丹 | 5min | 6 月 | 500 年 |
| 元婴 | 10min | 1 年 | 1000 年 |
| 化神 | 20min | 3 年 | 3000 年 |
| 大乘 | 30min | 10 年 | 10000 年 |

- 跌境界：寿元 = 上限的 50%
- MVP 只实现炼气 1 行

---

## GameState 14 字段表（决定 #15）

| # | 系统 | Player 字段 | MVP 行为 |
|---|---|---|---|
| 1 | 灵根 | `Element root` | 选 + 限制可学功法 |
| 2 | 功法 | `List<Technique> learned` | 学 + 战斗单选 |
| 3 | 道心 | `Map<HeartPath, int> heartVector` (5 维) | 累加 + 5 段进度条 |
| 4 | 天劫 | `TribulationState? current` | 渡劫 IF 段触发 |
| 5 | 因果 | `int karma = 0` | 字段保留，事件 noop |
| 6 | 寿元 | `int lifespan, int lifespanMax` | 修真 ladder 修真 |
| 7 | 装备 | `List<Treasure> equipment` | 空，TODO 筑基+ |
| 8 | 丹药 | `List<Elixir> elixirs` | 空，TODO 筑基+ |
| 9 | 灵兽 | `List<SpiritBeast> beasts` | 空，TODO 筑基+ |
| 10 | 道侣 | `DaoCompanionState? companion` | null，TODO 元婴+ |
| 11 | 声望 | `Map<Faction, int> rep` | 空 map，TODO 筑基+ |
| 12 | 弟子 | `List<Disciple> disciples` | 空，TODO 元婴+ |
| 13 | 世界事件 | `WorldEvent? active` | null，TODO 化神+ |
| 14 | 转世 | `ReincarnationState?` | null，TODO 大乘+ |

外加 `World` (currentPlane / visitedNodes) + `IfState` (currentSegmentId / history) + `ProceduralSeed` (int) — 共 3 个 GameState 子结构。

---

## 仍需决定（deferred）

- **决定 #16**：v0.2+ 文档（combat/treasure/spirit-beast/dao-companion/disciple/reputation/reincarnation/world-event + karma full）怎么处理。候选：保留现状 / 加 `Status: DEFERRED` 头 / 移到 `docs/design-deferred/`
- **placeholder 泄漏修复**：`docs/design/combat.md` §10、`docs/design/karma.md` §3.1 有"修真 ladder 修真 ladder"占位符
- **combat.md 修真 ladder 修真 ladder 数据规模** 一节是模板未替换（修真 ladder 修真 ladder 修真 ladder 修真 ladder）
- **测试 seam**：修真 ladder 上 1 局 ~5 min，单元测试哪些必须？
- **修真 ladder 上 1 局时间预算**：MVP 一局 ~5 分钟（30s × 9 层），金手指 `[修为满]` 一键通关会破坏这个节奏

---

## 引用文件

- `CONTEXT.md` — 术语表
- `docs/adr/0001-0008.md` — 8 个架构决定
- `docs/prd/mvp.md` — MVP PRD
- `docs/design/flutter-architecture.md` — Flutter 架构
- `docs/issues/mvp-slice-1..7.md` — 7 个 vertical slice
- `docs/design/*.md` — 13 个 system 设计（多数 v0.2+ deferred）
