import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gnml/UI/Series/ui/on_air/on_air_builder.dart';

Padding onAirSeries(
  User? user,
  List<dynamic> seriesList,
  Map<String, dynamic> favoritesList,
  int themeColor,
  List<dynamic> gamesList,
  List<dynamic> moviesList,
  List<dynamic> booksList,
  List<dynamic> actorsList,
  int pageIndexOnTheAir,
) {
  return Padding(
    padding: const EdgeInsets.all(24.0),
    child: SizedBox(
      width: double.infinity,
      height: 1350,
      child: Card(
        elevation: 5,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Card(
                  color: Colors.blue.withOpacity(0.5),
                  elevation: 0,
                  child: const Padding(
                    padding: EdgeInsets.fromLTRB(16, 4, 16, 4),
                    child: Text(
                      "On Air",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ),
            onAirSeriesBuilder(
                user,
                seriesList,
                favoritesList,
                themeColor,
                gamesList,
                moviesList,
                booksList,
                actorsList,
                pageIndexOnTheAir),
          ],
        ),
      ),
    ),
  );
}
