import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:vault/Helper/theme_helper.dart';
import 'package:vault/Helper/ui_constants.dart';
import 'package:vault/Providers/user_provider.dart';
import 'package:vault/ui/Views/home_view.dart';
import 'package:vault/ui/Desktop/User/profile_page.dart';
import 'package:vault/ui/Desktop/Games/games_page.dart';
import 'package:vault/ui/Desktop/Library/library_page.dart';
import 'package:vault/ui/Desktop/Movies/movies_page.dart';
import 'package:vault/ui/Desktop/Series/series_page.dart';
import 'package:vault/ui/Desktop/User/settings_page.dart';
import 'package:vault/ui/Desktop/Animes/animes_page.dart';
import 'package:vault/ui/widgets/circularprogressindicator.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:vault/Providers/library_provider.dart';
import 'package:vault/Logic/animepage_logic.dart';
import 'package:vault/Logic/gamepage_logic.dart';
import 'package:vault/Logic/moviepage_logic.dart';
import 'package:vault/ui/Desktop/Details/anime_detail_page.dart';
import 'package:vault/ui/Desktop/Details/game_detail_page.dart';
import 'package:vault/ui/Desktop/Details/movie_detail_page.dart';
import 'package:vault/ui/Desktop/Details/serie_detail_page.dart';

class LayoutScaffold extends StatefulWidget {
  const LayoutScaffold({super.key});

  @override
  State<LayoutScaffold> createState() => _LayoutScaffoldState();
}

