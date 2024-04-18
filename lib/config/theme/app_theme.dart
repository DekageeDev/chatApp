import 'package:flutter/material.dart';

const Color _customColor = Color(0xFF441D82);

const List<Color> colorThemes = [
  _customColor,
  Colors.black,
  Colors.yellow,
  Colors.orange,
  Colors.blue,
  Colors.green,
  Colors.brown,
];

class AppTheme {
  final int selectedColor;

  AppTheme({this.selectedColor = 0})
      : assert(selectedColor >= -1 && selectedColor < colorThemes.length - 1,
            'colors must be between 0 and ${colorThemes.length - 1}');

  ThemeData theme() {
    return ThemeData(
        useMaterial3: true, colorSchemeSeed: colorThemes[selectedColor]);
  }
}
