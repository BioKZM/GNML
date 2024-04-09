import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gnml/UI/movies_page/ui/now_playing/now_playing_builder.dart';

Padding nowPlayingMovies(
    User? user,
    List<dynamic> moviesList,
    int themeColor,
    List<dynamic> gamesList,
    List<dynamic> seriesList,
    List<dynamic> booksList,
    List<dynamic> actorsList,
    int pageIndexNowPlaying) {
  return Padding(
    padding: const EdgeInsets.all(24.0),
    child: SizedBox(
      width: double.infinity,
      height: 1350,
      // height: double.maxFinite,
      child: Card(
        elevation: 5,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Card(
                  color: Colors.purple.withOpacity(0.5),
                  elevation: 0,
                  child: const Padding(
                    padding: EdgeInsets.fromLTRB(16, 4, 16, 4),
                    child: Text(
                      "Now Playing",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ),
            nowPlayingBuilder(user, moviesList, themeColor, gamesList,
                seriesList, booksList, actorsList, pageIndexNowPlaying),
          ],
        ),
      ),
    ),
  );
}