class _LayoutScaffoldState extends State<LayoutScaffold>
    with SingleTickerProviderStateMixin {
  User? get user => FirebaseAuth.instance.currentUser;
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  late TabController _tabController;
  GlobalKey key = GlobalKey();

  final LayerLink _searchLayerLink = LayerLink();
  OverlayEntry? _searchOverlay;
  final FocusNode _searchFocusNode = FocusNode();

  bool _isLeftOpen = true;
  bool _isRightOpen = false;
  String _activeRightPanel = '';
  String _selectedLibraryFolder = 'library';

  late Stream<DocumentSnapshot> _userStream;
  // late Future<_HeroCardData?> _exploreHeroFuture;
  // String? _backlogHeroKey;

  @override
  void initState() {
    super.initState();
    _tabController =
        TabController(length: 6, vsync: this); // Added Home, total 6

    // Listen to TabController to animate IndexedStack when Tab is clicked
    _tabController.addListener(() {
      setState(() {});
    });

    _searchFocusNode.addListener(() {
      if (_searchFocusNode.hasFocus) {
        _showSearchOverlay();
      } else {
        _hideSearchOverlay();
      }
    });

    // _userData = userBox.get('profile');
    // final user = context.watch<UserProvider>().userData;

    // CollectionReference data = _firestore.collection('users');
    // _userStream = data.doc(user!.uid).snapshots();
    // _exploreHeroFuture = _fetchExploreHero();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Future<_HeroCardData?> _fetchExploreHero() async {
  //   Future<_HeroCardData?> tryAnime() async {
  //     try {
  //       final items = await AnimePageLogic().getTopAnimes(limit: 20);
  //       if (items.isEmpty) return null;
  //       final pick =
  //           items[DateTime.now().millisecondsSinceEpoch % items.length];
  //       if (pick.id == null) return null;
  //       return _HeroCardData(
  //         title: pick.title ?? 'Anime',
  //         subtitle: 'Trending Anime',
  //         imageUrl: pick.imageURL,
  //         onOpen: () => AnimeDetailPage(animeId: pick.id!),
  //       );
  //     } catch (_) {
  //       return null;
  //     }
  //   }

  //   Future<_HeroCardData?> tryGame() async {
  //     try {
  //       final items =
  //           await GamePageLogic().getPopularGameList('popularRightNow');
  //       if (items.isEmpty) return null;
  //       final pick =
  //           items[DateTime.now().millisecondsSinceEpoch % items.length];
  //       if (pick.id == null) return null;
  //       return _HeroCardData(
  //         title: pick.name ?? 'Game',
  //         subtitle: 'Trending Game',
  //         imageUrl: pick.imageURL,
  //         onOpen: () => GameDetailPage(gameID: pick.id!),
  //       );
  //     } catch (_) {
  //       return null;
  //     }
  //   }

  //   Future<_HeroCardData?> tryMovie() async {
  //     try {
  //       final items = await MoviePageLogic().getPopularMovies();
  //       if (items.isEmpty) return null;
  //       final pick =
  //           items[DateTime.now().millisecondsSinceEpoch % items.length];
  //       if (pick.id == null) return null;
  //       return _HeroCardData(
  //         title: pick.title ?? 'Movie',
  //         subtitle: 'Trending Movie',
  //         imageUrl: pick.imageURL,
  //         onOpen: () => MovieDetailPage(movieID: pick.id!),
  //       );
  //     } catch (_) {
  //       return null;
  //     }
  //   }

  //   final options = <Future<_HeroCardData?> Function()>[
  //     tryAnime,
  //     tryGame,
  //     tryMovie,
  //   ];
  //   options.shuffle(Random(DateTime.now().millisecondsSinceEpoch));

  //   for (final fn in options) {
  //     final result = await fn();
  //     if (result != null) return result;
  //   }
  //   return null;
  // }

  // _HeroCardData? _pickBacklogHero(LibraryProvider provider) {
  //   final entries = provider.libraryMap.entries.where((e) {
  //     final raw = e.value;
  //     if (raw is! Map) return false;
  //     final m = Map<String, dynamic>.from(raw);
  //     return (m['folder']?.toString() ?? 'library') == 'backlog';
  //   }).toList();

  //   if (entries.isEmpty) return null;

  //   _backlogHeroKey ??=
  //       entries[DateTime.now().millisecondsSinceEpoch % entries.length]
  //           .key
  //           .toString();
  //   final chosen = entries.firstWhere(
  //     (e) => e.key.toString() == _backlogHeroKey,
  //     orElse: () => entries.first,
  //   );

  //   final raw = chosen.value;
  //   if (raw is! Map) return null;
  //   final m = Map<String, dynamic>.from(raw);
  //   final title = (m['title'] ?? 'Backlog').toString();
  //   final imageUrl = m['imageURL']?.toString();
  //   final id = m['id'];

  //   Widget Function()? onOpen;
  //   final prefix = chosen.key.toString().split('_').first;
  //   if (id is int) {
  //     switch (prefix) {
  //       case 'game':
  //         onOpen = () => GameDetailPage(gameID: id);
  //         break;
  //       case 'movie':
  //         onOpen = () => MovieDetailPage(movieID: id);
  //         break;
  //       case 'serie':
  //         onOpen = () => SerieDetailPage(serieID: id);
  //         break;
  //       case 'anime':
  //         onOpen = () => AnimeDetailPage(animeId: id);
  //         break;
  //     }
  //   }

  //   return _HeroCardData(
  //     title: title,
  //     subtitle: 'From Backlog',
  //     imageUrl: imageUrl,
  //     onOpen: onOpen,
  //   );
  // }

  // Widget _buildDoubleHero(Color primaryColor) {
  //   return Consumer<LibraryProvider>(
  //     builder: (context, libraryProvider, child) {
  //       final left = _pickBacklogHero(libraryProvider) ??
  //           _HeroCardData(
  //             title: 'Backlog boş',
  //             subtitle: 'İçerik ekleyerek backlog vitrini oluştur.',
  //             imageUrl: null,
  //             onOpen: null,
  //           );

  //       return Row(
  //         children: [
  //           Expanded(
  //             child: _HeroCard(
  //               primaryColor: primaryColor,
  //               title: left.title,
  //               subtitle: left.subtitle,
  //               imageUrl: left.imageUrl,
  //               onOpen: left.onOpen,
  //             ),
  //           ),
  //           const SizedBox(width: 12),
  //           Expanded(
  //             child: FutureBuilder<_HeroCardData?>(
  //               future: _exploreHeroFuture,
  //               builder: (context, snapshot) {
  //                 final right = snapshot.data ??
  //                     _HeroCardData(
  //                       title: "Vault'u Keşfet",
  //                       subtitle: 'Global Trends',
  //                       imageUrl: null,
  //                       onOpen: null,
  //                     );
  //                 return Skeletonizer(
  //                   enabled: snapshot.connectionState != ConnectionState.done,
  //                   child: _HeroCard(
  //                     primaryColor: primaryColor,
  //                     title: right.title,
  //                     subtitle: right.subtitle,
  //                     imageUrl: right.imageUrl,
  //                     onOpen: right.onOpen,
  //                   ),
  //                 );
  //               },
  //             ),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

  void _showSearchOverlay() {
    _searchOverlay = _createSearchOverlay();
    Overlay.of(context).insert(_searchOverlay!);
  }

  void _hideSearchOverlay() {
    _searchOverlay?.remove();
    _searchOverlay = null;
  }

  OverlayEntry _createSearchOverlay() {
    return OverlayEntry(
      builder: (context) => Positioned(
        width: 400, // Search bar width
        child: CompositedTransformFollower(
          link: _searchLayerLink,
          showWhenUnlinked: false,
          offset: const Offset(0, 50),
          child: Material(
            elevation: 8,
            color: const Color(0xFF1A1A1A),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildSearchSuggestion(
                    "Grand Theft Auto V", "Oyun", FontAwesomeIcons.gamepad),
                const Divider(height: 1, color: Colors.white10),
                _buildSearchSuggestion(
                    "Inception", "Film", FontAwesomeIcons.film),
                const Divider(height: 1, color: Colors.white10),
                _buildSearchSuggestion(
                    "Breaking Bad", "Dizi", FontAwesomeIcons.tv),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchSuggestion(String title, String type, IconData icon) {
    return ListTile(
      leading: SizedBox(
        width: 24,
        height: 24,
        child: Center(child: Icon(icon, color: Colors.white70, size: 18)),
      ),
      title: Text(
        title,
        style: GoogleFonts.inter(color: Colors.white, fontSize: 13),
      ),
      subtitle: Text(
        type,
        style: GoogleFonts.inter(color: Colors.white54, fontSize: 11),
      ),
      onTap: () {
        _searchFocusNode.unfocus();
      },
      hoverColor: Colors.white.withValues(alpha: 0.05),
    );
  }

  void _selectTab(int index) {
    setState(() {
      _selectedLibraryFolder = 'library';
      _tabController.animateTo(index);
    });
  }

  void _openLibraryFolder(String folder) {
    setState(() {
      _selectedLibraryFolder = folder;
      _tabController.animateTo(1);
    });
  }

  @override
  Widget build(BuildContext context) {
    int themeColor = Provider.of<ThemeProvider>(context).color;
    final primaryColor = Color(themeColor);
    final userProvider = context.watch<UserProvider>();
    final snapshotData = userProvider.userData;

    if (snapshotData == null) {
      return const Scaffold(
          body: Center(
        child: CircularProgressIndicator(),
      ));
    }
    // var snapshotData = snapshot.data?.data() as Map<String, dynamic>?;
    var imageURL = snapshotData['imageURL'];
    int totalContentCount = 0;
    if (snapshotData['library'] != null) {
      final lib = snapshotData['library'];
      if (lib is Map) {
        totalContentCount = lib.length;
      }
    }
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        toolbarHeight: 80,
        titleSpacing: 24,
        title: Row(
          children: [
            Text(
              "VAULT",
              style: GoogleFonts.orbitron(
                fontSize: 32,
                fontWeight: FontWeight.w800,
                letterSpacing: 6,
                color: Colors.white,
              ),
            ),
            Expanded(
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _ActionSquareButton(
                      icon: Icons.add,
                      onTap: () {},
                      primaryColor: Theme.of(context).primaryColor,
                    ),
                    const SizedBox(width: 12),
                    CompositedTransformTarget(
                      link: _searchLayerLink,
                      child: SizedBox(
                        width: 460,
                        height: 44,
                        child: TextField(
                          focusNode: _searchFocusNode,
                          style:
                              GoogleFonts.inter(color: Colors.white, fontSize: 14),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: const Color(0xFF1A1A1A),
                            hintText: 'Search Library...',
                            hintStyle: GoogleFonts.inter(
                                color: Colors.white38, fontSize: 14),
                            prefixIcon: const Icon(Icons.search,
                                color: Colors.white38, size: 20),
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 0, horizontal: 16),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                  color: Colors.white.withValues(alpha: 0.05),
                                  width: 1),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide:
                                  BorderSide(color: primaryColor, width: 1),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Row(
              children: [
                _ActionSquareButton(
                  onTap: () async {
                    final provider =
                        Provider.of<LibraryProvider>(context, listen: false);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text("Syncing library to cloud..."),
                          duration: Duration(seconds: 1)),
                    );
                    await provider.syncToFirebase();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text("Sync completed successfully!")),
                      );
                    }
                  },
                  icon: FontAwesomeIcons.cloudArrowUp,
                  primaryColor: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 8),
                _ActionSquareButton(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const SettingsPage()));
                  },
                  icon: FontAwesomeIcons.sliders,
                  primaryColor: Theme.of(context).primaryColor,
                ),

                Container(
                  height: 24,
                  width: 1,
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  color: Colors.white.withValues(alpha: 0.1),
                ),

                _ActionSquareButton(
                  onTap: () {
                    setState(() {
                      if (_activeRightPanel == 'timeline' && _isRightOpen) {
                        _isRightOpen = false;
                        _activeRightPanel = '';
                      } else {
                        _isRightOpen = true;
                        _activeRightPanel = 'timeline';
                      }
                    });
                  },
                  icon: FontAwesomeIcons.clock,
                  primaryColor: _activeRightPanel == 'timeline'
                      ? Theme.of(context).primaryColor
                      : Colors.white70,
                ),
                const SizedBox(width: 8),
                _ActionSquareButton(
                  onTap: () {
                    setState(() {
                      if (_activeRightPanel == 'friends' && _isRightOpen) {
                        _isRightOpen = false;
                        _activeRightPanel = '';
                      } else {
                        _isRightOpen = true;
                        _activeRightPanel = 'friends';
                      }
                    });
                  },
                  icon: FontAwesomeIcons.userGroup,
                  primaryColor: _activeRightPanel == 'friends'
                      ? Theme.of(context).primaryColor
                      : Colors.white70,
                ),
              ],
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            width: _isLeftOpen
                ? UIConstants.leftSidebarExpandedWidth
                : UIConstants.leftSidebarCollapsedWidth,
            color: const Color(0xFF121212),
            child: Column(
              children: [
                Expanded(
                  child: _isLeftOpen
                      ? _buildAppSidebar(context)
                      : _buildCollapsedSidebar(context),
                ),
                if (_isLeftOpen) ...[
                  _buildSidebarProfile(context, imageURL, primaryColor,
                      snapshotData?['username'], totalContentCount),
                  const SizedBox(height: 16),
                ] else ...[
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: CircleAvatar(
                      radius: 18,
                      backgroundImage: imageURL != null
                          ? CachedNetworkImageProvider(imageURL)
                          : null,
                      child: imageURL == null
                          ? const Icon(Icons.person, size: 18)
                          : null,
                    ),
                  )
                ]
              ],
            ),
          ),

          Expanded(
            child: LayoutBuilder(builder: (context, constraints) {
              return Container(
                width: constraints.maxWidth,
                decoration: const BoxDecoration(),
                child: ClipRRect(
                  child: IndexedStack(
                    index: _tabController.index,
                    children: [
                      const HomeView(),
                      LibraryPage(initialFolder: _selectedLibraryFolder),
                      const GamesPage(),
                      const MoviesPage(),
                      const SeriesPage(),
                      const AnimesPage(),
                    ],
                  ),
                ),
              );
            }),
          ),

          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            width: _isRightOpen ? UIConstants.rightSidebarWidth : 0,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: UIConstants.rightSidebarWidth,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: _activeRightPanel == 'friends'
                      ? _buildFriendsPanel(context)
                      : _buildTimelinePanel(context),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppSidebar(BuildContext context) {
    final primaryColor = Color(Provider.of<ThemeProvider>(context).color);
    final libraryProvider = context.watch<LibraryProvider>();
    final folderCounts = _buildFolderCounts(libraryProvider.libraryMap);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
          child: Row(
            children: [
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () {
                  setState(() {
                    _isLeftOpen = !_isLeftOpen;
                  });
                },
                icon: const Icon(
                  FluentIcons.panel_left_contract_24_regular,
                  color: Colors.white70,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Browse',
                style: GoogleFonts.inter(
                  color: Colors.white54,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSidebarNavItem(
                  icon: FluentIcons.home_24_regular,
                  label: 'Home',
                  selected: _tabController.index == 0,
                  primaryColor: primaryColor,
                  onTap: () => _selectTab(0),
                ),
                _buildSidebarNavItem(
                  icon: FluentIcons.library_24_regular,
                  label: 'Library',
                  selected:
                      _tabController.index == 1 && _selectedLibraryFolder == 'library',
                  primaryColor: primaryColor,
                  badge: folderCounts['library'],
                  onTap: () => _openLibraryFolder('library'),
                ),
                _buildSidebarNavItem(
                  icon: FontAwesomeIcons.gamepad,
                  label: 'Games',
                  selected: _tabController.index == 2,
                  primaryColor: primaryColor,
                  onTap: () => _selectTab(2),
                ),
                _buildSidebarNavItem(
                  icon: FontAwesomeIcons.film,
                  label: 'Movies',
                  selected: _tabController.index == 3,
                  primaryColor: primaryColor,
                  onTap: () => _selectTab(3),
                ),
                _buildSidebarNavItem(
                  icon: FontAwesomeIcons.tv,
                  label: 'Series',
                  selected: _tabController.index == 4,
                  primaryColor: primaryColor,
                  onTap: () => _selectTab(4),
                ),
                _buildSidebarNavItem(
                  icon: FontAwesomeIcons.dragon,
                  label: 'Anime',
                  selected: _tabController.index == 5,
                  primaryColor: primaryColor,
                  onTap: () => _selectTab(5),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 18, 16, 10),
                  child: Text(
                    'Your Library',
                    style: GoogleFonts.inter(
                      color: Colors.white54,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                _buildSidebarNavItem(
                  icon: FontAwesomeIcons.star,
                  label: 'Favorites',
                  selected: _tabController.index == 1 &&
                      _selectedLibraryFolder == 'favorites',
                  primaryColor: primaryColor,
                  badge: folderCounts['favorites'],
                  onTap: () => _openLibraryFolder('favorites'),
                ),
                _buildSidebarNavItem(
                  icon: FontAwesomeIcons.circleCheck,
                  label: 'Completed',
                  selected: _tabController.index == 1 &&
                      _selectedLibraryFolder == 'completed',
                  primaryColor: primaryColor,
                  badge: folderCounts['completed'],
                  onTap: () => _openLibraryFolder('completed'),
                ),
                _buildSidebarNavItem(
                  icon: FontAwesomeIcons.clock,
                  label: 'Backlog',
                  selected:
                      _tabController.index == 1 && _selectedLibraryFolder == 'backlog',
                  primaryColor: primaryColor,
                  badge: folderCounts['backlog'],
                  onTap: () => _openLibraryFolder('backlog'),
                ),
                ...libraryProvider.customFolders.map((folder) {
                  return _buildSidebarNavItem(
                    icon: FontAwesomeIcons.folderOpen,
                    label: folder,
                    selected: _tabController.index == 1 &&
                        _selectedLibraryFolder == folder,
                    primaryColor: primaryColor,
                    badge: folderCounts[folder],
                    onTap: () => _openLibraryFolder(folder),
                  );
                }),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCollapsedSidebar(BuildContext context) {
    final primaryColor = Color(Provider.of<ThemeProvider>(context).color);
    final libraryProvider = context.watch<LibraryProvider>();
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: IconButton(
            onPressed: () {
              setState(() {
                _isLeftOpen = !_isLeftOpen;
              });
            },
            icon: const Icon(
              FluentIcons.panel_left_expand_24_regular,
              color: Colors.white70,
            ),
          ),
        ),
        const SizedBox(height: 6),
        _buildCollapsedSidebarButton(
          icon: FluentIcons.home_24_regular,
          tooltip: 'Home',
          selected: _tabController.index == 0,
          primaryColor: primaryColor,
          onTap: () => _selectTab(0),
        ),
        _buildCollapsedSidebarButton(
          icon: FluentIcons.library_24_regular,
          tooltip: 'Library',
          selected: _tabController.index == 1 && _selectedLibraryFolder == 'library',
          primaryColor: primaryColor,
          onTap: () => _openLibraryFolder('library'),
        ),
        _buildCollapsedSidebarButton(
          icon: FontAwesomeIcons.gamepad,
          tooltip: 'Games',
          selected: _tabController.index == 2,
          primaryColor: primaryColor,
          onTap: () => _selectTab(2),
        ),
        _buildCollapsedSidebarButton(
          icon: FontAwesomeIcons.film,
          tooltip: 'Movies',
          selected: _tabController.index == 3,
          primaryColor: primaryColor,
          onTap: () => _selectTab(3),
        ),
        _buildCollapsedSidebarButton(
          icon: FontAwesomeIcons.tv,
          tooltip: 'Series',
          selected: _tabController.index == 4,
          primaryColor: primaryColor,
          onTap: () => _selectTab(4),
        ),
        _buildCollapsedSidebarButton(
          icon: FontAwesomeIcons.dragon,
          tooltip: 'Anime',
          selected: _tabController.index == 5,
          primaryColor: primaryColor,
          onTap: () => _selectTab(5),
        ),
        const SizedBox(height: 16),
        _buildCollapsedSidebarButton(
          icon: FontAwesomeIcons.star,
          tooltip: 'Favorites',
          selected:
              _tabController.index == 1 && _selectedLibraryFolder == 'favorites',
          primaryColor: primaryColor,
          onTap: () => _openLibraryFolder('favorites'),
        ),
        _buildCollapsedSidebarButton(
          icon: FontAwesomeIcons.circleCheck,
          tooltip: 'Completed',
          selected:
              _tabController.index == 1 && _selectedLibraryFolder == 'completed',
          primaryColor: primaryColor,
          onTap: () => _openLibraryFolder('completed'),
        ),
        _buildCollapsedSidebarButton(
          icon: FontAwesomeIcons.clock,
          tooltip: 'Backlog',
          selected:
              _tabController.index == 1 && _selectedLibraryFolder == 'backlog',
          primaryColor: primaryColor,
          onTap: () => _openLibraryFolder('backlog'),
        ),
        ...libraryProvider.customFolders.take(3).map((folder) {
          return _buildCollapsedSidebarButton(
            icon: FontAwesomeIcons.folderOpen,
            tooltip: folder,
            selected:
                _tabController.index == 1 && _selectedLibraryFolder == folder,
            primaryColor: primaryColor,
            onTap: () => _openLibraryFolder(folder),
          );
        }),
      ],
    );
  }

  Map<String, int> _buildFolderCounts(Map<String, dynamic> libraryMap) {
    final counts = <String, int>{
      'library': libraryMap.length,
      'favorites': 0,
      'completed': 0,
      'backlog': 0,
    };

    for (final entry in libraryMap.entries) {
      final raw = entry.value;
      if (raw is! Map) continue;
      final folder = raw['folder']?.toString() ?? 'library';
      counts[folder] = (counts[folder] ?? 0) + 1;
    }

    return counts;
  }

  Widget _buildSidebarNavItem({
    required IconData icon,
    required String label,
    required bool selected,
    required Color primaryColor,
    required VoidCallback onTap,
    int? badge,
  }) {
    final accentColor =
        selected ? primaryColor.withValues(alpha: 0.18) : Colors.transparent;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      child: _SidebarNavButton(
        icon: icon,
        label: label,
        selected: selected,
        primaryColor: primaryColor,
        badge: badge,
        badgeBackground: accentColor,
        onTap: onTap,
      ),
    );
  }

  Widget _buildCollapsedSidebarButton({
    required IconData icon,
    required String tooltip,
    required bool selected,
    required Color primaryColor,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Tooltip(
        message: tooltip,
        child: _CollapsedSidebarNavButton(
          icon: icon,
          selected: selected,
          primaryColor: primaryColor,
          onTap: onTap,
        ),
      ),
    );
  }

  Widget _buildFriendsPanel(BuildContext context) {
    final primaryColor = Color(Provider.of<ThemeProvider>(context).color);
    return Container(
      key: const ValueKey('friends'),
      width: UIConstants.rightSidebarWidth,
      padding: const EdgeInsets.all(16),
      color: const Color(0xFF0F0F0F), // Darker background
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "SOCIAL",
            style: GoogleFonts.inter(
              color: Colors.white54,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          _buildRightPanelItem(
            icon: Icons.circle,
            iconColor: Colors.green,
            title: "Online Friends",
            subtitle: "3 friends online",
            primaryColor: primaryColor,
          ),
          // More friends...
        ],
      ),
    );
  }

  Widget _buildTimelinePanel(BuildContext context) {
    final primaryColor = Color(Provider.of<ThemeProvider>(context).color);
    return Container(
      key: const ValueKey('timeline'),
      width: UIConstants.rightSidebarWidth,
      padding: const EdgeInsets.all(16),
      color: const Color(0xFF121212),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "ACTIVITY",
            style: GoogleFonts.inter(
              color: Colors.white54,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          _buildRightPanelItem(
            icon: FontAwesomeIcons.gamepad,
            iconColor: Colors.blueAccent,
            title: "Playing GTA V",
            subtitle: "User123 • 2h ago",
            primaryColor: primaryColor,
          ),
          _buildRightPanelItem(
            icon: FontAwesomeIcons.film,
            iconColor: Colors.redAccent,
            title: "Watched Inception",
            subtitle: "User456 • 5h ago",
            primaryColor: primaryColor,
          ),
        ],
      ),
    );
  }

  Widget _buildRightPanelItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required Color primaryColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 16),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                subtitle,
                style: GoogleFonts.inter(
                  color: Colors.white54,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarProfile(BuildContext context, String? imageURL,
      Color primaryColor, String? username, int totalContentCount) {
    String rank = _getRank(totalContentCount);

    return _HoverableSidebarItem(
      onTap: () {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const ProfilePage()));
      },
      primaryColor: primaryColor,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: Color(primaryColor.value).withValues(alpha: 1),
              width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                    color: Colors.white.withValues(alpha: 0.2), width: 1.5),
              ),
              child: CircleAvatar(
                radius: 22,
                backgroundColor: const Color(0xFF252525),
                backgroundImage: imageURL != null
                    ? CachedNetworkImageProvider(imageURL)
                    : null,
                child: imageURL == null
                    ? const Icon(Icons.person, color: Colors.white70, size: 24)
                    : null,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    username ?? 'Kullanıcı',
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    rank,
                    style: GoogleFonts.inter(
                      color: Colors.white54,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getRank(int count) {
    const ranks = [
      "Yeni Yetme",
      "Çırak",
      "Meraklı",
      "İzleyici",
      "Oyuncu",
      "Koleksiyoncu",
      "Arşivci",
      "Sinefil",
      "Kitap Kurdu",
      "Kültür Elçisi",
      "Seçkin",
      "Üstad",
      "Efsane",
      "Mitik",
      "Ölümsüz",
      "Medya Gurusu",
      "Evrensel Hafıza",
      "Kütüphane Gardiyanı",
      "Bilge",
      "Vizyoner",
      "Omni-God"
    ];

    // Her rank için gereken içerik sayısı (Örn: her 25 içerikte bir rank atla)
    // 0-24: Yeni Yetme, 25-49: Çırak, ...
    int index = (count / 25).floor();
    if (index >= ranks.length) {
      return ranks.last;
    }
    return ranks[index];
  }
}

class _HoverableSidebarItem extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  final Color primaryColor;

  const _HoverableSidebarItem({
    required this.child,
    required this.onTap,
    required this.primaryColor,
  });

  @override
  State<_HoverableSidebarItem> createState() => _HoverableSidebarItemState();
}

class _HoverableSidebarItemState extends State<_HoverableSidebarItem> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    // build metodunun içindeki return kısmını şöyle güncelle:
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: _isHovering
                ? Colors.white.withValues(alpha: 0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(5),
            // Taşan border ve shadow'u şimdilik kaldırıp dene, gerekirse aşağıdakini yap
          ),
          child: widget.child,
        ),
      ),
    );
  }
}

