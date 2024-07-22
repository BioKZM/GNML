import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gnml/UI/Desktop/Games/ui/coming_soon/coming_soon_builder.dart';

Padding comingSoon(
  User? user,
  List<dynamic> gamesList,
  Map<String, dynamic> favoritesList,
  int themeColor,
  List<dynamic> moviesList,
  List<dynamic> seriesList,
  List<dynamic> booksList,
  List<dynamic> actorsList,
  PageController pageControllerComingSoon,
) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 12),
    child: SizedBox(
      width: double.infinity,
      height: 1650,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Card(
                // color:
                // const Color.fromARGB(255, 0, 116, 0).withOpacity(0.5),
                elevation: 0,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16, 4, 16, 4),
                  child: Text(
                    "Coming Soon",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                )),
          ),
          comingSoonBuilder(
              user,
              gamesList,
              favoritesList,
              themeColor,
              moviesList,
              seriesList,
              booksList,
              actorsList,
              pageControllerComingSoon),
        ],
      ),
    ),
  );
}
