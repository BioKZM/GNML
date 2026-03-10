import 'dart:async';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vault/Data/Model/anime_model.dart';
import 'package:vault/Data/Model/game_model.dart';
import 'package:vault/Data/Model/library_item_model.dart';
import 'package:vault/Data/Model/movie_model.dart';
import 'package:vault/Data/Model/user_library.dart';
import 'package:vault/Helper/rating_helper.dart';
import 'package:vault/Helper/theme_helper.dart';
import 'package:vault/Logic/animepage_logic.dart';
import 'package:vault/Logic/gamepage_logic.dart';
import 'package:vault/Logic/moviepage_logic.dart';
import 'package:vault/UI/Desktop/Details/actors_detail_page.dart';
import 'package:vault/UI/Desktop/Details/books_detail_page.dart';
import 'package:vault/UI/Desktop/Details/anime_detail_page.dart';
import 'package:vault/UI/Desktop/Details/game_detail_page.dart';
import 'package:vault/UI/Desktop/Details/movie_detail_page.dart';
import 'package:vault/UI/Desktop/Details/serie_detail_page.dart';
import 'package:vault/Widgets/generic_content_card.dart';
import 'package:provider/provider.dart';
import 'package:vault/Providers/library_provider.dart';
import 'package:skeletonizer/skeletonizer.dart';

import 'package:hive/hive.dart';

enum Sort { atoz, ztoa }

class LibraryPage extends StatefulWidget {
  const LibraryPage({super.key});

  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage>
    with AutomaticKeepAliveClientMixin {
  Sort buttonSort = Sort.atoz;
  ContentType? filterType;
  bool isGroupedView = true;
  String folderView = 'library';
  final PageController _heroPageController = PageController();
  int _currentHeroIndex = 0;
  Timer? _heroTimer;
  List<_FlatLibraryItem>? _cachedHeroItems;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    // Start timer for hero slideshow
    _startHeroTimer();
  }

  Future<void> _updateDetailsForHeroItem(_FlatLibraryItem flatItem) async {
    final detailsProvider =
        Provider.of<LibraryProvider>(context, listen: false);
    final item = LibraryItemModel(
      id: flatItem.raw['id'],
      title: flatItem.raw['title']?.toString(),
      imageURL: flatItem.raw['imageURL']?.toString(),
    );

    detailsProvider.setDetails(
      title: item.title ?? 'DETAILS',
      description: '',
      scoreText: '-',
      dateText: '-',
      imageUrl: item.imageURL,
      genreText: '-',
    );

    final description = await _getHeroDescription(item, flatItem.type);
    if (!mounted) return;
    detailsProvider.setDetails(description: description);

    final box = Hive.box('content_cache');
    final id = item.id?.toString() ?? '';
    if (id.isEmpty) return;

    if (flatItem.type == ContentType.anime) {
      final cached = box.get('anime_details_$id');
      if (cached is AnimeModel) {
        detailsProvider.setDetails(
          scoreText:
              cached.score != null ? cached.score!.toStringAsFixed(1) : '-',
          genreText: (cached.genres ?? const []).join(', '),
          dateText: cached.aired_string ?? '-',
        );
      }
    }

    if (flatItem.type == ContentType.games) {
      final cached = box.get('game_details_$id');
      if (cached is GameModel) {
        final score = RatingHelper.getScore(cached);
        final dateText = cached.first_release_date != null
            ? DateTime.fromMillisecondsSinceEpoch(
                    cached.first_release_date! * 1000)
                .year
                .toString()
            : '-';
        detailsProvider.setDetails(
          scoreText: score > 0 ? score.ceil().toString() : '-',
          dateText: dateText,
        );
      }
    }
  }

  void _startHeroTimer() {
    _heroTimer?.cancel();
    _heroTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_heroPageController.hasClients) {
        int nextPage = _currentHeroIndex + 1;
        // Assuming max 3 items as per our logic
        if (nextPage >= 3) nextPage = 0;

        _heroPageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _heroTimer?.cancel();
    _heroPageController.dispose();
    super.dispose();
  }

