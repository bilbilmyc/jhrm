# Slice 4: 闭关 + 修为 + 小层 突破

> **Parent**: [MVP PRD](../prd/mvp.md)
> **Blocked by**: [Slice 1](./mvp-slice-1.md)
> **User stories**: #13-#19 (灵根/功法/道心), #20-#26 (闭关/突破)

## What to build

灵根 + 功法 + 道心 系统，闭关 修为 机制，小层 突破 IF。

具体:
- Character creation: 选 灵根 (金/木/水/火/土)
- 灵根检查: 限制可学 功法
- 1 个简化技能树: 3-5 个 功法
- 学习 功法 IF 段（特定节点）
- 闭关按钮 → 30s 计时器 → 修为 +1
- 修为 bar 实时显示
- 修为满 → 触发 小层 突破 IF
- 小层 突破 IF 段: 2 outcome (升 / 修为 -30%)
- 道心 4 path 显示: 剑/魔/王/无

修真 ladder at 炼气: 30s / 闭 (per ADR-0007)。

## Acceptance criteria

- [ ] Character creation 选 灵根，UI 显示
- [ ] 灵根不匹配时 功法 不可学
- [ ] 3-5 个 功法可学，至少 1 个含 `heart_delta` 影响道心
- [ ] 闭关按钮 → 30s 计时 → 修为填满 → 触发小层 IF
- [ ] 小层 IF 段 outcome 正确（升层 / 修为 -30%）
- [ ] 修为 economy 单元测试: 30s × 9 = 1 境界

## Blocked by
- Slice 1 (GameState + 修为 字段)

## User stories
#13, #14, #15, #16, #17, #18, #19, #20, #21, #22, #23, #24, #25, #26
