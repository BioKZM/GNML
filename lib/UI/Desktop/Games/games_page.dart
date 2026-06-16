import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:vault/data/model/game_model.dart';
import 'package:vault/Helper/theme_helper.dart';
import 'package:vault/Logic/gamepage_logic.dart';
import 'package:vault/ui/Desktop/Details/game_detail_page.dart';

const int _gamesPageChunkSize = 15;

class GamesPage extends StatefulWidget {
  const GamesPage({Key? key}) : super(key: key);

  @override
  State<GamesPage> createState() => _GamesPageState();
}

class _GamesPageState extends State<GamesPage>
    with AutomaticKeepAliveClientMixin {
  late Future<List<GameModel>> _popularFuture;
  late Future<List<GameModel>> _newlyReleasedFuture;
  late Future<List<GameModel>> _comingSoonFuture;
  late Future<List<GameModel>> _anticipatedFuture;

  int _popularVisible = _gamesPageChunkSize;
  int _newlyReleasedVisible = _gamesPageChunkSize;
  int _comingSoonVisible = _gamesPageChunkSize;
  int _anticipatedVisible = _gamesPageChunkSize;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _popularFuture = _fetchCategory('popularRightNow');
    _newlyReleasedFuture = _fetchCategory('newlyReleased');
    _comingSoonFuture = _fetchCategory('comingSoon');
    _anticipatedFuture = _fetchCategory('mostlyAnticipated');
  }

  Future<List<GameModel>> _fetchCategory(String key) async {
    final result = await GamePageLogic().getPopularGameList(key);
    return result.where((item) => item.id != null).toList();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final themeColor = Provider.of<ThemeProvider>(context).color;
    final primaryColor = Color(themeColor);

    return Scaffold(
      body: FutureBuilder<List<List<GameModel>>>(
        future: Future.wait([
          _popularFuture,
          _newlyReleasedFuture,
          _comingSoonFuture,
          _anticipatedFuture,
        ]),
        builder: (context, snapshot) {
          final loading = snapshot.connectionState != ConnectionState.done;
          final popular = snapshot.data?[0] ?? const <GameModel>[];
          final newlyReleased = snapshot.data?[1] ?? const <GameModel>[];
          final comingSoon = snapshot.data?[2] ?? const <GameModel>[];
          final anticipated = snapshot.data?[3] ?? const <GameModel>[];

          return Skeletonizer(
            enabled: loading,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1480),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _GamesTopHero(
                        primaryColor: primaryColor,
                        popular: popular.take(5).toList(),
                        newlyReleased: newlyReleased.take(5).toList(),
                        comingSoon: comingSoon.take(5).toList(),
                        anticipated: anticipated.take(5).toList(),
                      ),
                      const SizedBox(height: 22),
                      _GamesSection(
                        titleTop: 'POPULAR',
                        titleBottom: 'GAMES',
                        primaryColor: primaryColor,
                        items: popular.take(_popularVisible).toList(),
                        onShowMore: () {
                          setState(() {
                            _popularVisible =
                                (_popularVisible + _gamesPageChunkSize).clamp(
                              _gamesPageChunkSize,
                              popular.length,
                            );
                          });
                        },
                        hasMore: _popularVisible < popular.length,
                      ),
                      const SizedBox(height: 28),
                      _GamesSection(
                        titleTop: 'NEWLY',
                        titleBottom: 'RELEASED',
                        primaryColor: primaryColor,
                        items: newlyReleased.take(_newlyReleasedVisible).toList(),
                        onShowMore: () {
                          setState(() {
                            _newlyReleasedVisible =
                                (_newlyReleasedVisible + _gamesPageChunkSize)
                                    .clamp(
                              _gamesPageChunkSize,
                              newlyReleased.length,
                            );
                          });
                        },
                        hasMore: _newlyReleasedVisible < newlyReleased.length,
                      ),
                      const SizedBox(height: 28),
                      _GamesSection(
                        titleTop: 'COMING',
                        titleBottom: 'SOON',
                        primaryColor: primaryColor,
                        items: comingSoon.take(_comingSoonVisible).toList(),
                        onShowMore: () {
                          setState(() {
                            _comingSoonVisible =
                                (_comingSoonVisible + _gamesPageChunkSize)
                                    .clamp(
                              _gamesPageChunkSize,
                              comingSoon.length,
                            );
                          });
                        },
                        hasMore: _comingSoonVisible < comingSoon.length,
                      ),
                      const SizedBox(height: 28),
                      _GamesSection(
                        titleTop: 'MOSTLY',
                        titleBottom: 'ANTICIPATED',
                        primaryColor: primaryColor,
                        items: anticipated.take(_anticipatedVisible).toList(),
                        onShowMore: () {
                          setState(() {
                            _anticipatedVisible =
                                (_anticipatedVisible + _gamesPageChunkSize)
                                    .clamp(
                              _gamesPageChunkSize,
                              anticipated.length,
                            );
                          });
                        },
                        hasMore: _anticipatedVisible < anticipated.length,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _GamesTopHero extends StatelessWidget {
  final Color primaryColor;
  final List<GameModel> popular;
  final List<GameModel> newlyReleased;
  final List<GameModel> comingSoon;
  final List<GameModel> anticipated;

  const _GamesTopHero({
    required this.primaryColor,
    required this.popular,
    required this.newlyReleased,
    required this.comingSoon,
    required this.anticipated,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'GAMES',
            style: GoogleFonts.orbitron(
              color: Colors.white,
              fontSize: 42,
              fontWeight: FontWeight.w900,
              letterSpacing: 2.4,
            ),
          ),
          const SizedBox(height: 18),
          _HeroStripRow(
            label: 'Popular',
            items: popular,
            primaryColor: primaryColor,
          ),
          const SizedBox(height: 14),
          _HeroStripRow(
            label: 'Newly Released',
            items: newlyReleased,
            primaryColor: primaryColor,
          ),
          const SizedBox(height: 14),
          _HeroStripRow(
            label: 'Coming Soon',
            items: comingSoon,
            primaryColor: primaryColor,
          ),
          const SizedBox(height: 14),
          _HeroStripRow(
            label: 'Mostly Anticipated',
            items: anticipated,
            primaryColor: primaryColor,
          ),
        ],
      ),
    );
  }
}

class _HeroStripRow extends StatelessWidget {
  final String label;
  final List<GameModel> items;
  final Color primaryColor;

  const _HeroStripRow({
    required this.label,
    required this.items,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 180,
          child: Text(
            label,
            style: GoogleFonts.inter(
              color: Colors.white70,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Expanded(
          child: SizedBox(
            height: 108,
            child: Row(
              children: List.generate(items.length, (index) {
                final item = items[index];
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      right: index == items.length - 1 ? 0 : 10,
                    ),
                    child: _HeroStripCard(
                      item: item,
                      primaryColor: primaryColor,
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ],
    );
  }
}

class _HeroStripCard extends StatelessWidget {
  final GameModel item;
  final Color primaryColor;

  const _HeroStripCard({
    required this.item,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: item.id == null
          ? null
          : () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => GameDetailPage(gameID: item.id!),
                ),
              );
            },
      borderRadius: BorderRadius.circular(14),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: const Color(0xFF181818),
          image: item.imageURL != null
              ? DecorationImage(
                  image: CachedNetworkImageProvider(item.imageURL!),
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                )
              : null,
          border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withValues(alpha: 0.10),
                Colors.black.withValues(alpha: 0.48),
                Colors.black.withValues(alpha: 0.88),
              ],
            ),
          ),
          padding: const EdgeInsets.all(12),
          child: Align(
            alignment: Alignment.bottomLeft,
            child: Text(
              item.name ?? 'Game',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GamesSection extends StatelessWidget {
  final String titleTop;
  final String titleBottom;
  final Color primaryColor;
  final List<GameModel> items;
  final VoidCallback onShowMore;
  final bool hasMore;

  const _GamesSection({
    required this.titleTop,
    required this.titleBottom,
    required this.primaryColor,
    required this.items,
    required this.onShowMore,
    required this.hasMore,
  });

  @override
  Widget build(BuildContext context) {
    final first = items.take(5).toList();
    final second = items.skip(5).take(5).toList();
    final third = items.skip(10).take(5).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(24, 22, 24, 20),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                titleTop,
                style: GoogleFonts.orbitron(
                  color: Colors.white,
                  fontSize: 42,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2.2,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  titleBottom,
                  style: GoogleFonts.orbitron(
                    color: primaryColor,
                    fontSize: 34,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2.4,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        if (first.isNotEmpty)
          _GamesSectionMosaicRow(
            items: first,
            primaryColor: primaryColor,
            wideIndexes: const {1},
          ),
        if (second.isNotEmpty) const SizedBox(height: 14),
        if (second.isNotEmpty)
          _GamesSectionMosaicRow(
            items: second,
            primaryColor: primaryColor,
            wideIndexes: const {0, 3},
          ),
        if (third.isNotEmpty) const SizedBox(height: 14),
        if (third.isNotEmpty)
          _GamesSectionMosaicRow(
            items: third,
            primaryColor: primaryColor,
            wideIndexes: const {2, 3},
          ),
        if (hasMore) ...[
          const SizedBox(height: 18),
          Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton(
              onPressed: onShowMore,
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: primaryColor.withValues(alpha: 0.35)),
                foregroundColor: primaryColor,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text('Show more'),
            ),
          ),
        ],
      ],
    );
  }
}

class _GamesSectionMosaicRow extends StatelessWidget {
  final List<GameModel> items;
  final Color primaryColor;
  final Set<int> wideIndexes;

  const _GamesSectionMosaicRow({
    required this.items,
    required this.primaryColor,
    required this.wideIndexes,
  });

  @override
  Widget build(BuildContext context) {
    const gap = 12.0;
    const posterAspectRatio = 220 / 330;

    return LayoutBuilder(
      builder: (context, constraints) {
        final totalUnits = items.length + wideIndexes.length;
        final totalGap = gap * (items.length - 1);
        final unitWidth = (constraints.maxWidth - totalGap) / totalUnits;
        final rowHeight = unitWidth / posterAspectRatio;

        return SizedBox(
          height: rowHeight,
          child: Row(
            children: List.generate(items.length, (index) {
              final item = items[index];
              final isWide = wideIndexes.contains(index);
              final width = isWide ? (unitWidth * 2) + gap : unitWidth;
              return Padding(
                padding: EdgeInsets.only(
                  right: index == items.length - 1 ? 0 : gap,
                ),
                child: SizedBox(
                  width: width,
                  height: rowHeight,
                  child: isWide
                      ? _GamesWideCard(
                          item: item,
                          primaryColor: primaryColor,
                        )
                      : _GamesPosterCard(item: item),
                ),
              );
            }),
          ),
        );
      },
    );
  }
}

class _GamesPosterCard extends StatelessWidget {
  final GameModel item;

  const _GamesPosterCard({
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: item.id == null
          ? null
          : () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => GameDetailPage(gameID: item.id!),
                ),
              );
            },
      borderRadius: BorderRadius.circular(14),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: const Color(0xFF181818),
          image: item.imageURL != null
              ? DecorationImage(
                  image: CachedNetworkImageProvider(item.imageURL!),
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                )
              : null,
          border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
        ),
      ),
    );
  }
}

class _GamesWideCard extends StatelessWidget {
  final GameModel item;
  final Color primaryColor;

  const _GamesWideCard({
    required this.item,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: item.id == null
          ? null
          : () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => GameDetailPage(gameID: item.id!),
                ),
              );
            },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: const Color(0xFF181818),
          image: item.imageURL != null
              ? DecorationImage(
                  image: CachedNetworkImageProvider(item.imageURL!),
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                )
              : null,
          border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
        ),
        child: Container(
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
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: primaryColor.withValues(alpha: 0.35),
                  ),
                ),
                child: Text(
                  'FEATURED',
                  style: GoogleFonts.inter(
                    color: primaryColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              const SizedBox(height: 12),
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
              Text(
                item.summary?.trim().isNotEmpty == true
                    ? item.summary!.trim()
                    : 'Open the details and take a closer look.',
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
      ),
    );
  }
}
