import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gnml/Data/Model/game_model.dart';
import 'package:gnml/Data/firebase_user_data.dart';
import 'package:gnml/Data/games_data.dart';

Padding cards(
    User? user,
    List<GameModel> pageData,
    int innerIndex,
    dateTime,
    ValueNotifier<bool> isHovering,
    ValueNotifier<bool> isFavorite,
    imageId,
    List<dynamic> gamesList,
    int themeColor,
    List<dynamic> moviesList,
    List<dynamic> seriesList,
    List<dynamic> booksList,
    List<dynamic> actorsList) {
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: Column(
      children: [
        Expanded(
          child: SizedBox(
            height: double.infinity,
            width: 180,
            child: GridTile(
              child: Stack(
                children: [
                  Card(
                    elevation: 0,
                    shape: const RoundedRectangleBorder(
                      side: BorderSide(
                        color: Colors.transparent,
                      ),
                      borderRadius: BorderRadius.all(
                        Radius.circular(12),
                      ),
                    ),
                    child: Column(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 240,
                            width: 180,
                            child: ClipRRect(
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(12),
                                topRight: Radius.circular(12),
                              ),
                              child: Image(
                                fit: BoxFit.fill,
                                image: CachedNetworkImageProvider(
                                  """https://${pageData[innerIndex].url}""",
                                ),
                              ),
                            ),
                          ),
                        ),
                        Tooltip(
                          message: pageData[innerIndex].name,
                          child: SizedBox(
                            width: 180,
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: Text(
                                    pageData[innerIndex].name.toString(),
                                    softWrap: true,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 4.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(4.0),
                                        child: Text(
                                          dateTime.toString(),
                                          softWrap: true,
                                          overflow: TextOverflow.ellipsis,
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(4.0),
                                        child: GamesData().gameCategoryCard(
                                            pageData[innerIndex].category),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  ValueListenableBuilder(
                    valueListenable: isHovering,
                    builder: (context, value, child) {
                      return isHovering.value
                          ? Positioned(
                              top: 5,
                              right: 5,
                              child: Card(
                                elevation: 0,
                                color: const Color.fromARGB(125, 0, 0, 0),
                                child: ValueListenableBuilder(
                                    valueListenable: isFavorite,
                                    builder: (context, value, child) {
                                      Map<String, dynamic> gameMap = GamesData()
                                          .getGameMap(
                                              pageData, innerIndex, imageId);
                                      GamesData().addFavoritesToGameList(
                                          gamesList,
                                          pageData,
                                          innerIndex,
                                          isFavorite);
                                      return isFavorite.value
                                          ? IconButton(
                                              highlightColor: Color(themeColor),
                                              hoverColor: Colors.transparent,
                                              onPressed: () {
                                                GamesData().removeFromGameList(
                                                    gamesList,
                                                    pageData[innerIndex].id);
                                                FirebaseUserData(user: user)
                                                    .updateData(
                                                        gamesList,
                                                        moviesList,
                                                        seriesList,
                                                        booksList,
                                                        actorsList);
                                                isFavorite.value =
                                                    !isFavorite.value;
                                              },
                                              icon: Icon(
                                                Icons.favorite,
                                                color: Color(themeColor),
                                              ),
                                            )
                                          : IconButton(
                                              highlightColor: Color(themeColor),
                                              hoverColor: Colors.transparent,
                                              onPressed: () {
                                                GamesData().addToGamesList(
                                                    gamesList, gameMap);
                                                FirebaseUserData(user: user)
                                                    .updateData(
                                                        gamesList,
                                                        moviesList,
                                                        seriesList,
                                                        booksList,
                                                        actorsList);
                                                isFavorite.value =
                                                    !isFavorite.value;
                                              },
                                              icon: const Icon(
                                                Icons.favorite_outline,
                                                color: Colors.white,
                                                // color: Color(themeColor),
                                              ),
                                            );
                                    }),
                              ),
                            )
                          : const SizedBox();
                    },
                  ),
                ],
              ),
            ),
          ),
        )
      ],
    ),
  );
}
