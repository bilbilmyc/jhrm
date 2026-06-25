# Slice 3: IF 段显示 + 选择

> **Parent**: [MVP PRD](../prd/mvp.md)
> **Blocked by**: [Slice 2](./mvp-slice-2.md)
> **User stories**: #8, #9, #10, #11, #12, #42, #43, #44

## What to build

点节点 → 读 IF 段 → 显示文字 + 选项 → 选一个 → 跳到下一段。

具体:
- 写 3-5 个 IF 段 .md 文件（在 `content/凡界/<node>/`）
  - 至少 1 段含 `heart_delta` (道心累加)
  - 至少 1 段含 `requires` (触发条件)
- IF 加载器: 扫描 content/，解析 .md，分离 frontmatter (YAML) + 正文
- IF 数据结构: `IfSegment(id, trigger, requires, next[], text, heart_delta)`
- IF 显示屏: 正文（古风） + 选项按钮列表
- 选项点击 → 根据 frontmatter 更新 state（道心、跳转）→ 回到地图 或 继续 IF
- 道心 2D vector (x=善恶, y=剑魔) 累加
- 道心 trend 指示器在状态栏

## Acceptance criteria

- [ ] 至少 3 个 .md IF 段写好，frontmatter 正确
- [ ] 点节点触发对应 IF 段（按 trigger 条件）
- [ ] IF 段正文 + 选项正确显示
- [ ] 选项点击触发状态更新（道心、跳转）
- [ ] 道心 2D vector 累加测试通过
- [ ] IF 加载器单元测试: 3 个 .md 全部 parse 成功

## Blocked by
- Slice 2 (need node selection → trigger IF)

## User stories
#8, #9, #10, #11, #12, #42, #43, #44
