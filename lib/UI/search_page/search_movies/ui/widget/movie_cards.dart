import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gnml/Data/firebase_user_data.dart';
import 'package:gnml/Data/movies_data.dart';

Padding movieCards(
    List<dynamic> data,
    int innerIndex,
    ValueNotifier<bool> isHovering,
    ValueNotifier<bool> isFavorite,
    List<dynamic> moviesList,
    int themeColor,
    User? user,
    List<dynamic> gamesList,
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
                                image: NetworkImage(
                                  data[innerIndex].imageURL.toString(),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Tooltip(
                          message: data[innerIndex].title,
                          child: SizedBox(
                            width: 180,
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: Text(
                                    data[innerIndex].title.toString(),
                                    softWrap: true,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 4.0),
                                  child: Text(
                                    MoviesData()
                                        .getMovieReleaseDate(data[innerIndex]),
                                    softWrap: true,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(fontSize: 12),
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
                                    Map<String, dynamic> movieMap = MoviesData()
                                        .getMovieMap(data, innerIndex);
                                    MoviesData().addFavoritesToMoviesList(
                                        moviesList,
                                        data,
                                        innerIndex,
                                        isFavorite);
                                    return isFavorite.value
                                        ? IconButton(
                                            highlightColor: Color(themeColor),
                                            hoverColor: Colors.transparent,
                                            onPressed: () {
                                              MoviesData().removeFromMoviesList(
                                                  moviesList,
                                                  data[innerIndex]['movieID']);
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
                                              MoviesData().addToMoviesList(
                                                  moviesList, movieMap);
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
                                            ),
                                          );
                                  },
                                ),
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
