import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gnml/Logic/moviepage_logic.dart';
import 'package:gnml/UI/movies_page/ui/now_playing/widget/now_playing_card.dart';
import 'package:gnml/Widgets/shimmer.dart';

Expanded nowPlayingBuilder(
  User? user,
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
                    return nowPlayingCards(
                        user,
                        data,
                        moviesList,
                        themeColor,
                        gamesList,
                        seriesList,
                        booksList,
                        actorsList,
                        setState,
                        totalPages,
                        pageIndexNowPlaying);
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
                                        'Veriler yüklenirken bir hata oluştu. Yeniden denemek için tıkla'),
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
