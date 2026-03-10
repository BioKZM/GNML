import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:vault/Data/Model/game_model.dart';
import 'package:vault/Data/Model/movie_model.dart';
import 'package:vault/Data/Model/serie_model.dart';
import 'package:vault/Data/Model/book_model.dart';
import 'package:vault/Data/Model/actor_model.dart';
import 'package:vault/Data/Model/anime_model.dart';
import 'package:vault/Data/theme_data.dart';
import 'package:vault/Helper/redirect.dart';
import 'package:vault/Helper/theme_helper.dart';
import 'package:vault/Helper/window_helper.dart';
import 'package:vault/Widgets/custom_app_window.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:app_links/app_links.dart';

import 'package:vault/Providers/library_provider.dart';
import 'package:vault/UI/Desktop/User/profile_page.dart';
import 'package:vault/UI/Desktop/User/public_profile_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize Hive
  await Hive.initFlutter();
  Hive.registerAdapter(GameModelAdapter());
  Hive.registerAdapter(MovieModelAdapter());
  Hive.registerAdapter(SerieModelAdapter());
  Hive.registerAdapter(BookModelAdapter());
  Hive.registerAdapter(ActorModelAdapter());
  Hive.registerAdapter(AnimeModelAdapter());
  await Hive.openBox('content_cache');
  await Hive.openBox('user_library'); // Ensure this box is open

  ThemeProvider themeProvider = ThemeProvider();
  await themeProvider.getTheme();

  LibraryProvider libraryProvider = LibraryProvider();
  await libraryProvider.init();

  if (!kIsWeb && Platform.isWindows) {
    doWhenWindowReady(() async {
      WindowProvider windowProvider = WindowProvider();
      await windowProvider.getSize();

      Size initialSize = Size(windowProvider.width, windowProvider.height);
      appWindow.minSize = const Size(800, 600);
      appWindow.size = initialSize;
      appWindow.alignment = Alignment.center;
      appWindow.title = "VAULT";
      appWindow.show();
    });
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: themeProvider),
        ChangeNotifierProvider.value(value: libraryProvider),
      ],
      child: const MainPage(),
    ),
  );
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  late final AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSub;

  @override
  void initState() {
    super.initState();
    _appLinks = AppLinks();
    _initLinks();
  }

  Future<void> _initLinks() async {
    try {
      final initial = await _appLinks.getInitialLink();
      if (initial != null) {
        _openUri(initial);
      }
    } catch (_) {}

    _linkSub = _appLinks.uriLinkStream.listen(
      (uri) => _openUri(uri),
      onError: (_) {},
    );
  }

  void _openUri(Uri uri) {
    final path = uri.path;
    if (path.isEmpty) return;
    _navigatorKey.currentState?.pushNamed(path);
  }

  @override
  void dispose() {
    _linkSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VAULT',
      debugShowCheckedModeBanner: false,
      navigatorKey: _navigatorKey,
      theme: getAppTheme(context),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: const TextScaler.linear(0.9),
          ),
          child: child!,
        );
      },
      onGenerateRoute: (settings) {
        final name = settings.name;
        if (name != null) {
          final uri = Uri.parse(name);
          final segments = uri.pathSegments;
          if (segments.length == 2 && segments[1] == 'profile') {
            return MaterialPageRoute(
              builder: (context) => PublicProfilePage(handle: segments[0]),
              settings: settings,
            );
          }
          if (uri.path == '/profile') {
            return MaterialPageRoute(
              builder: (context) => const ProfilePage(),
              settings: settings,
            );
          }
        }
        return null;
      },
      home: Scaffold(
        body: Stack(
          children: [
            if (!kIsWeb && Platform.isWindows)
              CustomAppWindow(isExitable: false),
            Padding(
              padding: EdgeInsets.only(
                top: (!kIsWeb && Platform.isWindows) ? 35.0 : 0,
              ),
              child: const Redirect(),
            ),
          ],
        ),
      ),
    );
  }
}