class _SidebarNavButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final Color primaryColor;
  final int? badge;
  final Color badgeBackground;
  final VoidCallback onTap;

  const _SidebarNavButton({
    required this.icon,
    required this.label,
    required this.selected,
    required this.primaryColor,
    required this.badge,
    required this.badgeBackground,
    required this.onTap,
  });

  @override
  State<_SidebarNavButton> createState() => _SidebarNavButtonState();
}

class _SidebarNavButtonState extends State<_SidebarNavButton> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          transform: Matrix4.translationValues(_isHovering ? 4 : 0, 0, 0),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: widget.selected
                ? widget.primaryColor.withValues(alpha: 0.14)
                : _isHovering
                    ? Colors.white.withValues(alpha: 0.05)
                    : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Icon(
                widget.icon,
                size: 17,
                color: widget.selected ? widget.primaryColor : Colors.white60,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  widget.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    color: widget.selected ? Colors.white : Colors.white70,
                    fontSize: 13,
                    fontWeight:
                        widget.selected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ),
              if (widget.badge != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: widget.badgeBackground,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '${widget.badge}',
                    style: GoogleFonts.inter(
                      color:
                          widget.selected ? widget.primaryColor : Colors.white54,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CollapsedSidebarNavButton extends StatefulWidget {
  final IconData icon;
  final bool selected;
  final Color primaryColor;
  final VoidCallback onTap;

  const _CollapsedSidebarNavButton({
    required this.icon,
    required this.selected,
    required this.primaryColor,
    required this.onTap,
  });

  @override
  State<_CollapsedSidebarNavButton> createState() =>
      _CollapsedSidebarNavButtonState();
}

class _CollapsedSidebarNavButtonState extends State<_CollapsedSidebarNavButton> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          transform: Matrix4.translationValues(_isHovering ? 2 : 0, 0, 0),
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: widget.selected
                ? widget.primaryColor.withValues(alpha: 0.14)
                : _isHovering
                    ? Colors.white.withValues(alpha: 0.05)
                    : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            widget.icon,
            size: 17,
            color: widget.selected ? widget.primaryColor : Colors.white60,
          ),
        ),
      ),
    );
  }
}

