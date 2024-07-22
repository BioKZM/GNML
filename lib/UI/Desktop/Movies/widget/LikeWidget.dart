import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gnml/Data/firebase_user_data.dart';
import 'package:gnml/Data/movies_data.dart';

class LikeWidget extends StatelessWidget {
  const LikeWidget({
    super.key,
    required this.isHovering,
    required this.isLiked,
    required this.data,
    required this.innerIndex,
    required this.gamesList,
    required this.moviesList,
    required this.seriesList,
    required this.booksList,
    required this.actorsList,
    required this.themeColor,
    required this.user,
  });

  final ValueNotifier<bool> isHovering;
  final ValueNotifier<bool> isLiked;
  final data;
  final int innerIndex;
  final List<dynamic> gamesList;
  final List<dynamic> moviesList;
  final List<dynamic> seriesList;
  final List<dynamic> booksList;
  final List<dynamic> actorsList;
  final int themeColor;
  final User? user;

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
                      Map<String, dynamic> movieMap =
                          MoviesData().getMovieMap(data, innerIndex);
                      MoviesData().addFavoritesFromData(
                          moviesList, data, innerIndex, isLiked);
                      return isLiked.value
                          ? IconButton(
                              highlightColor: Color(themeColor),
                              hoverColor: Colors.transparent,
                              onPressed: () {
                                MoviesData().removeFromMoviesList(
                                    moviesList, data[innerIndex].id);
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
                                MoviesData()
                                    .addToMoviesList(moviesList, movieMap);
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
                    },
                  ),
                ),
              )
            : const SizedBox();
      },
    );
  }
}
