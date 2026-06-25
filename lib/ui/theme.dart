// 修真主题：古风色板 + 字体 + 山水背景纹理（用渐变 + Material 3 配色调制）。
// Avoid heavy asset dependencies; everything here is pure Flutter.

import 'package:flutter/material.dart';

class XianxiaTheme {
  // 修真 / 仙侠 / 山水的传统色。
  // Inspired by classical Chinese ink-and-gold palette.
  static const Color inkBlack = Color(0xFF1A1410);
  static const Color scrollTan = Color(0xFFE8D9B5);
  static const Color goldLeaf = Color(0xFFB6892C);
  static const Color cinnabarRed = Color(0xFFB03327);
  static const Color jadeGreen = Color(0xFF3E5C3B);
  static const Color skyBlue = Color(0xFF3A5E78);
  static const Color paperWhite = Color(0xFFF6EDD8);
  static const Color shadowBrown = Color(0xFF3A2C1E);

  // Element glyphs (CJK characters used as quick visual mnemonics for 灵根).
  static const Map<String, String> elementGlyph = {
    '金': '金', '木': '木', '水': '水', '火': '火', '土': '土',
    '风': '风', '雷': '雷', '冰': '冰',
  };

  // Element colors (used in 灵根 chip + 道心 progress tint).
  static const Map<String, Color> elementColor = {
    '金': Color(0xFFCBA74E),
    '木': Color(0xFF4E8A4A),
    '水': Color(0xFF4A7AA8),
    '火': Color(0xFFB85447),
    '土': Color(0xFF8A6B3E),
    '风': Color(0xFF9BB897),
    '雷': Color(0xFF7B5BB6),
    '冰': Color(0xFF7BB6CC),
  };

  // Heart path colors (5 道心).
  static const Map<String, Color> heartColor = {
    '剑道': Color(0xFFCFD8E0),
    '魔道': Color(0xFF6B2B2B),
    '王道': Color(0xFFB6892C),
    '隐道': Color(0xFF5C7A6E),
    '无道': Color(0xFF6B6058),
  };

  // Build the app theme.
  static ThemeData light() {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: inkBlack,
        onPrimary: paperWhite,
        secondary: goldLeaf,
        onSecondary: paperWhite,
        tertiary: cinnabarRed,
        surface: paperWhite,
        onSurface: inkBlack,
        error: cinnabarRed,
      ),
      scaffoldBackgroundColor: scrollTan,
      fontFamily: 'serif',
    );
    return base.copyWith(
      appBarTheme: const AppBarTheme(
        backgroundColor: inkBlack,
        foregroundColor: paperWhite,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: 'serif',
          color: paperWhite,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          letterSpacing: 2,
        ),
      ),
      cardTheme: CardThemeData(
        color: paperWhite,
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
          side: const BorderSide(color: shadowBrown, width: 0.5),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: scrollTan,
        selectedColor: goldLeaf,
        side: const BorderSide(color: shadowBrown, width: 0.5),
        labelStyle: const TextStyle(color: inkBlack),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: inkBlack,
          foregroundColor: paperWhite,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(2),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          textStyle: const TextStyle(
            fontFamily: 'serif',
            fontSize: 16,
            letterSpacing: 1.2,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: shadowBrown),
      ),
      dividerTheme: const DividerThemeData(
        color: shadowBrown,
        thickness: 0.5,
        space: 1,
      ),
    );
  }

  /// A subtle 山水 background — three vertical bands like a scroll painting.
  /// Pure widget, no asset, no extra dependency.
  static Widget scrollBackground({required Widget child}) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [scrollTan, Color(0xFFD4C28E), Color(0xFFBEAA77)],
          stops: [0.0, 0.65, 1.0],
        ),
      ),
      child: child,
    );
  }

  /// A horizontal rule drawn like 印章 (calligraphy seal) — single fat
  /// stroke for use as a section divider inside IF text.
  static Widget sealDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Expanded(child: Container(height: 1, color: shadowBrown)),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Text('道', style: TextStyle(
              color: cinnabarRed,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            )),
          ),
          Expanded(child: Container(height: 1, color: shadowBrown)),
        ],
      ),
    );
  }
}
