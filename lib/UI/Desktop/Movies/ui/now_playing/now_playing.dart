import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gnml/UI/Desktop/Movies/ui/now_playing/now_playing_builder.dart';

Padding nowPlayingMovies(
    User? user,
    List<dynamic> moviesList,
    Map<String, dynamic> favoritesList,
    int themeColor,
    List<dynamic> gamesList,
    List<dynamic> seriesList,
    List<dynamic> booksList,
    List<dynamic> actorsList,
    int pageIndexNowPlaying) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 12),
    child: SizedBox(
      width: double.infinity,
      height: 1650,
      // height: double.maxFinite,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Card(
              // color: Colors.purple.withOpacity(0.5),
              elevation: 0,
              child: Padding(
                padding: EdgeInsets.fromLTRB(16, 4, 16, 4),
                child: Text(
                  "Now Playing",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
            ),
          ),
          nowPlayingBuilder(
              user,
              favoritesList,
              moviesList,
              themeColor,
              gamesList,
              seriesList,
              booksList,
              actorsList,
              pageIndexNowPlaying),
        ],
      ),
    ),
  );
}
