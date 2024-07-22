import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gnml/Data/firebase_user_data.dart';
import 'package:gnml/Data/series_data.dart';

class FavoritesWidget extends StatelessWidget {
  const FavoritesWidget({
    super.key,
    required this.isHovering,
    required this.favoriteSeries,
    required this.isFavorited,
    required this.favoriteGames,
    required this.favoriteMovies,
    required this.favoriteBooks,
    required this.favoriteActors,
    required this.data,
    required this.index,
    required this.innerIndex,
    required this.user,
    required this.seriesList,
  });

  final ValueNotifier<bool> isHovering;
  final List favoriteSeries;
  final ValueNotifier<bool> isFavorited;
  final List favoriteGames;
  final List favoriteMovies;
  final List favoriteBooks;
  final List favoriteActors;
  final data;
  final int index;
  final int innerIndex;
  final User? user;
  final List<dynamic> seriesList;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: isHovering,
      builder: (context, value, child) {
        SeriesData().addFavoritesFromList(
          seriesList,
          favoriteSeries,
          index,
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
                                  SeriesData().removeFromSeriesList(
                                      favoriteSeries,
                                      seriesList[index]['serieID']);
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
                                  Map<String, dynamic> serieMap = SeriesData()
                                      .getSeriesMap(data[innerIndex].id, data,
                                          innerIndex);
                                  SeriesData().addToSeriesList(
                                      favoriteSeries, serieMap);
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
                                  // color: Color(themeColor),
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
