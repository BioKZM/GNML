import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gnml/Data/Model/game_model.dart';
import 'package:gnml/UI/Desktop/Details/game_detail_page.dart';
import 'package:gnml/Data/games_data.dart';
import 'package:gnml/UI/Desktop/Search/search_games/ui/widget/cards_widget.dart';

Expanded gameCardsBuilder(
  User? user,
  int totalPages,
  List<GameModel> data,
  List<dynamic> gamesList,
  int themeColor,
  List<dynamic> moviesList,
  List<dynamic> seriesList,
  List<dynamic> booksList,
  List<dynamic> actorsList,
  PageController searchGamesController,
  Map<String, dynamic> favoritesList,
) {
  return Expanded(
    child: SizedBox(
      child: PageView.builder(
          controller: searchGamesController,
          itemCount: totalPages,
          itemBuilder: (context, int index) {
            final int startIndex = index * 15;
            final int endIndex = (index + 1) * 15;
            final pageData = data.sublist(
              startIndex,
              endIndex.clamp(0, data.length),
            );
            return GridView.builder(
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 350),
              shrinkWrap: true,
              itemCount: pageData.length,
              itemBuilder: (context, innerIndex) {
                ValueNotifier<bool> isHovering = ValueNotifier<bool>(false);
                ValueNotifier<bool> isFavorite = ValueNotifier<bool>(false);
                ValueNotifier<bool> isFavorited = ValueNotifier<bool>(false);

                // ignore: prefer_typing_uninitialized_variables
                var imageId = GamesData().getGameImageID(pageData, innerIndex);
                // ignore: prefer_typing_uninitialized_variables
                var dateTime =
                    GamesData().getGameReleaseDate(pageData, innerIndex);
                int gameID = GamesData().getGameID(pageData, innerIndex);
                return MouseRegion(
                  onHover: (event) => isHovering.value = true,
                  onExit: (event) => isHovering.value = false,
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => GameDetailPage(gameID: gameID),
                        ),
                      );
                    },
                    child: cards(
                      user,
                      pageData,
                      innerIndex,
                      dateTime,
                      isHovering,
                      isFavorite,
                      isFavorited,
                      imageId,
                      gamesList,
                      themeColor,
                      moviesList,
                      seriesList,
                      booksList,
                      actorsList,
                      favoritesList,
                    ),
                  ),
                );
              },
            );
          }),
    ),
  );
}
