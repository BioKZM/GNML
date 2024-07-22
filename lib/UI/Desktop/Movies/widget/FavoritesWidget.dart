import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gnml/Data/firebase_user_data.dart';
import 'package:gnml/Data/movies_data.dart';

class FavoritesWidget extends StatelessWidget {
  const FavoritesWidget({
    super.key,
    required this.isHovering,
    required this.isFavorited,
    required this.favoriteMovies,
    required this.favoriteGames,
    required this.favoriteSeries,
    required this.favoriteBooks,
    required this.favoriteActors,
    required this.data,
    required this.innerIndex,
    required this.user,
  });

  final ValueNotifier<bool> isHovering;
  final ValueNotifier<bool> isFavorited;
  final List favoriteMovies;
  final List favoriteGames;
  final List favoriteSeries;
  final List favoriteBooks;
  final List favoriteActors;
  final data;
  final int innerIndex;
  final User? user;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: isHovering,
      builder: (context, value, child) {
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
                        Map<String, dynamic> movieMap =
                            MoviesData().getMovieMap(data, innerIndex);
                        MoviesData().addFavoritesFromData(
                          favoriteMovies,
                          data,
                          innerIndex,
                          isFavorited,
                        );
                        return isFavorited.value
                            ? IconButton(
                                highlightColor: Colors.amber,
                                hoverColor: Colors.transparent,
                                onPressed: () {
                                  MoviesData().removeFromMoviesList(
                                      favoriteMovies, data[innerIndex].id);
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
                                  MoviesData().addToMoviesList(
                                      favoriteMovies, movieMap);
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
