import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:vault/Data/Model/anime_model.dart';
import 'package:vault/Data/Model/game_model.dart';
import 'package:vault/Data/Model/movie_model.dart';
import 'package:vault/Data/Model/serie_model.dart';
import 'package:vault/Helper/theme_helper.dart';
import 'package:vault/Logic/animepage_logic.dart';
import 'package:vault/Logic/gamepage_logic.dart';
import 'package:vault/Logic/moviepage_logic.dart';
import 'package:vault/Logic/seriespage_logic.dart';
import 'package:vault/UI/Desktop/Animes/animes_page.dart';
import 'package:vault/UI/Desktop/Details/anime_detail_page.dart';
import 'package:vault/UI/Desktop/Details/game_detail_page.dart';
import 'package:vault/UI/Desktop/Details/movie_detail_page.dart';
import 'package:vault/UI/Desktop/Details/serie_detail_page.dart';
import 'package:vault/UI/Desktop/Games/games_page.dart';
import 'package:vault/UI/Desktop/Movies/movies_page.dart';
import 'package:vault/UI/Desktop/Series/series_page.dart';
// import 'package:vault/UI/Views/library_view.dart';
import 'package:vault/Widgets/generic_content_card.dart';

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

  Future<_HomePayload> _fetch() async {
    final results = await Future.wait([
      GamePageLogic().getPopularGameList('popularRightNow'),
      MoviePageLogic().getPopularMovies(),
      SeriesPageLogic().getPopularSeries(),
      AnimePageLogic().getTopAnimes(limit: 25),
    ]);

    final games = (results[0] as List).whereType<GameModel>().toList();
    final movies = (results[1] as List).whereType<MovieModel>().toList();
    final series = (results[2] as List).whereType<SerieModel>().toList();
    final animes = (results[3] as List).whereType<AnimeModel>().toList();

    final rng = Random(DateTime.now().millisecondsSinceEpoch);

    _HeroTileData pickHero() {
      final buckets = <List<_HeroTileData>>[
        games
            .where((e) => e.id != null)
            .map((e) => _HeroTileData(
                  title: e.name ?? 'Game',
                  subtitle: 'Trending Game',
                  imageUrl: e.imageURL,
                  onOpen: () => GameDetailPage(gameID: e.id!),
                ))
            .toList(),
        movies
            .where((e) => e.id != null)
            .map((e) => _HeroTileData(
                  title: e.title ?? 'Movie',
                  subtitle: 'Popular Movie',
                  imageUrl: e.imageURL,
                  onOpen: () => MovieDetailPage(movieID: e.id!),
                ))
            .toList(),
        series
            .where((e) => e.id != null)
            .map((e) => _HeroTileData(
                  title: e.title ?? 'Series',
                  subtitle: 'Popular Series',
                  imageUrl: e.imageURL,
                  onOpen: () => SerieDetailPage(serieID: e.id!),
                ))
            .toList(),
        animes
            .where((e) => e.id != null)
            .map((e) => _HeroTileData(
                  title: e.title ?? 'Anime',
                  subtitle: 'Top Anime',
                  imageUrl: e.imageURL,
                  onOpen: () => AnimeDetailPage(animeId: e.id!),
                ))
            .toList(),
      ];

      final nonEmpty = buckets.where((b) => b.isNotEmpty).toList();
      if (nonEmpty.isEmpty) {
        return _HeroTileData(
          title: "Vault'u Keşfet",
          subtitle: 'Trending',
          imageUrl: null,
          onOpen: null,
        );
      }
      final bucket = nonEmpty[rng.nextInt(nonEmpty.length)];
      return bucket[rng.nextInt(bucket.length)];
    }

    final hero1 = pickHero();
    var hero2 = pickHero();
    int guard = 0;
    while (hero2.title == hero1.title && guard < 5) {
      hero2 = pickHero();
      guard += 1;
    }

    List<T> pick7<T>(List<T> list) {
      if (list.length <= 7) return list;
      final copy = List<T>.from(list);
      copy.shuffle(rng);
      return copy.take(7).toList();
    }

    return _HomePayload(
      heroLeft: hero1,
      heroRight: hero2,
      games: pick7(games),
      movies: pick7(movies),
      series: pick7(series),
      animes: pick7(animes),
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

        final payload = data ??
            _HomePayload.skeleton(
              heroLeft: _HeroTileData.skeleton(),
              heroRight: _HeroTileData.skeleton(),
            );

        return Skeletonizer(
          enabled: loading,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _HeroTile(
                        primaryColor: primaryColor,
                        data: payload.heroLeft,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _HeroTile(
                        primaryColor: primaryColor,
                        data: payload.heroRight,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                _SectionHeader(
                  leftText: "Games",
                  rightText: "See All Games",
                  onSeeAll: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const GamesPage()),
                    );
                  },
                  primaryColor: primaryColor,
                ),
                const SizedBox(height: 8),
                _HorizontalRow(
                  themeColor: themeColor,
                  children: payload.games
                      .map((e) => GenericContentCard(
                            item: e,
                            type: ContentType.games,
                            themeColor: themeColor,
                            detailPage: GameDetailPage(gameID: e.id ?? 0),
                          ))
                      .toList(),
                ),
                const SizedBox(height: 18),
                _SectionHeader(
                  leftText: "Movies",
                  rightText: "See All Movies",
                  onSeeAll: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const MoviesPage()),
                    );
                  },
                  primaryColor: primaryColor,
                ),
                const SizedBox(height: 8),
                _HorizontalRow(
                  themeColor: themeColor,
                  children: payload.movies
                      .map((e) => GenericContentCard(
                            item: e,
                            type: ContentType.movies,
                            themeColor: themeColor,
                            detailPage: MovieDetailPage(movieID: e.id ?? 0),
                          ))
                      .toList(),
                ),
                const SizedBox(height: 18),
                _SectionHeader(
                  leftText: "Series",
                  rightText: "See All Series",
                  onSeeAll: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const SeriesPage()),
                    );
                  },
                  primaryColor: primaryColor,
                ),
                const SizedBox(height: 8),
                _HorizontalRow(
                  themeColor: themeColor,
                  children: payload.series
                      .map((e) => GenericContentCard(
                            item: e,
                            type: ContentType.series,
                            themeColor: themeColor,
                            detailPage: SerieDetailPage(serieID: e.id ?? 0),
                          ))
                      .toList(),
                ),
                const SizedBox(height: 18),
                _SectionHeader(
                  leftText: "Animes",
                  rightText: "See All Animes",
                  onSeeAll: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const AnimesPage()),
                    );
                  },
                  primaryColor: primaryColor,
                ),
                const SizedBox(height: 8),
                _HorizontalRow(
                  themeColor: themeColor,
                  children: payload.animes
                      .map((e) => GenericContentCard(
                            item: e,
                            type: ContentType.anime,
                            themeColor: themeColor,
                            detailPage: AnimeDetailPage(animeId: e.id ?? 0),
                          ))
                      .toList(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _TopNavButton extends StatelessWidget {
  final String label;
  final bool selected;
  final Color primaryColor;
  final VoidCallback onTap;

  const _TopNavButton({
    required this.label,
    required this.selected,
    required this.primaryColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: selected
              ? primaryColor.withValues(alpha: 0.14)
              : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected
                ? primaryColor.withValues(alpha: 0.35)
                : Colors.white.withValues(alpha: 0.08),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? primaryColor : Colors.white70,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String leftText;
  final String rightText;
  final VoidCallback onSeeAll;
  final Color primaryColor;

  const _SectionHeader({
    required this.leftText,
    required this.rightText,
    required this.onSeeAll,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          leftText,
          style: GoogleFonts.inter(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          "|",
          style: TextStyle(color: Colors.white.withValues(alpha: 0.25)),
        ),
        const SizedBox(width: 8),
        TextButton(
          onPressed: onSeeAll,
          child: Text(
            rightText,
            style: TextStyle(
              color: primaryColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _HorizontalRow extends StatelessWidget {
  final int themeColor;
  final List<Widget> children;

  const _HorizontalRow({
    required this.themeColor,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 260,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: children,
      ),
    );
  }
}

class _HeroTileData {
  final String title;
  final String subtitle;
  final String? imageUrl;
  final Widget Function()? onOpen;

  _HeroTileData({
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.onOpen,
  });

  static _HeroTileData skeleton() => _HeroTileData(
        title: 'Loading',
        subtitle: 'Trending',
        imageUrl: null,
        onOpen: null,
      );
}

class _HeroTile extends StatelessWidget {
  final Color primaryColor;
  final _HeroTileData data;

  const _HeroTile({
    required this.primaryColor,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: data.onOpen == null
          ? null
          : () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => data.onOpen!()),
              );
            },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 180,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          color: Colors.white.withValues(alpha: 0.04),
          image: data.imageUrl == null
              ? null
              : DecorationImage(
                  image: CachedNetworkImageProvider(data.imageUrl!),
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
                const Color(0xFF121212).withValues(alpha: 0.08),
                const Color(0xFF121212).withValues(alpha: 0.92),
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
                  color: primaryColor.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(12),
                  border:
                      Border.all(color: primaryColor.withValues(alpha: 0.35)),
                ),
                child: Text(
                  data.subtitle.toUpperCase(),
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
                data.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(
                    data.onOpen == null
                        ? Icons.hourglass_empty
                        : Icons.play_arrow,
                    color: Colors.white.withValues(alpha: 0.8),
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    data.onOpen == null ? "Loading" : "Open",
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

class _HomePayload {
  final _HeroTileData heroLeft;
  final _HeroTileData heroRight;
  final List<GameModel> games;
  final List<MovieModel> movies;
  final List<SerieModel> series;
  final List<AnimeModel> animes;

  _HomePayload({
    required this.heroLeft,
    required this.heroRight,
    required this.games,
    required this.movies,
    required this.series,
    required this.animes,
  });

  factory _HomePayload.skeleton({
    required _HeroTileData heroLeft,
    required _HeroTileData heroRight,
  }) {
    final dummyGame = GameModel(id: 0, name: 'Loading', url: null);
    final dummyMovie = MovieModel(id: 0, title: 'Loading', imageURL: null);
    final dummySerie = SerieModel(id: 0, name: 'Loading', imageURL: null);
    final dummyAnime = AnimeModel(id: 0, title: 'Loading', imageURL: null);
    return _HomePayload(
      heroLeft: heroLeft,
      heroRight: heroRight,
      games: List.generate(7, (_) => dummyGame),
      movies: List.generate(7, (_) => dummyMovie),
      series: List.generate(7, (_) => dummySerie),
      animes: List.generate(7, (_) => dummyAnime),
    );
  }
}
