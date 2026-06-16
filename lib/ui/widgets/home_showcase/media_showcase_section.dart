import 'dart:math';

import 'package:flutter/material.dart';
import 'package:vault/ui/widgets/home_showcase/media_mosaic_row.dart';

class MediaShowcaseSection<T> extends StatelessWidget {
  final List<T> items;
  final String Function(T item) getTitle;
  final String Function(T item) getDescription;
  final String? Function(T item) getImageUrl;
  final double Function(T item) getScore;
  final Widget Function(T item) buildDetailPage;

  const MediaShowcaseSection({
    super.key,
    required this.items,
    required this.getTitle,
    required this.getDescription,
    required this.getImageUrl,
    required this.getScore,
    required this.buildDetailPage,
  });

  @override
  Widget build(BuildContext context) {
    final row1 = items.take(5).toList();
    final row2 = items.skip(5).take(5).toList();
    final row3 = items.skip(10).take(5).toList();
    final rng = Random(items.length * 97);

    Set<int> pickWideIndexes(int itemCount, int wideCount) {
      final pool = List<int>.generate(itemCount, (index) => index);
      pool.shuffle(rng);
      return pool.take(min(wideCount, itemCount)).toSet();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (row1.isNotEmpty)
          MediaMosaicRow<T>(
            items: row1,
            wideIndexes: pickWideIndexes(row1.length, 1),
            getTitle: getTitle,
            getDescription: getDescription,
            getImageUrl: getImageUrl,
            getScore: getScore,
            buildDetailPage: buildDetailPage,
          ),
        if (row1.isNotEmpty) const SizedBox(height: 22),
        if (row2.isNotEmpty)
          MediaMosaicRow<T>(
            items: row2,
            wideIndexes: pickWideIndexes(row2.length, 1),
            getTitle: getTitle,
            getDescription: getDescription,
            getImageUrl: getImageUrl,
            getScore: getScore,
            buildDetailPage: buildDetailPage,
          ),
        if (row2.isNotEmpty) const SizedBox(height: 22),
        if (row3.isNotEmpty)
          MediaMosaicRow<T>(
            items: row3,
            wideIndexes: pickWideIndexes(row3.length, 1),
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
