import 'dart:async';
import 'dart:io' show Platform;

import 'package:app_links/app_links.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:vault/data/model/actor_model.dart';
import 'package:vault/data/model/anime_model.dart';
import 'package:vault/data/model/book_model.dart';
import 'package:vault/data/model/game_model.dart';
import 'package:vault/data/model/movie_model.dart';
import 'package:vault/data/model/serie_model.dart';
import 'package:vault/data/theme_data.dart';
import 'package:vault/Helper/redirect.dart';
import 'package:vault/Helper/theme_helper.dart';
import 'package:vault/Helper/window_helper.dart';
import 'package:vault/Providers/library_provider.dart';
import 'package:vault/Providers/user_provider.dart';
import 'package:vault/ui/Desktop/User/profile_page.dart';
import 'package:vault/ui/Desktop/User/public_profile_page.dart';
import 'package:vault/ui/widgets/custom_app_window.dart';

import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  debugPrint('BOOT 1: binding ready');
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  debugPrint('BOOT 2: firebase ready');

  try {
    await dotenv.load(fileName: '.env');
  } catch (_) {}
  debugPrint('BOOT 3: dotenv ready');

  await Hive.initFlutter();
  debugPrint('BOOT 4: hive ready');
  if (!Hive.isAdapterRegistered(0)) Hive.registerAdapter(GameModelAdapter());
  if (!Hive.isAdapterRegistered(1)) Hive.registerAdapter(MovieModelAdapter());
  if (!Hive.isAdapterRegistered(2)) Hive.registerAdapter(SerieModelAdapter());
  if (!Hive.isAdapterRegistered(3)) Hive.registerAdapter(BookModelAdapter());
  if (!Hive.isAdapterRegistered(4)) Hive.registerAdapter(ActorModelAdapter());
  if (!Hive.isAdapterRegistered(5)) Hive.registerAdapter(AnimeModelAdapter());
  debugPrint('BOOT 5: adapters ready');

  await Hive.openBox('content_cache');
  await Hive.openBox('user_library');
  await Hive.openBox('user_profile');
  debugPrint('BOOT 6: boxes ready');

  final themeProvider = ThemeProvider();
  await themeProvider.getTheme();
  debugPrint('BOOT 7: theme ready');

  final libraryProvider = LibraryProvider();
  final userProvider = UserProvider();
  debugPrint('BOOT 8: providers created');

  if (!kIsWeb && Platform.isWindows) {
    doWhenWindowReady(() async {
      final windowProvider = WindowProvider();
      await windowProvider.getSize();

      final initialSize = Size(windowProvider.width, windowProvider.height);
      appWindow.minSize = const Size(800, 600);
      appWindow.size = initialSize;
      appWindow.alignment = Alignment.center;
      appWindow.title = 'VAULT';
      appWindow.show();
    });
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: themeProvider),
        ChangeNotifierProvider.value(value: libraryProvider),
        ChangeNotifierProvider.value(value: userProvider),
      ],
      child: const MainPage(),
    ),
  );
  debugPrint('BOOT 9: runApp called');
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
    if (!kIsWeb) {
      _appLinks = AppLinks();
      _initLinks();
    }
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
