# 修仙文字游戏 (Xianxia Text Game)

传统仙侠风格的文字冒险沙盒游戏。移动端单玩家、个人玩为主、隐藏金手指作开发调试。

## 世界结构 (World)

**位面 (Plane)**:
世界分为四层：凡界 (Mortal) / 灵界 (Spirit) / 仙界 (Immortal) / 神界 (Divine)，每层对应一个大境界。每次大突破升一层。
_Avoid_: layer, dimension, world-tier, 位面层

**节点 (Node)**:
位面内一个具体地点，挂载事件或活动。位面主页用列表展示节点（可切换 2D 迷你地图）。
_Avoid_: location, area, spot, 地点, 区域

**位面切换 (Plane Transition)**:
每次大境界突破触发的事件——玩家从当前位面（凡/灵/仙/神）移动到下一个。3 次切换：炼气→筑基（凡→灵）、金丹→元婴（灵→仙）、化神→大乘（仙→神）。每次 = 渡劫 IF + 新位面入口 + 新节点清单，是"重新开始感"的大事件。
_Avoid_: 飞升（不要与终局混用）, plane shift, 位面移动

## 境界与修炼 (Realm & Cultivation)

**境界 (Realm)**:
修炼大境界，共六个：炼气 / 筑基 / 金丹 / 元婴 / 化神 / 大乘，每境界分 9 层。
_Avoid_: level, stage, tier, 等级, 品级

**修为 (Cultivation XP)**:
数值化积累。当前境界层满 → 触发突破。
_Avoid_: experience, XP, energy, 经验

**灵根 (Spiritual Root)**:
先天元素属性（金 / 木 / 水 / 火 / 土 / 风 / 雷 / 冰）。决定能学哪些功法。
_Avoid_: element, affinity, talent, 元素

**寿元 (Lifespan)**:
剩余寿命。给突破施加时间压力。
_Avoid_: age, lifetime, 寿命

**天劫 (Tribulation)**:
每次大境界突破时触发的重大 IF 段。两种结局：飞升（升到下个境界）或 跌回 1 层 + 修为腰斩（失败代价）。无 Game Over / 无身死。
_Avoid_: trial, test, ordeal, 雷劫

**渡劫 (Tribulation Trial)**:
天劫 的动词形式——玩家进入天劫 IF 段、做选择、出结果。
_Avoid_: 试炼, 渡天劫

**层 (Layer)**:
境界内的 9 个小层（炼气 1-9 / 筑基 1-9 / ...）。修为条满一层触发突破。
_Avoid_: 级别, level, sub-tier, 小境界

**突破 (Breakthrough)**:
从当前层升到下一层的动作。修为条满时触发——小层走小 IF，大境界走渡劫 IF。
_Avoid_: 升级, advancement, level-up

**大境界突破 (Major Breakthrough)**:
从某境界 9 层升到下一境界 1 层的动作（如 炼气 9 → 筑基 1）。触发渡劫 IF + 位面切换。是全游戏最重要的事件。
_Avoid_: 大突破, major advancement, realm-up

## 功法与战斗 (Techniques & Combat)

**功法 (Technique)**:
可学习的修炼法门，归入技能树（剑 / 法 / 体）。每个功法解锁具体战斗法术。
_Avoid_: skill, spell, art, 技能, 法术

**法宝 (Treasure)**:
角色携带的装备。由 (模板 + 元素 + 品级) 程序化生成。
_Avoid_: weapon, gear, item, equipment, 武器, 装备

**丹药 (Elixir)**:
可消耗品，由配方炼制。由 (配方 + 品级) 程序化生成。
_Avoid_: potion, medicine, 药

**灵兽 (Spirit Beast)**:
捕获并培养的伙伴生物。程序化生成。
_Avoid_: pet, mount, 召唤兽

**道侣 (Dao Companion)**:
可攻略的 NPC 角色，有独立关系线。v0.2+ 特性。
_Avoid_: lover, spouse, partner

## 故事与选择 (Story & Choice)

**道心 (Path of Heart)**:
角色所走的道（剑道 / 魔道 / 王道 / ...）。影响剧情分支和结局。
_Avoid_: alignment, morality, virtue, 阵营

**因果 (Karma)**:
善恶数值 + 事件标志。影响 NPC 态度、世界状态和部分事件触发。
_Avoid_: reputation, alignment, fate, 善恶

**IF 段 (IF Segment)**:
一段分支叙事，用 Markdown 文件 + YAML frontmatter 写作（triggers / choices / conditions / 跳转）。
_Avoid_: scene, chapter, passage, 章节

**Boss 段 (Boss Segment)**:
遭遇强敌时玩的较长 IF 段，一个境界的高潮节点。
_Avoid_: boss fight, climax, encounter, BOSS 战

**飞升 (Ascension)**:
终局事件。大乘 9/9 → 进入飞升 IF 段 → 道心 决定 ending（4-6 个：剑道→剑仙、魔道→魔尊、王道→圣王、隐道→散仙、无道→天地客等）。
_Avoid_: 升天, transcendence, 位面切换（不要混用）

## 游戏机制 (Game Mechanics)

**金手指 (Gold Finger)**:
开发者的作弊/调试菜单，通过隐藏手势或密语调出。正常 UI 中不可见。
_Avoid_: cheat menu, debug menu, console, 作弊

**存档 (Save)**:
游戏状态持久化快照——角色、世界、IF 状态、程序化种子。支持多存档槽 + 自动存 + 手动存。
_Avoid_: state, progress, file, 进度
