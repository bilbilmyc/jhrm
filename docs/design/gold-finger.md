# 金手指菜单设计细节

> **Date**: 2026-06-25
> **Scope**: MVP（per ADR-0002 隐藏手势 + 4 类全功能 + ADR-0004 MVP 范围）
> **触发**: 5-tap top-left 角 (1 秒内) **OR** 密码 "godmode"

---

## 1. 触发机制

### 1.1 手势触发（主路径）
- **位置**: 屏幕 top-left 角 (50dp × 50dp 区域)
- **次数**: 5 次
- **时间窗**: 1 秒内
- **检测**: 每次 tap 重置计时器；满 5 次且 < 1s → 触发
- **副作用**: 无视觉反馈（隐藏性）；触发时打开菜单 + 播放微小震动
- **测试**: 5-tap 触发 / 4-tap 不触发 / 5-tap 跨 2 秒不触发

### 1.2 密码触发（备用）
- **入口**: 开发模式专属，UI 中**不**显示文本框
- **检测**: 监听键盘输入（Android/iOS debug build 默认开启）
- **密码**: `godmode` (case-insensitive)
- **副作用**: 同上手势触发
- **测试**: 输入 "godmode" 触发 / "godmod" 不触发 / "GodMode" 触发（case-insensitive）

### 1.3 关闭
- 菜单外点击（覆盖层背景）→ 关闭
- "退出" 按钮 → 关闭
- 触发动作后 → 关闭（默认）

---

## 2. 菜单结构

```
[金手指菜单 - 覆盖层]

  修为 (4 个)
  ├── [修为 ×10]   当前修为 ×10 (cap at max)
  ├── [修为 ×100]  当前修为 ×100 (cap at max)
  └── [修为满]     直接 set to max

  跳章 (1 个)
  └── [跳到下一章] 跳过当前 IF 段到下一段；或小层满则触发 突破

  Build / 状态 (4 个)
  ├── [切换灵根]  重新随机选 灵根 (金/木/水/火/土)
  ├── [切换道心]  重置道心 vector 到 0
  ├── [+10 因果]  因果 +10
  └── [+10 寿元]  寿元 +10 (year)

  渡劫 / 触发 / 重置 (3 个)
  ├── [渡劫成功]  若当前 渡劫 进行中 → 强制 success
  ├── [重置存档]  删除存档文件 + 重置 GameState (新存档)
  └── [退出菜单]
```

总计 **13 个按钮**，按 4 类分组（per ADR-0002 4 类全功能）。

---

## 3. 每个动作的精确行为

### 3.1 修为 ×10

**做什么**:
```
newXP = currentXP × 10
if (newXP > maxXP) newXP = maxXP
gameState.player.cultivationXP = newXP
```

**副作用**:
- 通知 listeners（UI 修为 bar 立刻更新）
- 不触发 突破（修为条满才触发，玩家需手动 闭关 一下或用 [修为满]）
- Log: `goldfinger: 修为×10 from X to Y`

**确认**: 无（直接执行）

### 3.2 修为 ×100

同 3.1，倍率改 100。

### 3.3 修为满

**做什么**:
```
gameState.player.cultivationXP = maxXP
```
**副作用**:
- 修为条满 → **自动触发 突破**（小层 IF / 或 炼气 9 时 渡劫 IF）
- Log: `goldfinger: 修为满 → 触发突破`

**确认**: 无

### 3.4 跳到下一章

**做什么**:
```
if (currentIfSegment != null) {
  // 跳过当前 IF 段
  currentIfSegment = nextSegment of current (or 回到主屏)
} else if (player.cultivationXP >= maxXP) {
  // 修为满则触发 突破
  triggerBreakthrough();
} else {
  // 无事可做 → noop + 提示
  showToast("没有可跳过的内容");
}
```

**副作用**:
- 当前 IF 段如有 `heart_delta`，**不**累加（跳过）
- Log: `goldfinger: 跳到下一章`

**确认**: 无

### 3.5 切换灵根

**做什么**:
```
oldRoot = gameState.player.spiritualRoot
newRoot = random pick from [金, 木, 水, 火, 土]
gameState.player.spiritualRoot = newRoot
// 重新计算可学 功法
gameState.player.learnableTechniques = recalculateLearnable(newRoot)
```

