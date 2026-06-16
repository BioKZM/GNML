import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vault/Helper/rating_helper.dart';
import 'package:vault/ui/widgets/home_showcase/showcase_image_url.dart';

class ShowcasePosterCard<T> extends StatefulWidget {
  final T item;
  final String Function(T item) getTitle;
  final String? Function(T item) getImageUrl;
  final double Function(T item) getScore;
  final Widget Function(T item) buildDetailPage;

  const ShowcasePosterCard({
    super.key,
    required this.item,
    required this.getTitle,
    required this.getImageUrl,
    required this.getScore,
    required this.buildDetailPage,
  });

  @override
  State<ShowcasePosterCard<T>> createState() => _ShowcasePosterCardState<T>();
}

class _ShowcasePosterCardState<T> extends State<ShowcasePosterCard<T>> {
  bool _hovering = false;

  bool _hasUsableImage(String? imageUrl) {
    if (imageUrl == null) return false;
    final trimmed = imageUrl.trim();
    if (trimmed.isEmpty) return false;
    return !trimmed.endsWith('/null') &&
        !trimmed.endsWith('/undefined') &&
        !trimmed.contains('null)');
  }

  Widget _buildImage(String imageUrl) {
    if (kIsWeb) {
      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
        alignment: Alignment.topCenter,
        errorBuilder: (context, error, stackTrace) => Container(
          alignment: Alignment.center,
          color: Colors.grey[850],
          child: const Icon(
            Icons.image_not_supported_rounded,
            color: Colors.white38,
          ),
        ),
      );
    }

    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: BoxFit.cover,
      alignment: Alignment.topCenter,
      placeholder: (context, url) => Container(
        color: Colors.grey[850],
        alignment: Alignment.center,
        child: const SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
      errorWidget: (context, url, error) => Container(
        alignment: Alignment.center,
        color: Colors.grey[850],
        child: const Icon(
          Icons.image_not_supported_rounded,
          color: Colors.white38,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.getTitle(widget.item);
    final imageUrl = optimizeShowcaseImageUrl(widget.getImageUrl(widget.item));
    final hasImage = _hasUsableImage(imageUrl);
    final score = widget.getScore(widget.item);
    final hasRating = score > 0;
    final ratingColor = hasRating
        ? RatingHelper.getRatingColor(score)
        : Colors.white54;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      cursor: SystemMouseCursors.click,
      child: AnimatedScale(
        scale: _hovering ? 1.015 : 1.0,
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        child: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => widget.buildDetailPage(widget.item),
              ),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: const Color(0xFF181818),
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (hasImage)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: _buildImage(imageUrl!),
                  )
                else
                  Container(
                    alignment: Alignment.center,
                    color: Colors.grey[850],
                    child: const Icon(
                      Icons.image_not_supported_rounded,
                      color: Colors.white38,
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
                              title,
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
  }
}
