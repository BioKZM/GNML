import 'dart:convert';
import 'dart:ui';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import 'package:vault/data/model/serie_model.dart';
import 'package:vault/Helper/content_type.dart';
import 'package:vault/Helper/rating_helper.dart';
import 'package:vault/Helper/theme_helper.dart';
import 'package:vault/Helper/ui_constants.dart';
import 'package:vault/Logic/seriespage_logic.dart';
import 'package:vault/Providers/library_provider.dart';

class SerieDetailPage extends StatefulWidget {
  final int serieID;

  const SerieDetailPage({super.key, required this.serieID});

  @override
  State<SerieDetailPage> createState() => _SerieDetailPageState();
}

class _SerieDetailPageState extends State<SerieDetailPage> {
  final SeriesPageLogic _logic = SeriesPageLogic();
  final ScrollController _screenshots = ScrollController();
  final ScrollController _videos = ScrollController();
  Future<_SerieBundle?>? _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  @override
  void dispose() {
    _screenshots.dispose();
    _videos.dispose();
    super.dispose();
  }

  Future<_SerieBundle?> _load() async {
    final details = await _logic.getSerieDetails(widget.serieID);
    if (details.isEmpty) return null;
    final raw = await _logic.getSerieRawDetails(widget.serieID);
    final seasonNumbers = (((raw?['seasons'] as List?) ?? const [])
            .whereType<Map>()
            .map((e) => e['season_number'])
            .whereType<int>())
        .where((value) => value > 0)
        .take(6)
        .toList();
    final seasons = seasonNumbers.isEmpty
        ? <Map<String, dynamic>>[]
        : await _logic.getSeasonDetails(widget.serieID, seasonNumbers);
    return _SerieBundle(details.first, raw, seasons);
  }

