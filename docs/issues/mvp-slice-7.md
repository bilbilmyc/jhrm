# Slice 7: 存档自动 + 读档

> **Parent**: [MVP PRD](../prd/mvp.md)
> **Blocked by**: [Slice 4](./mvp-slice-4.md)
> **User stories**: #39, #40, #41, #3 (完整)

## What to build

GameState 持久化 + 自动存档 + 启动时读档。

具体:
- SaveService: GameState.toJson() → 写本地文件（`path_provider`）
- 存档时机 hooks: 闭关结束, 突破完成, 渡劫结束, IF 选完
- App 启动时检查存档，存在则 fromJson 加载
- 1 个存档槽（MVP 不实现多槽，per ADR-0004）
- 存档路径: app's local documents directory
- 金手指"重置存档"按钮删除存档文件（依赖 slice 6）

## Acceptance criteria

- [ ] 闭关 / 突破 / 渡劫 / IF 选完后自动存档
- [ ] App 重启后状态恢复（修为、境界、灵根、道心）
- [ ] 杀进程重开不丢进度
- [ ] 金手指"重置存档"清空存档（需 slice 6）
- [ ] 存档 round-trip 单元测试: toJson + fromJson 完整

## Blocked by
- Slice 4 (need 闭关 + 突破 mechanism to know when to save)
- Slice 6 (金手指 "重置存档" 入口)

## User stories
#39, #40, #41, #3 (完整)
