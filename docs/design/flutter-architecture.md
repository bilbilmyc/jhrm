# Flutter 项目架构设计

> **Date**: 2026-06-25
> **Skills applied**: `codebase-design`（deep module 词汇表）
> **Scope**: MVP（per `docs/prd/mvp.md` + `docs/issues/mvp-slice-1..7.md`）

---

## 1. 顶层决策

### 状态管理: **Provider + ChangeNotifier**
- 简单，足够 MVP
- 后续可换 Riverpod 但**不**要换 Bloc（boilerplate 太重）
- `GameState extends ChangeNotifier`，UI 通过 `context.watch<GameState>()` 订阅

### 内容格式
- `.md` + YAML frontmatter（per ADR）
- 启动时一次性 `ContentLoader.loadAll()` 加载进内存
- 运行时不读盘（除了 存档）

### 持久化
- `path_provider` + `dart:io` 写 JSON
- 1 个存档槽（per MVP）
- 启动时检查并加载

### 目录约定
- `lib/` 三层: `state/` (数据) / `engine/` (逻辑) / `ui/` (视图) / `content/` (内容加载) / `save/` (存档)
- `content/` 顶层与 `lib/` 平级（资源文件）
- `test/` 三层: `unit/` / `widget/` / `integration/`

---

## 2. 核心模块（按 `codebase-design` 词汇表）

| 模块 | 类型 | 接口（深度）| 实现（隐藏的）| Seam |
|---|---|---|---|---|
| **GameState** | Model | `get/set + toJson/fromJson` | 14 系统全部字段 + 不变量 | 公开类边界 |
| **ContentLoader** | Service | `loadAll() / get(id)` | 文件扫描 + YAML 解析 + 缓存 | 加载器接口（mockable）|
| **CultivationEngine** | Logic | `start / tick / breakthrough` | Timer + 状态转移 + IF 触发 | Engine 接口 |
| **TribulationEngine** | Logic | `trigger / choose / getOutcome` | 渡劫 IF 加载 + 选择导航 + outcome 应用 | Engine 接口 |
| **HeartTracker** | Logic | `apply / getTrend` | 2D vector 累加 + 4 path 归类 | Tracker 接口 |
| **GoldFinger** | Service | `show / execute / isActive` | 手势检测 + 菜单 UI + action 派发 | Dev 边界（不暴露给普通 UI）|
| **SaveService** | Service | `save / load / delete` | 文件 I/O + JSON + 错误处理 | Service 接口（mockable）|

**深度评估**：
- GameState: **深** — 14 系统的状态，接口只是 getter/setter
- ContentLoader: **深** — 隐藏文件 I/O + YAML + 缓存
- CultivationEngine: **中深** — 修真 ladder + 突破 IF + 状态机
- TribulationEngine: **中深** — 渡劫 IF + 多 outcome
- HeartTracker: **浅**（OK 因为逻辑简单）— 2D vector 加法
- GoldFinger: **深** — 隐藏 4 类 actions 全部
- SaveService: **深** — 隐藏文件 + 错误恢复

---

## 3. 项目结构

```
jhrm/
├── lib/
│   ├── main.dart                          # 入口
│   ├── app.dart                           # App root + Provider setup
│   ├── state/
│   │   ├── game_state.dart                # 14 系统全部字段
│   │   ├── player.dart
│   │   ├── world.dart
│   │   ├── if_state.dart
│   │   ├── procedural_seed.dart
│   │   └── enums.dart                     # Realm, Element, HeartPath
│   ├── engine/
│   │   ├── cultivation_engine.dart        # 闭关/修为/小层 突破
│   │   ├── tribulation_engine.dart        # 渡劫 (大境界 突破)
│   │   ├── breakthrough_resolver.dart     # 突破 outcome 逻辑
│   │   ├── heart_tracker.dart             # 道心 2D vector
│   │   └── gold_finger.dart               # 隐藏手势 + 菜单 + 4 类 actions
│   ├── content/
│   │   ├── content_loader.dart            # 扫描 content/ 加载所有 .md
│   │   ├── if_segment.dart                # IfSegment 数据类
│   │   ├── frontmatter.dart               # YAML 解析
│   │   └── content_provider.dart          # 暴露给 UI
│   ├── save/
│   │   ├── save_service.dart              # 存档读写
│   │   └── save_paths.dart                # 存档路径
│   ├── ui/
│   │   ├── screens/
│   │   │   ├── main_screen.dart           # 主页
│   │   │   ├── world_view.dart            # 凡界 列表 + 2D 地图
│   │   │   ├── if_screen.dart             # IF 段显示
│   │   │   ├── cultivation_screen.dart    # 闭关 + 修为 bar
│   │   │   ├── status_bar.dart            # 修为/灵根/道心
│   │   │   ├── character_creation.dart    # 选 灵根
│   │   │   ├── breakthrough_screen.dart   # 小层/大境界 突破 IF
│   │   │   ├── tribulation_screen.dart    # 渡劫 IF
│   │   │   └── gold_finger_menu.dart      # 覆盖层
│   │   ├── widgets/
│   │   │   ├── node_card.dart
│   │   │   ├── mini_map.dart              # 2D SVG 节点
│   │   │   ├── if_text.dart               # IF 正文
│   │   │   ├── choice_button.dart
│   │   │   ├── svg_icon.dart              # SVG 包装
│   │   │   ├── progress_bar.dart          # 修为 bar
│   │   │   └── heart_indicator.dart       # 道心 4 path 显示
│   │   └── theme.dart                     # 古风主题
│   └── utils/
│       ├── ancient_strings.dart           # 古风文案 helpers
│       └── debug_log.dart                 # Dev 日志
├── content/                                # 内容（git 追踪）
│   └── 凡界/
│       ├── nodes.json
│       ├── 山门/
│       ├── 集市/
│       └── 渡劫/
├── test/
│   ├── unit/
│   │   ├── game_state_test.dart
│   │   ├── heart_tracker_test.dart
│   │   ├── cultivation_engine_test.dart
│   │   ├── tribulation_engine_test.dart
│   │   ├── content_loader_test.dart
│   │   └── save_service_test.dart
│   ├── widget/
│   │   ├── world_view_test.dart
│   │   ├── if_screen_test.dart
│   │   └── gold_finger_menu_test.dart
│   └── integration/
│       └── mvp_happy_path_test.dart        # E2E
├── pubspec.yaml
├── README.md
└── docs/
    ├── adr/0001-0008.md
    ├── agents/
    ├── prd/mvp.md
    ├── issues/mvp-slice-1..7.md
    └── design/
        ├── flutter-architecture.md         # 本文件
        ├── gold-finger.md
        └── if-format.md
```

