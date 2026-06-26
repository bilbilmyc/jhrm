# 江湖如梦 (jhrm)

传统仙侠风格的文字冒险沙盒。移动端单玩家为主，隐藏金手指作开发调试入口。

## 跑起来

```bash
flutter pub get
flutter run
```

- 主入口：`lib/main.dart`
- 状态：`lib/state/`（Player / World / IfState / ProceduralSeed / enums）
- 引擎：`lib/engine/`（CultivationEngine / TribulationEngine / GoldFinger / EndingResolver）
- 内容：`lib/content/`（Markdown IF 段 + Mustache-lite 模板）
- 存档：`lib/save/SaveService`（1-slot JSON，path_provider）
- 视图：`lib/world/`（WorldView 修真感 list + 2D 迷你地图）+ `lib/ui/`（StatusBar / 闭关 / 渡劫 / 金手指 / 主题）

## 测试

```bash
flutter test
```

58+ 单元 + widget 测试，覆盖 GameState / 修真 / 渡劫 / 飞升 / 金手指 / IF 链 / WorldView 路由。

## 设计文档

- [`CONTEXT.md`](CONTEXT.md) — 术语表（修真 ladder 命名规范）
- [`docs/decisions.md`](docs/decisions.md) — 16 个 grilling 决定（修真 ladder、寿元、渡劫公式、GameState 14 字段）
- [`docs/adr/`](docs/adr/) — 8 个架构决定（Flutter / 金手指 / MVP / 修真 ladder / 位面 / 渡劫 ladder / 飞升 ending）
- [`docs/design/`](docs/design/) — 4 个 MVP 设计（架构 / 金手指 / NPC / 主线）
- [`docs/design-deferred/`](docs/design-deferred/) — 10 个 v0.2+ 蓝图（战斗 / 法宝 / 灵兽 / 道侣 / 弟子 / 因果 / 功法 / 声望 / 转世 / 世界事件）
- [`docs/issues/mvp-slice-1..7.md`](docs/issues/) — 7 个 MVP vertical slice

## 修真 ladder 概览

```
炼气 1-9 → 筑基 1-9 → 金丹 1-9 → 元婴 1-9 → 化神 1-9 → 大乘 1-9 → 飞升
```

每次闭关 30s（炼气期），加 1 修为、扣 1 月寿元；修为满 100 触发渡劫；寿元耗尽跌回上 1 层；渡劫失败跌回当前境界 1 层 + 寿元腰斩；大乘 9/9 + 修为满触发飞升 5 道抉择 → 1/5 ending（剑仙 / 魔尊 / 圣王 / 散仙 / 天地客）。