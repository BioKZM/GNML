import 'package:flutter/material.dart';

Row changeActorsPage(
    int pageIndexActors, StateSetter setState, int? totalPages) {
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
            if (pageIndexActors > 1) {
              setState(() => pageIndexActors = 1);
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
            if (pageIndexActors > 1) {
              setState(() => pageIndexActors -= 1);
            }
          },
        ),
      ),
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text("${pageIndexActors.toString()}/$totalPages"),
      ),
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: IconButton(
          icon: const Icon(
            Icons.arrow_right,
            color: Colors.white,
          ),
          onPressed: () {
            if (pageIndexActors < totalPages!) {
              setState(() {
                pageIndexActors += 1;
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
            if (pageIndexActors < totalPages!) {
              setState(() {
                pageIndexActors = totalPages;
              });
            }
          },
        ),
      ),
    ],
  );
}
