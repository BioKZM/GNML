import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gnml/Data/Model/game_model.dart';
import 'package:gnml/Logic/gamepage_logic.dart';
import 'package:gnml/UI/search_page/search_games/ui/change_page.dart';
import 'package:gnml/UI/search_page/search_games/ui/game_cards_builder.dart';
import 'package:gnml/Widgets/circularprogressindicator.dart';

FutureBuilder<List<GameModel>> searchGamesBuilder(
  User? user,
  List<dynamic> gamesList,
  int themeColor,
  List<dynamic> moviesList,
  List<dynamic> seriesList,
  List<dynamic> booksList,
  List<dynamic> actorsList,
  ValueNotifier<int> pageIndex,
  PageController searchGamesController,
  String searchText,
) {
  return FutureBuilder(
    future: GamePageLogic().searchGames(searchText),
    builder: (context, snapshot) {
      if (snapshot.hasData &&
          snapshot.connectionState == ConnectionState.done) {
        var data = snapshot.data;
        int totalPages = (data!.length / 15).ceil();
        return Column(
          children: [
            gameCardsBuilder(
                user,
                totalPages,
                data,
                gamesList,
                themeColor,
                moviesList,
                seriesList,
                booksList,
                actorsList,
                searchGamesController),
            changeGamePages(pageIndex, totalPages, searchGamesController),
          ],
        );
      } else if (!snapshot.hasData &&
          snapshot.connectionState == ConnectionState.done) {
        return const Center(
          child: Text("No Result"),
        );
      } else {
        return const CustomCPI();
      }
    },
  );
}
