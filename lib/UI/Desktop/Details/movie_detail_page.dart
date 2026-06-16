import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import 'package:vault/data/model/movie_model.dart';
import 'package:vault/Helper/content_type.dart';
import 'package:vault/Helper/rating_helper.dart';
import 'package:vault/Helper/theme_helper.dart';
import 'package:vault/Helper/ui_constants.dart';
import 'package:vault/Logic/moviepage_logic.dart';
import 'package:vault/Providers/library_provider.dart';

class MovieDetailPage extends StatefulWidget {
  final int movieID;

  const MovieDetailPage({super.key, required this.movieID});

  @override
  State<MovieDetailPage> createState() => _MovieDetailPageState();
}

class _MovieDetailPageState extends State<MovieDetailPage> {
  final ScrollController _screenshotsController = ScrollController();
  final ScrollController _videosController = ScrollController();
  final ScrollController _castController = ScrollController();
  final ScrollController _crewController = ScrollController();
  Future<List<MovieModel>>? _movieDetailsFuture;

  @override
  void initState() {
    super.initState();
    _movieDetailsFuture = MoviePageLogic().getMovieDetails(widget.movieID);
  }

  @override
  void dispose() {
    _screenshotsController.dispose();
    _videosController.dispose();
    _castController.dispose();
    _crewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accentColor = Color(Provider.of<ThemeProvider>(context).color);
    _movieDetailsFuture ??= MoviePageLogic().getMovieDetails(widget.movieID);

    return FutureBuilder<List<MovieModel>>(
      future: _movieDetailsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.hasData &&
            snapshot.data!.isNotEmpty) {
          final data = snapshot.data!.first;
          final posterUrl = data.imageURL ?? '';
          final backgroundUrl =
              data.background_image_url?.isNotEmpty == true
                  ? data.background_image_url!
                  : posterUrl;
          final overview = _sanitizeText(
            data.overview,
            fallback:
                'Nothing too dramatic here yet, but this one deserves a proper spotlight.',
          );
          final compact = MediaQuery.of(context).size.width < 1380;

          return Consumer<LibraryProvider>(
            builder: (context, libraryProvider, child) {
              final isLiked =
                  libraryProvider.isInLibrary(ContentType.movies, widget.movieID);

              return Scaffold(
                body: Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(backgroundUrl),
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
                              _buildBackButton(accentColor),
                              const SizedBox(height: 28),
                              compact
                                  ? Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        _buildPosterPanel(
                                          data: data,
                                          posterUrl: posterUrl,
                                          accentColor: accentColor,
                                          isLiked: isLiked,
                                          libraryProvider: libraryProvider,
                                        ),
                                        const SizedBox(height: 28),
                                        _buildOverviewPanel(
                                          data: data,
                                          overview: overview,
                                          accentColor: accentColor,
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
                                            posterUrl: posterUrl,
                                            accentColor: accentColor,
                                            isLiked: isLiked,
                                            libraryProvider: libraryProvider,
                                          ),
                                        ),
                                        const SizedBox(
                                            width: UIConstants.detailOuterGap),
                                        Expanded(
                                          flex: 6,
                                          child: _buildOverviewPanel(
                                            data: data,
                                            overview: overview,
                                            accentColor: accentColor,
                                            compact: false,
                                          ),
                                        ),
                                        const SizedBox(
                                            width: UIConstants.detailOuterGap),
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

        return Scaffold(
          body: Center(
            child: snapshot.connectionState == ConnectionState.waiting
                ? Skeletonizer(
                    enabled: true,
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 260,
                            height: 360,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          const SizedBox(height: 18),
                          Container(
                            width: 320,
                            height: 28,
                            color: Colors.white.withValues(alpha: 0.05),
                          ),
                          const SizedBox(height: 10),
                          Container(
                            width: 240,
                            height: 18,
                            color: Colors.white.withValues(alpha: 0.05),
                          ),
                        ],
                      ),
                    ),
                  )
                : IconButton(
                    onPressed: () {
                      setState(() {
                        _movieDetailsFuture =
                            MoviePageLogic().getMovieDetails(widget.movieID);
                      });
                    },
                    icon: const Icon(Icons.refresh_rounded),
                  ),
          ),
        );
      },
    );
  }

  Widget _buildPosterPanel({
    required MovieModel data,
    required String posterUrl,
    required Color accentColor,
    required bool isLiked,
    required LibraryProvider libraryProvider,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(UIConstants.detailPosterRadius),
          child: AspectRatio(
            aspectRatio: 0.72,
            child: Image.network(
              posterUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                color: Colors.white.withValues(alpha: 0.04),
                child: const Icon(
                  Icons.movie_creation_outlined,
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
                ContentType.movies,
                widget.movieID,
              );
            } else {
              libraryProvider.addOrUpdateItem(
                type: ContentType.movies,
                id: widget.movieID,
                title: data.title,
                imageUrl: posterUrl,
                extra: {
                  'id': widget.movieID,
                  'type': 'movie',
                  'title': data.title,
                  'imageURL': posterUrl,
                  'folder': 'library',
                },
              );
            }
          },
        ),
      ],
    );
  }

  Widget _buildOverviewPanel({
    required MovieModel data,
    required String overview,
    required Color accentColor,
    required bool compact,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A).withValues(alpha: 0.62),
            borderRadius: BorderRadius.circular(UIConstants.detailPanelRadius),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: compact
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildOverviewPrimary(
                      data: data,
                      overview: overview,
                      accentColor: accentColor,
                    ),
                    const SizedBox(height: 24),
                    _buildRatingsPanel(data),
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: _buildOverviewPrimary(
                        data: data,
                        overview: overview,
                        accentColor: accentColor,
                      ),
                    ),
                    const SizedBox(width: UIConstants.detailInnerGap),
                    Expanded(
                      flex: 1,
                      child: _buildRatingsPanel(data),
                    ),
                  ],
                ),
        ),
        const SizedBox(height: UIConstants.detailSectionGap),
        _buildCreditsPanel(data),
        const SizedBox(height: UIConstants.detailSectionGap),
        _buildVideosPanel(data),
      ],
    );
  }

  Widget _buildOverviewPrimary({
    required MovieModel data,
    required String overview,
    required Color accentColor,
  }) {
    final tags = _mapNamedList(data.genres);
    final title = _sanitizeText(data.title, fallback: 'Unknown title');
    final tagline = _sanitizeText(data.tagline);
    final screenshots = _extractScreenshotUrls(data.images);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 44,
                  fontFamily: 'RobotoBold',
                  height: 1.05,
                ),
              ),
            ),
            const SizedBox(width: 16),
            _buildNeutralDateChip(_formatDate(data.release_date)),
          ],
        ),
        if (tagline.isNotEmpty) ...[
          const SizedBox(height: 14),
          Text(
            tagline,
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 14,
              fontFamily: 'RobotoMedium',
            ),
          ),
        ],
        const SizedBox(height: 24),
        Text(
          overview,
          textAlign: TextAlign.justify,
          style: const TextStyle(
            color: Colors.white70,
            fontFamily: 'RobotoMedium',
            fontSize: 16,
            height: 1.7,
          ),
        ),
        if (screenshots.isNotEmpty) ...[
          const SizedBox(height: 36),
          _buildScreenshotsSection(screenshots),
        ],
        if (tags.isNotEmpty) ...[
          const SizedBox(height: 18),
          _buildHashtagStrip(tags, accentColor),
        ],
      ],
    );
  }

  Widget _buildRatingsPanel(MovieModel data) {
    final score = RatingHelper.getScore(data);
    final ratingColor = RatingHelper.getRatingColor(score);
    final mood = _ratingMood(score);

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.035),
        borderRadius: BorderRadius.circular(UIConstants.detailPanelRadius),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ratings',
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'RobotoBold',
              fontSize: 22,
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'TMDB Community',
            style: TextStyle(
              color: Colors.white70,
              fontFamily: 'RobotoMedium',
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.03),
              borderRadius:
                  BorderRadius.circular(UIConstants.detailMetaPanelRadius),
            ),
            child: Row(
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: ratingColor.withValues(alpha: 0.13),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(Icons.star_rounded, color: ratingColor, size: 26),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        score > 0 ? score.ceil().toString() : 'N/A',
                        style: const TextStyle(
                          color: Colors.white,
                          fontFamily: 'RobotoBold',
                          fontSize: 26,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  mood,
                  style: TextStyle(
                    color: ratingColor,
                    fontFamily: 'RobotoBold',
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildStatTile(
            'Vote Average',
            data.vote_average == null
                ? 'Unknown'
                : data.vote_average!.toStringAsFixed(1),
          ),
          const SizedBox(height: 10),
          _buildStatTile(
            'Votes',
            data.votecount?.toString() ?? 'Unknown',
          ),
          const SizedBox(height: 10),
          _buildStatTile(
            'Status',
            _sanitizeText(data.status, fallback: 'Unknown'),
          ),
        ],
      ),
    );
  }

  Widget _buildUtilityRail(MovieModel data, Color accentColor) {
    final productionCompanies = _mapNamedList(data.production_companies);
    final providerLinks = _extractProviderLinks(data.providers);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          constraints: const BoxConstraints(minHeight: 420),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.035),
            borderRadius:
                BorderRadius.circular(UIConstants.detailMetaPanelRadius),
            border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
              _buildMetaInfoRow(
                'Production',
                productionCompanies,
                null,
              ),
              if ((data.budget ?? 0) > 0 || (data.revenue ?? 0) > 0) ...[
                const SizedBox(height: 22),
                _buildRevenueBudgetGraph(data),
              ],
            ],
          ),
        ),
        const SizedBox(height: 18),
          if (providerLinks.isNotEmpty)
            _buildSubPanel(
              title: 'Where to Watch',
              child: Column(
                children: providerLinks.take(8).map((link) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _buildLinkTile(link),
                  );
                }).toList(),
              ),
            ),
        if (providerLinks.isNotEmpty) ...[
          const SizedBox(height: 10),
          Text(
            'Provided by JustWatch',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.45),
              fontFamily: 'RobotoMedium',
              fontSize: 11,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildScreenshotsSection(List<String> screenshots) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Screenshots',
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'RobotoBold',
                fontSize: 22,
              ),
            ),
            const SizedBox(width: 12),
            _buildArrowButton(
              icon: Icons.arrow_back_rounded,
              onPressed: () =>
                  _scrollController(_screenshotsController, -340),
            ),
            const SizedBox(width: 8),
            _buildArrowButton(
              icon: Icons.arrow_forward_rounded,
              onPressed: () => _scrollController(_screenshotsController, 340),
            ),
          ],
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 146,
          child: _buildHorizontalDragScroll(
            ListView.separated(
              controller: _screenshotsController,
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: screenshots.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final imageUrl = screenshots[index];
                return InkWell(
                  onTap: () => _showScreenshotPreview(screenshots, index),
                  borderRadius: BorderRadius.circular(
                    UIConstants.detailMediaThumbRadius,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(
                      UIConstants.detailMediaThumbRadius,
                    ),
                    child: Image.network(
                      imageUrl,
                      width: 256,
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVideosPanel(MovieModel data) {
    final videos = _extractVideoEntries(data.videos);

    return _buildSubPanel(
      title: 'Videos',
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
                    'No trailers yet.',
                    style: TextStyle(color: Colors.white54),
                  ),
                ),
              )
            : _buildHorizontalDragScroll(
                ListView.separated(
                  controller: _videosController,
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: videos.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final video = videos[index];
                    final thumbUrl =
                        'https://img.youtube.com/vi/${video.key}/hqdefault.jpg';

                    return InkWell(
                      onTap: () => _showVideoPreview(videos, index),
                      borderRadius: BorderRadius.circular(14),
                      child: SizedBox(
                        width: 250,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Image.network(thumbUrl, fit: BoxFit.cover),
                              Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.black.withValues(alpha: 0.20),
                                      Colors.black.withValues(alpha: 0.52),
                                    ],
                                  ),
                                ),
                              ),
                              Center(
                                child: Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.55),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color:
                                          Colors.white.withValues(alpha: 0.12),
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.play_arrow_rounded,
                                    color: Colors.white,
                                    size: 28,
                                  ),
                                ),
                              ),
                              Positioned(
                                left: 14,
                                right: 14,
                                bottom: 14,
                                child: Text(
                                  video.value,
                                  maxLines: 2,
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
                    );
                  },
                ),
              ),
      ),
    );
  }

  Widget _buildCreditsPanel(MovieModel data) {
    final cast = _extractCastEntries(data.cast);
    final crew = _extractCrewEntries(data.crew);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(UIConstants.detailPanelRadius),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCreditGroup('Cast', cast, _castController),
          const SizedBox(height: 18),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Divider(
              color: Colors.white.withValues(alpha: 0.08),
              height: 1,
            ),
          ),
          const SizedBox(height: 18),
          _buildCreditGroup('Crew', crew, _crewController),
        ],
      ),
    );
  }

  Widget _buildCreditGroup(
    String title,
    List<_CreditCardData> values,
    ScrollController controller,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontFamily: 'RobotoBold',
                fontSize: 18,
              ),
            ),
            const Spacer(),
            _buildArrowButton(
              icon: Icons.arrow_back_rounded,
              onPressed: () => _scrollController(controller, -320),
            ),
            const SizedBox(width: 8),
            _buildArrowButton(
              icon: Icons.arrow_forward_rounded,
              onPressed: () => _scrollController(controller, 320),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (values.isEmpty)
          const Text(
            'Unknown',
            style: TextStyle(
              color: Colors.white54,
              fontFamily: 'RobotoMedium',
              fontSize: 14,
            ),
          )
        else
          SizedBox(
            height: 232,
            child: _buildHorizontalDragScroll(
              ListView.separated(
                controller: controller,
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: values.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final value = values[index];
                  return Container(
                    width: 144,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.04),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.06),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(14),
                            ),
                            child: value.imageUrl == null
                                ? Container(
                                    color: Colors.white.withValues(alpha: 0.04),
                                    child: const Icon(
                                      Icons.person_outline_rounded,
                                      color: Colors.white38,
                                      size: 36,
                                    ),
                                  )
                                : Image.network(
                                    value.imageUrl!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        color: Colors.white.withValues(alpha: 0.04),
                                        child: const Icon(
                                          Icons.person_outline_rounded,
                                          color: Colors.white38,
                                          size: 36,
                                        ),
                                      );
                                    },
                                  ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.20),
                            borderRadius: const BorderRadius.vertical(
                              bottom: Radius.circular(14),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                value.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'RobotoBold',
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                value.subtitle,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white60,
                                  fontFamily: 'RobotoMedium',
                                  fontSize: 11,
                                  height: 1.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildHashtagStrip(List<String> tags, Color accentColor) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: tags.take(8).map((tag) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(UIConstants.detailChipRadius),
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
        );
      }).toList(),
    );
  }

  Widget _buildRevenueBudgetGraph(MovieModel data) {
    final budget = (data.budget ?? 0).toDouble();
    final revenue = (data.revenue ?? 0).toDouble();
    final maxValue = [budget, revenue].reduce((a, b) => a > b ? a : b);
    final budgetRatio = maxValue == 0 ? 0.0 : budget / maxValue;
    final revenueRatio = maxValue == 0 ? 0.0 : revenue / maxValue;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Performance',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'RobotoMedium',
            fontSize: 14,
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: 12),
        _buildMetricBar('Budget', budgetRatio, budget, const Color(0xFF7C8799)),
        const SizedBox(height: 10),
        _buildMetricBar(
          'Revenue',
          revenueRatio,
          revenue,
          const Color(0xFF4F8EF7),
        ),
      ],
    );
  }

  Widget _buildMetricBar(
    String label,
    double ratio,
    double value,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                color: Colors.white70,
                fontFamily: 'RobotoMedium',
                fontSize: 12,
              ),
            ),
            const Spacer(),
            Text(
              '\$${_compactCurrency(value.toInt())}',
              style: const TextStyle(
                color: Colors.white,
                fontFamily: 'RobotoMedium',
                fontSize: 12,
              ),
            ),
          ],
        ),
        const SizedBox(height: 7),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: ratio.clamp(0.0, 1.0),
            minHeight: 8,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            backgroundColor: Colors.white.withValues(alpha: 0.06),
          ),
        ),
      ],
    );
  }

  Widget _buildMetaInfoRow(
      String title,
      List<String> values,
      Color? accentColor,
    ) {
    final foreground = accentColor == null ? Colors.white70 : bestContrastOn(accentColor);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontFamily: 'RobotoMedium',
            fontSize: 14,
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: 10),
        if (values.isEmpty)
          const Text(
            'Unknown',
            style: TextStyle(
              color: Colors.white54,
              fontFamily: 'RobotoMedium',
              fontSize: 14,
            ),
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: values.take(8).map((value) {
              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                decoration: BoxDecoration(
                  color: accentColor ?? Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.06),
                  ),
                ),
                child: Text(
                  value,
                  style: TextStyle(
                    color: foreground,
                    fontFamily: 'RobotoMedium',
                    fontSize: 12,
                  ),
                ),
              );
            }).toList(),
          ),
      ],
    );
  }

  Widget _buildSubPanel({
    required String title,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(UIConstants.detailPanelRadius),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontFamily: 'RobotoBold',
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildStatTile(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white70,
                fontFamily: 'RobotoMedium',
                fontSize: 13,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontFamily: 'RobotoBold',
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLinkTile(_ProviderLink link) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: link.url == null ? null : () => launchUrl(Uri.parse(link.url!)),
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.03),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                if (link.logoPath != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      _providerLogoUrl(link.logoPath!),
                      width: 32,
                      height: 32,
                      fit: BoxFit.cover,
                    ),
                  )
                else
                  const Icon(
                    Icons.play_circle_outline_rounded,
                    size: 24,
                    color: Colors.white70,
                  ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    link.label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontFamily: 'RobotoMedium',
                      fontSize: 15,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                const Icon(
                  Icons.north_east_rounded,
                  size: 17,
                  color: Colors.white54,
                ),
                const SizedBox(width: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProviderLogo(_ProviderLink provider) {
    if (provider.logoPath != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Image.network(
          _providerLogoUrl(provider.logoPath!),
          width: 24,
          height: 24,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Text(
              provider.label.characters.first.toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontFamily: 'RobotoBold',
                fontSize: 16,
              ),
            );
          },
        ),
      );
    }

    return Text(
      provider.label.characters.first.toUpperCase(),
      style: const TextStyle(
        color: Colors.white,
        fontFamily: 'RobotoBold',
        fontSize: 16,
      ),
    );
  }

  Widget _buildDateChip(String label, Color accentColor) {
    final foreground = bestContrastOn(accentColor);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: accentColor,
        borderRadius: BorderRadius.circular(UIConstants.detailChipRadius),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.calendar_today_rounded, size: 13, color: foreground),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: foreground,
              fontFamily: 'RobotoMedium',
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNeutralDateChip(String label) {
    return Container(
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
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontFamily: 'RobotoMedium',
              fontSize: 12,
            ),
          ),
        ],
      ),
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

  void _showVideoPreview(List<MapEntry<String, String>> videos, int initialIndex) {
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

  List<_ProviderLink> _extractProviderLinks(dynamic providers) {
    if (providers is! Map) return const [];
    const regionPriority = ['TR', 'US', 'GB'];

    Map<String, dynamic>? regionData;
    for (final region in regionPriority) {
      final candidate = providers[region];
      if (candidate is Map<String, dynamic>) {
        regionData = candidate;
        break;
      }
      if (candidate is Map) {
        regionData = Map<String, dynamic>.from(candidate);
        break;
      }
    }

    if (regionData == null) {
      for (final entry in providers.entries) {
        if (entry.value is Map) {
          regionData = Map<String, dynamic>.from(entry.value as Map);
          break;
        }
      }
    }

    if (regionData == null) return const [];

    final regionUrl = regionData['link']?.toString();
    final seen = <int>{};
    final output = <_ProviderLink>[];

    for (final bucket in ['flatrate', 'buy', 'rent', 'free', 'ads']) {
      final list = regionData[bucket];
      if (list is! List) continue;
      for (final raw in list) {
        if (raw is! Map) continue;
        final map = Map<String, dynamic>.from(raw);
        final id = map['provider_id'];
        if (id is int && !seen.add(id)) continue;
        output.add(
          _ProviderLink(
            label: map['provider_name']?.toString() ?? 'Provider',
            logoPath: map['logo_path']?.toString(),
            url: regionUrl,
          ),
        );
      }
    }

    return output;
  }

  List<String> _extractScreenshotUrls(List<dynamic>? images) {
    if (images == null) return const [];
    return images
        .whereType<Map>()
        .map((item) => item['file_path']?.toString())
        .whereType<String>()
        .map((path) => 'https://image.tmdb.org/t/p/original$path')
        .take(12)
        .toList();
  }

  List<String> _mapNamedList(List<dynamic>? raw) {
    if (raw == null) return const [];
    return raw
        .whereType<Map>()
        .map((item) => item['name']?.toString().trim() ?? '')
        .where((value) => value.isNotEmpty)
        .toList();
  }

  List<_CreditCardData> _extractCastEntries(List<dynamic>? cast) {
    if (cast == null) return const [];
    return cast
        .whereType<Map>()
        .take(10)
        .map((item) {
          final name = item['name']?.toString().trim() ?? '';
          if (name.isEmpty) return null;
          final character =
              item['character']?.toString().trim().isNotEmpty == true
                  ? item['character'].toString().trim()
                  : 'Cast';
          final profilePath = item['profile_path']?.toString();
          return _CreditCardData(
            name: name,
            subtitle: character,
            imageUrl: profilePath == null || profilePath.isEmpty
                ? null
                : 'https://image.tmdb.org/t/p/w300$profilePath',
          );
        })
        .whereType<_CreditCardData>()
        .toList();
  }

  List<_CreditCardData> _extractCrewEntries(List<dynamic>? crew) {
    if (crew == null) return const [];
    return crew
        .whereType<Map>()
        .where((item) {
          final job = item['job']?.toString().toLowerCase();
          return job == 'director' ||
              job == 'writer' ||
              job == 'screenplay' ||
              job == 'producer';
        })
        .take(10)
        .map((item) {
          final name = item['name']?.toString().trim() ?? '';
          final job = item['job']?.toString().trim() ?? '';
          if (name.isEmpty) return null;
          final profilePath = item['profile_path']?.toString();
          return _CreditCardData(
            name: name,
            subtitle: job.isEmpty ? 'Crew' : job,
            imageUrl: profilePath == null || profilePath.isEmpty
                ? null
                : 'https://image.tmdb.org/t/p/w300$profilePath',
          );
        })
        .whereType<_CreditCardData>()
        .toList();
  }

  List<MapEntry<String, String>> _extractVideoEntries(List<dynamic>? videos) {
    if (videos == null) return const [];
    return videos
        .whereType<Map>()
        .where((item) {
          final site = item['site']?.toString().toLowerCase();
          final type = item['type']?.toString().toLowerCase();
          return site == 'youtube' &&
              item['key'] != null &&
              (type == null ||
                  type == 'trailer' ||
                  type == 'teaser' ||
                  type == 'clip');
        })
        .map(
          (item) => MapEntry(
            item['key'].toString(),
            _sanitizeText(item['name']?.toString(), fallback: 'Official Video'),
          ),
        )
        .toList();
  }

  String _sanitizeText(String? text, {String fallback = ''}) {
    if (text == null || text.trim().isEmpty) return fallback;
    return utf8
        .decode(text.runes.toList(), allowMalformed: true)
        .replaceAll('ï¿½', '')
        .trim();
  }

  String _formatDate(String? raw) {
    if (raw == null || raw.isEmpty) return 'Unknown release';
    final parsed = DateTime.tryParse(raw);
    if (parsed == null) return raw;
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${parsed.day} ${months[parsed.month - 1]} ${parsed.year}';
  }

  String _languageLabel(String? code) {
    switch (code?.toLowerCase()) {
      case 'en':
        return 'English';
      case 'ja':
        return 'Japanese';
      case 'ko':
        return 'Korean';
      case 'tr':
        return 'Turkish';
      case 'fr':
        return 'French';
      case 'de':
        return 'German';
      case 'es':
        return 'Spanish';
      default:
        return code?.toUpperCase() ?? 'Unknown';
    }
  }

  String _ratingMood(double score) {
    if (score < 20) return 'Bad';
    if (score < 50) return 'Unlikely';
    if (score < 75) return 'Average';
    if (score < 90) return 'Good';
    return 'Great';
  }

  String _providerLogoUrl(String path) {
    return 'https://image.tmdb.org/t/p/w200$path';
  }

  String _compactCurrency(int value) {
    if (value >= 1000000000) {
      return '${(value / 1000000000).toStringAsFixed(1)}B';
    }
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    }
    if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    }
    return value.toString();
  }
}

