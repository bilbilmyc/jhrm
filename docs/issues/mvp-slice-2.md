# Slice 2: 凡界世界视图（列表 + 2D 迷你地图）

> **Parent**: [MVP PRD](../prd/mvp.md)
> **Blocked by**: [Slice 1](./mvp-slice-1.md)
> **User stories**: #4, #5, #6, #7, #45

## What to build

凡界的世界视图。两个 tab 切换：列表视图 + 2D 迷你地图。

具体：
- 定义 10 个凡界节点（数据可放 `content/凡界/nodes.json` 或 Dart 常量）
  - 山门 / 集市 / 妖兽森林 / 古修遗府 / 灵草谷 / 坊市 / 静修洞府 / 灵泉 / 藏书阁 / 渡劫台
- 节点字段: id, 名称, 描述, 坐标 (x, y), 元素
- 列表视图: 每节点一行，名称 + 描述 + 小 SVG 图标
- 2D 迷你地图视图: 节点作为点，SVG 渲染
- 顶部 tab 切换 [列表 | 地图]
- 点击节点高亮 + 记录 selection
- 移动瞬时（per "移动自由" 设计）

## Acceptance criteria

- [ ] 凡界主页显示 10 个节点（列表视图）
- [ ] 顶部 tab 切到 2D 地图视图正确显示
- [ ] 每个节点有小 SVG 图标
- [ ] 点击节点高亮 + state 记录 selection
- [ ] 2D 视图里节点位置不重叠
- [ ] Widget test: 列表视图渲染 10 个节点

## Blocked by
- Slice 1 (need GameState)

## User stories
#4, #5, #6, #7, #45