---

## 4. 关键设计原则（按 codebase-design）

### 4.1 Deep modules over shallow

**GameState** (深):
```dart
// Interface 极简
class GameState extends ChangeNotifier {
  Player get player;
  World get world;
  IfState get ifState;
  ProceduralSeed get seed;
  // ... 14 系统的 getter
  void notifyListeners();  // 状态变化时
  Map<String, dynamic> toJson();
  factory GameState.fromJson(Map<String, dynamic> json);
}
```
**实现**隐藏了：14 系统的全部字段、不变量（境界必须有效、修为不能超 max、灵根必须匹配 功法...）。

### 4.2 Accept dependencies, don't create them

`CultivationEngine`:
```dart
// Testable
class CultivationEngine {
  CultivationEngine({
    required this.gameState,
    required this.contentLoader,
    required this.breakthroughResolver,
  });
  Future<void> start();
  void tick();
  Future<BreakthroughResult> breakthrough();
}
```

**Bad** (shallow, untestable):
```dart
class CultivationEngine {
  final _state = GameState();
  final _content = ContentLoader();
  // 自己创建依赖
}
```

### 4.3 One seam per real variation

- **ContentLoader** seam: in-memory adapter (default) vs file adapter (prod)
- **SaveService** seam: in-memory (test) vs file (prod)
- 其他模块**不需要 seam**——没有第二个 adapter

### 4.4 The deletion test

- GameState: delete 它 → 14 系统的状态全没了。**Earning keep**.
- ContentLoader: delete 它 → IF 段全没了。**Earning keep**.
- HeartTracker: delete 它 → 道心没了，但可以直接 merge 到 GameState。**Shallow — should consider merging**.

### 4.5 Internal seams

GameState 内部可以有 private helper（不暴露），例如 `_validateLifespan()` 在 setter 时调用。**External seam** = GameState 公开 API; **Internal seam** = 私有 helper。

---

## 5. 状态机（高阶）

```
[App Launch]
  ↓ load
[Title / Main Menu]
  ↓
[Character Creation] → 选 灵根
  ↓
[Main Screen] (凡界主页)
  ├── [World View] (列表 / 2D 地图)
  │     ↓ tap node
  │   [IF Screen] ← reads content
  │     ↓ make choice
  │   back to [Main Screen] (道心 updated)
  │
  ├── [Cultivation Screen]
  │     ↓ start 闭关
  │   [Timer running] (30s per 闭)
  │     ↓ timer ends
  │   [Breakthrough] (小层 IF)
  │     ↓ outcome
  │   back to [Main Screen]
  │
  └── (secret) [Gold Finger Menu] (5-tap / godmode)
        ↓ execute action
      back to [Main Screen]

炼气 9/9 修为满:
  ↓ automatic
[Tribulation IF] (渡劫)
  ↓ outcome (飞升 / 跌回)
back to [Main Screen] OR show "飞升成功"画面
```

---

## 6. 测试 seams (per PRD Testing Decisions)

| Seam | 类型 | 覆盖 |
|---|---|---|
| **External 1** | E2E integration | 启动 → 走完 MVP happy path |
| **External 2** | Widget | 关键 UI 渲染（world view, IF screen, gold finger menu）|
| **External 3** | Unit | GameState / HeartTracker / 修为 economy / IF loader / 渡劫 outcome / 存档 |
| **Internal** | Unit (private) | 修真 ladder 闭时长映射、IF 跳转解析、YAML schema validation |

---

## 7. 依赖（pubspec.yaml）

```yaml
dependencies:
  flutter:
    sdk: flutter
  provider: ^6.1.0
  shared_preferences: ^2.2.0
  path_provider: ^2.1.0
  yaml: ^3.1.0
  flutter_svg: ^2.0.0      # SVG icons
  intl: ^0.19.0            # 古风时间格式

dev_dependencies:
  flutter_test:
    sdk: flutter
  integration_test:
    sdk: flutter
  flutter_lints: ^4.0.0
```

---

## 8. 开发顺序

按 `docs/issues/mvp-slice-1..7.md`：
1. slice 1: 脚手架 + GameState
2. slice 2 + 4 + 6 (parallel): 主页 / 闭关 / 金手指
3. slice 3: IF 段
4. slice 5: 渡劫
5. slice 7: 存档

---

## 9. 未来扩展 (out of MVP scope)

- Riverpod 替换 Provider（如果 GameState 变大变复杂）
- 多存档槽（per 多存档 + 手/自动 设计）
- 装备 / 丹药 / 灵兽 程序化（per ADR-0003）
- 灵界 / 仙界 / 神界（per ADR-0006 1-2-2-1 映射）
