import 'package:flutter/material.dart';
import 'package:gnml/Helper/theme_helper.dart';
import 'package:provider/provider.dart';

ThemeData getAppTheme(BuildContext context) {
  int themeColor = Provider.of<ThemeProvider>(context).color;

  return getDarkTheme(themeColor);
}

ThemeData getDarkTheme(themeColor) {
  const double brightnessThreshold = 0.4;
  double brightness = Color(themeColor).computeLuminance();

  ThemeData themeData = ThemeData();
  themeData = ThemeData(
    tabBarTheme: TabBarTheme(
      unselectedLabelColor: brightness < brightnessThreshold
          ? Colors.grey.shade400
          : Colors.black54,
      indicatorColor:
          brightness < brightnessThreshold ? Colors.white : Colors.black,
      labelColor:
          brightness < brightnessThreshold ? Colors.white : Colors.black,
    ),
    fontFamily: 'RobotoMedium',
    brightness: Brightness.dark,
    useMaterial3: true,
    scaffoldBackgroundColor: const Color.fromARGB(255, 24, 24, 24),
    primaryColorDark: Color(themeColor),
    iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
      highlightColor: Colors.transparent,
    )),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color.fromARGB(255, 0, 0, 0),
        foregroundColor: Color(themeColor),
      ),
    ),
    colorScheme: ColorScheme(
      surfaceTint: const Color.fromARGB(255, 255, 255, 255),
      brightness: Brightness.dark,
      primary: Color(themeColor),
      onPrimary: Colors.white,
      secondary: Color(themeColor).withAlpha(100),
      onSecondary: Colors.white,
      error: Color(themeColor),
      onError: Color(themeColor),
      background: Colors.black,
      onBackground: Colors.grey.shade600,
      surface: const Color.fromARGB(255, 37, 35, 42),
      onSurface: Colors.white,
      shadow: const Color(0xFF000000),
      scrim: const Color(0xFF000000),
    ),
    splashColor: const Color.fromARGB(0, 255, 255, 255),
  );

  return themeData;
}
