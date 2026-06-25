// NodeRegistry: per-plane nodes (per docs/design/storyline.md).
//
// 4 planes × ~8 nodes each. Position layout is hand-picked so dots don't
// overlap on a 0..1 canvas. Each plane's node set reflects its central
// narrative theme:
//   - 凡界: 山门、集市、藏经阁、灵草谷、灵泉、妖兽森林、古修遗府、渡劫台
//   - 灵界: 浮空岛、灵兽山、妖精市集、灵枢阁、修士道场、灵草仙境、幽冥海、灵山之巅
//   - 仙界: 玉京山、天庭、王道殿、仙台、仙籍阁、群仙会、金仙道场、藏经阁天
//   - 神界: 神坛废墟、隐道之渊、万神殿、旧神居、天道裂隙、飞升台、神火谷、旧朝遗痕
//
// `ifSegmentIds` is a placeholder list (one element each) — the loader
// doesn't require it to resolve; missing segments just won't open an IF.

import '../state/enums.dart';
import 'node.dart';

class NodeRegistry {
  static const List<Node> mortalNodes = [
    Node(
      id: 'shan-men',
      name: '山门',
      x: 0.5, y: 0.15,
      element: Element.earth,
      ifSegmentIds: ['meeting-elder-01'],
    ),
    Node(
      id: 'ji-shi',
      name: '集市',
      x: 0.25, y: 0.3,
      element: Element.earth,
      ifSegmentIds: ['market-01'],
    ),
    Node(
      id: 'cang-shu-ge',
      name: '藏书阁',
      x: 0.55, y: 0.3,
      element: Element.wind,
      ifSegmentIds: ['learn-xuanqing-sword'],
    ),
    Node(
      id: 'jing-xiu-dong-fu',
      name: '静修洞府',
      x: 0.75, y: 0.25,
      element: Element.water,
      ifSegmentIds: ['cultivate-01'],
    ),
    Node(
      id: 'ling-cao-gu',
      name: '灵草谷',
      x: 0.15, y: 0.55,
      element: Element.wood,
      ifSegmentIds: ['gather-herb-01'],
    ),
    Node(
      id: 'ling-quan',
      name: '灵泉',
      x: 0.85, y: 0.5,
      element: Element.water,
      ifSegmentIds: ['spring-01'],
    ),
    Node(
      id: 'yao-shou-sen-lin',
      name: '妖兽森林',
      x: 0.4, y: 0.7,
      element: Element.fire,
      ifSegmentIds: ['beast-encounter-01'],
    ),
    Node(
      id: 'gu-xiu-yi-fu',
      name: '古修遗府',
      x: 0.7, y: 0.75,
      element: Element.thunder,
      ifSegmentIds: ['ruin-enter-01'],
    ),
    Node(
      id: 'du-jie-tai',
      name: '渡劫台',
      x: 0.5, y: 0.9,
      element: Element.thunder,
      ifSegmentIds: ['tribulation-01'],
    ),
    Node(
      id: 'fang-shi',
      name: '坊市',
      x: 0.35, y: 0.45,
      element: Element.gold,
      ifSegmentIds: ['market-01'],
    ),
  ];

  static const List<Node> spiritNodes = [
    Node(id: 'fu-kong-dao', name: '浮空岛', x: 0.5, y: 0.1, element: Element.wind, ifSegmentIds: ['spirit-01']),
    Node(id: 'ling-shou-shan', name: '灵兽山', x: 0.2, y: 0.3, element: Element.fire, ifSegmentIds: ['spirit-02']),
    Node(id: 'yao-jing-shi', name: '妖精市集', x: 0.5, y: 0.35, element: Element.gold, ifSegmentIds: ['spirit-03']),
    Node(id: 'ling-shu-ge', name: '灵枢阁', x: 0.8, y: 0.3, element: Element.wood, ifSegmentIds: ['spirit-04']),
    Node(id: 'xiu-shi-dao-chang', name: '修士道场', x: 0.3, y: 0.55, element: Element.earth, ifSegmentIds: ['spirit-05']),
    Node(id: 'ling-cao-xian-jing', name: '灵草仙境', x: 0.7, y: 0.55, element: Element.wood, ifSegmentIds: ['spirit-06']),
    Node(id: 'you-ming-hai', name: '幽冥海', x: 0.15, y: 0.8, element: Element.water, ifSegmentIds: ['spirit-07']),
    Node(id: 'ling-shan-zhi-dian', name: '灵山之巅', x: 0.85, y: 0.85, element: Element.thunder, ifSegmentIds: ['spirit-08']),
  ];

