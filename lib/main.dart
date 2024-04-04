import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:gnml/Helper/redirect.dart';
import 'package:gnml/Helper/theme_helper.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:gnml/Helper/window_helper.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:updat/updat.dart';
import 'package:window_manager/window_manager.dart';
import 'firebase_options.dart';
import 'package:http/http.dart' as http;

Future<void> main() async {
  await dotenv.load(fileName: ".env");
  String supabaseURL = dotenv.get("SUPABASE_URL");
  String supabaseKey = dotenv.get("SUPABASE_KEY");
  ThemeProvider themeProvider = ThemeProvider();
  WindowProvider windowProvider = WindowProvider();
  await themeProvider.getTheme();
  await windowProvider.getSize();
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();
  windowManager.setResizable(false);
  WindowManager.instance
      .setSize(Size(windowProvider.width, windowProvider.height));
  WindowManager.instance.setMinimumSize(const Size(800, 600));
  WindowManager.instance.setMaximumSize(const Size(1920, 1080));
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await Supabase.initialize(
    url: supabaseURL,
    anonKey: supabaseKey,
  );

  runApp(
    ChangeNotifierProvider.value(
      value: themeProvider,
      child: const MainPage(),
    ),
  );
}

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'GNML',
      theme: getAppTheme(context),
      home: const Redirect(),
    );
  }
}

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

String get platformExt {
  switch (Platform.operatingSystem) {
    case 'windows':
      {
        return 'exe';
      }

    case 'macos':
      {
        return 'dmg';
      }

    case 'linux':
      {
        return 'AppImage';
      }
    default:
      {
        return 'zip';
      }
  }
}
