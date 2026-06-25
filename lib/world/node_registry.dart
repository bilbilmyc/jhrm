// NodeRegistry: 10 凡界 nodes (per docs/issues/mvp-slice-2.md).
//
// Position layout is hand-picked so 10 dots don't overlap on a 0..1 canvas
// and roughly mirror a real mountain / town / forest / cave layout.

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
}
