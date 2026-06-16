import 'dart:async';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:vault/data/model/anime_model.dart';
import 'package:vault/data/model/game_model.dart';
import 'package:vault/data/model/movie_model.dart';
import 'package:vault/data/model/serie_model.dart';
import 'package:vault/Helper/content_type.dart';
import 'package:vault/Helper/theme_helper.dart';
import 'package:vault/Helper/rating_helper.dart';
import 'package:vault/Logic/animepage_logic.dart';
import 'package:vault/Logic/gamepage_logic.dart';
import 'package:vault/Logic/moviepage_logic.dart';
import 'package:vault/Logic/seriespage_logic.dart';
import 'package:vault/Providers/library_provider.dart';
import 'package:vault/ui/Desktop/Details/anime_detail_page.dart';
import 'package:vault/ui/Desktop/Details/game_detail_page.dart';
import 'package:vault/ui/Desktop/Details/movie_detail_page.dart';
import 'package:vault/ui/Desktop/Details/serie_detail_page.dart';
import 'package:vault/ui/widgets/home_showcase_widgets.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  late Future<_HomePayload> _future;

  @override
  void initState() {
    super.initState();
    _future = _fetch();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<_HomePayload> _fetch() async {
    final gameLogic = GamePageLogic();
    final movieLogic = MoviePageLogic();
    final seriesLogic = SeriesPageLogic();
    final animeLogic = AnimePageLogic();
    final results = await Future.wait([
      gameLogic.getPopularGameList('popularRightNow').catchError((e) {
        debugPrint('Games fetch error: $e');
        return <GameModel>[];
      }),
      movieLogic.getPopularMovies().catchError((e) {
        debugPrint('Movies fetch error: $e');
        return <MovieModel>[];
      }),
      seriesLogic.getPopularSeries().catchError((e) {
        debugPrint('Series fetch error: $e');
        return <SerieModel>[];
      }),
      animeLogic.getTopAnimes(limit: 15).catchError((e) {
        debugPrint('Animes fetch error: $e');
        return <AnimeModel>[];
      }),
    ]);

    final games = (results[0] as List).whereType<GameModel>().toList();
    final movies = (results[1] as List).whereType<MovieModel>().toList();
    final series = (results[2] as List).whereType<SerieModel>().toList();
    final animes = (results[3] as List).whereType<AnimeModel>().toList();
    final rng = Random(DateTime.now().millisecondsSinceEpoch);

    List<T> pickN<T>(List<T> list, int count) {
      if (list.length <= count) return list;
      final copy = List<T>.from(list);
      copy.shuffle(rng);
      return copy.take(count).toList();
    }

    Future<GameModel> hydrateGameSummary(GameModel game) async {
      if (game.id == null) return game;
      final summary = game.summary?.trim() ?? '';
      if (summary.isNotEmpty) return game;

      try {
        final details = await gameLogic.getGameDetails(game.id!);
        if (details.isNotEmpty &&
            (details.first.summary?.trim().isNotEmpty ?? false)) {
          game.summary = details.first.summary?.trim();
        }
      } catch (_) {}

      return game;
    }

    Future<HomeHeroSlideData?> buildGameSlide(GameModel game) async {
      if (game.id == null) return null;
      String description = game.summary?.trim() ?? '';
      if (description.isEmpty) {
        try {
          final details = await gameLogic.getGameDetails(game.id!);
          if (details.isNotEmpty) {
            description = details.first.summary?.trim() ?? '';
          }
        } catch (_) {}
      }
      if (description.isEmpty) return null;
      return HomeHeroSlideData(
        title: game.name ?? 'Game',
        subtitle: 'Popular Game',
        category: HomeHeroCategory.games,
        imageUrl: game.imageURL,
        description: description,
        gameAggregatedRating: game.aggregated_rating,
        gameRating: game.rating,
        onOpen: () => GameDetailPage(gameID: game.id!),
      );
    }

    HomeHeroSlideData? buildMovieSlide(MovieModel movie) {
      if (movie.id == null) return null;
      final description = movie.overview?.trim() ?? '';
      if (description.isEmpty) return null;
      return HomeHeroSlideData(
        title: movie.title ?? 'Movie',
        subtitle: 'Popular Movie',
        category: HomeHeroCategory.movies,
        imageUrl: movie.imageURL,
        description: description,
        onOpen: () => MovieDetailPage(movieID: movie.id!),
      );
    }

    HomeHeroSlideData? buildSeriesSlide(SerieModel show) {
      if (show.id == null) return null;
      final description = show.overview?.trim() ?? '';
      if (description.isEmpty) return null;
      return HomeHeroSlideData(
        title: show.title ?? 'Series',
        subtitle: 'Popular Series',
        category: HomeHeroCategory.series,
        imageUrl: show.imageURL,
        description: description,
        onOpen: () => SerieDetailPage(serieID: show.id!),
      );
    }

    HomeHeroSlideData? buildAnimeSlide(AnimeModel anime) {
      if (anime.id == null) return null;
      final description = anime.synopsis?.trim() ?? '';
      if (description.isEmpty) return null;
      return HomeHeroSlideData(
        title: anime.title ?? 'Anime',
        subtitle: 'Top Anime',
        category: HomeHeroCategory.animes,
        imageUrl: anime.imageURL,
        description: description,
        onOpen: () => AnimeDetailPage(animeId: anime.id!),
      );
    }

    final heroCandidates = <HomeHeroSlideData>[];

    for (final game in games.take(5)) {
      final slide = await buildGameSlide(game);
      if (slide != null) {
        heroCandidates.add(slide);
      }
    }

    for (final movie in movies.take(5)) {
      final slide = buildMovieSlide(movie);
      if (slide != null) {
        heroCandidates.add(slide);
      }
    }

    for (final show in series.take(5)) {
      final slide = buildSeriesSlide(show);
      if (slide != null) {
        heroCandidates.add(slide);
      }
    }

    for (final anime in animes.take(5)) {
      final slide = buildAnimeSlide(anime);
      if (slide != null) {
        heroCandidates.add(slide);
      }
    }

    final heroSlides = heroCandidates;

    if (heroSlides.isEmpty) {
      heroSlides.add(
        const HomeHeroSlideData(
          title: "Vault'u Kesfet",
          subtitle: 'Trending',
          category: HomeHeroCategory.games,
          imageUrl: null,
          description: 'Oyun, film, dizi ve anime koleksiyonunu tek yerde tut.',
          gameAggregatedRating: null,
          gameRating: null,
          onOpen: null,
        ),
      );
    }

    final selectedGames = pickN(games, 15);
    for (var i = 0; i < selectedGames.length; i++) {
      selectedGames[i] = await hydrateGameSummary(selectedGames[i]);
    }

    return _HomePayload(
      heroSlides: heroSlides,
      games: selectedGames,
      movies: pickN(movies, 15),
      series: pickN(series, 15),
      animes: pickN(animes, 15),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = Provider.of<ThemeProvider>(context).color;
    final primaryColor = Color(themeColor);

    return FutureBuilder<_HomePayload>(
      future: _future,
      builder: (context, snapshot) {
        final data = snapshot.data;
        final loading = snapshot.connectionState != ConnectionState.done;
        final payload = data ?? _HomePayload.skeleton();

        return Skeletonizer(
          enabled: loading,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 44, vertical: 24),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1360),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    HomeHeroSlider(
                      primaryColor: primaryColor,
                      slides: payload.heroSlides,
                    ),
                    const SizedBox(height: 34),
                    _GamesSectionHeader(
                      primaryColor: primaryColor,
                    ),
                    const SizedBox(height: 16),
                    _GamesShowcaseSection(
                      items: payload.games,
                      themeColor: themeColor,
                    ),
                    const SizedBox(height: 32),
                    MediaSectionBlock<MovieModel>(
                      primaryColor: primaryColor,
                      sectionTop: 'POPULAR',
                      sectionBottom: 'MOVIES',
                      items: payload.movies,
                      getTitle: (item) => item.title ?? 'Movie',
                      getDescription: (item) =>
                          item.overview?.trim().isNotEmpty == true
                              ? item.overview!.trim()
                              : (item.tagline?.trim().isNotEmpty == true
                                  ? item.tagline!.trim()
                                  : 'No summary available yet.'),
                      getImageUrl: (item) => item.imageURL,
                      getScore: (item) => RatingHelper.getScore(item),
                      buildDetailPage: (item) => MovieDetailPage(
                        movieID: item.id ?? 0,
                      ),
                    ),
                    const SizedBox(height: 32),
                    MediaSectionBlock<SerieModel>(
                      primaryColor: primaryColor,
                      sectionTop: 'POPULAR',
                      sectionBottom: 'SERIES',
                      items: payload.series,
                      getTitle: (item) => item.name ?? 'Series',
                      getDescription: (item) =>
                          item.overview?.trim().isNotEmpty == true
                              ? item.overview!.trim()
                              : (item.tagline?.trim().isNotEmpty == true
                                  ? item.tagline!.trim()
                                  : 'No summary available yet.'),
                      getImageUrl: (item) => item.imageURL,
                      getScore: (item) => RatingHelper.getScore(item),
                      buildDetailPage: (item) => SerieDetailPage(
                        serieID: item.id ?? 0,
                      ),
                    ),
                    const SizedBox(height: 32),
                    MediaSectionBlock<AnimeModel>(
                      primaryColor: primaryColor,
                      sectionTop: 'TOP',
                      sectionBottom: 'ANIMES',
                      items: payload.animes,
                      getTitle: (item) => item.title ?? 'Anime',
                      getDescription: (item) =>
                          item.synopsis?.trim().isNotEmpty == true
                              ? item.synopsis!.trim()
                              : 'No summary available yet.',
                      getImageUrl: (item) => item.imageURL,
                      getScore: (item) => RatingHelper.getScore(item),
                      buildDetailPage: (item) => AnimeDetailPage(
                        animeId: item.id ?? 0,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _GamesShowcaseSection extends StatelessWidget {
  final List<GameModel> items;
  final int themeColor;

  const _GamesShowcaseSection({
    required this.items,
    required this.themeColor,
  });

  @override
  Widget build(BuildContext context) {
    final row1 = items.take(5).toList();
    final row2 = items.skip(5).take(5).toList();
    final row3 = items.skip(10).take(5).toList();
    final rng = Random(items.fold<int>(0, (sum, item) => sum + (item.id ?? 0)));

    Set<int> pickWideIndexes(int itemCount, int wideCount) {
      final pool = List<int>.generate(itemCount, (index) => index);
      pool.shuffle(rng);
      return pool.take(min(wideCount, itemCount)).toSet();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (row1.isNotEmpty)
          _GamesMosaicRow(
            items: row1,
            themeColor: themeColor,
            wideIndexes: pickWideIndexes(row1.length, 1),
          ),
        if (row1.isNotEmpty) const SizedBox(height: 22),
        if (row2.isNotEmpty)
          _GamesMosaicRow(
            items: row2,
            themeColor: themeColor,
            wideIndexes: pickWideIndexes(row2.length, 1),
          ),
        if (row2.isNotEmpty) const SizedBox(height: 22),
        if (row3.isNotEmpty)
          _GamesMosaicRow(
            items: row3,
            themeColor: themeColor,
            wideIndexes: pickWideIndexes(row3.length, 1),
          ),
      ],
    );
  }
}

class _GamesSectionHeader extends StatelessWidget {
  final Color primaryColor;

  const _GamesSectionHeader({
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'POPULAR',
              style: GoogleFonts.orbitron(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.w900,
                letterSpacing: 2.0,
              ),
            ),
            const SizedBox(width: 12),
            Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Text(
                'GAMES',
                style: GoogleFonts.orbitron(
                  color: primaryColor,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2.1,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          height: 1,
          color: Colors.white.withValues(alpha: 0.08),
        ),
      ],
    );
  }
}

class _GamesMosaicRow extends StatelessWidget {
  final List<GameModel> items;
  final int themeColor;
  final Set<int> wideIndexes;

  const _GamesMosaicRow({
    required this.items,
    required this.themeColor,
    required this.wideIndexes,
  });

  @override
  Widget build(BuildContext context) {
    const gap = 12.0;
    const hoverRoom = 8.0;
    const posterAspectRatio = 220 / 330;

    return LayoutBuilder(
      builder: (context, constraints) {
        final totalUnits = items.length + wideIndexes.length;
        final totalGap = gap * (items.length - 1);
        final unitWidth =
            (constraints.maxWidth - totalGap - (hoverRoom * 2)) / totalUnits;
        final posterWidth = unitWidth;
        final posterHeight = posterWidth / posterAspectRatio;

        return SizedBox(
          height: posterHeight + 8,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: hoverRoom),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(items.length, (index) {
                final item = items[index];
                final isWide = wideIndexes.contains(index);
                final width = isWide ? unitWidth * 2 : unitWidth;

                return Padding(
                  padding: EdgeInsets.only(
                      right: index == items.length - 1 ? 0 : gap),
                  child: SizedBox(
                    width: width,
                    height: posterHeight,
                    child: isWide
                        ? _FeaturedGameCard(
                            item: item,
                            themeColor: Color(themeColor),
                          )
                        : _GamePosterMiniCard(
                            item: item,
                          ),
                  ),
                );
              }),
            ),
          ),
        );
      },
    );
  }
}

Map<String, dynamic> _buildGameLibraryMap(GameModel item, String folder) {
  return {
    'id': item.id,
    'type': 'game',
    'title': item.name,
    'imageURL': item.imageURL,
    'folder': folder,
  };
}

void _showHomeGameContextMenu({
  required BuildContext context,
  required RelativeRect position,
  required LibraryProvider provider,
  required GameModel item,
  required bool inLibrary,
}) {
  final id = item.id;
  showMenu<void>(
    context: context,
    position: position,
    color: const Color(0xFF141414),
    elevation: 18,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      side: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
    ),
    items: <PopupMenuEntry<void>>[
      PopupMenuItem<void>(
        height: 42,
        onTap: () {
          if (id == null) return;
          provider.addOrUpdateItem(
            type: ContentType.games,
            id: id,
            title: item.name,
            imageUrl: item.imageURL,
            folder: 'favorites',
            extra: _buildGameLibraryMap(item, 'favorites'),
          );
        },
        child: const Text('Move to Favorites'),
      ),
      PopupMenuItem<void>(
        height: 42,
        onTap: () {
          if (id == null) return;
          provider.addOrUpdateItem(
            type: ContentType.games,
            id: id,
            title: item.name,
            imageUrl: item.imageURL,
            folder: 'completed',
            extra: _buildGameLibraryMap(item, 'completed'),
          );
        },
        child: const Text('Move to Completed'),
      ),
      PopupMenuItem<void>(
        height: 42,
        onTap: () {
          if (id == null) return;
          provider.addOrUpdateItem(
            type: ContentType.games,
            id: id,
            title: item.name,
            imageUrl: item.imageURL,
            folder: 'backlog',
            extra: _buildGameLibraryMap(item, 'backlog'),
          );
        },
        child: const Text('Move to Backlog'),
      ),
      if (provider.customFolders.isNotEmpty) const PopupMenuDivider(),
      for (final folder in provider.customFolders)
        PopupMenuItem<void>(
          height: 42,
          onTap: () {
            if (id == null) return;
            provider.addOrUpdateItem(
              type: ContentType.games,
              id: id,
              title: item.name,
              imageUrl: item.imageURL,
              folder: folder,
              extra: _buildGameLibraryMap(item, folder),
            );
          },
          child: Text('Move to $folder'),
        ),
      if (inLibrary) ...[
        const PopupMenuDivider(),
        PopupMenuItem<void>(
          height: 42,
          onTap: () {
            if (id == null) return;
            provider.removeFromLibrary(ContentType.games, id);
          },
          child: const Text(
            'Remove from Library',
            style: TextStyle(color: Colors.redAccent),
          ),
        ),
      ],
    ],
  );
}

