import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isLightTheme = false;
  int _themeColor = const Color.fromARGB(255, 180, 0, 0).value;

  ThemeProvider() {
    getTheme();
  }

  bool get isDark => _isLightTheme;
  int get color => _themeColor;

  Future setColor(color) async {
    _themeColor = color;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt("themeColor", color);
    notifyListeners();
  }

  Future<int?> getColor() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    var color = prefs.getInt("themeColor");
    return color;
  }

  Future<void> getTheme() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    var themeColor = prefs.getInt("themeColor") ??
        const Color.fromARGB(255, 180, 0, 0).value;
    setColor(themeColor);
  }
}
