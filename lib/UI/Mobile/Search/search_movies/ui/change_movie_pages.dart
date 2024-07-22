import 'package:flutter/material.dart';

Row changeMoviePages(
    int pageIndexMovies, StateSetter setState, int? totalPages) {
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
            if (pageIndexMovies > 1) {
              setState(() => pageIndexMovies = 1);
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
            if (pageIndexMovies > 1) {
              setState(() => pageIndexMovies -= 1);
            }
          },
        ),
      ),
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text("${pageIndexMovies.toString()}/$totalPages"),
      ),
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: IconButton(
          icon: const Icon(
            Icons.arrow_right,
            color: Colors.white,
          ),
          onPressed: () {
            if (pageIndexMovies < totalPages!) {
              setState(() {
                pageIndexMovies += 1;
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
            if (pageIndexMovies < totalPages!) {
              setState(() {
                pageIndexMovies = totalPages;
              });
            }
          },
        ),
      ),
    ],
  );
}