class _ActionSquareButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color primaryColor;

  const _ActionSquareButton({
    required this.icon,
    required this.onTap,
    required this.primaryColor,
  });

  @override
  State<_ActionSquareButton> createState() => _ActionSquareButtonState();
}

class _ActionSquareButtonState extends State<_ActionSquareButton> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: _isHovering ? widget.primaryColor : const Color(0xFF2A2A2A),
            borderRadius: BorderRadius.circular(8),
            boxShadow: _isHovering
                ? [
                    BoxShadow(
                      color: widget.primaryColor.withValues(alpha: 0.6),
                      blurRadius: 12,
                      spreadRadius: 2,
                    )
                  ]
                : [],
            border: Border.all(
              color: _isHovering
                  ? widget.primaryColor
                  : Colors.white.withValues(alpha: 0.1),
            ),
          ),
          child: Icon(
            widget.icon,
            color: _isHovering ? Colors.white : Colors.white70,
            size: 20,
          ),
        ),
      ),
    );
  }
}

class _ModernTabItem extends StatefulWidget {
  final String label;
  final int index;
  final TabController controller;
  final Color primaryColor;

  const _ModernTabItem({
    required this.label,
    required this.index,
    required this.controller,
    required this.primaryColor,
  });

  @override
  State<_ModernTabItem> createState() => _ModernTabItemState();
}

