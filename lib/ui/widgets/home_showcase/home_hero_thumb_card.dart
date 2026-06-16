import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vault/Helper/rating_helper.dart';
import 'package:vault/ui/widgets/home_showcase/home_hero_slide_data.dart';
import 'package:vault/ui/widgets/home_showcase/showcase_image_url.dart';

class HomeHeroThumbCard extends StatelessWidget {
  final HomeHeroSlideData slide;
  final bool isActive;
  final Color primaryColor;
  final int progressSeed;
  final VoidCallback onTap;

  const HomeHeroThumbCard({
    super.key,
    required this.slide,
    required this.isActive,
    required this.primaryColor,
    required this.progressSeed,
    required this.onTap,
  });

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
          width: 16,
          height: 16,
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
    final imageUrl = optimizeShowcaseImageUrl(slide.imageUrl);
    final hasImage = imageUrl.isNotEmpty && !imageUrl.endsWith('/null');
    final score = slide.gameAggregatedRating != null
        ? slide.gameAggregatedRating!.toDouble()
        : (slide.gameRating?.toDouble() ?? 0);
    final hasRating = score > 0;
    final ratingColor = hasRating
        ? RatingHelper.getRatingColor(score)
        : Colors.white54;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Column(
        children: [
          Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isActive
                      ? primaryColor.withValues(alpha: 0.85)
                      : Colors.white.withValues(alpha: 0.08),
                  width: isActive ? 1.6 : 1,
                ),
                color: const Color(0xFF181818),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (hasImage)
                      _buildImage(imageUrl)
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
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.12),
                            Colors.black.withValues(alpha: 0.72),
                            Colors.black.withValues(alpha: 0.95),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      left: 14,
                      right: 14,
                      bottom: 12,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Text(
                              slide.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
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
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            height: 4,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              color: Colors.white.withValues(alpha: 0.10),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: Align(
                alignment: Alignment.centerLeft,
                child: TweenAnimationBuilder<double>(
                  key: ValueKey('${slide.title}-$isActive-$progressSeed'),
                  tween: Tween<double>(begin: 0, end: isActive ? 1 : 0),
                  duration: Duration(milliseconds: isActive ? 6000 : 180),
                  curve: Curves.linear,
                  builder: (context, value, child) {
                    return FractionallySizedBox(
                      widthFactor: value,
                      child: child,
                    );
                  },
                  child: Container(color: primaryColor),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
