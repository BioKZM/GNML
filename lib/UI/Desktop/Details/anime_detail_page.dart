import 'dart:convert';
import 'dart:ui';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import 'package:vault/Helper/content_type.dart';
import 'package:vault/Helper/rating_helper.dart';
import 'package:vault/Helper/theme_helper.dart';
import 'package:vault/Helper/ui_constants.dart';
import 'package:vault/Logic/animepage_logic.dart';
import 'package:vault/Providers/library_provider.dart';
import 'package:vault/data/model/anime_model.dart';

class AnimeDetailPage extends StatefulWidget {
  final int animeId;

  const AnimeDetailPage({super.key, required this.animeId});

  @override
  State<AnimeDetailPage> createState() => _AnimeDetailPageState();
}

class _AnimeDetailPageState extends State<AnimeDetailPage> {
  final AnimePageLogic _logic = AnimePageLogic();
  final ScrollController _screenshots = ScrollController();
  final ScrollController _videos = ScrollController();
  final ScrollController _cast = ScrollController();
  Future<_AnimeBundle?>? _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  @override
  void dispose() {
    _screenshots.dispose();
    _videos.dispose();
    _cast.dispose();
    super.dispose();
  }

  Future<_AnimeBundle?> _load() async {
    final details = await _logic.getAnimeDetails(widget.animeId);
    if (details == null) return null;
    final raw = await _logic.getAnimeRawDetails(widget.animeId);
    final pictures = await _logic.getAnimePictures(widget.animeId);
    final videos = await _logic.getAnimeVideos(widget.animeId);
    final characters = await _logic.getAnimeCharacters(widget.animeId);
    final episodes = await _logic.getAnimeEpisodes(widget.animeId);
    return _AnimeBundle(details, raw, pictures, videos, characters, episodes);
  }

