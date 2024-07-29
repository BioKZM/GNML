import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:gnml/Data/theme_data.dart';
import 'package:gnml/Helper/redirect.dart';
import 'package:gnml/Helper/theme_helper.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:gnml/Helper/window_helper.dart';
import 'package:gnml/Widgets/custom_app_window.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'firebase_options.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:bitsdojo_window/bitsdojo_window.dart';

Future<void> main() async {
  await dotenv.load(fileName: ".env");
  String supabaseURL = dotenv.get("SUPABASE_URL");
  String supabaseKey = dotenv.get("SUPABASE_KEY");
  ThemeProvider themeProvider = ThemeProvider();
  if (kIsWeb) {
  } else {
    if (Platform.isWindows) {
      doWhenWindowReady(() async {
        WindowProvider windowProvider = WindowProvider();
        await windowProvider.getSize();

        Size initialSize = Size(windowProvider.width, windowProvider.height);
        appWindow.minSize = const Size(800, 600);
        appWindow.size = initialSize;
        appWindow.alignment = Alignment.center;
        appWindow.title = "GNML";
        appWindow.show();
      });
      // WindowProvider windowProvider = WindowProvider();

      // await windowProvider.getSize();
      // await windowManager.ensureInitialized();
      // windowManager.setResizable(false);
      // WindowManager.instance
      //     .setSize(Size(windowProvider.width, windowProvider.height));
      // WindowManager.instance.setMinimumSize(const Size(800, 600));
      // WindowManager.instance.setMaximumSize(const Size(1920, 1080));
    }
  }

  await themeProvider.getTheme();
  WidgetsFlutterBinding.ensureInitialized();
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
    // return Expanded(
    //   child: Container(
    //     height: 1000,
    //     width: 1000,
    //     child: Column(
    //       children: [
    //         WindowTitleBarBox(
    //           child: Row(
    //             children: [
    //               Expanded(
    //                 child: Container(),
    //               ),
    //               Row(
    //                 children: [
    //                   MinimizeWindowButton(),
    //                   MaximizeWindowButton(),
    //                   CloseWindowButton(),
    //                 ],
    //               ),
    //             ],
    //           ),
    //         ),
    //       ],
    //     ),
    //   ),
    // );
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: getAppTheme(context),
      home: Scaffold(
        body: Stack(
          children: [
            CustomAppWindow(
              isExitable: false,
            ),
            const Padding(
              padding: EdgeInsets.only(
                top: 35.0,
              ),
              child: Redirect(),
            ),
          ],
        ),
      ),
    );
    // return MaterialApp(
    //   debugShowCheckedModeBanner: false,
    //   title: 'GNML',
    //   theme: getAppTheme(context),
    //   home: const Redirect(),
    // );
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
