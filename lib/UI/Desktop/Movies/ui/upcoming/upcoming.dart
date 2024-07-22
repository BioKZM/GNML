import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gnml/UI/Desktop/Movies/ui/upcoming/upcoming_builder.dart';

Padding upcomingMovies(
  User? user,
  List<dynamic> moviesList,
  Map<String, dynamic> favoritesList,
  int themeColor,
  List<dynamic> gamesList,
  List<dynamic> seriesList,
  List<dynamic> booksList,
  List<dynamic> actorsList,
  int pageIndexUpcoming,
) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: SizedBox(
      width: double.infinity,
      height: 1650,
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
                  "Upcoming",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
            ),
          ),
          upcomingMoviesBuilder(
            user,
            moviesList,
            favoritesList,
            themeColor,
            gamesList,
            seriesList,
            booksList,
            actorsList,
            pageIndexUpcoming,
          ),
        ],
      ),
    ),
  );
}
