import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vault/ui/widgets/home_showcase/media_showcase_section.dart';

class MediaSectionBlock<T> extends StatelessWidget {
  final Color primaryColor;
  final String sectionTop;
  final String sectionBottom;
  final List<T> items;
  final String Function(T item) getTitle;
  final String Function(T item) getDescription;
  final String? Function(T item) getImageUrl;
  final double Function(T item) getScore;
  final Widget Function(T item) buildDetailPage;

  const MediaSectionBlock({
    super.key,
    required this.primaryColor,
    required this.sectionTop,
    required this.sectionBottom,
    required this.items,
    required this.getTitle,
    required this.getDescription,
    required this.getImageUrl,
    required this.getScore,
    required this.buildDetailPage,
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
              sectionTop,
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
                sectionBottom,
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
        const SizedBox(height: 8),
        MediaShowcaseSection<T>(
          items: items,
          getTitle: getTitle,
          getDescription: getDescription,
          getImageUrl: getImageUrl,
          getScore: getScore,
          buildDetailPage: buildDetailPage,
        ),
      ],
    );
  }
}
