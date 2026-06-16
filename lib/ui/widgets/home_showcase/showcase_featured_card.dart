import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vault/Helper/rating_helper.dart';
import 'package:vault/ui/widgets/home_showcase/showcase_image_url.dart';

class ShowcaseFeaturedCard<T> extends StatefulWidget {
  final T item;
  final String Function(T item) getTitle;
  final String Function(T item) getDescription;
  final String? Function(T item) getImageUrl;
  final double Function(T item) getScore;
  final Widget Function(T item) buildDetailPage;

  const ShowcaseFeaturedCard({
    super.key,
    required this.item,
    required this.getTitle,
    required this.getDescription,
    required this.getImageUrl,
    required this.getScore,
    required this.buildDetailPage,
  });

  @override
  State<ShowcaseFeaturedCard<T>> createState() =>
      _ShowcaseFeaturedCardState<T>();
}

class _ShowcaseFeaturedCardState<T> extends State<ShowcaseFeaturedCard<T>> {
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
          width: 20,
          height: 20,
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
    final description = widget.getDescription(widget.item);
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
              borderRadius: BorderRadius.circular(16),
              color: const Color(0xFF181818),
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (hasImage)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
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
                Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        title,
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
                        description,
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
  }
}
