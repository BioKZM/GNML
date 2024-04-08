import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gnml/Data/Model/game_model.dart';
import 'package:gnml/UI/games_page/data/games_page_data.dart';
import 'package:gnml/Data/firebase_user_data.dart';

Stack popularGamesCard(
    String? imageId,
    List<GameModel>? data,
    int index,
    ValueNotifier<bool> isHovering,
    ValueNotifier<bool> isFavorite,
    List<dynamic> gamesList,
    int themeColor,
    User? user,
    List<dynamic> moviesList,
    List<dynamic> seriesList,
    List<dynamic> booksList,
    List<dynamic> actorsList) {
  return Stack(
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
            SizedBox(
              height: 140,
              width: 110,
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
                child: Image(
                  fit: BoxFit.fill,
                  image: CachedNetworkImageProvider(
                    "https://images.igdb.com/igdb/image/upload/t_cover_big/$imageId.png"
                        .toString(),
                  ),
                ),
              ),
            ),
            Tooltip(
              message: data![index].name,
              child: SizedBox(
                width: 100,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    data[index].name.toString(),
                    softWrap: true,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
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
                          Map<String, dynamic> gameMap =
                              GamesPageData().getGameMap(data, index, imageId);
                          GamesPageData().addFavoritesFromGamesList(
                              gamesList, data, index, isFavorite);
                          return isFavorite.value
                              ? IconButton(
                                  highlightColor: Color(themeColor),
                                  hoverColor: Colors.transparent,
                                  onPressed: () {
                                    GamesPageData().removeFromGamesList(
                                        gamesList, data, index);
                                    FirebaseUserData(user: user).updateData(
                                        gamesList,
                                        moviesList,
                                        seriesList,
                                        booksList,
                                        actorsList);
                                    isFavorite.value = !isFavorite.value;
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
                                    GamesPageData()
                                        .addToGamesList(gamesList, gameMap);
                                    FirebaseUserData(user: user).updateData(
                                        gamesList,
                                        moviesList,
                                        seriesList,
                                        booksList,
                                        actorsList);
                                    isFavorite.value = !isFavorite.value;
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
  );
}