**副作用**:
- 已学的不匹配 功法 标记为 "不可用"（但**不**自动遗忘）
- Log: `goldfinger: 灵根 旧=X 新=Y`

**确认**: 弹 1 个二次确认（"切换灵根会影响可学功法，确定？"）— 防止误触

### 3.6 切换道心

**做什么**:
```
gameState.player.heartVector = Vector2.zero()
// 4 path 趋势重置
gameState.player.heartTrend = computeTrend(heartVector)
```

**副作用**:
- 已积累的道心全部清零
- Log: `goldfinger: 道心 reset`

**确认**: 弹 1 个二次确认

### 3.7 +10 因果

**做什么**:
```
gameState.player.karma += 10
```

**副作用**:
- 因果影响 NPC 态度（per 修真 IF 设计）
- Log: `goldfinger: 因果 +10 → X`

**确认**: 无

### 3.8 +10 寿元

**做什么**:
```
gameState.player.lifespan += 10  // 加 10 年
```

**副作用**:
- Log: `goldfinger: 寿元 +10 → X`

**确认**: 无

### 3.9 渡劫成功

**做什么**:
```
if (gameState.currentTribulation != null) {
  gameState.currentTribulation.forceSuccess = true
  // 渡劫 IF 段下一次 choice 自动走 success outcome
}
```

**副作用**:
- 当前 渡劫 强制成功
- Log: `goldfinger: 渡劫强制成功`

**确认**: 无

**未在渡劫中**: 按钮 disabled + 提示"当前不在渡劫"

### 3.10 重置存档

**做什么**:
```
// 1. 删存档文件
await saveService.delete()

// 2. 重置 GameState 到 initial
gameState.reset()

// 3. 重新加载 content
await contentLoader.reload()

// 4. 跳到 character creation
navigation.toCharacterCreation()
```

**副作用**:
- 全部进度丢失
- 重新走 character creation
- Log: `goldfinger: 重置存档`

**确认**: **强确认**（"所有进度将被删除，无法恢复。确定？" + [取消] / [确认]）

### 3.11 退出菜单

**做什么**: 关闭覆盖层，回到原屏幕。

---

## 4. UI 视觉

- 覆盖层: 50% 透明度黑色背景
- 菜单面板: 屏幕中央，白色背景，圆角 16dp
- 标题: "金手指"（古风字体）
- 按钮: 4 组（修为 / 跳章 / Build / 渡劫），每组用分隔线
- 反馈: 每个动作执行后底部 toast 显示"修为满 ✓" / "灵根切换 ✓"
- Log 区: 底部小字显示最近 5 条 log（dev 可见）

---

## 5. 安全 / 隔离

- 金手指**仅** debug build 启用（`kDebugMode` check）
- Release build 中: 触发器 noop + 菜单 noop + 所有 setter noop
- 这样 release 包给朋友玩时，金手指不会暴露

---

## 6. 测试矩阵

| 动作 | 单元测试 | Widget 测试 | E2E |
|---|---|---|---|
| 5-tap 触发 | ✓ (timer logic) | ✓ (UI) | ✓ |
| 密码触发 | ✓ | — | — |
| 修为 ×10/×100/满 | ✓ (setter) | ✓ (UI 反馈) | ✓ |
| 跳到下一章 | ✓ (state transition) | ✓ | ✓ |
| 切换灵根 | ✓ (recalculation) | ✓ (二次确认) | — |
| 切换道心 | ✓ | ✓ (二次确认) | — |
| +10 因果 / 寿元 | ✓ | — | — |
| 渡劫成功 | ✓ (force flag) | ✓ | ✓ |
| 重置存档 | ✓ (file delete) | ✓ (强确认) | ✓ |

---

## 7. 跟 MVP slice 的关系

- **Slice 6 (金手指)** 包含本设计全部 13 个动作
- **Slice 7 (存档)** 提供 [重置存档] 依赖
- **Slice 1 (GameState)** 提供所有 setter
- **Slice 4 (闭关 / 修为)** 提供 [修为满] 触发 突破 的依赖
- **Slice 5 (渡劫)** 提供 [渡劫成功] 的 forceSuccess flag
