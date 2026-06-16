import 'package:flutter/material.dart';
import 'package:vault/ui/widgets/home_showcase/showcase_featured_card.dart';
import 'package:vault/ui/widgets/home_showcase/showcase_poster_card.dart';

class MediaMosaicRow<T> extends StatelessWidget {
  final List<T> items;
  final Set<int> wideIndexes;
  final String Function(T item) getTitle;
  final String Function(T item) getDescription;
  final String? Function(T item) getImageUrl;
  final double Function(T item) getScore;
  final Widget Function(T item) buildDetailPage;

  const MediaMosaicRow({
    super.key,
    required this.items,
    required this.wideIndexes,
    required this.getTitle,
    required this.getDescription,
    required this.getImageUrl,
    required this.getScore,
    required this.buildDetailPage,
  });

  @override
  Widget build(BuildContext context) {
    const gap = 12.0;
    const hoverRoom = 8.0;
    const posterAspectRatio = 220 / 330;

    return LayoutBuilder(
      builder: (context, constraints) {
        final totalUnits = items.length + wideIndexes.length;
        final totalGap = gap * (items.length - 1);
        final unitWidth =
            (constraints.maxWidth - totalGap - (hoverRoom * 2)) / totalUnits;
        final posterHeight = unitWidth / posterAspectRatio;

        return SizedBox(
          height: posterHeight + 8,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: hoverRoom),
            child: Row(
              children: List.generate(items.length, (index) {
                final item = items[index];
                final isWide = wideIndexes.contains(index);
                final width = isWide ? unitWidth * 2 : unitWidth;

                return Padding(
                  padding: EdgeInsets.only(
                    right: index == items.length - 1 ? 0 : gap,
                  ),
                  child: SizedBox(
                    width: width,
                    height: posterHeight,
                    child: isWide
                        ? ShowcaseFeaturedCard<T>(
                            item: item,
                            getTitle: getTitle,
                            getDescription: getDescription,
                            getImageUrl: getImageUrl,
                            getScore: getScore,
                            buildDetailPage: buildDetailPage,
                          )
                        : ShowcasePosterCard<T>(
                            item: item,
                            getTitle: getTitle,
                            getImageUrl: getImageUrl,
                            getScore: getScore,
                            buildDetailPage: buildDetailPage,
                          ),
                  ),
                );
              }),
            ),
          ),
        );
      },
    );
  }
}