  @override
  Widget build(BuildContext context) {
    final accentColor = Color(Provider.of<ThemeProvider>(context).color);

    return FutureBuilder<_AnimeBundle?>(
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
        final backgroundUrl = _backgroundUrl(bundle) ?? posterUrl;
        final compact = MediaQuery.of(context).size.width < 1380;
        final inLibrary = context.watch<LibraryProvider>().isInLibrary(
              ContentType.anime,
              widget.animeId,
            );

        return Scaffold(
          body: Container(
            decoration: BoxDecoration(
              image: backgroundUrl.isEmpty
                  ? null
                  : DecorationImage(
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
                        _backButton(accentColor),
                        const SizedBox(height: 28),
                        compact
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _posterCard(data, posterUrl, accentColor, inLibrary),
                                  const SizedBox(height: 28),
                                  _overviewPanel(bundle, compact: true),
                                  const SizedBox(height: 28),
                                  _metaPanel(bundle),
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
                                  Expanded(
                                    flex: 6,
                                    child: _overviewPanel(bundle, compact: false),
                                  ),
                                  const SizedBox(width: UIConstants.detailOuterGap),
                                  SizedBox(width: 320, child: _metaPanel(bundle)),
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

  Widget _posterCard(
    AnimeModel data,
    String posterUrl,
    Color accentColor,
    bool isLiked,
  ) {
    final library = context.read<LibraryProvider>();
    final foreground = isLiked ? bestContrastOn(accentColor) : Colors.white;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(UIConstants.detailPosterRadius),
          child: AspectRatio(
            aspectRatio: 0.72,
            child: _image(
              posterUrl,
              fit: BoxFit.cover,
              fallback: const Icon(
                Icons.movie_filter_rounded,
                color: Colors.white38,
                size: 38,
              ),
            ),
          ),
        ),
        const SizedBox(height: 18),
        InkWell(
          onTap: () {
            if (isLiked) {
              library.removeFromLibrary(ContentType.anime, widget.animeId);
            } else {
              library.addOrUpdateItem(
                type: ContentType.anime,
                id: widget.animeId,
                title: data.title,
                imageUrl: posterUrl,
                extra: {
                  'id': widget.animeId,
                  'type': 'anime',
                  'title': data.title,
                  'imageURL': posterUrl,
                  'folder': 'library',
                },
              );
            }
          },
          borderRadius: BorderRadius.circular(14),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: isLiked ? accentColor : Colors.transparent,
              borderRadius: BorderRadius.circular(14),
              border: isLiked
                  ? null
                  : Border.all(color: Colors.white.withValues(alpha: 0.10)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isLiked
                      ? Icons.favorite_rounded
                      : Icons.favorite_outline_rounded,
                  color: foreground,
                  size: 18,
                ),
                const SizedBox(width: 10),
                Text(
                  isLiked ? 'In Library' : 'Add to Library',
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
      ],
    );
  }

  Widget _overviewPanel(_AnimeBundle bundle, {required bool compact}) {
    return Container(
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
                _overviewPrimary(bundle),
                const SizedBox(height: 24),
                _ratingsPanel(bundle),
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 3, child: _overviewPrimary(bundle)),
                const SizedBox(width: UIConstants.detailInnerGap),
                Expanded(flex: 1, child: _ratingsPanel(bundle)),
              ],
            ),
    );
  }

  Widget _overviewPrimary(_AnimeBundle bundle) {
    final data = bundle.data;
    final screenshots = _pictureUrls(bundle);
    final tags = (data.genres ?? const [])
        .whereType<String>()
        .where((e) => e.trim().isNotEmpty)
        .toList();
    final videos = _videoEntries(bundle);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                _clean(data.title, fallback: 'Unknown title'),
                style: const TextStyle(
                  fontSize: 44,
                  fontFamily: 'RobotoBold',
                  height: 1.05,
                ),
              ),
            ),
            const SizedBox(width: 16),
            _dateChip(_clean(data.aired_string, fallback: 'Unknown release')),
          ],
        ),
        const SizedBox(height: 24),
        Text(
          _clean(
            data.synopsis,
            fallback:
                'This anime still deserves a proper spotlight, but the synopsis has not arrived yet.',
          ),
          textAlign: TextAlign.justify,
          style: const TextStyle(
            color: Colors.white70,
            fontFamily: 'RobotoMedium',
            fontSize: 16,
            height: 1.7,
          ),
        ),
        if (screenshots.isNotEmpty) ...[
          const SizedBox(height: 28),
          _screenshotsPanel(screenshots),
        ],
        if (tags.isNotEmpty) ...[
          const SizedBox(height: 18),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: tags.take(8).map((tag) {
              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(
                    UIConstants.detailChipRadius,
                  ),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.06),
                  ),
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
          ),
        ],
        if (videos.isNotEmpty) ...[
          const SizedBox(height: UIConstants.detailSectionGap),
          _videosPanel(videos),
        ],
        if (bundle.episodes.isNotEmpty) ...[
          const SizedBox(height: UIConstants.detailSectionGap),
          _episodesPanel(bundle.episodes),
        ],
      ],
    );
  }

  Widget _ratingsPanel(_AnimeBundle bundle) {
    final data = bundle.data;
    final score = RatingHelper.getScore(data);
    final ratingColor = RatingHelper.getRatingColor(score);
    final mood = _ratingMood(score);
    final rank = bundle.raw?['rank']?.toString();
    final popularity = bundle.raw?['popularity']?.toString();
    final members = bundle.raw?['members']?.toString();

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
            'MAL Community',
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
              borderRadius: BorderRadius.circular(
                UIConstants.detailMetaPanelRadius,
              ),
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
                  child: Text(
                    score > 0 ? score.ceil().toString() : 'N/A',
                    style: const TextStyle(
                      color: Colors.white,
                      fontFamily: 'RobotoBold',
                      fontSize: 26,
                    ),
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
          _stat('Episodes', data.episodes?.toString() ?? 'Unknown'),
          const SizedBox(height: 10),
          _stat('Rank', _clean(rank, fallback: 'Unknown')),
          const SizedBox(height: 10),
          _stat('Popularity', _clean(popularity, fallback: members ?? 'Unknown')),
        ],
      ),
    );
  }

  Widget _metaPanel(_AnimeBundle bundle) {
    final details = <String>[
      if (_clean(bundle.data.type).isNotEmpty) _clean(bundle.data.type),
      if (_clean(bundle.data.status).isNotEmpty) _clean(bundle.data.status),
      if (_clean(bundle.data.rating).isNotEmpty) _clean(bundle.data.rating),
      if (_clean(bundle.raw?['source']?.toString()).isNotEmpty)
        _clean(bundle.raw?['source']?.toString()),
    ];
    final studios = _namedEntries(bundle.raw?['studios']);
    final producers = _namedEntries(bundle.raw?['producers']);
    final demographics = _namedEntries(bundle.raw?['demographics']);
    final cast = _castEntries(bundle.characters);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: 420),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.035),
            borderRadius: BorderRadius.circular(
              UIConstants.detailMetaPanelRadius,
            ),
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
              _metaSection('Details', details),
              if (studios.isNotEmpty) ...[
                const SizedBox(height: 22),
                _metaSection('Studios', studios),
              ],
              if (producers.isNotEmpty) ...[
                const SizedBox(height: 22),
                _metaSection('Producers', producers),
              ],
              if (demographics.isNotEmpty) ...[
                const SizedBox(height: 22),
                _metaSection('Demographics', demographics),
              ],
            ],
          ),
        ),
        if (cast.isNotEmpty) ...[
          const SizedBox(height: 18),
          _subPanel(
            title: 'Cast',
            child: SizedBox(
              height: 244,
              child: ListView.separated(
                controller: _cast,
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: cast.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final item = cast[index];
                  return Container(
                    width: 150,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.03),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.05),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(14),
                            ),
                            child: _image(
                              item.imageUrl,
                              fit: BoxFit.cover,
                              fallback: const Icon(
                                Icons.person_rounded,
                                color: Colors.white38,
                                size: 34,
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.name,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'RobotoBold',
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                item.subtitle,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white54,
                                  fontFamily: 'RobotoMedium',
                                  fontSize: 12,
                                  height: 1.35,
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
      ],
    );
  }

  Widget _screenshotsPanel(List<String> screenshots) {
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
            _arrowButton(
              icon: Icons.arrow_back_rounded,
              onPressed: () => _scroll(_screenshots, -340),
            ),
            const SizedBox(width: 8),
            _arrowButton(
              icon: Icons.arrow_forward_rounded,
              onPressed: () => _scroll(_screenshots, 340),
            ),
          ],
        ),
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
                  borderRadius: BorderRadius.circular(
                    UIConstants.detailMediaThumbRadius,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(
                      UIConstants.detailMediaThumbRadius,
                    ),
                    child: SizedBox(
                      width: 256,
                      child: _image(
                        screenshots[index],
                        fit: BoxFit.cover,
                        fallback: const Icon(
                          Icons.image_not_supported_outlined,
                          color: Colors.white38,
                        ),
                      ),
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
              final thumbUrl =
                  'https://img.youtube.com/vi/${video.key}/hqdefault.jpg';
              return InkWell(
                onTap: () => _showVideoPreview(videos, index),
                borderRadius: BorderRadius.circular(14),
                child: SizedBox(
                  width: 260,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        _image(
                          thumbUrl,
                          fit: BoxFit.cover,
                          fallback: const Icon(
                            Icons.play_circle_outline_rounded,
                            color: Colors.white38,
                            size: 42,
                          ),
                        ),
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
                        const Center(
                          child: Icon(
                            Icons.play_circle_fill_rounded,
                            size: 52,
                            color: Colors.white,
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

  Widget _episodesPanel(List<Map<String, dynamic>> episodes) {
    return _subPanel(
      title: 'Episodes',
      child: Column(
        children: episodes.take(12).map((episode) {
          final title = _clean(
            episode['title']?.toString(),
            fallback: 'Episode ${(episode['mal_id'] ?? '').toString()}',
          );
          final aired = _clean(
            episode['aired']?.toString(),
            fallback: 'Airing TBD',
          );
          final duration = _clean(
            episode['duration']?.toString(),
            fallback: 'Runtime TBD',
          );
          return Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
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
                      'E${episode['mal_id'] ?? '?'}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontFamily: 'RobotoBold',
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontFamily: 'RobotoBold',
                          fontSize: 14,
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '$aired • $duration',
                        style: const TextStyle(
                          color: Colors.white54,
                          fontFamily: 'RobotoMedium',
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _metaSection(String title, List<String> values) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontFamily: 'RobotoMedium',
            fontSize: 14,
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
            children: values.take(10).map((value) {
              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.06),
                  ),
                ),
                child: Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white70,
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

  Widget _subPanel({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
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

  Widget _dragScroll(Widget child) => ScrollConfiguration(
        behavior: const MaterialScrollBehavior().copyWith(
          dragDevices: {
            PointerDeviceKind.mouse,
            PointerDeviceKind.touch,
            PointerDeviceKind.trackpad,
          },
        ),
        child: child,
      );

  Widget _stat(String label, String value) {
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

  Widget _dateChip(String label) {
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
          child: Center(
            child: Icon(Icons.arrow_back_rounded, color: accentColor, size: 18),
          ),
        ),
      ),
    );
  }

  Widget _arrowButton({
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

  Widget _previewNavButton({
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

  void _scroll(ScrollController controller, double offset) {
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
            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => Navigator.of(context).pop(),
              child: Material(
                color: Colors.transparent,
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
                                  child: _image(
                                    imageUrls[currentIndex],
                                    fit: BoxFit.contain,
                                    fallback: const Icon(
                                      Icons.image_not_supported_outlined,
                                      color: Colors.white38,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            if (currentIndex > 0)
                              Positioned(
                                left: 16,
                                child: _previewNavButton(
                                  icon: Icons.arrow_back_rounded,
                                  onTap: () => setDialogState(() {
                                    currentIndex--;
                                  }),
                                ),
                              ),
                            if (currentIndex < imageUrls.length - 1)
                              Positioned(
                                right: 16,
                                child: _previewNavButton(
                                  icon: Icons.arrow_forward_rounded,
                                  onTap: () => setDialogState(() {
                                    currentIndex++;
                                  }),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showVideoPreview(
    List<MapEntry<String, String>> videos,
    int initialIndex,
  ) {
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
              setDialogState(() => currentIndex = nextIndex);
              controller.loadVideoById(videoId: videos[nextIndex].key);
            }

            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => Navigator.of(dialogContext).pop(),
              child: Material(
                color: Colors.transparent,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (currentIndex > 0)
                      Padding(
                        padding: const EdgeInsets.only(right: 20),
                        child: _previewNavButton(
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
                        child: _previewNavButton(
                          icon: Icons.arrow_forward_rounded,
                          onTap: () => showAt(currentIndex + 1),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    ).then((_) => controller.close());
  }

  Widget _image(
    String? url, {
    required BoxFit fit,
    required Widget fallback,
  }) {
    if (url == null || url.isEmpty) {
      return Container(
        color: Colors.white.withValues(alpha: 0.04),
        child: Center(child: fallback),
      );
    }
    return Image.network(
      url,
      fit: fit,
      errorBuilder: (_, __, ___) => Container(
        color: Colors.white.withValues(alpha: 0.04),
        child: Center(child: fallback),
      ),
    );
  }

  String _clean(String? text, {String fallback = ''}) {
    if (text == null || text.trim().isEmpty) return fallback;
    return utf8
        .decode(text.runes.toList(), allowMalformed: true)
        .replaceAll('ï¿½', '')
        .trim();
  }

  String? _backgroundUrl(_AnimeBundle bundle) {
    final screenshots = _pictureUrls(bundle);
    if (screenshots.isNotEmpty) return screenshots.first;
    return normalizeAnimeImageUrl(
      bundle.raw?['trailer']?['images']?['maximum_image_url']?.toString() ??
          bundle.raw?['trailer']?['images']?['large_image_url']?.toString(),
    );
  }

  List<String> _pictureUrls(_AnimeBundle bundle) {
    return bundle.pictures
        .map((item) {
          final jpg = item['jpg'];
          final webp = item['webp'];
          return normalizeAnimeImageUrl(
            webp?['large_image_url']?.toString() ??
                webp?['image_url']?.toString() ??
                jpg?['large_image_url']?.toString() ??
                jpg?['image_url']?.toString(),
          );
        })
        .whereType<String>()
        .take(12)
        .toList();
  }

  List<String> _namedEntries(dynamic raw) {
    if (raw is! List) return const [];
    return raw
        .whereType<Map>()
        .map((item) => _clean(item['name']?.toString()))
        .where((value) => value.isNotEmpty)
        .toList();
  }

  List<MapEntry<String, String>> _videoEntries(_AnimeBundle bundle) {
    final output = <MapEntry<String, String>>[];
    final trailerId = bundle.raw?['trailer']?['youtube_id']?.toString();
    if (trailerId != null && trailerId.isNotEmpty) {
      output.add(MapEntry(trailerId, 'Official Trailer'));
    }
    for (final item in bundle.videos) {
      final trailer = item['trailer'];
      if (trailer is! Map) continue;
      final id = trailer['youtube_id']?.toString();
      if (id == null || id.isEmpty) continue;
      output.add(
        MapEntry(
          id,
          _clean(item['title']?.toString(), fallback: 'Official Video'),
        ),
      );
    }
    final seen = <String>{};
    return output
        .where((entry) => entry.key.isNotEmpty && seen.add(entry.key))
        .take(10)
        .toList();
  }

  List<_AnimeCastCard> _castEntries(List<Map<String, dynamic>> raw) {
    return raw.take(10).map((item) {
      final character = item['character'];
      final voiceActors = item['voice_actors'];
      var subtitle = 'Character';
      if (voiceActors is List && voiceActors.isNotEmpty) {
        final first = voiceActors.first;
        if (first is Map) {
          subtitle = _clean(
            first['person']?['name']?.toString(),
            fallback: subtitle,
          );
        }
      }
      return _AnimeCastCard(
        _clean(character?['name']?.toString(), fallback: 'Character'),
        subtitle,
        normalizeAnimeImageUrl(
          character?['images']?['jpg']?['image_url']?.toString() ??
              character?['images']?['webp']?['image_url']?.toString(),
        ),
      );
    }).toList();
  }

  String _ratingMood(double score) {
    if (score < 20) return 'Bad';
    if (score < 50) return 'Unlikely';
    if (score < 75) return 'Average';
    if (score < 90) return 'Good';
    return 'Great';
  }
}

class _AnimeBundle {
  final AnimeModel data;
  final Map<String, dynamic>? raw;
  final List<Map<String, dynamic>> pictures;
  final List<Map<String, dynamic>> videos;
  final List<Map<String, dynamic>> characters;
  final List<Map<String, dynamic>> episodes;

  const _AnimeBundle(
    this.data,
    this.raw,
    this.pictures,
    this.videos,
    this.characters,
    this.episodes,
  );
}

class _AnimeCastCard {
  final String name;
  final String subtitle;
  final String? imageUrl;

  const _AnimeCastCard(this.name, this.subtitle, this.imageUrl);
}
