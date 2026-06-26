// StatusBar: 修真感 style. Shows 境界/层, 修为 bar, 寿元, 灵根, 5 道心 vector.

import 'package:flutter/material.dart';

import '../engine/cultivation_engine.dart';
import '../state/enums.dart' as domain;
import '../state/enums.dart';
import '../state/game_state.dart';
import 'theme.dart';

class StatusBar extends StatelessWidget {
  const StatusBar({super.key, required this.state});
  final GameState state;

  @override
  Widget build(BuildContext context) {
    final p = state.player;
    final xpRatio = CultivationEngine.cultivationXpMax == 0
        ? 0.0
        : p.cultivationXp / CultivationEngine.cultivationXpMax;
    final lifespanRatio = p.lifespanMax == 0
        ? 0.0
        : p.lifespan / p.lifespanMax;
    final rootColor = XianxiaTheme.elementColor[p.root.displayName] ?? XianxiaTheme.goldLeaf;

    return Container(
      decoration: const BoxDecoration(
        color: XianxiaTheme.inkBlack,
        border: Border(
          bottom: BorderSide(color: XianxiaTheme.goldLeaf, width: 1),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                p.realm.displayName,
                style: const TextStyle(
                  color: XianxiaTheme.paperWhite,
                  fontSize: 20,
                  letterSpacing: 4,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '第 ${p.layer} 层',
                style: const TextStyle(
                  color: XianxiaTheme.scrollTan,
                  fontSize: 14,
                ),
              ),
              const Spacer(),
              _elementChip(p.root.displayName, rootColor),
            ],
          ),
          const SizedBox(height: 8),
          _bar('修为', xpRatio, '${p.cultivationXp}/${CultivationEngine.cultivationXpMax}',
              XianxiaTheme.goldLeaf),
          const SizedBox(height: 4),
          _bar('寿元', lifespanRatio, '${p.lifespan}/${p.lifespanMax} 月',
              lifespanRatio < 0.3 ? XianxiaTheme.cinnabarRed : XianxiaTheme.jadeGreen),
          const SizedBox(height: 4),
          _karmaRow(p.karma),
          if (p.daoCompanion != null) ...[
            const SizedBox(height: 4),
            _companionRow(p.daoCompanion!),
          ],
          const SizedBox(height: 10),
          const Text('心之所向', style: TextStyle(
            color: XianxiaTheme.goldLeaf,
            fontSize: 12,
            letterSpacing: 2,
          )),
          const SizedBox(height: 4),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              for (final e in p.heartVector.entries)
                _heartChip(e.key, e.value),
            ],
          ),
        ],
      ),
    );
  }

  Widget _bar(String label, double ratio, String value, Color color) {
    return Row(
      children: [
        SizedBox(
          width: 32,
          child: Text(label, style: const TextStyle(
            color: XianxiaTheme.scrollTan,
            fontSize: 12,
          )),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: ratio.clamp(0.0, 1.0),
              minHeight: 6,
              backgroundColor: XianxiaTheme.shadowBrown,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(value, style: const TextStyle(
          color: XianxiaTheme.scrollTan,
          fontSize: 10,
        )),
      ],
    );
  }

  Widget _elementChip(String name, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        border: Border.all(color: color, width: 1),
        borderRadius: BorderRadius.circular(2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('灵根', style: TextStyle(color: color, fontSize: 10)),
          const SizedBox(width: 4),
          Text(name, style: TextStyle(
            color: color,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          )),
        ],
      ),
    );
  }

  Widget _heartChip(HeartPath path, int value) {
    final color = XianxiaTheme.heartColor[path.displayName] ?? XianxiaTheme.scrollTan;
    final active = value > 0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: active ? color.withValues(alpha: 0.25) : Colors.transparent,
        border: Border.all(
          color: active ? color : XianxiaTheme.shadowBrown,
          width: active ? 1.2 : 0.5,
        ),
        borderRadius: BorderRadius.circular(2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(path.displayName, style: TextStyle(
            color: active ? color : XianxiaTheme.scrollTan,
            fontSize: 11,
            fontWeight: active ? FontWeight.w600 : FontWeight.normal,
          )),
          const SizedBox(width: 4),
          Text('$value', style: TextStyle(
            color: active ? color : XianxiaTheme.scrollTan,
            fontSize: 11,
          )),
        ],
      ),
    );
  }

  Widget _karmaRow(int karma) {
    final color = karma > 0
        ? XianxiaTheme.jadeGreen
        : karma < 0
            ? XianxiaTheme.cinnabarRed
            : XianxiaTheme.scrollTan;
    final label = karma > 0 ? '善' : karma < 0 ? '恶' : '中';
    return Row(
      children: [
        SizedBox(
          width: 32,
          child: Text('因果', style: const TextStyle(
            color: XianxiaTheme.scrollTan,
            fontSize: 12,
          )),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            border: Border.all(color: color, width: 0.5),
            borderRadius: BorderRadius.circular(2),
          ),
          child: Text('$label $karma', style: TextStyle(
            color: color,
            fontSize: 11,
          )),
        ),
      ],
    );
  }

  /// 道侣 (dao companion) row. Shown only if the player has a companion.
  /// The 道心倾向 (heart-path tendency) is hard-coded per companion name
  /// for v0.1 — 玉箫 is 隐道. Future slices can add a companion profile
  /// table.
  Widget _companionRow(String name) {
    final tendency = _tendencyForCompanion(name);
    final color = tendency != null
        ? (XianxiaTheme.heartColor[tendency.displayName] ?? XianxiaTheme.scrollTan)
        : XianxiaTheme.scrollTan;
    return Row(
      children: [
        const SizedBox(
          width: 32,
          child: Text('道侣', style: TextStyle(
            color: XianxiaTheme.scrollTan,
            fontSize: 12,
          )),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            border: Border.all(color: color, width: 0.5),
            borderRadius: BorderRadius.circular(2),
          ),
          child: Text(
            tendency == null
                ? name
                : '$name · ${tendency.displayName}',
            style: TextStyle(color: color, fontSize: 11),
          ),
        ),
      ],
    );
  }

  domain.HeartPath? _tendencyForCompanion(String name) {
    switch (name) {
      case '玉箫':
        return domain.HeartPath.hiddenDao;
      default:
        return null;
    }
  }
}