class _ProviderLink {
  final String label;
  final String? logoPath;
  final String? url;

  const _ProviderLink({
    required this.label,
    required this.logoPath,
    required this.url,
  });
}

class _CreditCardData {
  final String name;
  final String subtitle;
  final String? imageUrl;

  const _CreditCardData({
    required this.name,
    required this.subtitle,
    required this.imageUrl,
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
    final foreground = isActive ? bestContrastOn(accentColor) : Colors.white;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        color: isActive ? accentColor : Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        border: isActive
            ? null
            : Border.all(color: Colors.white.withValues(alpha: 0.10)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isActive
                      ? Icons.favorite_rounded
                      : Icons.favorite_outline_rounded,
                  size: 18,
                  color: foreground,
                ),
                const SizedBox(width: 10),
                Text(
                  isActive ? 'In Library' : 'Add to Library',
                  style: TextStyle(
                    color: foreground,
                    fontFamily: 'RobotoBold',
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StoreSquareButton extends StatefulWidget {
  final String tooltip;
  final Color accentColor;
  final double size;
  final VoidCallback? onTap;
  final Widget child;

  const _StoreSquareButton({
    required this.tooltip,
    required this.accentColor,
    required this.size,
    required this.onTap,
    required this.child,
  });

  @override
  State<_StoreSquareButton> createState() => _StoreSquareButtonState();
}

class _StoreSquareButtonState extends State<_StoreSquareButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: widget.tooltip,
      preferBelow: true,
      verticalOffset: 12,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF151515),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.24),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      textStyle: const TextStyle(
        color: Colors.white,
        fontFamily: 'RobotoMedium',
        fontSize: 12,
      ),
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          transform: Matrix4.translationValues(0, _hovered ? -2 : 0, 0),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.onTap,
              borderRadius:
                  BorderRadius.circular(UIConstants.detailStoreButtonRadius),
              child: Ink(
                width: widget.size,
                height: widget.size,
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(
                    UIConstants.detailStoreButtonRadius,
                  ),
                  border:
                      Border.all(color: Colors.white.withValues(alpha: 0.10)),
                ),
                child: Center(child: widget.child),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
