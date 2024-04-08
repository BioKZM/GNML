import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:gnml/Data/theme_data.dart';
import 'package:gnml/Helper/redirect.dart';
import 'package:gnml/Helper/theme_helper.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:gnml/Helper/window_helper.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:window_manager/window_manager.dart';
import 'firebase_options.dart';

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
