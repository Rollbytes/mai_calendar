import 'package:flutter/material.dart';

/// This is an adapter to transform various color formats to HexColor
class HexColor extends Color {
  HexColor(final String hexColor) : super(_getColorFromHex(hexColor));

  static int _getColorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF$hexColor";
    }
    return int.parse(hexColor, radix: 16);
  }

  /// Parses a color string in various formats and returns a HexColor
  static Color parse(String colorString) {
    if (colorString.startsWith('Color(')) {
      // 處理 Color 對象的字符串表示
      final hexValue = colorString.substring(colorString.indexOf('0x') + 2, colorString.length - 1);
      return Color(int.parse(hexValue, radix: 16));
    } else {
      // 處理普通的十六進制顏色字符串
      return HexColor(colorString);
    }
  }

  /// Converts a Color to a hex string - RGB format only
  static String toHex(Color selectedColor) {
    // 只返回 RGB 部分（後6位），忽略透明度
    final fullHex = selectedColor.value.toRadixString(16).padLeft(8, '0').toUpperCase();
    return '#${fullHex.substring(2)}'; // 去掉前兩個字符（透明度）
  }

  /// Creates a HexColor from a Color
  static HexColor fromColor(Color color) {
    return HexColor('#${color.value.toRadixString(16).padLeft(8, '0')}');
  }
}
