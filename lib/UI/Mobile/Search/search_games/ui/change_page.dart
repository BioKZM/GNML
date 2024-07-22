import 'package:flutter/material.dart';

ValueListenableBuilder<int> changeGamePages(
  ValueNotifier<int> pageIndex,
  int totalPages,
  PageController searchGamesController,
) {
  return ValueListenableBuilder(
      valueListenable: pageIndex,
      builder: (context, value, child) {
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
                  if (pageIndex.value > 1) {
                    searchGamesController.jumpToPage(0);
                    pageIndex.value = 1;
                    // setState(() =>
                    //     pageIndex.value =
                    //         1);
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
                  if (pageIndex.value > 1) {
                    searchGamesController.previousPage(
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.ease,
                    );
                    pageIndex.value -= 1;
                  }
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text("${pageIndex.value}/$totalPages"),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: IconButton(
                icon: const Icon(
                  Icons.arrow_right,
                  color: Colors.white,
                ),
                onPressed: () {
                  if (pageIndex.value < totalPages) {
                    searchGamesController.nextPage(
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.ease,
                    );
                    pageIndex.value += 1;
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
                  if (pageIndex.value < totalPages) {
                    searchGamesController.jumpToPage(totalPages - 1);
                    pageIndex.value = totalPages;
                  }
                },
              ),
            ),
          ],
        );
      });
}
