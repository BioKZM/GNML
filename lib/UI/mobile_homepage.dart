import 'package:flutter/material.dart';
import 'package:gnml/UI/Mobile/Games/games_page.dart';
import 'package:gnml/UI/Mobile/Library/library_page.dart';
import 'package:gnml/UI/Mobile/Movies/movies_page.dart';
import 'package:gnml/UI/Mobile/Search/search_page.dart';
import 'package:gnml/UI/Mobile/Series/series_page.dart';
import 'package:gnml/UI/Mobile/User/settings_page.dart';

class MobileHomePage extends StatefulWidget {
  const MobileHomePage({super.key});

  @override
  State<MobileHomePage> createState() => _MobileHomePageState();
}

class _MobileHomePageState extends State<MobileHomePage>
    with SingleTickerProviderStateMixin {
  int currentIndex = 0;
  final pages = [
    const LibraryPage(),
    const GamesPage(),
    const MoviesPage(),
    const SeriesPage(),
    const SearchPage(),
    const SettingsPage(),
  ];

  GlobalKey key = GlobalKey();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: IndexedStack(
          index: currentIndex,
          children: pages,
        ),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          // backgroundColor: Colors.white,
          selectedItemColor: Colors.red.shade700,
          unselectedItemColor: Colors.white,
          currentIndex: currentIndex,
          onTap: (index) => setState(
            () => currentIndex = index,
          ),
          items: const [
            BottomNavigationBarItem(
              label: "Library",
              icon: Icon(Icons.library_books),
            ),
            BottomNavigationBarItem(
              label: "Games",
              icon: Icon(Icons.games),
            ),
            BottomNavigationBarItem(
              label: "Movies",
              icon: Icon(Icons.movie),
            ),
            BottomNavigationBarItem(
              label: "Series",
              icon: Icon(Icons.camera),
            ),
            BottomNavigationBarItem(
              label: "Search",
              icon: Icon(Icons.search),
            ),
          ],
        ),
      ),
    );
  }
}
