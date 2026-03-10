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
import 'package:vault/UI/Views/home_view.dart';
import 'package:vault/UI/Desktop/User/profile_page.dart';
import 'package:vault/UI/Desktop/Games/games_page.dart';
import 'package:vault/UI/Desktop/Library/library_page.dart';
import 'package:vault/UI/Desktop/Movies/movies_page.dart';
import 'package:vault/UI/Desktop/Series/series_page.dart';
import 'package:vault/UI/Desktop/User/settings_page.dart';
import 'package:vault/UI/Desktop/Animes/animes_page.dart';
import 'package:vault/Widgets/circularprogressindicator.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:updat/updat.dart';
import 'package:http/http.dart' as http;
import 'package:vault/Providers/library_provider.dart';
import 'package:vault/Logic/animepage_logic.dart';
import 'package:vault/Logic/gamepage_logic.dart';
import 'package:vault/Logic/moviepage_logic.dart';
import 'package:vault/UI/Desktop/Details/anime_detail_page.dart';
import 'package:vault/UI/Desktop/Details/game_detail_page.dart';
import 'package:vault/UI/Desktop/Details/movie_detail_page.dart';
import 'package:vault/UI/Desktop/Details/serie_detail_page.dart';

class LayoutScaffold extends StatefulWidget {
  const LayoutScaffold({super.key});

  @override
  State<LayoutScaffold> createState() => _LayoutScaffoldState();
}