class _HomeGameMenuButton extends StatelessWidget {
  final VoidCallback onTap;

  const _HomeGameMenuButton({
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Ink(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.58),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.26),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(
            Icons.more_horiz_rounded,
            color: Colors.white,
            size: 18,
          ),
        ),
      ),
    );
  }
}

class _GamePosterMiniCard extends StatefulWidget {
  final GameModel item;

  const _GamePosterMiniCard({
    required this.item,
  });

  @override
  State<_GamePosterMiniCard> createState() => _GamePosterMiniCardState();
}

class _GamePosterMiniCardState extends State<_GamePosterMiniCard> {
  bool _hovering = false;
  final GlobalKey _menuAnchorKey = GlobalKey();

  void _openMenu(LibraryProvider provider, bool inLibrary) {
    final renderObject =
        _menuAnchorKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderObject == null) return;
    final overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox?;
    if (overlay == null) return;
    final offset = renderObject.localToGlobal(Offset.zero, ancestor: overlay);
    _showHomeGameContextMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        offset.dx,
        offset.dy + renderObject.size.height + 6,
        offset.dx + renderObject.size.width,
        offset.dy,
      ),
      provider: provider,
      item: widget.item,
      inLibrary: inLibrary,
    );
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final score = RatingHelper.getScore(item);
    final hasRating = score > 0;
    final ratingColor =
        hasRating ? RatingHelper.getRatingColor(score) : Colors.white54;
    return Consumer<LibraryProvider>(
      builder: (context, provider, child) {
        final inLibrary = item.id == null
            ? false
            : provider.isInLibrary(ContentType.games, item.id!);

        return MouseRegion(
          onEnter: (_) => setState(() => _hovering = true),
          onExit: (_) => setState(() => _hovering = false),
          cursor: SystemMouseCursors.click,
          child: AnimatedScale(
            scale: _hovering ? 1.015 : 1.0,
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutCubic,
            child: GestureDetector(
              onTap: item.id == null
                  ? null
                  : () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              GameDetailPage(gameID: item.id!),
                        ),
                      );
                    },
              onLongPressStart: (_) => _openMenu(provider, inLibrary),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: const Color(0xFF181818),
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (item.imageURL != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Image(
                          image: CachedNetworkImageProvider(item.imageURL!),
                          fit: BoxFit.cover,
                          alignment: Alignment.topCenter,
                        ),
                      ),
                    if (_hovering)
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.08),
                              Colors.black.withValues(alpha: 0.40),
                              Colors.black.withValues(alpha: 0.82),
                            ],
                          ),
                        ),
                      ),
                    if (_hovering)
                      Positioned(
                        top: 10,
                        right: 10,
                        child: KeyedSubtree(
                          key: _menuAnchorKey,
                          child: _HomeGameMenuButton(
                            onTap: () => _openMenu(provider, inLibrary),
                          ),
                        ),
                      ),
                    if (_hovering)
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: Container(
                          height: 74,
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.vertical(
                              bottom: Radius.circular(14),
                            ),
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black.withValues(alpha: 0.10),
                                Colors.black.withValues(alpha: 0.70),
                                Colors.black.withValues(alpha: 0.95),
                              ],
                            ),
                          ),
                          padding: const EdgeInsets.fromLTRB(12, 14, 12, 12),
                          child: Align(
                            alignment: Alignment.bottomLeft,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  item.name ?? 'Game',
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.inter(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.star_rounded,
                                      size: 14,
                                      color: ratingColor,
                                    ),
                                    if (!hasRating) ...[
                                      const SizedBox(width: 2),
                                      Icon(
                                        Icons.question_mark_rounded,
                                        size: 12,
                                        color: ratingColor,
                                      ),
                                    ],
                                    if (hasRating) ...[
                                      const SizedBox(width: 4),
                                      Text(
                                        '${score.ceil()}',
                                        style: GoogleFonts.inter(
                                          color: ratingColor,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _FeaturedGameCard extends StatefulWidget {
  final GameModel item;
  final Color themeColor;

  const _FeaturedGameCard({
    required this.item,
    required this.themeColor,
  });

  @override
  State<_FeaturedGameCard> createState() => _FeaturedGameCardState();
}

class _FeaturedGameCardState extends State<_FeaturedGameCard> {
  bool _hovering = false;
  final GlobalKey _menuAnchorKey = GlobalKey();

  void _openMenu(LibraryProvider provider, bool inLibrary) {
    final renderObject =
        _menuAnchorKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderObject == null) return;
    final overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox?;
    if (overlay == null) return;
    final offset = renderObject.localToGlobal(Offset.zero, ancestor: overlay);
    _showHomeGameContextMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        offset.dx,
        offset.dy + renderObject.size.height + 6,
        offset.dx + renderObject.size.width,
        offset.dy,
      ),
      provider: provider,
      item: widget.item,
      inLibrary: inLibrary,
    );
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final score = RatingHelper.getScore(item);
    final hasRating = score > 0;
    final ratingColor =
        hasRating ? RatingHelper.getRatingColor(score) : Colors.white54;
    return Consumer<LibraryProvider>(
      builder: (context, provider, child) {
        final inLibrary = item.id == null
            ? false
            : provider.isInLibrary(ContentType.games, item.id!);

        return MouseRegion(
          onEnter: (_) => setState(() => _hovering = true),
          onExit: (_) => setState(() => _hovering = false),
          cursor: SystemMouseCursors.click,
          child: AnimatedScale(
            scale: _hovering ? 1.015 : 1.0,
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutCubic,
            child: GestureDetector(
              onTap: item.id == null
                  ? null
                  : () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              GameDetailPage(gameID: item.id!),
                        ),
                      );
                    },
              onLongPressStart: (_) => _openMenu(provider, inLibrary),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: const Color(0xFF181818),
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (item.imageURL != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image(
                          image: CachedNetworkImageProvider(item.imageURL!),
                          fit: BoxFit.cover,
                          alignment: Alignment.topCenter,
                        ),
                      ),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.08),
                            Colors.black.withValues(alpha: 0.78),
                            Colors.black.withValues(alpha: 0.96),
                          ],
                        ),
                      ),
                    ),
                    if (_hovering)
                      Positioned(
                        top: 12,
                        right: 12,
                        child: KeyedSubtree(
                          key: _menuAnchorKey,
                          child: _HomeGameMenuButton(
                            onTap: () => _openMenu(provider, inLibrary),
                          ),
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            item.name ?? 'Game',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.orbitron(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.star_rounded,
                                size: 14,
                                color: ratingColor,
                              ),
                              if (!hasRating) ...[
                                const SizedBox(width: 2),
                                Icon(
                                  Icons.question_mark_rounded,
                                  size: 12,
                                  color: ratingColor,
                                ),
                              ],
                              if (hasRating) ...[
                                const SizedBox(width: 4),
                                Text(
                                  '${score.ceil()}',
                                  style: GoogleFonts.inter(
                                    color: ratingColor,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            item.summary?.trim().isNotEmpty == true
                                ? item.summary!.trim()
                                : (item.storyline?.trim().isNotEmpty == true
                                    ? item.storyline!.trim()
                                    : 'No summary available yet.'),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                              color: Colors.white70,
                              fontSize: 12,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _HomePayload {
  final List<HomeHeroSlideData> heroSlides;
  final List<GameModel> games;
  final List<MovieModel> movies;
  final List<SerieModel> series;
  final List<AnimeModel> animes;

  _HomePayload({
    required this.heroSlides,
    required this.games,
    required this.movies,
    required this.series,
    required this.animes,
  });

  factory _HomePayload.skeleton() {
    final dummyGame = GameModel(id: 0, name: 'Loading', url: null);
    final dummyMovie = MovieModel(id: 0, title: 'Loading', imageURL: null);
    final dummySerie = SerieModel(id: 0, name: 'Loading', imageURL: null);
    final dummyAnime = AnimeModel(id: 0, title: 'Loading', imageURL: null);
    return _HomePayload(
      heroSlides: List.generate(5, (_) => HomeHeroSlideData.skeleton()),
      games: List.generate(15, (_) => dummyGame),
      movies: List.generate(7, (_) => dummyMovie),
      series: List.generate(7, (_) => dummySerie),
      animes: List.generate(7, (_) => dummyAnime),
    );
  }
}
