# Slice 5: 渡劫 IF + 飞升/跌回 outcome

> **Parent**: [MVP PRD](../prd/mvp.md)
> **Blocked by**: [Slice 4](./mvp-slice-4.md)
> **User stories**: #27, #28, #29, #30, #34

## What to build

炼气 9 → 触发 渡劫 IF 段 → 4-6 个 choice → 飞升 or 跌回。

具体:
- 1 个 渡劫 IF 段: `content/凡界/渡劫/炼气-9-到-筑基.md`
- 4-6 个 choice, 每个 leads to success / fail
- 渡劫 IF 段正文 + 选项 UI
- Success outcome: 升到 筑基 1/9 (MVP 不展开筑基内容，显示"飞升成功"画面 + 暂停)
- Fail outcome: 跌回 炼气 1/9 + 修为 = 50%
- 飞升成功时记录"已到达 筑基"在 state

渡劫 2 outcome (per 修真 ladder / ADR), 无 Game Over (per ADR-0008 后果)。

## Acceptance criteria

- [ ] 1 个 渡劫 IF 段写好，4-6 个 choice
- [ ] 炼气 9 修为满时自动触发 渡劫
- [ ] 飞升 success: state.境界 = 筑基 1/9
- [ ] 飞升 fail: state.境界 = 炼气 1/9, 修为 = 50%
- [ ] 渡劫 outcome 单元测试: 4-6 个 choice 全部产生预期 outcome
- [ ] E2E happy path test: 炼气 1 → 9 → 渡劫 success → 筑基画面

## Blocked by
- Slice 4 (need 突破 mechanism + 9 层修为)

## User stories
#27, #28, #29, #30, #34
