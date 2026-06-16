import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import 'package:vault/data/model/game_model.dart';
import 'package:vault/Helper/content_type.dart';
import 'package:vault/Helper/rating_helper.dart';
import 'package:vault/Helper/theme_helper.dart';
import 'package:vault/Helper/ui_constants.dart';
import 'package:vault/Logic/gamepage_logic.dart';
import 'package:vault/Providers/library_provider.dart';

class GameDetailPage extends StatefulWidget {
  final int gameID;

  const GameDetailPage({
    super.key,
    required this.gameID,
  });

  @override
  State<GameDetailPage> createState() => _GameDetailPageState();
}

class _GameDetailPageState extends State<GameDetailPage> {
  final ScrollController _screenshotsController = ScrollController();
  final ScrollController _videosController = ScrollController();
  final LayerLink _accentButtonLink = LayerLink();
  Future<List<GameModel>>? _gameDetailsFuture;
  String? connectionText;
  Color? _detailAccentColor;
  OverlayEntry? _accentOverlayEntry;

  @override
  void initState() {
    super.initState();
    _gameDetailsFuture = GamePageLogic().getGameDetails(widget.gameID);
  }

  @override
  void dispose() {
    _accentOverlayEntry?.remove();
    _screenshotsController.dispose();
    _videosController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = Provider.of<ThemeProvider>(context).color;
    final accentColor = _detailAccentColor ?? Color(themeColor);
    _gameDetailsFuture ??= GamePageLogic().getGameDetails(widget.gameID);

    return FutureBuilder<List<GameModel>>(
      future: _gameDetailsFuture,
      builder: (context, snapshot) {
        if (snapshot.hasData &&
            snapshot.connectionState == ConnectionState.done) {
          final data = snapshot.data!.first;
          final coverUrl = _getImageUrl(data.image_id);
          final summary = _sanitizeText(
            data.summary,
            fallback: "Nothing here yet, but this one is worth a closer look.",
          );

          return Consumer<LibraryProvider>(
            builder: (context, libraryProvider, child) {
              final isLiked =
                  libraryProvider.isInLibrary(ContentType.games, widget.gameID);
              final compact = MediaQuery.of(context).size.width < 1360;

              return Scaffold(
                body: Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(coverUrl),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Container(
                    color: Colors.black.withValues(alpha: 0.74),
                    child: SingleChildScrollView(
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 90, sigmaY: 90),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(40, 28, 40, 40),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  _buildBackButton(accentColor),
                                  const Spacer(),
                                  _buildDetailColorButton(accentColor),
                                ],
                              ),
                              const SizedBox(height: 28),
                              compact
                                  ? Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        _buildPosterPanel(
                                          data: data,
                                          coverUrl: coverUrl,
                                          accentColor: accentColor,
                                          isLiked: isLiked,
                                          libraryProvider: libraryProvider,
                                        ),
                                        const SizedBox(height: 28),
                                        _buildOverviewPanel(
                                          data: data,
                                          accentColor: accentColor,
                                          summary: summary,
                                          compact: true,
                                        ),
                                        const SizedBox(height: 28),
                                        _buildUtilityRail(data, accentColor),
                                      ],
                                    )
                                  : Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          width: 260,
                                          child: _buildPosterPanel(
                                            data: data,
                                            coverUrl: coverUrl,
                                            accentColor: accentColor,
                                            isLiked: isLiked,
                                            libraryProvider: libraryProvider,
                                          ),
                                        ),
                                        const SizedBox(width: 72),
                                        Expanded(
                                          flex: 6,
                                          child: _buildOverviewPanel(
                                            data: data,
                                            accentColor: accentColor,
                                            summary: summary,
                                            compact: false,
                                          ),
                                        ),
                                        const SizedBox(width: 72),
                                        SizedBox(
                                          width: 320,
                                          child: _buildUtilityRail(
                                            data,
                                            accentColor,
                                          ),
                                        ),
                                      ],
                                    ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        }

        final loading = snapshot.connectionState != ConnectionState.done;
        return Scaffold(
          appBar: AppBar(title: const Text("Game Details")),
          body: Center(
            child: loading
                ? Skeletonizer(
                    enabled: true,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 220,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.06),
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text('Loading title'),
                          const SizedBox(height: 8),
                          const Text('Loading subtitle'),
                        ],
                      ),
                    ),
                  )
                : Card(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                              'An error occurred while loading data. Click to try again'),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: IconButton(
                            icon: const Icon(Icons.refresh),
                            onPressed: () {
                              setState(() {
                                connectionText = null;
                              });
                            },
                          ),
                        )
                      ],
                    ),
                  ),
          ),
        );
      },
    );
  }

  Widget _buildPosterPanel({
    required GameModel data,
    required String coverUrl,
    required Color accentColor,
    required bool isLiked,
    required LibraryProvider libraryProvider,
  }) {
    final storeLinks = _getStoreLinks(data);
    const spacing = 10.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: AspectRatio(
            aspectRatio: 0.72,
            child: Image.network(
              coverUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                color: Colors.white.withValues(alpha: 0.04),
                child: const Icon(
                  Icons.broken_image_outlined,
                  size: 40,
                  color: Colors.white38,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 18),
        _AnimatedLibraryButton(
          isActive: isLiked,
          accentColor: accentColor,
          onTap: () {
            if (isLiked) {
              libraryProvider.removeFromLibrary(
                ContentType.games,
                widget.gameID,
              );
            } else {
              libraryProvider.addOrUpdateItem(
                type: ContentType.games,
                id: widget.gameID,
                title: data.name,
                imageUrl: coverUrl,
                extra: {
                  "id": widget.gameID,
                  "type": "game",
                  "title": data.name,
                  "imageURL": coverUrl,
                  "folder": "library",
                },
              );
            }
          },
        ),
        if (storeLinks.isNotEmpty) ...[
          const SizedBox(height: 14),
          LayoutBuilder(
            builder: (context, constraints) {
              final gridMode = storeLinks.length >= 4;
              final buttonSize = gridMode
                  ? ((constraints.maxWidth - (spacing * 3)) / 4)
                      .clamp(44.0, 56.0)
                  : 52.0;

              return Align(
                alignment: Alignment.center,
                child: Wrap(
                  alignment: WrapAlignment.center,
                  spacing: spacing,
                  runSpacing: spacing,
                  children: storeLinks
                      .map(
                        (link) => _StoreSquareButton(
                          tooltip: link.label,
                          accentColor: accentColor,
                          size: buttonSize,
                          onTap: () => launchUrl(Uri.parse(link.url)),
                          child: _buildStoreIcon(link),
                        ),
                      )
                      .toList(),
                ),
              );
            },
          ),
        ],
      ],
    );
  }

  Widget _buildOverviewPanel({
    required GameModel data,
    required Color accentColor,
    required String summary,
    required bool compact,
  }) {
    final releaseDate = getDateTime(data);
    final genres = _mapNamedList(data.genres);
    final themes = _mapNamedList(data.themes);
    final keywords = _mapNamedList(data.keywords);
    final tags = [...genres, ...themes, ...keywords].take(10).toList();

    return Container(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A).withValues(alpha: 0.62),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                compact
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                        _buildOverviewPrimary(
                          data: data,
                          title: data.name ?? "Unknown title",
                          releaseDate: releaseDate,
                          summary: summary,
                          ),
                          const SizedBox(height: 24),
                          _buildOverviewMetaRail(
                            data: data,
                            accentColor: accentColor,
                          ),
                        ],
                      )
                    : Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 3,
                            child: _buildOverviewPrimary(
                              data: data,
                              title: data.name ?? "Unknown title",
                              releaseDate: releaseDate,
                              summary: summary,
                            ),
                          ),
                          const SizedBox(width: 24),
                          Expanded(
                            flex: 1,
                            child: _buildOverviewMetaRail(
                              data: data,
                              accentColor: accentColor,
                            ),
                          ),
                        ],
                      ),
                const SizedBox(height: 28),
                _buildScreenshotsStrip(data),
                if (tags.isNotEmpty) ...[
                  const SizedBox(height: 18),
                  _buildHashtagStrip(tags),
                ],
              ],
            ),
          ),
          const SizedBox(height: 28),
          _buildVideosPanel(data, accentColor),
        ],
      ),
    );
  }

  Widget _buildOverviewPrimary({
      required GameModel data,
      required String title,
      required String releaseDate,
      required String summary,
    }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 44,
            fontFamily: 'RobotoBold',
            height: 1.05,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(UIConstants.detailChipRadius),
            border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.calendar_today_rounded,
                size: 13,
                color: Colors.white70,
              ),
              const SizedBox(width: 8),
              Text(
                releaseDate,
                style: const TextStyle(
                  color: Colors.white70,
                  fontFamily: 'RobotoMedium',
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        Text(
          summary,
          textAlign: TextAlign.justify,
          style: const TextStyle(
            color: Colors.white70,
            fontFamily: 'RobotoMedium',
            fontSize: 16,
            height: 1.7,
          ),
        ),
      ],
    );
  }

  Widget _buildOverviewMetaRail({
    required GameModel data,
    required Color accentColor,
  }) {
    return _buildRatingsPanel(data, accentColor);
  }

  Widget _buildCreditsPage(
    List<String> developers,
    List<String> publishers,
    List<String> engines,
    Color accentColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildMetaInfoRow('Developers', developers, accentColor),
        const SizedBox(height: 22),
        _buildMetaInfoRow('Publishers', publishers, accentColor),
        const SizedBox(height: 22),
        _buildMetaInfoRow('Engines', engines, accentColor),
      ],
    );
  }

  Widget _buildHashtagStrip(List<String> tags) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: tags
          .map(
            (tag) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
              ),
              child: Text(
                '#${tag.replaceAll(' ', '').toLowerCase()}',
                style: const TextStyle(
                  color: Colors.white70,
                  fontFamily: 'RobotoMedium',
                  fontSize: 12,
                ),
              ),
            )
          )
          .toList(),
    );
  }

  Widget _buildPlatformsPage(List<String> platforms, Color accentColor) {
    if (platforms.isEmpty) return _buildMetaEmptySurface();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Available on',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'RobotoBold',
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 16),
        Align(
          alignment: Alignment.bottomLeft,
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: platforms
                .take(8)
                .map(
                  (platform) => Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(10),
                      border:
                          Border.all(color: Colors.white.withValues(alpha: 0.06)),
                    ),
                    child: Text(
                      platform,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontFamily: 'RobotoMedium',
                        fontSize: 11,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildMetaInfoRow(
      String title, List<String> values, Color? accentColor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 92,
          child: Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontFamily: 'RobotoMedium',
                fontSize: 14,
                letterSpacing: 0.2,
              ),
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: values.isEmpty
              ? const Padding(
                  padding: EdgeInsets.only(top: 6),
                  child: Text(
                    'Unknown',
                    style: TextStyle(
                      color: Colors.white38,
                      fontFamily: 'RobotoMedium',
                      fontSize: 14,
                    ),
                  ),
                )
              : Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: values
                      .take(5)
                      .map((value) => _buildDataChip(value, accentColor))
                      .toList(),
                ),
        ),
      ],
    );
  }

  Widget _buildMetaEmptySurface() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Text(
        'Nothing here yet.',
        style: TextStyle(
          color: Colors.white54,
          fontFamily: 'RobotoMedium',
          fontSize: 13,
        ),
      ),
    );
  }

  Widget _buildUtilityRail(GameModel data, Color accentColor) {
    final platforms = _mapNamedList(data.platforms);
    final developers =
        _filterCompanyNames(data.involved_companies, 'developer');
    final publishers =
        _filterCompanyNames(data.involved_companies, 'publisher');
    final engines = _mapNamedList(data.game_engines).take(4).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          constraints: const BoxConstraints(minHeight: 420),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.03),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const Text(
                'Metadata',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'RobotoBold',
                  fontSize: 24,
                ),
              ),
              const SizedBox(height: 18),
              _buildCreditsPage(developers, publishers, engines, accentColor),
              const SizedBox(height: 18),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Divider(
                  color: Colors.white.withValues(alpha: 0.08),
                  height: 1,
                ),
              ),
              const SizedBox(height: 18),
              _buildPlatformsPage(platforms, accentColor),
            ],
          ),
        ),
        const SizedBox(height: 20),
        _buildLinksPanel(data, accentColor),
      ],
    );
  }

  Widget _buildRatingsPanel(GameModel data, Color accentColor) {
    final metaScore = data.aggregated_rating?.toDouble();
    final userScore = data.rating?.toDouble();

    return _buildSubPanel(
      title: "Ratings",
      child: Column(
        children: [
          if (metaScore != null)
            _buildRatingRow("Meta Rating", metaScore, accentColor),
          if (metaScore != null && userScore != null)
            Divider(color: Colors.white.withValues(alpha: 0.05), height: 20),
          if (userScore != null)
            _buildRatingRow("User Rating", userScore, accentColor),
          if (metaScore == null && userScore == null)
            const Text(
              "No ratings available yet.",
              style: TextStyle(color: Colors.white54),
            ),
        ],
      ),
    );
  }

  Widget _buildLinksPanel(GameModel data, Color accentColor) {
    final grouped = _groupLinks(_getExternalLinks(data));

    return _buildSubPanel(
      title: "Links",
      child: grouped.isEmpty
          ? const Text(
              "Nothing linked yet.",
              style: TextStyle(color: Colors.white54),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: grouped.entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.key,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontFamily: 'RobotoBold',
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Column(
                        children: entry.value.map((link) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: _buildLinkTile(link, accentColor),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
    );
  }

  Widget _buildScreenshotsStrip(GameModel data) {
    final screenshots = data.screenshots_list ?? <dynamic>[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              "Screenshots",
              style: TextStyle(fontFamily: 'RobotoBold', fontSize: 20),
            ),
            if (screenshots.length > 1) ...[
              const SizedBox(width: 12),
              _buildArrowButton(
                icon: Icons.arrow_back_rounded,
                onPressed: () =>
                    _scrollController(_screenshotsController, -280),
              ),
              const SizedBox(width: 8),
              _buildArrowButton(
                icon: Icons.arrow_forward_rounded,
                onPressed: () => _scrollController(_screenshotsController, 280),
              ),
            ],
            const Spacer(),
          ],
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            final cardWidth =
                (constraints.maxWidth * 0.34).clamp(180.0, 240.0);

            return SizedBox(
              width: double.infinity,
              height: 132,
              child: screenshots.isEmpty
                  ? Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.03),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Text(
                          "Nothing here yet.",
                          style: TextStyle(color: Colors.white54),
                        ),
                      ),
                    )
                  : _buildHorizontalDragScroll(
                      ListView.separated(
                        controller: _screenshotsController,
                        physics: const BouncingScrollPhysics(),
                        scrollDirection: Axis.horizontal,
                        itemCount: screenshots.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(width: 12),
                        itemBuilder: (context, index) {
                          final imageId = screenshots[index];
                          final imageUrl =
                              "https://images.igdb.com/igdb/image/upload/t_screenshot_big/$imageId.png";

                          return GestureDetector(
                            onTap: () => _showScreenshotPreview(
                              screenshots
                                  .map((shot) =>
                                      "https://images.igdb.com/igdb/image/upload/t_screenshot_big/$shot.png")
                                  .toList(),
                              index,
                            ),
                            child: SizedBox(
                              width: cardWidth,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(
                                  UIConstants.detailMediaThumbRadius,
                                ),
                                child: Image.network(
                                  imageUrl,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildVideosPanel(GameModel data, Color accentColor) {
    final videos = _getVideoEntries(data);

    return _buildSubPanel(
      title: "Videos",
      trailing: videos.length > 1
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildArrowButton(
                  icon: Icons.arrow_back_rounded,
                  onPressed: () => _scrollController(_videosController, -320),
                ),
                const SizedBox(width: 8),
                _buildArrowButton(
                  icon: Icons.arrow_forward_rounded,
                  onPressed: () => _scrollController(_videosController, 320),
                ),
              ],
            )
          : null,
      child: SizedBox(
        height: 216,
        child: videos.isEmpty
            ? Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.03),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Center(
                  child: Text(
                    "No trailers yet.",
                    style: TextStyle(color: Colors.white54),
                  ),
                ),
              )
            : _buildHorizontalDragScroll(
                ListView.separated(
                  controller: _videosController,
                  physics: const BouncingScrollPhysics(),
                  scrollDirection: Axis.horizontal,
                  itemCount: videos.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final video = videos[index];
                    final videoId = video.key;
                    final label = video.value;
                    final thumbnailUrl =
                        "https://img.youtube.com/vi/$videoId/hqdefault.jpg";

                    return SizedBox(
                      width: 276,
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => _showVideoPreview(videos, index),
                          borderRadius: BorderRadius.circular(12),
                          child: Ink(
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.03),
                              borderRadius: BorderRadius.circular(
                                UIConstants.detailMediaThumbRadius,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                AspectRatio(
                                  aspectRatio: 16 / 9,
                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      Image.network(
                                        thumbnailUrl,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                Container(
                                          color: Colors.white.withValues(
                                            alpha: 0.04,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                            colors: [
                                              Colors.black.withValues(alpha: 0.42),
                                              Colors.black.withValues(alpha: 0.68),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Center(
                                        child: Container(
                                          width: 46,
                                          height: 46,
                                          decoration: BoxDecoration(
                                            color: accentColor.withValues(
                                              alpha: 0.92,
                                            ),
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.play_arrow_rounded,
                                            color: Colors.white,
                                            size: 26,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(12, 10, 12, 14),
                                  child: Text(
                                    label,
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontFamily: 'RobotoMedium',
                                      fontSize: 13,
                                      height: 1.35,
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
                ),
              ),
      ),
    );
  }

  Widget _buildSubPanel({
    required String title,
    Widget? titleIcon,
    Widget? trailing,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (titleIcon != null) ...[
                titleIcon,
                const SizedBox(width: 8),
              ],
              Text(
                title,
                style: const TextStyle(fontFamily: 'RobotoBold', fontSize: 20),
              ),
              const Spacer(),
              if (trailing != null) trailing,
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildRatingRow(String label, double score, Color accentColor) {
    final color = RatingHelper.getRatingColor(score);
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(Icons.star_rounded, color: color, size: 20),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white70,
                  fontFamily: 'RobotoMedium',
                ),
              ),
              const SizedBox(height: 4),
              Text(
                score.ceil().toString(),
                style: const TextStyle(
                  fontFamily: 'RobotoBold',
                  fontSize: 20,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            _ratingMood(score),
            style: TextStyle(color: color, fontFamily: 'RobotoBold'),
          ),
        ),
      ],
    );
  }

  Widget _buildArrowButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
        ),
        child: Icon(icon, color: Colors.white70, size: 15),
      ),
    );
  }

  Widget _buildPreviewNavButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.black.withValues(alpha: 0.38),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
          ),
          child: Icon(icon, color: Colors.white, size: 22),
        ),
      ),
    );
  }

  Widget _buildLinkTile(_ExternalLink link, Color accentColor) {
    final iconForeground = bestContrastOn(accentColor);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => launchUrl(Uri.parse(link.url)),
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.03),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 52,
                height: 48,
                decoration: BoxDecoration(
                  color: accentColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(14),
                    bottomLeft: Radius.circular(14),
                  ),
                ),
                child: Center(
                  child: _buildBrandGlyph(
                    link,
                    size: 16,
                    color: iconForeground,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  link.label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontFamily: 'RobotoMedium',
                    height: 1,
                  ),
                ),
              ),
              const Icon(
                Icons.north_east_rounded,
                size: 16,
                color: Colors.white54,
              ),
              const SizedBox(width: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBackButton(Color accentColor) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => Navigator.of(context).maybePop(),
        borderRadius: BorderRadius.circular(8),
        child: Ink(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: Center(
            child: Icon(Icons.arrow_back_rounded, color: accentColor, size: 18),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailColorButton(Color accentColor) {
    return CompositedTransformTarget(
      link: _accentButtonLink,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _toggleAccentOverlay(accentColor),
          borderRadius: BorderRadius.circular(10),
          child: Ink(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            ),
            child: Center(
              child: Container(
                width: 18,
                height: 18,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: SweepGradient(
                    colors: [
                      Colors.red,
                      Colors.orange,
                      Colors.yellow,
                      Colors.green,
                      Colors.cyan,
                      Colors.blue,
                      Colors.purple,
                      Colors.red,
                    ],
                  ),
                ),
                child: Center(
                  child: Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.18),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAccentPopover(Color accentColor) {
    final currentColor = _detailAccentColor ?? accentColor;
    final hsvColor = HSVColor.fromColor(currentColor);

    return Material(
      color: Colors.transparent,
      child: Container(
        width: 280,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF111111).withValues(alpha: 0.98),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.35),
              blurRadius: 24,
              spreadRadius: -8,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: currentColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  'Detail Accent',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'RobotoBold',
                    fontSize: 16,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: _hideAccentOverlay,
                  child: Icon(
                    Icons.close_rounded,
                    size: 16,
                    color: Colors.white.withValues(alpha: 0.55),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
                children: _detailAccentPresets.map((preset) {
                  final isSelected = preset.toARGB32() == currentColor.toARGB32();
                  return GestureDetector(
                    onTap: () => _updateDetailAccent(preset),
                    child: AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: preset,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected
                            ? Colors.white
                            : Colors.white.withValues(alpha: 0.14),
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 14),
            Text(
              'Hue',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.72),
                fontFamily: 'RobotoMedium',
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 6),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 5,
                thumbShape:
                    const RoundSliderThumbShape(enabledThumbRadius: 7),
                overlayShape:
                    const RoundSliderOverlayShape(overlayRadius: 14),
              ),
              child: Slider(
                min: 0,
                max: 360,
                value: hsvColor.hue,
                activeColor: currentColor,
                inactiveColor: Colors.white.withValues(alpha: 0.10),
                onChanged: (value) {
                  _updateDetailAccent(
                    hsvColor
                        .withHue(value)
                        .withSaturation(hsvColor.saturation)
                        .toColor(),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Value',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.72),
                fontFamily: 'RobotoMedium',
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 6),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 5,
                thumbShape:
                    const RoundSliderThumbShape(enabledThumbRadius: 7),
                overlayShape:
                    const RoundSliderOverlayShape(overlayRadius: 14),
              ),
              child: Slider(
                min: 0.2,
                max: 1,
                value: hsvColor.value.clamp(0.2, 1.0),
                activeColor: currentColor,
                inactiveColor: Colors.white.withValues(alpha: 0.10),
                onChanged: (value) {
                  _updateDetailAccent(
                    hsvColor
                        .withValue(value)
                        .withSaturation(hsvColor.saturation)
                        .toColor(),
                  );
                },
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                TextButton(
                  onPressed: () {
                    _updateDetailAccent(null);
                    _hideAccentOverlay();
                  },
                  child: const Text('Reset'),
                ),
                const Spacer(),
                FilledButton(
                  onPressed: _hideAccentOverlay,
                  child: const Text('Done'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _toggleAccentOverlay(Color accentColor) {
    if (_accentOverlayEntry != null) {
      _hideAccentOverlay();
      return;
    }

    _accentOverlayEntry = OverlayEntry(
      builder: (context) {
        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: _hideAccentOverlay,
                child: const SizedBox.expand(),
              ),
            ),
            CompositedTransformFollower(
              link: _accentButtonLink,
              showWhenUnlinked: false,
              targetAnchor: Alignment.bottomRight,
              followerAnchor: Alignment.topRight,
              offset: const Offset(0, 12),
              child: _buildAccentPopover(accentColor),
            ),
          ],
        );
      },
    );

    Overlay.of(context).insert(_accentOverlayEntry!);
  }

  void _hideAccentOverlay() {
    _accentOverlayEntry?.remove();
    _accentOverlayEntry = null;
  }

  void _updateDetailAccent(Color? color) {
    setState(() {
      _detailAccentColor = color;
    });
    _accentOverlayEntry?.markNeedsBuild();
  }

  Widget _buildHorizontalDragScroll(Widget child) {
    return ScrollConfiguration(
      behavior: const MaterialScrollBehavior().copyWith(
        dragDevices: {
          PointerDeviceKind.mouse,
          PointerDeviceKind.touch,
          PointerDeviceKind.trackpad,
          PointerDeviceKind.stylus,
          PointerDeviceKind.unknown,
        },
      ),
      child: child,
    );
  }

  void _scrollController(ScrollController controller, double offset) {
    if (!controller.hasClients) return;
    final target = (controller.offset + offset).clamp(
      0.0,
      controller.position.maxScrollExtent,
    );
    controller.animateTo(
      target,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
  }

  void _showScreenshotPreview(List<String> imageUrls, int initialIndex) {
    showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.84),
      builder: (context) {
        final screenSize = MediaQuery.of(context).size;
        final maxPreviewWidth =
            screenSize.width * UIConstants.detailPreviewWidthFactor;
        final maxPreviewHeight =
            screenSize.height * UIConstants.detailPreviewHeightFactor;
        var currentIndex = initialIndex;
        return StatefulBuilder(
          builder: (context, setDialogState) {
            void showAt(int nextIndex) {
              if (nextIndex < 0 || nextIndex >= imageUrls.length) return;
              setDialogState(() {
                currentIndex = nextIndex;
              });
            }

            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => Navigator.of(context).pop(),
              child: Material(
                color: Colors.transparent,
                child: GestureDetector(
                  onTap: () {},
                  child: Stack(
                    children: [
                      Center(
                        child: SizedBox(
                          width: maxPreviewWidth,
                          height: maxPreviewHeight,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Positioned.fill(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(
                                    UIConstants.detailPanelRadius,
                                  ),
                                  child: InteractiveViewer(
                                    minScale: 1,
                                    maxScale: 4,
                                    child: Image.network(
                                      imageUrls[currentIndex],
                                      width: maxPreviewWidth,
                                      height: maxPreviewHeight,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                              ),
                              if (currentIndex > 0)
                                Positioned(
                                  left: 16,
                                  child: _buildPreviewNavButton(
                                    icon: Icons.arrow_back_rounded,
                                    onTap: () => showAt(currentIndex - 1),
                                  ),
                                ),
                              if (currentIndex < imageUrls.length - 1)
                                Positioned(
                                  right: 16,
                                  child: _buildPreviewNavButton(
                                    icon: Icons.arrow_forward_rounded,
                                    onTap: () => showAt(currentIndex + 1),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        top: 24,
                        right: 24,
                        child: Material(
                          color: Colors.black.withValues(alpha: 0.45),
                          borderRadius: BorderRadius.circular(999),
                          child: IconButton(
                            onPressed: () => Navigator.of(context).pop(),
                            icon: const Icon(Icons.close, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showVideoPreview(
      List<MapEntry<String, String>> videos, int initialIndex) {
    var currentIndex = initialIndex;
    final controller = YoutubePlayerController.fromVideoId(
      videoId: videos[currentIndex].key,
      autoPlay: true,
      params: const YoutubePlayerParams(
        showControls: true,
        showFullscreenButton: true,
        strictRelatedVideos: true,
      ),
    );

    showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.88),
      builder: (dialogContext) {
        final screenSize = MediaQuery.of(dialogContext).size;
        final maxPreviewWidth =
            screenSize.width * UIConstants.detailVideoPreviewWidthFactor;
        final maxPreviewHeight =
            screenSize.height * UIConstants.detailVideoPreviewHeightFactor;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            void showAt(int nextIndex) {
              if (nextIndex < 0 || nextIndex >= videos.length) return;
              setDialogState(() {
                currentIndex = nextIndex;
              });
              controller.loadVideoById(videoId: videos[nextIndex].key);
            }

            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => Navigator.of(dialogContext).pop(),
              child: Material(
                color: Colors.transparent,
                child: GestureDetector(
                  onTap: () {},
                  child: Stack(
                    children: [
                      Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (currentIndex > 0)
                              Padding(
                                padding: const EdgeInsets.only(right: 20),
                                child: _buildPreviewNavButton(
                                  icon: Icons.arrow_back_rounded,
                                  onTap: () => showAt(currentIndex - 1),
                                ),
                              ),
                            SizedBox(
                              width: maxPreviewWidth,
                              height: maxPreviewHeight,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(
                                  UIConstants.detailPanelRadius,
                                ),
                                child: YoutubePlayerScaffold(
                                  controller: controller,
                                  builder: (context, player) => player,
                                ),
                              ),
                            ),
                            if (currentIndex < videos.length - 1)
                              Padding(
                                padding: const EdgeInsets.only(left: 20),
                                child: _buildPreviewNavButton(
                                  icon: Icons.arrow_forward_rounded,
                                  onTap: () => showAt(currentIndex + 1),
                                ),
                              ),
                          ],
                        ),
                      ),
                      Positioned(
                        top: 24,
                        right: 24,
                        child: Material(
                          color: Colors.black.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(16),
                          child: InkWell(
                            onTap: () => Navigator.of(dialogContext).pop(),
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              width: 46,
                              height: 46,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.10),
                                ),
                              ),
                              child: const Icon(
                                Icons.close_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    ).then((_) => controller.close());
  }

  Widget _buildStoreIcon(_ExternalLink link) {
    return _buildBrandGlyph(link, size: 22, color: Colors.white);
  }

  Widget _buildBrandGlyph(_ExternalLink link,
      {required double size, required Color color}) {
    switch (link.label) {
      case 'Steam':
        return FaIcon(FontAwesomeIcons.steamSymbol, size: size, color: color);
      case 'Epic Games':
        return Text(
          'EPIC',
          style: TextStyle(
            color: color,
            fontSize: size * 0.42,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.3,
          ),
        );
      case 'Xbox':
        return FaIcon(FontAwesomeIcons.xbox, size: size, color: color);
      case 'PlayStation':
        return FaIcon(
          FontAwesomeIcons.playstation,
          size: size,
          color: color,
        );
      case 'Blizzard':
        return Icon(Icons.ac_unit, size: size, color: color);
      case 'Discord':
        return FaIcon(FontAwesomeIcons.discord, size: size, color: color);
      case 'X':
        return FaIcon(FontAwesomeIcons.xTwitter, size: size, color: color);
      case 'Facebook':
        return FaIcon(FontAwesomeIcons.facebookF, size: size, color: color);
      case 'Instagram':
        return FaIcon(FontAwesomeIcons.instagram, size: size, color: color);
      case 'Twitch':
        return FaIcon(FontAwesomeIcons.twitch, size: size, color: color);
      case 'Reddit':
        return FaIcon(FontAwesomeIcons.redditAlien, size: size, color: color);
      case 'YouTube':
        return FaIcon(FontAwesomeIcons.youtube, size: size, color: color);
      case 'GOG':
        return Text('GOG',
            style: TextStyle(
              color: color,
              fontSize: size * 0.55,
              fontWeight: FontWeight.w700,
            ));
      case 'EA':
        return Text('EA',
            style: TextStyle(
              color: color,
              fontSize: size * 0.7,
              fontWeight: FontWeight.w700,
            ));
      case 'Nintendo':
        return Text('N',
            style: TextStyle(
              color: color,
              fontSize: size * 0.85,
              fontWeight: FontWeight.w700,
            ));
      case 'Ubisoft':
        return Text('U',
            style: TextStyle(
              color: color,
              fontSize: size * 0.85,
              fontWeight: FontWeight.w700,
            ));
      default:
        return Icon(link.icon, size: size, color: color);
    }
  }

  Widget _buildDateChip(String label, Color accentColor) {
    final foreground = bestContrastOn(accentColor);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: accentColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.calendar_month_outlined, size: 14, color: foreground),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: foreground,
              fontFamily: 'RobotoMedium',
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTagChip(String label, Color? accentColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
      decoration: BoxDecoration(
        color: accentColor ?? Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontFamily: 'RobotoMedium',
        ),
      ),
    );
  }

  Widget _buildDataChip(String label, Color? accentColor) {
    final background = accentColor ?? Colors.white.withValues(alpha: 0.05);
    final foreground =
        accentColor != null ? bestContrastOn(accentColor) : Colors.white;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: foreground,
          fontSize: 12,
          fontFamily: 'RobotoMedium',
        ),
      ),
    );
  }
}

class _ExternalLink {
  final String label;
  final String url;
  final IconData icon;

  const _ExternalLink({
    required this.label,
    required this.url,
    required this.icon,
  });
}

class _AnimatedLibraryButton extends StatelessWidget {
  final bool isActive;
  final Color accentColor;
  final VoidCallback onTap;

  const _AnimatedLibraryButton({
    required this.isActive,
    required this.accentColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOutCubic,
          height: 48,
          decoration: BoxDecoration(
            color: isActive ? accentColor : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
            border: isActive
                ? null
                : Border.all(color: Colors.white.withValues(alpha: 0.10)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isActive ? Icons.favorite : Icons.favorite_outline,
                color: Colors.white,
                size: 18,
              ),
              const SizedBox(width: 10),
              Text(
                isActive ? "In Library" : "Add to Library",
                style: TextStyle(
                  color: isActive ? Colors.white : Colors.white70,
                  fontFamily: 'RobotoBold',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StoreSquareButton extends StatefulWidget {
  final String tooltip;
  final Color accentColor;
  final VoidCallback onTap;
  final Widget child;
  final double size;

  const _StoreSquareButton({
    required this.tooltip,
    required this.accentColor,
    required this.onTap,
    required this.child,
    required this.size,
  });

  @override
  State<_StoreSquareButton> createState() => _StoreSquareButtonState();
}

class _StoreSquareButtonState extends State<_StoreSquareButton> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: widget.tooltip,
      preferBelow: true,
      verticalOffset: 18,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      margin: const EdgeInsets.only(top: 10),
      textStyle: const TextStyle(
        color: Colors.white,
        fontFamily: 'RobotoMedium',
        fontSize: 12,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF111111).withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.28),
            blurRadius: 16,
            spreadRadius: -6,
          ),
        ],
      ),
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovering = true),
        onExit: (_) => setState(() => _isHovering = false),
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: _isHovering
                    ? widget.accentColor.withValues(alpha: 0.55)
                    : Colors.white.withValues(alpha: 0.14),
              ),
              boxShadow: _isHovering
                  ? [
                      BoxShadow(
                        color: widget.accentColor.withValues(alpha: 0.18),
                        blurRadius: 12,
                        spreadRadius: -4,
                      ),
                    ]
                  : [],
            ),
            child: Center(
                child: IconTheme.merge(
                    data: IconThemeData(size: widget.size * 0.42),
                    child: widget.child)),
          ),
        ),
      ),
    );
  }
}

String _sanitizeText(String? source, {required String fallback}) {
  final decoded = utf8
      .decode(source.toString().runes.toList(), allowMalformed: true)
      .replaceAll(String.fromCharCode(65533), "")
      .trim();

  if (decoded.isEmpty || decoded == "null" || decoded == "Nothing here.") {
    return fallback;
  }
  return decoded;
}

List<MapEntry<String, String>> _getVideoEntries(GameModel data) {
  final source = data.videos;
  if (source == null || source.isEmpty) return const [];

  final entries = <MapEntry<String, String>>[];
  for (final item in source) {
    if (item is! Map) continue;

    final rawId = item['video_id'] ?? item['id'];
    if (rawId == null) continue;

    final videoId = rawId.toString().trim();
    if (videoId.isEmpty) continue;

    final title = item['name']?.toString().trim();
    entries.add(
      MapEntry(
        videoId,
        title == null || title.isEmpty ? 'Official Video' : title,
      ),
    );
  }

  return entries;
}

String _getImageUrl(String? imageId) {
  if (imageId == null || imageId == "0") {
    return "https://images.igdb.com/igdb/image/upload/t_cover_big/co1q1f.png";
  }
  return "https://images.igdb.com/igdb/image/upload/t_original/$imageId.png";
}

String getDateTime(GameModel data) {
  if (data.first_release_date == 0 || data.first_release_date == null) {
    return "Unknown release";
  }
  final dateTime =
      DateTime.fromMillisecondsSinceEpoch(data.first_release_date! * 1000);
  return DateFormat('dd MMMM yyyy').format(dateTime);
}

List<String> _mapNamedList(List<dynamic>? source) {
  if (source == null || source.isEmpty) return [];
  return source
      .map((entry) => entry is Map ? entry['name']?.toString() : null)
      .whereType<String>()
      .where((value) => value.trim().isNotEmpty)
      .toList();
}

List<String> _filterCompanyNames(List<dynamic>? companies, String roleKey) {
  if (companies == null || companies.isEmpty) return [];
  return companies
      .where((entry) => entry is Map && entry[roleKey] == true)
      .map((entry) {
        if (entry is Map &&
            entry['company'] is Map &&
            entry['company']['name'] != null) {
          return entry['company']['name'].toString();
        }
        return null;
      })
      .whereType<String>()
      .toList();
}

Widget getLanguageTable(GameModel data) {
  final support = data.language_support;
  if (support == null || support.isEmpty) {
    return const Text(
      "Unknown",
      style: TextStyle(color: Colors.white54),
    );
  }

  final tableColumns = [
    const DataColumn(
      label: Text(
        "Language",
        style: TextStyle(color: Colors.white, fontFamily: 'RobotoBold'),
      ),
    ),
    const DataColumn(
      label: Text(
        "Interface",
        style: TextStyle(color: Colors.white, fontFamily: 'RobotoBold'),
      ),
    ),
    const DataColumn(
      label: Text(
        "Audio",
        style: TextStyle(color: Colors.white, fontFamily: 'RobotoBold'),
      ),
    ),
    const DataColumn(
      label: Text(
        "Subtitles",
        style: TextStyle(color: Colors.white, fontFamily: 'RobotoBold'),
      ),
    ),
  ];

  final tableRows = support.entries.map((entry) {
    final values =
        (entry.value as List?)?.map((e) => e.toString()).toSet() ?? <String>{};
    return DataRow(cells: [
      DataCell(
        Text(
          entry.key.toString(),
          style:
              const TextStyle(color: Colors.white, fontFamily: 'HackRegular'),
        ),
      ),
      DataCell(_buildLanguageSupportIcon(values.contains('Interface'))),
      DataCell(_buildLanguageSupportIcon(values.contains('Audio'))),
      DataCell(_buildLanguageSupportIcon(values.contains('Subtitles'))),
    ]);
  }).toList();

  return SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: DataTable(columns: tableColumns, rows: tableRows),
  );
}

Widget _buildLanguageSupportIcon(bool enabled) {
  return Icon(
    enabled ? Icons.check : Icons.clear,
    color: enabled ? Colors.green : Colors.red,
  );
}

List<_ExternalLink> _getExternalLinks(GameModel data) {
  final websites = data.websites;
  if (websites == null || websites.isEmpty) return [];

  final links = <_ExternalLink>[];
  final seen = <String>{};
  for (final entry in websites) {
    if (entry is! Map || entry['url'] == null) continue;
    final url = entry['url'].toString();
    if (url.contains("wikipedia") || !seen.add(url)) continue;

    var label = "Website";
    var icon = Icons.link;
    if (url.contains("store.steampowered.com")) {
      label = "Steam";
      icon = Icons.sports_esports;
    } else if (url.contains("epicgames.com")) {
      label = "Epic Games";
      icon = Icons.videogame_asset_outlined;
    } else if (url.contains("gog.com")) {
      label = "GOG";
      icon = Icons.gamepad_outlined;
    } else if (url.contains("playstation.com")) {
      label = "PlayStation";
      icon = Icons.sports_esports_outlined;
    } else if (url.contains("ea.com")) {
      label = "EA";
      icon = Icons.sports;
    } else if (url.contains("nintendo.com")) {
      label = "Nintendo";
      icon = Icons.catching_pokemon;
    } else if (url.contains("xbox.com")) {
      label = "Xbox";
      icon = Icons.videogame_asset;
    } else if (url.contains("ubisoft.com")) {
      label = "Ubisoft";
      icon = Icons.blur_circular;
    } else if (url.contains("battle.net") || url.contains("blizzard.com")) {
      label = "Blizzard";
      icon = Icons.ac_unit;
    } else if (url.contains("discord")) {
      label = "Discord";
      icon = Icons.chat_bubble_outline;
    } else if (url.contains("facebook")) {
      label = "Facebook";
      icon = Icons.facebook;
    } else if (url.contains("twitter") || url.contains("x.com")) {
      label = "X";
      icon = Icons.close_rounded;
    } else if (url.contains("instagram")) {
      label = "Instagram";
      icon = Icons.camera_alt_outlined;
    } else if (url.contains("bsky.app") || url.contains("bluesky")) {
      label = "Bluesky";
      icon = Icons.cloud_outlined;
    } else if (url.contains("twitch")) {
      label = "Twitch";
      icon = Icons.live_tv_outlined;
    } else if (url.contains("reddit")) {
      label = "Reddit";
      icon = Icons.forum_outlined;
    } else if (url.contains("youtube.com") || url.contains("youtu.be")) {
      label = "YouTube";
      icon = Icons.play_circle_outline;
    } else {
      try {
        final uri = Uri.parse(url);
        label = uri.host.replaceFirst("www.", "");
        if (label.isEmpty) label = "Link";
      } catch (_) {
        label = "Link";
      }
    }
    links.add(_ExternalLink(label: label, url: url, icon: icon));
  }

  links.sort((a, b) => _linkPriority(a).compareTo(_linkPriority(b)));
  return links;
}

List<_ExternalLink> _getStoreLinks(GameModel data) {
  const storeLabels = {
    'Steam',
    'Epic Games',
    'GOG',
    'PlayStation',
    'EA',
    'Nintendo',
    'Xbox',
    'Ubisoft',
    'Blizzard',
  };
  return _getExternalLinks(data)
      .where((link) => storeLabels.contains(link.label))
      .toList();
}

Map<String, List<_ExternalLink>> _groupLinks(List<_ExternalLink> links) {
  final grouped = <String, List<_ExternalLink>>{};
  for (final link in links
      .where((link) => !_getStoreLinksFromLabels().contains(link.label))) {
    final section = _linkSection(link);
    grouped.putIfAbsent(section, () => []).add(link);
  }
  return grouped;
}

Set<String> _getStoreLinksFromLabels() {
  return {
    'Steam',
    'Epic Games',
    'GOG',
    'PlayStation',
    'EA',
    'Nintendo',
    'Xbox',
    'Ubisoft',
    'Blizzard',
  };
}

String _linkSection(_ExternalLink link) {
  if (link.label == 'Discord') return 'Community';
  if (const {
    'X',
    'Facebook',
    'Instagram',
    'Bluesky',
    'Twitch',
    'Reddit',
    'YouTube'
  }
      .contains(link.label)) {
    return 'Social';
  }
  return 'Other';
}

int _linkPriority(_ExternalLink link) {
  switch (link.label) {
    case 'Steam':
      return 0;
    case 'Epic Games':
      return 1;
    case 'PlayStation':
      return 2;
    case 'GOG':
      return 3;
    case 'Xbox':
      return 4;
    case 'Nintendo':
      return 5;
    case 'EA':
      return 6;
    case 'Ubisoft':
      return 7;
    case 'Blizzard':
      return 8;
    case 'Discord':
      return 9;
    case 'X':
      return 10;
    case 'Facebook':
      return 11;
    case 'Instagram':
      return 12;
    case 'Bluesky':
      return 13;
    case 'Twitch':
      return 14;
    case 'Reddit':
      return 15;
    case 'YouTube':
      return 16;
    default:
      return 20;
  }
}

String _ratingMood(double score) {
  if (score < 20) return "Bad";
  if (score < 50) return "Unlikely";
  if (score < 75) return "Average";
  if (score < 90) return "Good";
  return "Great";
}

const List<Color> _detailAccentPresets = [
  Color(0xFFB40000),
  Color(0xFFD9480F),
  Color(0xFFE0A800),
  Color(0xFF2B8A3E),
  Color(0xFF00897B),
  Color(0xFF1565C0),
  Color(0xFF5E35B1),
  Color(0xFFC2185B),
];
