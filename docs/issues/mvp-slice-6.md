# Slice 6: 金手指（隐藏手势 + 密语 + 菜单）

> **Parent**: [MVP PRD](../prd/mvp.md)
> **Blocked by**: [Slice 1](./mvp-slice-1.md)
> **User stories**: #35, #36, #37, #38

## What to build

隐藏手势/密语触发的开发者菜单。

具体:
- 5-tap top-left 角检测器（5 次 1 秒内）
- 密码输入检测: 监听 "godmode"（开发模式用文本框或 hotkey）
- 菜单 UI（覆盖层）: 修为×N / 修为满 / 跳到下一章 / 切换灵根 / 切换道心 / 渡劫成功 / 重置存档
- 每个动作调用 GameState 相应 setter
- 正常 UI 中**不**显示任何入口（per ADR-0002）

## Acceptance criteria

- [ ] 5-tap top-left 在 1 秒内触发金手指菜单
- [ ] 密码 "godmode" 触发金手指菜单（开发模式）
- [ ] 修为满 / 切换灵根 / 切换道心 / 渡劫成功 / 重置存档 全部工作
- [ ] 正常 UI 中无金手指入口（dev 之外不暴露）
- [ ] 金手指 trigger 单元测试: 5-tap 触发，4-tap 不触发

## Blocked by
- Slice 1 (need GameState setters)

## User stories
#35, #36, #37, #38