class _ModernTabItemState extends State<_ModernTabItem> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_update);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_update);
    super.dispose();
  }

  void _update() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final isSelected = widget.controller.index == widget.index;
    return GestureDetector(
      onTap: () {
        // We handle navigation via PageView controller now if accessible,
        // or just animate tab controller which might not sync perfectly without PageView access.
        // Better approach: Find the HomePage State or pass a callback.
        // For now, let's keep simple TabController animation,
        // BUT HomePage PageView should listen to TabController changes?
        // No, we removed that listener to avoid loops.
        // So we need to ensure tapping this updates the PageView.
        // Since we don't have access to _pageController here easily without passing it down,
        // let's rely on TabController.animateTo triggering a listener in HomePage if we re-add it carefully,
        // OR pass a callback.
        widget.controller.animateTo(widget.index);
        // We need to signal HomePage to animate PageView.
        // Re-adding the listener in HomePage with a check is the standard way.
        // Let's modify HomePage initState again to handle this direction: Tab -> PageView.
      },
      child: AnimatedScale(
        scale: isSelected ? 1.05 : 1.0,
        duration: const Duration(milliseconds: 200),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.label,
              style: GoogleFonts.inter(
                color: isSelected ? Colors.white : Colors.white54,
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                shadows: isSelected
                    ? [
                        Shadow(
                          color: widget.primaryColor.withValues(alpha: 0.6),
                          blurRadius: 8,
                        )
                      ]
                    : [],
              ),
            ),
            const SizedBox(height: 4),
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              height: 2,
              width: isSelected ? 20 : 0,
              decoration: BoxDecoration(
                color: widget.primaryColor,
                borderRadius: BorderRadius.circular(2),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: widget.primaryColor.withValues(alpha: 0.8),
                          blurRadius: 6,
                          spreadRadius: 1,
                        )
                      ]
                    : [],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DiscoverItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color primaryColor;

  const _DiscoverItem({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.primaryColor,
  });

  @override
  State<_DiscoverItem> createState() => _DiscoverItemState();
}

