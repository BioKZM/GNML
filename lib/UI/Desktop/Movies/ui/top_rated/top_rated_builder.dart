import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:gnml/Logic/moviepage_logic.dart';
import 'package:gnml/UI/Desktop/Movies/ui/top_rated/top_rated_card.dart';
import 'package:gnml/Widgets/shimmerCard.dart';

Expanded topRatedMoviesBuilder(
  User? user,
  List<dynamic> moviesList,
  Map<String, dynamic> favoritesList,
  int themeColor,
  List<dynamic> gamesList,
  List<dynamic> seriesList,
  List<dynamic> booksList,
  List<dynamic> actorsList,
  int pageIndexTopRated,
) {
  return Expanded(
    child: StatefulBuilder(
      builder: (context, setState) {
        return FutureBuilder<int>(
            future: MoviePageLogic().getTopRatedMoviesTotalPages(),
            builder: (context, snapshot) {
              int? totalPages = snapshot.data;
              return FutureBuilder<List<dynamic>>(
                future: MoviePageLogic().getTopRatedMovies(pageIndexTopRated),
                builder: (context, snapshot) {
                  var data = snapshot.data;

                  if (snapshot.hasData &&
                      snapshot.connectionState == ConnectionState.done) {
                    return Column(
                      children: [
                        SizedBox(
                          height: 1500,
                          child: topRatedMoviesCards(
                            user,
                            data,
                            moviesList,
                            favoritesList,
                            themeColor,
                            gamesList,
                            seriesList,
                            booksList,
                            actorsList,
                            setState,
                            totalPages,
                            pageIndexTopRated,
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: IconButton(
                                icon: const Icon(
                                  FluentIcons.arrow_left_16_filled,
                                  color: Colors.white,
                                ),
                                onPressed: () {
                                  if (pageIndexTopRated > 1) {
                                    setState(() => pageIndexTopRated -= 1);
                                  }
                                },
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                  "${pageIndexTopRated.toString()}/$totalPages"),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: IconButton(
                                icon: const Icon(
                                  FluentIcons.arrow_right_16_filled,
                                  color: Colors.white,
                                ),
                                onPressed: () {
                                  if (pageIndexTopRated < totalPages!) {
                                    setState(() {
                                      pageIndexTopRated += 1;
                                    });
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  } else {
                    bool connectionBool = true;
                    if (snapshot.connectionState == ConnectionState.done) {
                      connectionBool = false;
                    }
                    return connectionBool
                        ? const ShimmerEffect()
                        : Center(
                            child: Card(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text(
                                        'An error occurred while loading data. Click to try again'),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: IconButton(
                                      icon: const Icon(Icons.refresh),
                                      onPressed: () {
                                        setState(() {});
                                      },
                                    ),
                                  )
                                ],
                              ),
                            ),
                          );
                  }
                },
              );
            });
      },
    ),
  );
}
