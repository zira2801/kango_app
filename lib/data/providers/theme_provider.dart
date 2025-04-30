import 'package:flutter/material.dart';
import 'package:scan_barcode_app/ui/theme/theme.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeData _themeDataStyle = ThemeDataStyle.lightMode;

  ThemeData get themeDataStyle => _themeDataStyle;

  set themeDataStyle(ThemeData themeData) {
    _themeDataStyle = themeData;
    notifyListeners();
  }

  void changeTheme() {
    if (_themeDataStyle == ThemeDataStyle.lightMode) {
      themeDataStyle = ThemeDataStyle.darkMode;
    } else {
      themeDataStyle = ThemeDataStyle.lightMode;
    }
  }
}
