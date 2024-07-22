import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gnml/UI/Desktop/Series/ui/popular_series/popular_series_builder.dart';

Card popularSeries(
    User? user,
    List<dynamic> seriesList,
    Map<String, dynamic> favoritesList,
    int themeColor,
    List<dynamic> gamesList,
    List<dynamic> moviesList,
    List<dynamic> booksList,
    List<dynamic> actorsList,
    PageController pageController) {
  return Card(
    // color: Colors.blue.withOpacity(0.5),
    elevation: 5,
    child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 8),
            child: Card(
              elevation: 0,
              child: Padding(
                padding:
                    EdgeInsets.only(left: 16, top: 4, right: 16, bottom: 4),
                child: Text(
                  "Popular Series",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.arrow_left,
                ),
                onPressed: () {
                  pageController.previousPage(
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.ease,
                  );
                },
              ),
              popularSeriesBuilder(
                  user,
                  pageController,
                  seriesList,
                  favoritesList,
                  themeColor,
                  gamesList,
                  moviesList,
                  booksList,
                  actorsList),
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: IconButton(
                  icon: const Icon(Icons.arrow_right),
                  onPressed: () {
                    pageController.nextPage(
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.ease,
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
