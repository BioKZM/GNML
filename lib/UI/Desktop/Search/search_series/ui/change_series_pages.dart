import 'package:flutter/material.dart';

Row changeSeriesPages(
    int pageIndexSeries, StateSetter setState, int? totalPages) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: IconButton(
          icon: const Icon(
            Icons.arrow_circle_left_outlined,
            color: Colors.white,
          ),
          onPressed: () {
            if (pageIndexSeries > 1) {
              setState(() => pageIndexSeries = 1);
            }
          },
        ),
      ),
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: IconButton(
          icon: const Icon(
            Icons.arrow_left,
            color: Colors.white,
          ),
          onPressed: () {
            if (pageIndexSeries > 1) {
              setState(() => pageIndexSeries -= 1);
            }
          },
        ),
      ),
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text("${pageIndexSeries.toString()}/$totalPages"),
      ),
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: IconButton(
          icon: const Icon(
            Icons.arrow_right,
            color: Colors.white,
          ),
          onPressed: () {
            if (pageIndexSeries < totalPages!) {
              setState(() {
                pageIndexSeries += 1;
              });
            }
          },
        ),
      ),
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: IconButton(
          icon: const Icon(
            Icons.arrow_circle_right_outlined,
            color: Colors.white,
          ),
          onPressed: () {
            if (pageIndexSeries < totalPages!) {
              setState(() {
                pageIndexSeries = totalPages;
              });
            }
          },
        ),
      ),
    ],
  );
}
