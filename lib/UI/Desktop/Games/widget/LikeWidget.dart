import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gnml/Data/Model/game_model.dart';
import 'package:gnml/Data/firebase_user_data.dart';
import 'package:gnml/UI/Desktop/Games/data/games_page_data.dart';

class LikeWidget extends StatelessWidget {
  const LikeWidget({
    super.key,
    required this.isHovering,
    required this.isLiked,
    required this.imageId,
    required this.pageData,
    required this.data,
    required this.innerIndex,
    required this.gamesList,
    required this.moviesList,
    required this.seriesList,
    required this.booksList,
    required this.actorsList,
    required this.user,
    required this.themeColor,
  });

  final ValueNotifier<bool> isHovering;
  final ValueNotifier<bool> isLiked;
  final String? imageId;
  final List<GameModel> pageData;
  final data;
  final int innerIndex;
  final List<dynamic> gamesList;
  final List<dynamic> moviesList;
  final List<dynamic> seriesList;
  final List<dynamic> booksList;
  final List<dynamic> actorsList;
  final User? user;
  final int themeColor;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
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
                      valueListenable: isLiked,
                      builder: (context, value, child) {
                        Map<String, dynamic> gameMap = GamesPageData()
                            .getGameMap(data, innerIndex, imageId);
                        GamesPageData().addLikesFromGamesList(
                            gamesList, pageData, innerIndex, isLiked);
                        return isLiked.value
                            ? IconButton(
                                highlightColor: Color(themeColor),
                                hoverColor: Colors.transparent,
                                onPressed: () {
                                  GamesPageData().removeFromGamesList(
                                      gamesList, pageData, innerIndex);
                                  FirebaseUserData(user: user).updateData(
                                      gamesList,
                                      moviesList,
                                      seriesList,
                                      booksList,
                                      actorsList);
                                  isLiked.value = !isLiked.value;
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
                                  isLiked.value = !isLiked.value;
                                },
                                icon: const Icon(
                                  Icons.favorite_outline,
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
