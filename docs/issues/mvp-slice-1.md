# Slice 1: 项目脚手架 + GameState

> **Parent**: [MVP PRD](../prd/mvp.md)
> **Blocked by**: None — can start immediately
> **User stories**: #1, #2, #3 (部分)

## What to build

Flutter 项目脚手架 + GameState 数据模型骨架。跑通 hello world + 状态显示的最小闭环。

具体：
- `flutter create` 项目
- `pubspec.yaml` 依赖: `flutter`, `provider` 或 `riverpod`, `shared_preferences`, `path_provider`, `yaml`
- 定义 `GameState` 类（含 `Player`, `World`, `IfState`, `ProceduralSeed` 子结构）
- Player 包含 14 个系统全部字段（即使 MVP 只用 3 个），per ADR-0004
- GameState JSON 序列化 + 反序列化（toJson / fromJson）
- 主屏显示"修为 0/100, 炼气 1/9"
- 1 个单元测试: GameState JSON round-trip

## Acceptance criteria

- [ ] `flutter run` 启动 App，主屏显示"修为 0/100, 炼气 1/9"
- [ ] `GameState` 含 Player / World / IfState / ProceduralSeed 4 个子结构
- [ ] `Player` 含 14 个系统字段（equipment / elixirs / beasts / dao_companion / ...）
- [ ] GameState.toJson() / fromJson() round-trip 测试通过
- [ ] 主屏文字用古风语言（"炼气 1/9" 而非 "Level 1"）
- [ ] 项目结构遵循 MVP 3 层架构（UI / 逻辑 / 内容）

## Blocked by
None

## User stories
#1 (开 App), #2 (看状态), #3 (记得进度 - 部分, 等 slice 7)