class _DiscoverItemState extends State<_DiscoverItem> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: _isHovering
                ? Colors.white.withValues(alpha: 0.05)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                widget.icon,
                color: _isHovering ? widget.primaryColor : Colors.white54,
                size: 18,
              ),
              const SizedBox(width: 16),
              Text(
                widget.label,
                style: GoogleFonts.inter(
                  color: _isHovering ? Colors.white : Colors.white70,
                  fontSize: 14,
                  fontWeight: _isHovering ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
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

Future<String> getAppVersion() async {
  PackageInfo packageInfo = await PackageInfo.fromPlatform();
  return packageInfo.version;
}

class _HeroCardData {
  final String title;
  final String subtitle;
  final String? imageUrl;
  final Widget Function()? onOpen;

  _HeroCardData({
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.onOpen,
  });
}

class _HeroCard extends StatelessWidget {
  final Color primaryColor;
  final String title;
  final String subtitle;
  final String? imageUrl;
  final Widget Function()? onOpen;

  const _HeroCard({
    required this.primaryColor,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onOpen == null
          ? null
          : () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => onOpen!()),
              );
            },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          color: Colors.white.withValues(alpha: 0.04),
          image: imageUrl == null
              ? null
              : DecorationImage(
                  image: CachedNetworkImageProvider(imageUrl!),
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                ),
        ),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              colors: [
                const Color(0xFF121212).withValues(alpha: 0.10),
                const Color(0xFF121212).withValues(alpha: 0.90),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(12),
                  border:
                      Border.all(color: primaryColor.withValues(alpha: 0.35)),
                ),
                child: Text(
                  subtitle.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: primaryColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(
                    onOpen == null ? Icons.add : Icons.play_arrow,
                    color: Colors.white.withValues(alpha: 0.8),
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    onOpen == null ? "Add to Backlog" : "Open",
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.75),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