  Widget _buildLibrarySkeleton(Color primaryColor) {
    return Skeletonizer(
      enabled: true,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 400,
              child: Row(
                children: [
                  Expanded(
                    flex: 6,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        color: const Color(0xFF1E1E1E),
                        child: const Center(
                          child: Icon(Icons.image, color: Colors.white24),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    flex: 4,
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1A1A),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: Colors.white.withValues(alpha: 0.05)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Vault'u Keşfet",
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "Popüler içerikler yükleniyor...",
                            style: GoogleFonts.inter(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Container(
                            height: 44,
                            width: 160,
                            decoration: BoxDecoration(
                              color: primaryColor,
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: List.generate(
                10,
                (index) => Container(
                  width: 140,
                  height: 200,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E1E),
                    borderRadius: BorderRadius.circular(12),
                    border:
                        Border.all(color: Colors.white.withValues(alpha: 0.05)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    int themeColor = Provider.of<ThemeProvider>(context).color;
    final primaryColor = Color(themeColor);

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: Consumer<LibraryProvider>(
        builder: (context, libraryProvider, child) {
          if (libraryProvider.isLoading) {
            return _buildLibrarySkeleton(primaryColor);
          }

          if (libraryProvider.library == null) {
            return const Center(
                child: Text("Failed to load library",
                    style: TextStyle(color: Colors.white)));
          }

          final library = libraryProvider.library!;
          final allItems = _buildFlattenedItems(library);
          final visibleItems = _applyFilter(allItems);

          if (_cachedHeroItems == null && visibleItems.isNotEmpty) {
            final random = Random();
            final itemsCopy = List<_FlatLibraryItem>.from(visibleItems.where(
                (e) =>
                    e.type != ContentType.books &&
                    e.type != ContentType.actors));
            if (itemsCopy.isNotEmpty) {
              itemsCopy.shuffle(random);
              _cachedHeroItems = itemsCopy.take(3).toList();
            } else {
              _cachedHeroItems = [];
            }
          }
          final heroItems = _cachedHeroItems ?? [];
          if (heroItems.isNotEmpty && libraryProvider.detailsTitle == null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;
              _updateDetailsForHeroItem(heroItems[_currentHeroIndex]);
            });
          }

          return SingleChildScrollView(
            padding:
                const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                heroItems.isNotEmpty
                    ? _buildHeroSection(heroItems, primaryColor)
                    : _buildExploreHeroSection(primaryColor),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    // Row(
                    //   children: [
                    //     Text(
                    //       "Library",
                    //       style: GoogleFonts.orbitron(
                    //           fontWeight: FontWeight.bold,
                    //           fontSize: 32,
                    //           color: Colors.white),
                    //     ),
                    //   ],
                    // ),
                    Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            setState(() {
                              isGroupedView = !isGroupedView;
                            });
                          },
                          tooltip: isGroupedView
                              ? "Switch to Grid View"
                              : "Switch to Grouped View",
                          icon: Icon(
                            isGroupedView
                                ? FluentIcons.grid_24_regular
                                : FluentIcons.list_24_regular,
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Container(
                          height: 32,
                          width: 1,
                          color: Colors.white.withValues(alpha: 0.1),
                        ),
                        const SizedBox(width: 16),
                        _buildSortButton(themeColor),
                      ],
                    )
                  ],
                ),
                const SizedBox(height: 16),
                _buildFolderChips(libraryProvider, themeColor),
                const SizedBox(height: 24),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder:
                      (Widget child, Animation<double> animation) {
                    return FadeTransition(opacity: animation, child: child);
                  },
                  child: isGroupedView
                      ? _buildGroupedView(library, themeColor)
                      : _buildGridView(visibleItems, library, themeColor),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFolderChips(LibraryProvider libraryProvider, int themeColor) {
    final folders = <String>[
      'library',
      'favorites',
      'completed',
      'backlog',
      ...libraryProvider.customFolders,
    ];

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: folders.map((folder) {
        final selected = folderView == folder;
        return ChoiceChip(
          label: Text(folder),
          selected: selected,
          onSelected: (value) {
            if (!value) return;
            setState(() {
              folderView = folder;
              _cachedHeroItems = null;
              _currentHeroIndex = 0;
            });
          },
          selectedColor: Color(themeColor),
          backgroundColor: const Color(0xFF2A2A2A),
          labelStyle: TextStyle(
            color: selected ? Colors.white : Colors.white70,
            fontSize: 11,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
          ),
        );
      }).toList(),
    );
  }

  Future<String> _getHeroDescription(
      LibraryItemModel item, ContentType type) async {
    final box = Hive.box('content_cache');
    final cacheKey = '${type.name}_${item.id}_description';

    if (box.containsKey(cacheKey)) {
      return box.get(cacheKey) as String;
    }

    // If not in cache, return default or fetch (mocking fetch for now as we don't have direct API access here easily without refactor)
    // In a real scenario, you would call your API service here.
    // For now, we'll return a placeholder and save it to simulate the process.
    String description =
        "Explore this title in your library. Dive into the details and enjoy.";

    // Simulating fetching 'real' description if possible or just using a better default
    // If you have the description in the item model (e.g. from the list view), use it.
    // But often list items have truncated or no description.

    await box.put(cacheKey, description);
    return description;
  }

  Future<List<_ExploreSlide>> _fetchExploreSlides() async {
    Future<AnimeModel?> getAnime() async {
      try {
        final list = await AnimePageLogic().getTopAnimes(limit: 1);
        return list.isEmpty ? null : list.first;
      } catch (_) {
        return null;
      }
    }

    Future<GameModel?> getGame() async {
      try {
        final list =
            await GamePageLogic().getPopularGameList('popularRightNow');
        return list.isEmpty ? null : list.first;
      } catch (_) {
        return null;
      }
    }

    Future<MovieModel?> getMovie() async {
      try {
        final list = await MoviePageLogic().getPopularMovies();
        return list.isEmpty ? null : list.first;
      } catch (_) {
        return null;
      }
    }

    final results = await Future.wait<dynamic>([
      getAnime(),
      getGame(),
      getMovie(),
    ]);

    final anime = results[0] as AnimeModel?;
    final game = results[1] as GameModel?;
    final movie = results[2] as MovieModel?;

    return [
      _ExploreSlide(
        label: "Anime",
        title: anime?.title ?? "Top Anime",
        description: anime?.synopsis ?? "Yeni animeler keşfet.",
        imageUrl: anime?.imageURL,
        onOpen: anime?.id == null
            ? null
            : () => AnimeDetailPage(animeId: anime!.id!),
      ),
      _ExploreSlide(
        label: "Game",
        title: game?.name ?? "Popular Games",
        description: game?.summary ?? "Popüler oyunlara göz at.",
        imageUrl: game?.imageURL,
        onOpen:
            game?.id == null ? null : () => GameDetailPage(gameID: game!.id!),
      ),
      _ExploreSlide(
        label: "Movie",
        title: movie?.title ?? "Popular Movies",
        description: movie?.overview ?? "Popüler filmleri keşfet.",
        imageUrl: movie?.imageURL,
        onOpen: movie?.id == null
            ? null
            : () => MovieDetailPage(movieID: movie!.id!),
      ),
    ];
  }

  Widget _buildExploreHeroSection(Color primaryColor) {
    return SizedBox(
      height: 400,
      child: FutureBuilder<List<_ExploreSlide>>(
        future: _fetchExploreSlides(),
        builder: (context, snapshot) {
          final slides = snapshot.data ??
              [
                _ExploreSlide(
                  label: "Anime",
                  title: "Vault'u Keşfet",
                  description: "Popüler içerikler yükleniyor...",
                  imageUrl: null,
                  onOpen: null,
                ),
                _ExploreSlide(
                  label: "Game",
                  title: "Vault'u Keşfet",
                  description: "Popüler içerikler yükleniyor...",
                  imageUrl: null,
                  onOpen: null,
                ),
                _ExploreSlide(
                  label: "Movie",
                  title: "Vault'u Keşfet",
                  description: "Popüler içerikler yükleniyor...",
                  imageUrl: null,
                  onOpen: null,
                ),
              ];

          return Skeletonizer(
            enabled: snapshot.connectionState != ConnectionState.done,
            child: Row(
              children: [
                Expanded(
                  flex: 6,
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Stack(
                      children: [
                        PageView.builder(
                          controller: _heroPageController,
                          onPageChanged: (index) {
                            setState(() {
                              _currentHeroIndex = index;
                            });
                          },
                          itemCount: slides.length,
                          itemBuilder: (context, index) {
                            final slide = slides[index];
                            return GestureDetector(
                              onTap: slide.onOpen == null
                                  ? null
                                  : () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => slide.onOpen!(),
                                        ),
                                      );
                                    },
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  image: slide.imageUrl != null
                                      ? DecorationImage(
                                          image: CachedNetworkImageProvider(
                                              slide.imageUrl!),
                                          fit: BoxFit.cover,
                                          alignment: Alignment.topCenter,
                                        )
                                      : null,
                                  color: const Color(0xFF1E1E1E),
                                ),
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    gradient: LinearGradient(
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                      colors: [
                                        const Color(0xFF121212)
                                            .withValues(alpha: 0.95),
                                        const Color(0xFF121212)
                                            .withValues(alpha: 0.7),
                                        const Color(0xFF121212)
                                            .withValues(alpha: 0.1),
                                      ],
                                      stops: const [0.0, 0.4, 1.0],
                                    ),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(32.0),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: primaryColor,
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            slide.label.toUpperCase(),
                                            style: GoogleFonts.inter(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 10,
                                              letterSpacing: 1.5,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        Text(
                                          slide.title,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: GoogleFonts.orbitron(
                                            color: Colors.white,
                                            fontSize: 32,
                                            fontWeight: FontWeight.w900,
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        Text(
                                          slide.description,
                                          maxLines: 3,
                                          overflow: TextOverflow.ellipsis,
                                          style: GoogleFonts.inter(
                                            color: Colors.white70,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w300,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        Positioned(
                          bottom: 16,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.4),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.1)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: List.generate(slides.length, (index) {
                                  return AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 4),
                                    height: 8,
                                    width: _currentHeroIndex == index ? 24 : 8,
                                    decoration: BoxDecoration(
                                      color: _currentHeroIndex == index
                                          ? primaryColor
                                          : Colors.white.withValues(alpha: 0.5),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  );
                                }),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  flex: 4,
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1A1A),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: Colors.white.withValues(alpha: 0.05)),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Vault'u Keşfet",
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          "Kütüphanen boş. Popüler içeriklerden başlayarak koleksiyonunu oluştur.",
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            color: Colors.white70,
                            fontSize: 12,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: slides[_currentHeroIndex].onOpen == null
                              ? null
                              : () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          slides[_currentHeroIndex].onOpen!(),
                                    ),
                                  );
                                },
                          icon: const Icon(Icons.explore, color: Colors.white),
                          label: const Text(
                            "Detayları Aç",
                            style: TextStyle(color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 18, vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeroSection(List<_FlatLibraryItem> items, Color primaryColor) {
    return SizedBox(
      height: 400,
      child: Row(
        children: [
          Expanded(
            flex: 6,
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Stack(
                children: [
                  PageView.builder(
                    controller: _heroPageController,
                    onPageChanged: (index) {
                      setState(() {
                        _currentHeroIndex = index;
                      });
                      _updateDetailsForHeroItem(items[index]);
                    },
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final flatItem = items[index];
                      final item = LibraryItemModel(
                        id: flatItem.raw['id'],
                        title: flatItem.raw['title']?.toString(),
                        imageURL: flatItem.raw['imageURL']?.toString(),
                      );
                      final detailPage = _getDetailPage(flatItem.type, item.id);

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => detailPage));
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            image: item.imageURL != null
                                ? DecorationImage(
                                    image: CachedNetworkImageProvider(
                                        item.imageURL!),
                                    fit: BoxFit.cover,
                                    alignment: Alignment.topCenter,
                                  )
                                : null,
                            color: const Color(0xFF1E1E1E),
                          ),
                          child: Stack(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  gradient: LinearGradient(
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                    colors: [
                                      const Color(0xFF121212)
                                          .withValues(alpha: 0.95),
                                      const Color(0xFF121212)
                                          .withValues(alpha: 0.7),
                                      const Color(0xFF121212)
                                          .withValues(alpha: 0.1),
                                    ],
                                    stops: const [0.0, 0.4, 1.0],
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 0,
                                bottom: 0,
                                left: 0,
                                width: MediaQuery.of(context).size.width * 0.4,
                                child: Padding(
                                  padding: const EdgeInsets.all(32.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: primaryColor,
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          "FEATURED",
                                          style: GoogleFonts.inter(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 10,
                                            letterSpacing: 1.5,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        item.title ?? "Unknown Title",
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.orbitron(
                                          color: Colors.white,
                                          fontSize: 32,
                                          fontWeight: FontWeight.w900,
                                          shadows: [
                                            Shadow(
                                              color: Colors.black
                                                  .withValues(alpha: 0.8),
                                              blurRadius: 10,
                                              offset: const Offset(0, 4),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      FutureBuilder<String>(
                                          future: _getHeroDescription(
                                              item, flatItem.type),
                                          builder: (context, snapshot) {
                                            final desc = snapshot.data ??
                                                "Explore this title in your library.";
                                            return Text(
                                              desc,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: GoogleFonts.inter(
                                                color: Colors.white70,
                                                fontSize: 16,
                                                fontWeight: FontWeight.w300,
                                              ),
                                            );
                                          }),
                                    ],
                                  ),
                                ),
                              ),
                              Positioned(
                                left: 32,
                                bottom: 32,
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => detailPage));
                                  },
                                  icon: const Icon(Icons.play_arrow,
                                      color: Colors.white),
                                  label: const Text("View Details",
                                      style: TextStyle(color: Colors.white)),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: primaryColor,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 24, vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  // Indicators
                  Positioned(
                    bottom: 16,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: Colors.white.withValues(alpha: 0.1)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: List.generate(items.length, (index) {
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              height: 8,
                              width: _currentHeroIndex == index ? 24 : 8,
                              decoration: BoxDecoration(
                                color: _currentHeroIndex == index
                                    ? primaryColor
                                    : Colors.white.withValues(alpha: 0.5),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            );
                          }),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            flex: 4,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Quick Stats",
                    style: GoogleFonts.inter(
                      color: Colors.white54,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Consumer<LibraryProvider>(
                    builder: (context, libraryProvider, child) {
                      final title = libraryProvider.detailsTitle ?? '-';
                      final description =
                          libraryProvider.detailsDescription ?? '-';
                      final scoreText = libraryProvider.detailsScoreText ?? '-';
                      final dateText = libraryProvider.detailsDateText ?? '-';

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildGridStatItem(
                            "Score",
                            scoreText,
                            FontAwesomeIcons.star,
                            Colors.amber,
                          ),
                          const SizedBox(height: 12),
                          _buildGridStatItem(
                            "Date",
                            dateText,
                            FontAwesomeIcons.calendar,
                            Colors.blueAccent,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            description,
                            maxLines: 6,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                              color: Colors.white70,
                              fontSize: 12,
                              height: 1.4,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGridStatItem(
      String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  value,
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  label,
                  style: GoogleFonts.inter(
                    color: Colors.white54,
                    fontSize: 11,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _typePrefix(ContentType type) {
    switch (type) {
      case ContentType.games:
        return 'game';
      case ContentType.movies:
        return 'movie';
      case ContentType.series:
        return 'serie';
      case ContentType.books:
        return 'book';
      case ContentType.actors:
        return 'actor';
      case ContentType.anime:
        return 'anime';
    }
  }

  List<LibraryItemModel> _itemsForType(UserLibrary library, ContentType type) {
    final prefix = '${_typePrefix(type)}_';
    final result = <LibraryItemModel>[];
    for (final entry in library.library.entries) {
      if (!entry.key.startsWith(prefix)) continue;
      final raw = entry.value;
      if (raw is! Map) continue;
      final m = Map<String, dynamic>.from(raw);
      if ((m['folder'] ?? 'library') != folderView) continue;
      result.add(LibraryItemModel(
        id: m['id'],
        title: m['title']?.toString(),
        imageURL: m['imageURL']?.toString(),
      ));
    }
    return result;
  }

  Widget _buildGroupedView(UserLibrary library, int themeColor) {
    return Column(
      children: [
        _buildSection("Games", _itemsForType(library, ContentType.games),
            ContentType.games, themeColor, FontAwesomeIcons.gamepad),
        const SizedBox(height: 32),
        _buildSection("Movies", _itemsForType(library, ContentType.movies),
            ContentType.movies, themeColor, FontAwesomeIcons.film),
        const SizedBox(height: 32),
        _buildSection("Series", _itemsForType(library, ContentType.series),
            ContentType.series, themeColor, FontAwesomeIcons.tv),
        const SizedBox(height: 32),
        _buildSection("Animes", _itemsForType(library, ContentType.anime),
            ContentType.anime, themeColor, FontAwesomeIcons.dragon),
        const SizedBox(height: 32),
        _buildSection("Books", _itemsForType(library, ContentType.books),
            ContentType.books, themeColor, FontAwesomeIcons.book),
      ],
    );
  }

  Widget _buildSection(String title, List<LibraryItemModel> items,
      ContentType type, int themeColor, IconData icon) {
    final primaryColor = Color(themeColor);

    if (items.isEmpty) {
      return _buildEmptyState(title, icon, primaryColor);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: primaryColor, size: 20),
            const SizedBox(width: 12),
            Text(
              title,
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: primaryColor.withValues(alpha: 0.3)),
              ),
              child: Text(
                "${items.length}",
                style: GoogleFonts.inter(
                  color: primaryColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height:
              300, // Increased height to prevent overflow with 0.7 aspect ratio
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: items.length,
            separatorBuilder: (context, index) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              final model = items[index];
              return AspectRatio(
                aspectRatio: 0.7,
                child: GenericContentCard(
                  item: model,
                  type: type,
                  themeColor: themeColor,
                  detailPage: _getDetailPage(type, model.id),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildGridView(
      List<_FlatLibraryItem> items, UserLibrary library, int themeColor) {
    if (items.isEmpty) {
      return const Center(
          child: Text("Library is empty",
              style: TextStyle(color: Colors.white54)));
    }
    return Wrap(
      spacing: 24,
      runSpacing: 24,
      alignment: WrapAlignment.start,
      children: items.map((item) {
        final model = LibraryItemModel(
          id: item.raw['id'],
          title: item.raw['title']?.toString(),
          imageURL: item.raw['imageURL']?.toString(),
        );
        return GenericContentCard(
          item: model,
          type: item.type,
          themeColor: themeColor,
          detailPage: _getDetailPage(item.type, model.id),
        );
      }).toList(),
    );
  }

  Widget _buildEmptyState(String title, IconData icon, Color primaryColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 48, color: Colors.white10),
          const SizedBox(height: 16),
          Text(
            "No $title found",
            style: GoogleFonts.inter(
              color: Colors.white38,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: () {
              // Navigate to respective page to add content?
              // For now just a placeholder action
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: primaryColor,
              side: BorderSide(color: primaryColor.withValues(alpha: 0.5)),
            ),
            child: const Text("Add Content"),
          ),
        ],
      ),
    );
  }

  List<_FlatLibraryItem> _buildFlattenedItems(UserLibrary library) {
    final List<_FlatLibraryItem> items = [];

    ContentType? parseType(String compoundKey) {
      final idx = compoundKey.indexOf('_');
      if (idx <= 0) return null;
      final prefix = compoundKey.substring(0, idx);
      switch (prefix) {
        case 'game':
          return ContentType.games;
        case 'movie':
          return ContentType.movies;
        case 'serie':
          return ContentType.series;
        case 'book':
          return ContentType.books;
        case 'actor':
          return ContentType.actors;
        case 'anime':
          return ContentType.anime;
      }
      return null;
    }

    for (final entry in library.library.entries) {
      final type = parseType(entry.key);
      if (type == null) continue;
      final raw = entry.value;
      if (raw is! Map) continue;
      final m = Map<String, dynamic>.from(raw);
      items.add(_FlatLibraryItem(raw: m, type: type));
    }

    items.sort((a, b) {
      String titleA = (a.raw['title'] ?? "").toString();
      String titleB = (b.raw['title'] ?? "").toString();

      if (buttonSort == Sort.atoz) {
        return titleA.compareTo(titleB);
      } else {
        return titleB.compareTo(titleA);
      }
    });

    return items;
  }

  Widget _getDetailPage(ContentType type, dynamic id) {
    switch (type) {
      case ContentType.games:
        return GameDetailPage(gameID: id);
      case ContentType.movies:
        return MovieDetailPage(movieID: id);
      case ContentType.series:
        return SerieDetailPage(serieID: id);
      case ContentType.actors:
        return ActorDetailPage(actorID: id);
      case ContentType.books:
        return BooksDetailPage(bookID: id);
      case ContentType.anime:
        return AnimeDetailPage(animeId: id);
    }
  }

  Widget _buildSortButton(int themeColor) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildSortChip(
          label: "A-Z",
          value: Sort.atoz,
          themeColor: themeColor,
        ),
        const SizedBox(width: 6),
        _buildSortChip(
          label: "Z-A",
          value: Sort.ztoa,
          themeColor: themeColor,
        ),
      ],
    );
  }

  Widget _buildSortChip({
    required String label,
    required Sort value,
    required int themeColor,
  }) {
    final selected = buttonSort == value;

    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) {
        setState(() {
          buttonSort = value;
        });
      },
      backgroundColor: const Color(0xFF2A2A2A),
      selectedColor: Color(themeColor),
      labelStyle: const TextStyle(
        color: Colors.white,
        fontSize: 11,
      ),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: const VisualDensity(horizontal: -2, vertical: -2),
      shape: const StadiumBorder(
        side: BorderSide(color: Colors.transparent, width: 0),
      ),
    );
  }

  List<_FlatLibraryItem> _applyFilter(List<_FlatLibraryItem> items) {
    final folderFiltered = items.where((e) {
      final folder = e.raw['folder']?.toString() ?? 'library';
      return folder == folderView;
    }).toList();

    if (filterType == null) return folderFiltered;
    return folderFiltered.where((e) => e.type == filterType).toList();
  }
}

class _FlatLibraryItem {
  final Map<String, dynamic> raw;
  final ContentType type;

  _FlatLibraryItem({required this.raw, required this.type});
}

class _ExploreSlide {
  final String label;
  final String title;
  final String description;
  final String? imageUrl;
  final Widget Function()? onOpen;

  _ExploreSlide({
    required this.label,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.onOpen,
  });
}
