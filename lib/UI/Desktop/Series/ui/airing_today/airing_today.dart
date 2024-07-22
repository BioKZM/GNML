import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gnml/UI/Desktop/Series/ui/airing_today/airing_today_builder.dart';

Padding airingTodaySeries(
  User? user,
  List<dynamic> seriesList,
  Map<String, dynamic> favoritesList,
  int themeColor,
  List<dynamic> gamesList,
  List<dynamic> moviesList,
  List<dynamic> booksList,
  List<dynamic> actorsList,
  int pageIndexAiringToday,
) {
  return Padding(
    padding: const EdgeInsets.all(24.0),
    child: SizedBox(
      width: double.infinity,
      height: 1650,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Card(
              // color: Colors.blue.withOpacity(0.5),
              elevation: 0,
              child: Padding(
                padding: EdgeInsets.fromLTRB(16, 4, 16, 4),
                child: Text(
                  "Airing Today",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
            ),
          ),
          airingTodaySeriesBuilder(
            user,
            seriesList,
            favoritesList,
            themeColor,
            gamesList,
            moviesList,
            booksList,
            actorsList,
            pageIndexAiringToday,
          ),
        ],
      ),
    ),
  );
}