class _LayoutScaffoldState extends State<LayoutScaffold>
    with SingleTickerProviderStateMixin {
  User? user = FirebaseAuth.instance.currentUser;
  final _firestore = FirebaseFirestore.instance;

  late TabController _tabController;
  final PageController _pageController = PageController(initialPage: 0);
  GlobalKey key = GlobalKey();

  final LayerLink _searchLayerLink = LayerLink();
  OverlayEntry? _searchOverlay;
  final FocusNode _searchFocusNode = FocusNode();

  bool _isLeftOpen = true;
  bool _isRightOpen = true;
  String _activeRightPanel = 'timeline';

  late Stream<DocumentSnapshot> _userStream;
  late Future<_HeroCardData?> _exploreHeroFuture;
  String? _backlogHeroKey;

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

    CollectionReference data = _firestore.collection('users');
    _userStream = data.doc(user!.uid).snapshots();
    _exploreHeroFuture = _fetchExploreHero();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Future<_HeroCardData?> _fetchExploreHero() async {
    Future<_HeroCardData?> tryAnime() async {
      try {
        final items = await AnimePageLogic().getTopAnimes(limit: 20);
        if (items.isEmpty) return null;
        final pick =
            items[DateTime.now().millisecondsSinceEpoch % items.length];
        if (pick.id == null) return null;
        return _HeroCardData(
          title: pick.title ?? 'Anime',
          subtitle: 'Trending Anime',
          imageUrl: pick.imageURL,
          onOpen: () => AnimeDetailPage(animeId: pick.id!),
        );
      } catch (_) {
        return null;
      }
    }

    Future<_HeroCardData?> tryGame() async {
      try {
        final items =
            await GamePageLogic().getPopularGameList('popularRightNow');
        if (items.isEmpty) return null;
        final pick =
            items[DateTime.now().millisecondsSinceEpoch % items.length];
        if (pick.id == null) return null;
        return _HeroCardData(
          title: pick.name ?? 'Game',
          subtitle: 'Trending Game',
          imageUrl: pick.imageURL,
          onOpen: () => GameDetailPage(gameID: pick.id!),
        );
      } catch (_) {
        return null;
      }
    }

    Future<_HeroCardData?> tryMovie() async {
      try {
        final items = await MoviePageLogic().getPopularMovies();
        if (items.isEmpty) return null;
        final pick =
            items[DateTime.now().millisecondsSinceEpoch % items.length];
        if (pick.id == null) return null;
        return _HeroCardData(
          title: pick.title ?? 'Movie',
          subtitle: 'Trending Movie',
          imageUrl: pick.imageURL,
          onOpen: () => MovieDetailPage(movieID: pick.id!),
        );
      } catch (_) {
        return null;
      }
    }

    final options = <Future<_HeroCardData?> Function()>[
      tryAnime,
      tryGame,
      tryMovie,
    ];
    options.shuffle(Random(DateTime.now().millisecondsSinceEpoch));

    for (final fn in options) {
      final result = await fn();
      if (result != null) return result;
    }
    return null;
  }

  _HeroCardData? _pickBacklogHero(LibraryProvider provider) {
    final entries = provider.libraryMap.entries.where((e) {
      final raw = e.value;
      if (raw is! Map) return false;
      final m = Map<String, dynamic>.from(raw);
      return (m['folder']?.toString() ?? 'library') == 'backlog';
    }).toList();

    if (entries.isEmpty) return null;

    _backlogHeroKey ??=
        entries[DateTime.now().millisecondsSinceEpoch % entries.length]
            .key
            .toString();
    final chosen = entries.firstWhere(
      (e) => e.key.toString() == _backlogHeroKey,
      orElse: () => entries.first,
    );

    final raw = chosen.value;
    if (raw is! Map) return null;
    final m = Map<String, dynamic>.from(raw);
    final title = (m['title'] ?? 'Backlog').toString();
    final imageUrl = m['imageURL']?.toString();
    final id = m['id'];

    Widget Function()? onOpen;
    final prefix = chosen.key.toString().split('_').first;
    if (id is int) {
      switch (prefix) {
        case 'game':
          onOpen = () => GameDetailPage(gameID: id);
          break;
        case 'movie':
          onOpen = () => MovieDetailPage(movieID: id);
          break;
        case 'serie':
          onOpen = () => SerieDetailPage(serieID: id);
          break;
        case 'anime':
          onOpen = () => AnimeDetailPage(animeId: id);
          break;
      }
    }

    return _HeroCardData(
      title: title,
      subtitle: 'From Backlog',
      imageUrl: imageUrl,
      onOpen: onOpen,
    );
  }

  Widget _buildDoubleHero(Color primaryColor) {
    return Consumer<LibraryProvider>(
      builder: (context, libraryProvider, child) {
        final left = _pickBacklogHero(libraryProvider) ??
            _HeroCardData(
              title: 'Backlog boş',
              subtitle: 'İçerik ekleyerek backlog vitrini oluştur.',
              imageUrl: null,
              onOpen: null,
            );

        return Row(
          children: [
            Expanded(
              child: _HeroCard(
                primaryColor: primaryColor,
                title: left.title,
                subtitle: left.subtitle,
                imageUrl: left.imageUrl,
                onOpen: left.onOpen,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FutureBuilder<_HeroCardData?>(
                future: _exploreHeroFuture,
                builder: (context, snapshot) {
                  final right = snapshot.data ??
                      _HeroCardData(
                        title: "Vault'u Keşfet",
                        subtitle: 'Global Trends',
                        imageUrl: null,
                        onOpen: null,
                      );
                  return Skeletonizer(
                    enabled: snapshot.connectionState != ConnectionState.done,
                    child: _HeroCard(
                      primaryColor: primaryColor,
                      title: right.title,
                      subtitle: right.subtitle,
                      imageUrl: right.imageUrl,
                      onOpen: right.onOpen,
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

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

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        StreamBuilder<DocumentSnapshot>(
            stream: _userStream,
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(
                    child: CustomCPI(),
                  ),
                );
              }

              if (snapshot.hasError ||
                  !snapshot.hasData ||
                  snapshot.data == null ||
                  !snapshot.data!.exists) {
                // If no data, potentially first login or error.
                // Handle gracefully, maybe just show empty UI or redirect.
                // For now, let's assume we can show the scaffold with empty values.
              }

              var snapshotData = snapshot.data?.data() as Map<String, dynamic>?;
              var imageURL = snapshotData?['imageURL'];
              int totalContentCount = 0;
              if (snapshotData != null && snapshotData['library'] != null) {
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
                      // Left Section: Logo, Toggle, Nav
                      Text(
                        "VAULT",
                        style: GoogleFonts.orbitron(
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 6,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 48),
                      _buildTopNavigation(_tabController, context),

                      const Spacer(),

                      // Center Section: Search Bar
                      CompositedTransformTarget(
                        link: _searchLayerLink,
                        child: SizedBox(
                          width: 400,
                          height: 44,
                          child: TextField(
                            focusNode: _searchFocusNode,
                            style: GoogleFonts.inter(
                                color: Colors.white, fontSize: 14),
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
                                borderSide: BorderSide(
                                    color: Theme.of(context).primaryColor,
                                    width: 1),
                              ),
                            ),
                          ),
                        ),
                      ),

                      const Spacer(),

                      // Right Section: Actions
                      Row(
                        children: [
                          // Action Square (+)
                          _ActionSquareButton(
                            icon: Icons.add,
                            onTap: () {},
                            primaryColor: Theme.of(context).primaryColor,
                          ),
                          const SizedBox(width: 16),

                          // Settings Group
                          _ActionSquareButton(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const SettingsPage()));
                            },
                            icon: FontAwesomeIcons.sliders,
                            primaryColor: Theme.of(context).primaryColor,
                          ),
                          const SizedBox(width: 8),
                          _ActionSquareButton(
                            onTap: () async {
                              final provider = Provider.of<LibraryProvider>(
                                  context,
                                  listen: false);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content:
                                        Text("Syncing library to cloud..."),
                                    duration: Duration(seconds: 1)),
                              );
                              await provider.syncToFirebase();
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content:
                                          Text("Sync completed successfully!")),
                                );
                              }
                            },
                            icon: FontAwesomeIcons.cloudArrowUp,
                            primaryColor: Theme.of(context).primaryColor,
                          ),

                          // Vertical Divider
                          Container(
                            height: 24,
                            width: 1,
                            margin: const EdgeInsets.symmetric(horizontal: 16),
                            color: Colors.white.withValues(alpha: 0.1),
                          ),

                          // Right Panel Toggles
                          _ActionSquareButton(
                            onTap: () {
                              setState(() {
                                if (_activeRightPanel == 'timeline' &&
                                    _isRightOpen) {
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
                                if (_activeRightPanel == 'friends' &&
                                    _isRightOpen) {
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
                    // Left Panel (Navigation/Discover)
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
                                ? _buildDiscoverSidebar(context)
                                : _buildCollapsedSidebar(context),
                          ),
                          if (_isLeftOpen) ...[
                            const Spacer(),
                            _buildSidebarProfile(
                                context,
                                imageURL,
                                Theme.of(context).primaryColor,
                                snapshotData?['username'],
                                totalContentCount),
                            const SizedBox(height: 16),
                          ] else ...[
                            const Spacer(),
                            // Collapsed profile icon
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

                    // Main Content
                    Expanded(
                      child: LayoutBuilder(builder: (context, constraints) {
                        return Container(
                          width: constraints.maxWidth,
                          margin: const EdgeInsets.only(top: 4, bottom: 16),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.1),
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: IndexedStack(
                              index: _tabController.index,
                              children: [
                                const HomeView(),
                                const LibraryPage(),
                                _buildPageWithHero(const GamesPage()),
                                _buildPageWithHero(const MoviesPage()),
                                _buildPageWithHero(const SeriesPage()),
                                _buildPageWithHero(const AnimesPage()),
                              ],
                            ),
                          ),
                        );
                      }),
                    ),

                    // Right Panel (Social/Timeline)
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
            }),
        FutureBuilder(
            future: getAppVersion(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                String appVersion = "${snapshot.data}";
                return Positioned(
                  bottom: 10,
                  right: 10,
                  child: UpdatWidget(
                    closeOnInstall: true,
                    openOnDownload: false,
                    currentVersion: appVersion,
                    getLatestVersion: () async {
                      final data = await http.get(Uri.parse(
                        "https://api.github.com/repos/BioKZM/GNML/releases/latest",
                      ));
                      return jsonDecode(data.body)["tag_name"];
                    },
                    getBinaryUrl: (latestVersion) async {
                      return "https://github.com/BioKZM/GNML/releases/download/$latestVersion/GNML.exe";
                    },
                    appName: "GNML - Game and Movie Library",
                  ),
                );
              } else {
                return const Positioned(
                  bottom: 10,
                  left: 10,
                  child: Card(child: CustomCPI()),
                );
              }
            })
      ],
    );
  }

  Widget _buildPageWithHero(Widget child) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: SizedBox(
            height: 180,
            child: _buildDoubleHero(Theme.of(context).primaryColor),
          ),
        ),
        Expanded(child: child),
      ],
    );
  }

  Widget _buildTopNavigation(
      TabController tabController, BuildContext context) {
    final primaryColor = Color(Provider.of<ThemeProvider>(context).color);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _ModernTabItem(
          label: "Home",
          index: 0,
          controller: tabController,
          primaryColor: primaryColor,
        ),
        const SizedBox(width: 24),
        _ModernTabItem(
          label: "Library",
          index: 1,
          controller: tabController,
          primaryColor: primaryColor,
        ),
        const SizedBox(width: 24),
        _ModernTabItem(
          label: "Games",
          index: 2,
          controller: tabController,
          primaryColor: primaryColor,
        ),
        const SizedBox(width: 24),
        _ModernTabItem(
          label: "Movies",
          index: 3,
          controller: tabController,
          primaryColor: primaryColor,
        ),
        const SizedBox(width: 24),
        _ModernTabItem(
          label: "Series",
          index: 4,
          controller: tabController,
          primaryColor: primaryColor,
        ),
        const SizedBox(width: 24),
        _ModernTabItem(
          label: "Animes",
          index: 5,
          controller: tabController,
          primaryColor: primaryColor,
        ),
      ],
    );
  }

  Widget _buildDiscoverSidebar(BuildContext context) {
    final primaryColor = Color(Provider.of<ThemeProvider>(context).color);
    int currentPage = _tabController.index;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Row(
            children: [
              SizedBox(
                width: 24,
                height: 24,
                child: IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () {
                    setState(() {
                      _isLeftOpen = !_isLeftOpen;
                    });
                  },
                  icon: const Icon(Icons.menu, color: Colors.white70, size: 20),
                ),
              ),
            ],
          ),
        ),

        // Home View (Index 0)
        if (currentPage == 0) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(56, 8, 16, 12),
            child: Text(
              "QUICK ACCESS",
              style: GoogleFonts.inter(
                color: Colors.white54,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ),
          _DiscoverItem(
            icon: FontAwesomeIcons.fire,
            label: "Trending Now",
            onTap: () {},
            primaryColor: primaryColor,
          ),
          _DiscoverItem(
            icon: FontAwesomeIcons.bolt,
            label: "Quick Links",
            onTap: () {},
            primaryColor: primaryColor,
          ),
          _DiscoverItem(
            icon: FontAwesomeIcons.clockRotateLeft,
            label: "Recent Activity",
            onTap: () {},
            primaryColor: primaryColor,
          ),
        ] else if (currentPage == 1) ...[
          // Library (Index 1)
          Padding(
            padding: const EdgeInsets.fromLTRB(56, 8, 16, 12),
            child: Text(
              "LIBRARY",
              style: GoogleFonts.inter(
                color: Colors.white54,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ),
          _buildExpandableFolder("My Favorites", primaryColor,
              ["Game 1", "Movie A"], FontAwesomeIcons.star),
          _buildExpandableFolder("Completed", primaryColor, ["Game 2"],
              FontAwesomeIcons.circleCheck),
          _buildExpandableFolder("Backlog", primaryColor,
              ["Game 3", "Series X"], FontAwesomeIcons.clock),
        ] else if (currentPage == 2) ...[
          // Games (Index 2)
          Padding(
            padding: const EdgeInsets.fromLTRB(56, 8, 16, 12),
            child: Text(
              "DISCOVER GAMES",
              style: GoogleFonts.inter(
                color: Colors.white54,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ),
          _DiscoverItem(
            icon: FontAwesomeIcons.fire,
            label: "Hot",
            onTap: () {},
            primaryColor: primaryColor,
          ),
          _DiscoverItem(
            icon: FontAwesomeIcons.calendar,
            label: "Upcoming",
            onTap: () {},
            primaryColor: primaryColor,
          ),
          _DiscoverItem(
            icon: FontAwesomeIcons.star,
            label: "New Releases",
            onTap: () {},
            primaryColor: primaryColor,
          ),
        ] else ...[
          // Default Discover (Movies, Series, Animes)
          Padding(
            padding: const EdgeInsets.fromLTRB(56, 8, 16, 12),
            child: Text(
              "DISCOVER",
              style: GoogleFonts.inter(
                color: Colors.white54,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ),
          _DiscoverItem(
            icon: FontAwesomeIcons.fire,
            label: "Hot",
            onTap: () {},
            primaryColor: primaryColor,
          ),
          _DiscoverItem(
            icon: FontAwesomeIcons.towerBroadcast,
            label: "On Aired",
            onTap: () {},
            primaryColor: primaryColor,
          ),
          _DiscoverItem(
            icon: FontAwesomeIcons.calendar,
            label: "Upcoming",
            onTap: () {},
            primaryColor: primaryColor,
          ),
        ]
      ],
    );
  }

  Widget _buildExpandableFolder(
      String title, Color primaryColor, List<String> items, IconData icon) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16),
        leading: SizedBox(
          width: 24,
          height: 24,
          child: Center(
            child: Icon(icon, color: primaryColor, size: 18),
          ),
        ),
        title: Text(
          title,
          style: GoogleFonts.inter(
            color: Colors.white70,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        children: items
            .map((item) => ListTile(
                  contentPadding: const EdgeInsets.only(left: 56, right: 16),
                  visualDensity: VisualDensity.compact,
                  title: Text(
                    item,
                    style: GoogleFonts.inter(
                      color: Colors.white54,
                      fontSize: 13,
                    ),
                  ),
                  onTap: () {},
                  dense: true,
                ))
            .toList(),
      ),
    );
  }

  Widget _buildCollapsedSidebar(BuildContext context) {
    final primaryColor = Color(Provider.of<ThemeProvider>(context).color);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: IconButton(
            onPressed: () {
              setState(() {
                _isLeftOpen = !_isLeftOpen;
              });
            },
            icon: const Icon(FluentIcons.navigation_24_regular,
                color: Colors.white70),
          ),
        ),
        const SizedBox(height: 8),
        IconButton(
          icon: Icon(FontAwesomeIcons.fire, color: primaryColor),
          tooltip: "Hot",
          onPressed: () {},
        ),
        const SizedBox(height: 16),
        IconButton(
          icon: Icon(FontAwesomeIcons.towerBroadcast, color: primaryColor),
          tooltip: "On Aired",
          onPressed: () {},
        ),
        const SizedBox(height: 16),
        IconButton(
          icon: Icon(FontAwesomeIcons.calendar, color: primaryColor),
          tooltip: "Upcoming",
          onPressed: () {},
        ),
      ],
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
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                    color: primaryColor.withValues(alpha: 0.4), width: 1.5),
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
            borderRadius: BorderRadius.circular(12),
            boxShadow: _isHovering
                ? [
                    BoxShadow(
                      color: widget.primaryColor.withValues(alpha: 0.1),
                      blurRadius: 12,
                      spreadRadius: 0,
                    )
                  ]
                : [],
            border: Border.all(
              color: _isHovering
                  ? widget.primaryColor.withValues(alpha: 0.2)
                  : Colors.transparent,
            ),
          ),
          child: BackdropFilter(
            filter: ImageFilter.blur(
                sigmaX: _isHovering ? 4.0 : 0.0,
                sigmaY: _isHovering ? 4.0 : 0.0),
            child: widget.child,
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