  static const List<Node> immortalNodes = [
    Node(id: 'yu-jing-shan', name: '玉京山', x: 0.5, y: 0.1, element: Element.gold, ifSegmentIds: ['immortal-01']),
    Node(id: 'tian-ting', name: '天庭', x: 0.5, y: 0.3, element: Element.gold, ifSegmentIds: ['immortal-02']),
    Node(id: 'wang-dao-dian', name: '王道殿', x: 0.3, y: 0.5, element: Element.gold, ifSegmentIds: ['immortal-03']),
    Node(id: 'xian-tai', name: '仙台', x: 0.7, y: 0.5, element: Element.thunder, ifSegmentIds: ['immortal-04']),
    Node(id: 'xian-ji-ge', name: '仙籍阁', x: 0.2, y: 0.7, element: Element.wood, ifSegmentIds: ['immortal-05']),
    Node(id: 'qun-xian-hui', name: '群仙会', x: 0.8, y: 0.7, element: Element.water, ifSegmentIds: ['immortal-06']),
    Node(id: 'jin-xian-dao-chang', name: '金仙道场', x: 0.4, y: 0.85, element: Element.fire, ifSegmentIds: ['immortal-07']),
    Node(id: 'cang-shu-ge-tian', name: '藏经阁天', x: 0.6, y: 0.85, element: Element.wind, ifSegmentIds: ['immortal-08']),
  ];

  static const List<Node> divineNodes = [
    Node(id: 'shen-tan-fei-xu', name: '神坛废墟', x: 0.5, y: 0.1, element: Element.thunder, ifSegmentIds: ['divine-01']),
    Node(id: 'yin-dao-zhi-yuan', name: '隐道之渊', x: 0.3, y: 0.3, element: Element.water, ifSegmentIds: ['divine-02']),
    Node(id: 'wan-shen-dian', name: '万神殿', x: 0.7, y: 0.3, element: Element.gold, ifSegmentIds: ['divine-03']),
    Node(id: 'jiu-shen-ju', name: '旧神居', x: 0.5, y: 0.5, element: Element.earth, ifSegmentIds: ['divine-04']),
    Node(id: 'tian-dao-lie-xi', name: '天道裂隙', x: 0.2, y: 0.7, element: Element.thunder, ifSegmentIds: ['divine-05']),
    Node(id: 'fei-sheng-tai', name: '飞升台', x: 0.8, y: 0.7, element: Element.thunder, ifSegmentIds: ['divine-06']),
    Node(id: 'shen-huo-gu', name: '神火谷', x: 0.3, y: 0.85, element: Element.fire, ifSegmentIds: ['divine-07']),
    Node(id: 'jiu-chao-yi-hen', name: '旧朝遗痕', x: 0.7, y: 0.85, element: Element.gold, ifSegmentIds: ['divine-08']),
  ];

  /// Returns the node list for the given realm.
  static List<Node> nodesFor(Realm realm) {
    switch (realm) {
      case Realm.lianQi:
      case Realm.zhuJi:
        return mortalNodes;
      case Realm.jinDan:
      case Realm.yuanYing:
        return spiritNodes;
      case Realm.huaShen:
      case Realm.daCheng:
        return immortalNodes;
    }
  }
}
