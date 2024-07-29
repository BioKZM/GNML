import 'package:screen_retriever/screen_retriever.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WindowProvider {
  late double _width;
  late double _height;
  // bool _isLightTheme = false;
  // int _themeColor = const Color.fromARGB(255, 180, 0, 0).value;

  WindowProvider() {
    getSize();
  }

  double get width => _width;
  double get height => _height;

  Future setSize(width, height) async {
    _width = width;
    _height = height;
    // _themeColor = color;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    // await prefs.setInt("themeColor", color);
    await prefs.setDouble("width", width);
    await prefs.setDouble("height", height);
    // prefs.set
    // notifyListeners();
  }

  Future<void> getSize() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    Display primaryDisplay = await screenRetriever.getPrimaryDisplay();
    var width = prefs.getDouble("width");
    var height = prefs.getDouble("height");
    width ??= primaryDisplay.size.width;
    height ??= primaryDisplay.size.height;
    // return [prefs.getDouble("width"), prefs.getDouble("heigth")];
    setSize(width, height);
  }

  // Future<int?> getColor() async {
  //   final SharedPreferences prefs = await SharedPreferences.getInstance();
  //   var color = prefs.getInt("themeColor");
  //   return color;
  // }

  // Future<void> getTheme() async {
  //   final SharedPreferences prefs = await SharedPreferences.getInstance();
  //   var isLightTheme = prefs.getBool("lightTheme") ?? false;
  //   var themeColor = prefs.getInt("themeColor") ??
  //       const Color.fromARGB(255, 180, 0, 0).value;
  //   setColor(themeColor);
  //   setTheme(isLightTheme);
  // }

  // Future setTheme(theme) async {
  //   _isLightTheme = theme;
  //   final SharedPreferences prefs = await SharedPreferences.getInstance();
  //   await prefs.setBool("lightTheme", theme);
  //   // notifyListeners();
  // }
}
