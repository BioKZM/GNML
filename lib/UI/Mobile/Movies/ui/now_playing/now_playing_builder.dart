import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gnml/Logic/moviepage_logic.dart';
import 'package:gnml/UI/Desktop/Movies/ui/now_playing/now_playing_card.dart';
import 'package:gnml/Widgets/shimmerCard.dart';

Expanded nowPlayingBuilder(
  User? user,
  Map<String, dynamic> favoritesList,
  List<dynamic> moviesList,
  int themeColor,
  List<dynamic> gamesList,
  List<dynamic> seriesList,
  List<dynamic> booksList,
  List<dynamic> actorsList,
  int pageIndexNowPlaying,
) {
  return Expanded(
    child: StatefulBuilder(
      builder: (context, setState) {
        return FutureBuilder<int>(
            future: MoviePageLogic().getNowPlayingMoviesTotalPages(),
            builder: (context, snapshot) {
              int? totalPages = snapshot.data;
              return FutureBuilder<List<dynamic>>(
                future:
                    MoviePageLogic().getNowPlayingMovies(pageIndexNowPlaying),
                builder: (context, snapshot) {
                  var data = snapshot.data;

                  if (snapshot.hasData &&
                      snapshot.connectionState == ConnectionState.done) {
                    return Column(
                      children: [
                        SizedBox(
                          height: 1200,
                          child: nowPlayingCards(
                              user,
                              data,
                              favoritesList,
                              moviesList,
                              themeColor,
                              gamesList,
                              seriesList,
                              booksList,
                              actorsList,
                              setState,
                              totalPages,
                              pageIndexNowPlaying),
                        ),
                        Row(
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
                                  if (pageIndexNowPlaying > 1) {
                                    setState(() => pageIndexNowPlaying = 1);
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
                                  if (pageIndexNowPlaying > 1) {
                                    setState(() => pageIndexNowPlaying -= 1);
                                  }
                                },
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                  "${pageIndexNowPlaying.toString()}/$totalPages"),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: IconButton(
                                icon: const Icon(
                                  Icons.arrow_right,
                                  color: Colors.white,
                                ),
                                onPressed: () {
                                  if (pageIndexNowPlaying < totalPages!) {
                                    setState(() {
                                      pageIndexNowPlaying += 1;
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
                                  if (pageIndexNowPlaying < totalPages!) {
                                    setState(() {
                                      pageIndexNowPlaying = totalPages;
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
