import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gnml/Data/Model/game_model.dart';
import 'package:gnml/Data/firebase_user_data.dart';
import 'package:gnml/Data/games_data.dart';
import 'package:gnml/UI/Desktop/Games/data/games_page_data.dart';

class FavoritesWidget extends StatelessWidget {
  const FavoritesWidget({
    super.key,
    required this.isHovering,
    required this.favoriteGames,
    required this.pageData,
    required this.isFavorited,
    required this.favoriteMovies,
    required this.favoriteSeries,
    required this.favoriteBooks,
    required this.favoriteActors,
    required this.imageId,
    required this.innerIndex,
    required this.user,
  });

  final ValueNotifier<bool> isHovering;
  final List favoriteGames;
  final List<GameModel> pageData;
  final ValueNotifier<bool> isFavorited;
  final List favoriteMovies;
  final List favoriteSeries;
  final List favoriteBooks;
  final List favoriteActors;
  final String? imageId;
  final int innerIndex;
  final User? user;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: isHovering,
      builder: (context, value, child) {
        GamesData().addFavoritesFromData(
          favoriteGames,
          pageData,
          innerIndex,
          isFavorited,
        );
        return isHovering.value
            ? Positioned(
                top: 50,
                right: 5,
                child: Card(
                  elevation: 0,
                  color: const Color.fromARGB(125, 0, 0, 0),
                  child: ValueListenableBuilder(
                      valueListenable: isFavorited,
                      builder: (context, value, child) {
                        return isFavorited.value
                            ? IconButton(
                                highlightColor: Colors.amber,
                                hoverColor: Colors.transparent,
                                onPressed: () {
                                  GamesData().removeFromGameList(
                                      favoriteGames, pageData[innerIndex].id);
                                  FirebaseUserData(user: user)
                                      .updateFavoritesData(
                                    favoriteGames,
                                    favoriteMovies,
                                    favoriteSeries,
                                    favoriteBooks,
                                    favoriteActors,
                                  );
                                  isFavorited.value = !isFavorited.value;
                                },
                                icon: const Icon(
                                  Icons.star,
                                  color: Colors.amber,
                                ),
                              )
                            : IconButton(
                                highlightColor: Colors.amber,
                                hoverColor: Colors.transparent,
                                onPressed: () {
                                  Map<String, dynamic> gameMap = GamesPageData()
                                      .getGameMap(
                                          pageData, innerIndex, imageId);
                                  GamesData()
                                      .addToGamesList(favoriteGames, gameMap);
                                  FirebaseUserData(user: user)
                                      .updateFavoritesData(
                                    favoriteGames,
                                    favoriteMovies,
                                    favoriteSeries,
                                    favoriteBooks,
                                    favoriteActors,
                                  );
                                  isFavorited.value = !isFavorited.value;
                                },
                                icon: const Icon(
                                  Icons.star_outline,
                                  color: Colors.white,
                                ),
                              );
                      }),
                ),
              )
            : const SizedBox();
      },
    );
  }
}
