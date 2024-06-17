import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gnml/UI/Games/ui/popular_games/popular_games_builder.dart';

Card popularGames(
  User? user,
  List<dynamic> gamesList,
  Map<String, dynamic> favoritesList,
  int themeColor,
  List<dynamic> moviesList,
  List<dynamic> seriesList,
  List<dynamic> booksList,
  List<dynamic> actorsList,
  PageController pageController,
) {
  return Card(
    color: const Color.fromARGB(255, 0, 116, 0).withOpacity(0.5),
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
                child: Text("All Time Popular Games",
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
              popularGamesBuilder(
                  pageController,
                  gamesList,
                  favoritesList,
                  themeColor,
                  user,
                  moviesList,
                  seriesList,
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