  @override
  Widget build(BuildContext context) {
    final accentColor = Color(Provider.of<ThemeProvider>(context).color);
    return FutureBuilder<_SerieBundle?>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return Scaffold(
            body: Center(
              child: Skeletonizer(
                enabled: true,
                child: Container(
                  width: 320,
                  height: 420,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
              ),
            ),
          );
        }
        final bundle = snapshot.data;
        if (bundle == null) {
          return Scaffold(
            body: Center(
              child: IconButton(
                onPressed: () => setState(() => _future = _load()),
                icon: const Icon(Icons.refresh_rounded),
              ),
            ),
          );
        }
        final data = bundle.data;
        final posterUrl = data.imageURL ?? '';
        final screenshots = _screenshotUrls(bundle);
        final videos = _videoEntries(bundle);
        final compact = MediaQuery.of(context).size.width < 1380;
        final inLibrary = context.watch<LibraryProvider>().isInLibrary(
              ContentType.series,
              widget.serieID,
            );
        return Scaffold(
          body: Container(
            decoration: BoxDecoration(
              image: posterUrl.isEmpty
                  ? null
                  : DecorationImage(
                      image: NetworkImage(posterUrl),
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
                        _backButton(accentColor),
                        const SizedBox(height: 28),
                        compact
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _posterCard(data, posterUrl, accentColor, inLibrary),
                                  const SizedBox(height: 28),
                                  _overviewCard(bundle, screenshots),
                                  const SizedBox(height: 28),
                                  _metaCard(bundle),
                                ],
                              )
                            : Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    width: 260,
                                    child: _posterCard(
                                      data,
                                      posterUrl,
                                      accentColor,
                                      inLibrary,
                                    ),
                                  ),
                                  const SizedBox(width: UIConstants.detailOuterGap),
                                  Expanded(flex: 6, child: _overviewCard(bundle, screenshots)),
                                  const SizedBox(width: UIConstants.detailOuterGap),
                                  SizedBox(width: 320, child: _metaCard(bundle)),
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

  Widget _posterCard(SerieModel data, String posterUrl, Color accentColor, bool isLiked) {
    final library = context.read<LibraryProvider>();
    final foreground = isLiked ? bestContrastOn(accentColor) : Colors.white;
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      ClipRRect(
        borderRadius: BorderRadius.circular(UIConstants.detailPosterRadius),
        child: AspectRatio(
          aspectRatio: 0.72,
          child: Image.network(
            posterUrl,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              color: Colors.white.withValues(alpha: 0.04),
              child: const Icon(Icons.live_tv_rounded, size: 40, color: Colors.white38),
            ),
          ),
        ),
      ),
      const SizedBox(height: 18),
      InkWell(
        onTap: () {
          if (isLiked) {
            library.removeFromLibrary(ContentType.series, widget.serieID);
          } else {
            library.addOrUpdateItem(
              type: ContentType.series,
              id: widget.serieID,
              title: data.name,
              imageUrl: posterUrl,
              extra: {
                'id': widget.serieID,
                'type': 'serie',
                'title': data.name,
                'imageURL': posterUrl,
                'folder': 'library',
              },
            );
          }
        },
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          decoration: BoxDecoration(
            color: isLiked ? accentColor : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
            border: isLiked ? null : Border.all(color: Colors.white.withValues(alpha: 0.10)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(isLiked ? Icons.favorite_rounded : Icons.favorite_outline_rounded, size: 18, color: foreground),
            const SizedBox(width: 10),
            Text(isLiked ? 'In Library' : 'Add to Library', style: TextStyle(color: foreground, fontFamily: 'RobotoBold', fontSize: 14)),
          ]),
        ),
      ),
    ]);
  }

  Widget _overviewCard(_SerieBundle bundle, List<String> screenshots) {
    final data = bundle.data;
    final tags = _named(data.genres);
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A).withValues(alpha: 0.62),
        borderRadius: BorderRadius.circular(UIConstants.detailPanelRadius),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(
            child: Text(
              _clean(data.name, fallback: 'Unknown title'),
              style: const TextStyle(fontSize: 44, fontFamily: 'RobotoBold', height: 1.05),
            ),
          ),
          const SizedBox(width: 16),
          _dateChip(_formatDate(data.first_air_date)),
        ]),
        if (_clean(data.tagline).isNotEmpty) ...[
          const SizedBox(height: 14),
          Text(_clean(data.tagline), style: const TextStyle(color: Colors.white54, fontSize: 14, fontFamily: 'RobotoMedium')),
        ],
        const SizedBox(height: 24),
        Text(
          _clean(data.overview, fallback: 'This series still deserves a proper spotlight.'),
          textAlign: TextAlign.justify,
          style: const TextStyle(color: Colors.white70, fontFamily: 'RobotoMedium', fontSize: 16, height: 1.7),
        ),
        const SizedBox(height: 24),
        _ratingsPanel(data),
        if (screenshots.isNotEmpty) ...[
          const SizedBox(height: 28),
          _screenshotsPanel(screenshots),
        ],
        if (tags.isNotEmpty) ...[
          const SizedBox(height: 18),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: tags.take(8).map((tag) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(UIConstants.detailChipRadius),
                border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
              ),
              child: Text('#${tag.replaceAll(' ', '').toLowerCase()}', style: const TextStyle(color: Colors.white70, fontFamily: 'RobotoMedium', fontSize: 12)),
            )).toList(),
          ),
        ],
        if (videos.isNotEmpty) ...[
          const SizedBox(height: UIConstants.detailSectionGap),
          _videosPanel(videos),
        ],
        if (bundle.seasons.isNotEmpty) ...[
          const SizedBox(height: UIConstants.detailSectionGap),
          _seasonsPanel(bundle),
        ],
      ]),
    );
  }

  Widget _ratingsPanel(SerieModel data) {
    final score = RatingHelper.getScore(data);
    final ratingColor = RatingHelper.getRatingColor(score);
    final mood =
        score < 20 ? 'Bad' : score < 50 ? 'Unlikely' : score < 75 ? 'Average' : score < 90 ? 'Good' : 'Great';
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.035),
        borderRadius: BorderRadius.circular(UIConstants.detailPanelRadius),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Ratings', style: TextStyle(color: Colors.white, fontFamily: 'RobotoBold', fontSize: 22)),
        const SizedBox(height: 16),
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
            borderRadius: BorderRadius.circular(UIConstants.detailMetaPanelRadius),
          ),
          child: Row(children: [
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
              child: Text(
                score > 0 ? score.ceil().toString() : 'N/A',
                style: const TextStyle(color: Colors.white, fontFamily: 'RobotoBold', fontSize: 26),
              ),
            ),
            Text(mood, style: TextStyle(color: ratingColor, fontFamily: 'RobotoBold', fontSize: 14)),
          ]),
        ),
        const SizedBox(height: 16),
        _stat('Vote Average', data.vote_average?.toStringAsFixed(1) ?? 'Unknown'),
        const SizedBox(height: 10),
        _stat('Seasons', data.number_of_seasons?.toString() ?? 'Unknown'),
        const SizedBox(height: 10),
        _stat('Episodes', data.number_of_episodes?.toString() ?? 'Unknown'),
      ]),
    );
  }

  Widget _metaCard(_SerieBundle bundle) {
    final createdBy = _named(bundle.data.created_by);
    final production = _named(bundle.data.production_companies);
    final providers = _providers(bundle.data.providers);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.035),
          borderRadius: BorderRadius.circular(UIConstants.detailMetaPanelRadius),
          border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Metadata', style: TextStyle(color: Colors.white, fontFamily: 'RobotoBold', fontSize: 24)),
          const SizedBox(height: 18),
          _meta('Created by', createdBy),
          const SizedBox(height: 22),
          _meta('Production', production),
        ]),
      ),
      if (providers.isNotEmpty) ...[
        const SizedBox(height: 18),
        _subPanel(
          title: 'Where to Watch',
          child: Column(
            children: providers.take(8).map((provider) {
              return Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.03),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
                ),
                child: Text(provider.label, style: const TextStyle(color: Colors.white, fontFamily: 'RobotoMedium', fontSize: 14)),
              );
            }).toList(),
          ),
        ),
      ],
    ]);
  }

  Widget _screenshotsPanel(List<String> screenshots) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        const Text('Screenshots', style: TextStyle(color: Colors.white, fontFamily: 'RobotoBold', fontSize: 22)),
        const SizedBox(width: 12),
        _arrowButton(icon: Icons.arrow_back_rounded, onPressed: () => _scroll(_screenshots, -340)),
        const SizedBox(width: 8),
        _arrowButton(icon: Icons.arrow_forward_rounded, onPressed: () => _scroll(_screenshots, 340)),
      ]),
      const SizedBox(height: 14),
      SizedBox(
        height: 146,
        child: _dragScroll(
          ListView.separated(
            controller: _screenshots,
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: screenshots.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              return InkWell(
                onTap: () => _showScreenshotPreview(screenshots, index),
                borderRadius: BorderRadius.circular(UIConstants.detailMediaThumbRadius),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(UIConstants.detailMediaThumbRadius),
                  child: Image.network(screenshots[index], width: 256, fit: BoxFit.cover),
                ),
              );
            },
          ),
        ),
      ),
    ]);
  }

  Widget _videosPanel(List<MapEntry<String, String>> videos) {
    return _subPanel(
      title: 'Videos',
      child: SizedBox(
        height: 216,
        child: _dragScroll(
          ListView.separated(
            controller: _videos,
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: videos.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final video = videos[index];
              final thumbUrl = 'https://img.youtube.com/vi/${video.key}/hqdefault.jpg';
              return InkWell(
                onTap: () => _showVideoPreview(videos, index),
                borderRadius: BorderRadius.circular(14),
                child: SizedBox(
                  width: 260,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Stack(fit: StackFit.expand, children: [
                      Image.network(thumbUrl, fit: BoxFit.cover),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.22),
                              Colors.black.withValues(alpha: 0.78),
                            ],
                          ),
                        ),
                      ),
                      const Center(child: Icon(Icons.play_circle_fill_rounded, size: 52, color: Colors.white)),
                      Positioned(
                        left: 14,
                        right: 14,
                        bottom: 14,
                        child: Text(
                          video.value,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Colors.white, fontFamily: 'RobotoMedium', fontSize: 13, height: 1.35),
                        ),
                      ),
                    ]),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _seasonsPanel(_SerieBundle bundle) {
    return _subPanel(
      title: 'Seasons',
      child: Column(
        children: bundle.seasons.map((season) {
          final episodes = (season['episodes'] as List?) ?? const [];
          return Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(
                _clean(season['name']?.toString(), fallback: 'Season ${(season['season_number'] ?? '').toString()}'),
                style: const TextStyle(color: Colors.white, fontFamily: 'RobotoBold', fontSize: 18),
              ),
              const SizedBox(height: 6),
              Text('${episodes.length} episodes', style: const TextStyle(color: Colors.white54, fontFamily: 'RobotoMedium', fontSize: 12)),
              if (episodes.isNotEmpty) ...[
                const SizedBox(height: 14),
                Column(
                  children: episodes.take(8).map((rawEpisode) {
                    final episode = rawEpisode as Map;
                    return Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.04),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Text(
                                'E${episode['episode_number'] ?? '?'}',
                                style: const TextStyle(color: Colors.white, fontFamily: 'RobotoBold', fontSize: 12),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _clean(episode['name']?.toString(), fallback: 'Episode ${episode['episode_number'] ?? '?'}'),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(color: Colors.white, fontFamily: 'RobotoBold', fontSize: 14, height: 1.35),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  episode['air_date']?.toString().isNotEmpty == true
                                      ? _formatDate(episode['air_date']?.toString())
                                      : 'Runtime TBD',
                                  style: const TextStyle(color: Colors.white54, fontFamily: 'RobotoMedium', fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],
            ]),
          );
        }).toList(),
      ),
    );
  }

  Widget _meta(String title, List<String> values) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: const TextStyle(color: Colors.white, fontFamily: 'RobotoMedium', fontSize: 14)),
      const SizedBox(height: 10),
      if (values.isEmpty)
        const Text('Unknown', style: TextStyle(color: Colors.white54, fontFamily: 'RobotoMedium', fontSize: 14))
      else
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: values.take(10).map((value) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
            ),
            child: Text(value, style: const TextStyle(color: Colors.white70, fontFamily: 'RobotoMedium', fontSize: 12)),
          )).toList(),
        ),
    ]);
  }

  Widget _subPanel({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(UIConstants.detailPanelRadius),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(color: Colors.white, fontFamily: 'RobotoBold', fontSize: 20)),
        const SizedBox(height: 16),
        child,
      ]),
    );
  }

  Widget _stat(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(children: [
        Expanded(child: Text(label, style: const TextStyle(color: Colors.white70, fontFamily: 'RobotoMedium', fontSize: 13))),
        Text(value, style: const TextStyle(color: Colors.white, fontFamily: 'RobotoBold', fontSize: 14)),
      ]),
    );
  }

  Widget _dateChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(UIConstants.detailChipRadius),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.calendar_today_rounded, size: 13, color: Colors.white70),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(color: Colors.white70, fontFamily: 'RobotoMedium', fontSize: 12)),
      ]),
    );
  }

  Widget _backButton(Color accentColor) {
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
          child: Center(child: Icon(Icons.arrow_back_rounded, color: accentColor, size: 18)),
        ),
      ),
    );
  }

  Widget _arrowButton({required IconData icon, required VoidCallback onPressed}) {
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

  Widget _previewNavButton({required IconData icon, required VoidCallback onTap}) {
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

  void _scroll(ScrollController controller, double offset) {
    if (!controller.hasClients) return;
    final target = (controller.offset + offset).clamp(0.0, controller.position.maxScrollExtent);
    controller.animateTo(target, duration: const Duration(milliseconds: 320), curve: Curves.easeOutCubic);
  }

  void _showScreenshotPreview(List<String> imageUrls, int initialIndex) {
    showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.84),
      builder: (context) {
        final screenSize = MediaQuery.of(context).size;
        final maxPreviewWidth = screenSize.width * UIConstants.detailPreviewWidthFactor;
        final maxPreviewHeight = screenSize.height * UIConstants.detailPreviewHeightFactor;
        var currentIndex = initialIndex;
        return StatefulBuilder(builder: (context, setDialogState) {
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => Navigator.of(context).pop(),
            child: Material(
              color: Colors.transparent,
              child: Stack(children: [
                Center(
                  child: SizedBox(
                    width: maxPreviewWidth,
                    height: maxPreviewHeight,
                    child: Stack(alignment: Alignment.center, children: [
                      Positioned.fill(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(UIConstants.detailPanelRadius),
                          child: InteractiveViewer(
                            minScale: 1,
                            maxScale: 4,
                            child: Image.network(imageUrls[currentIndex], fit: BoxFit.contain),
                          ),
                        ),
                      ),
                      if (currentIndex > 0)
                        Positioned(
                          left: 16,
                          child: _previewNavButton(
                            icon: Icons.arrow_back_rounded,
                            onTap: () => setDialogState(() => currentIndex--),
                          ),
                        ),
                      if (currentIndex < imageUrls.length - 1)
                        Positioned(
                          right: 16,
                          child: _previewNavButton(
                            icon: Icons.arrow_forward_rounded,
                            onTap: () => setDialogState(() => currentIndex++),
                          ),
                        ),
                    ]),
                  ),
                ),
              ]),
            ),
          );
        });
      },
    );
  }

  void _showVideoPreview(List<MapEntry<String, String>> videos, int initialIndex) {
    var currentIndex = initialIndex;
    final controller = YoutubePlayerController.fromVideoId(
      videoId: videos[currentIndex].key,
      autoPlay: true,
      params: const YoutubePlayerParams(showControls: true, showFullscreenButton: true, strictRelatedVideos: true),
    );
    showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.88),
      builder: (dialogContext) {
        final screenSize = MediaQuery.of(dialogContext).size;
        final maxPreviewWidth = screenSize.width * UIConstants.detailVideoPreviewWidthFactor;
        final maxPreviewHeight = screenSize.height * UIConstants.detailVideoPreviewHeightFactor;
        return StatefulBuilder(builder: (context, setDialogState) {
          void showAt(int nextIndex) {
            if (nextIndex < 0 || nextIndex >= videos.length) return;
            setDialogState(() => currentIndex = nextIndex);
            controller.loadVideoById(videoId: videos[nextIndex].key);
          }
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => Navigator.of(dialogContext).pop(),
            child: Material(
              color: Colors.transparent,
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                if (currentIndex > 0)
                  Padding(
                    padding: const EdgeInsets.only(right: 20),
                    child: _previewNavButton(icon: Icons.arrow_back_rounded, onTap: () => showAt(currentIndex - 1)),
                  ),
                SizedBox(
                  width: maxPreviewWidth,
                  height: maxPreviewHeight,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(UIConstants.detailPanelRadius),
                    child: YoutubePlayerScaffold(controller: controller, builder: (context, player) => player),
                  ),
                ),
                if (currentIndex < videos.length - 1)
                  Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: _previewNavButton(icon: Icons.arrow_forward_rounded, onTap: () => showAt(currentIndex + 1)),
                  ),
              ]),
            ),
          );
        });
      },
    ).then((_) => controller.close());
  }

  Widget _dragScroll(Widget child) => ScrollConfiguration(
        behavior: const MaterialScrollBehavior().copyWith(
          dragDevices: {PointerDeviceKind.mouse, PointerDeviceKind.touch, PointerDeviceKind.trackpad},
        ),
        child: child,
      );

  String _clean(String? text, {String fallback = ''}) {
    if (text == null || text.trim().isEmpty) return fallback;
    return utf8.decode(text.runes.toList(), allowMalformed: true).replaceAll('Ã¯Â¿Â½', '').trim();
  }

  String _formatDate(String? raw) {
    if (raw == null || raw.isEmpty) return 'Unknown release';
    final parsed = DateTime.tryParse(raw);
    if (parsed == null) return raw;
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${parsed.day} ${months[parsed.month - 1]} ${parsed.year}';
  }

  List<String> _named(List<dynamic>? raw) => raw == null ? const [] : raw.whereType<Map>().map((item) => item['name']?.toString().trim() ?? '').where((value) => value.isNotEmpty).toList();

  List<String> _screenshotUrls(_SerieBundle bundle) {
    final source = ((bundle.raw?['images'] as Map?)?['backdrops'] as List?) ?? bundle.data.images;
    if (source == null) return const [];
    return source.whereType<Map>().map((item) => item['file_path']?.toString()).whereType<String>().map((path) => 'https://image.tmdb.org/t/p/original$path').take(12).toList();
  }

  List<MapEntry<String, String>> _videoEntries(_SerieBundle bundle) {
    final source = (((bundle.raw?['videos'] as Map?)?['results']) as List?) ?? const [];
    return source.whereType<Map>().where((item) => item['site']?.toString().toLowerCase() == 'youtube' && (item['key']?.toString().isNotEmpty ?? false)).map((item) => MapEntry(item['key'].toString(), _clean(item['name']?.toString(), fallback: 'Official Video'))).toList();
  }

  List<_ProviderLink> _providers(dynamic providers) {
    if (providers is! Map) return const [];
    const regionPriority = ['TR', 'US', 'GB'];
    Map<String, dynamic>? regionData;
    for (final region in regionPriority) {
      final candidate = providers[region];
      if (candidate is Map) {
        regionData = Map<String, dynamic>.from(candidate);
        break;
      }
    }
    if (regionData == null) return const [];
    final output = <_ProviderLink>[];
    final seen = <int>{};
    for (final bucket in ['flatrate', 'buy', 'rent', 'free', 'ads']) {
      final list = regionData[bucket];
      if (list is! List) continue;
      for (final raw in list) {
        if (raw is! Map) continue;
        final map = Map<String, dynamic>.from(raw);
        final id = map['provider_id'];
        if (id is int && !seen.add(id)) continue;
        output.add(_ProviderLink(map['provider_name']?.toString() ?? 'Provider'));
      }
    }
    return output;
  }
}

class _SerieBundle {
  final SerieModel data;
  final Map<String, dynamic>? raw;
  final List<Map<String, dynamic>> seasons;

  const _SerieBundle(this.data, this.raw, this.seasons);
}

class _ProviderLink {
  final String label;

  const _ProviderLink(this.label);
}
