import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gnml/Data/firebase_user_data.dart';
import 'package:gnml/Data/movies_data.dart';
import 'package:gnml/UI/Desktop/Details/movie_detail_page.dart';

Padding getMoviesFromLibrary(
    List<dynamic> moviesList,
    Map<String, dynamic> favoritesList,
    int index,
    BuildContext context,
    int themeColor,
    User? user,
    List<dynamic> gamesList,
    List<dynamic> seriesList,
    List<dynamic> booksList,
    List<dynamic> actorsList) {
  Map<String, dynamic> movieMap =
      MoviesData().getMovieMapLibrary(moviesList, index);
  List<dynamic> favoriteGames = favoritesList['games'];
  List<dynamic> favoriteMovies = favoritesList['movies'];
  List<dynamic> favoriteSeries = favoritesList['series'];
  List<dynamic> favoriteBooks = favoritesList['books'];
  List<dynamic> favoriteActors = favoritesList['actors'];
  ValueNotifier<bool> isHovering = ValueNotifier<bool>(false);
  ValueNotifier<bool> isLiked = ValueNotifier<bool>(true);
  ValueNotifier<bool> isFavorited = ValueNotifier<bool>(false);
  ValueNotifier<double> size = ValueNotifier<double>(1);
  return Padding(
    padding: const EdgeInsets.all(4.0),
    child: MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (event) {
        isHovering.value = true;
        size.value = 1.05;
      },
      onExit: (event) {
        isHovering.value = false;
        size.value = 1;
      },
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  MovieDetailPage(movieID: moviesList[index]['movieID']),
            ),
          );
        },
        child: ScaleTransition(
          scale: Animation<double>.fromValueListenable(
            size,
            transformer: (double value) {
              return value;
            },
          ),
          child: Stack(
            children: [
              Card(
                color: Colors.transparent,
                shape: const RoundedRectangleBorder(
                  side: BorderSide(
                    color: Colors.transparent,
                  ),
                  borderRadius: BorderRadius.all(
                    Radius.circular(8),
                  ),
                ),
                child: GridTile(
                  child: Column(
                    children: [
                      SizedBox(
                        height: 225,
                        width: 150,
                        child: ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(8),
                            topRight: Radius.circular(8),
                          ),
                          child: Image(
                            fit: BoxFit.fill,
                            image: NetworkImage(
                              "${moviesList[index]['imageURL'].substring(0, 27)}w300${moviesList[index]['imageURL'].substring(35)}",
                            ),
                          ),
                        ),
                      ),
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 120,
                            height: 30,
                            child: ClipRRect(
                              borderRadius: const BorderRadius.all(
                                Radius.circular(8),
                              ),
                              child: Image.network(
                                  "${moviesList[index]['imageURL'].substring(0, 27)}w300${moviesList[index]['imageURL'].substring(35)}",
                                  fit: BoxFit.fill),
                            ),
                          ),
                          SizedBox(
                            width: 150,
                            child: ClipRRect(
                              borderRadius: const BorderRadius.only(
                                  bottomLeft: Radius.circular(8),
                                  bottomRight: Radius.circular(8)),
                              child: BackdropFilter(
                                filter:
                                    ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Tooltip(
                                    message: moviesList[index]['movieName'],
                                    child: Text(
                                      moviesList[index]['movieName'],
                                      softWrap: true,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.center,
                                      style:
                                          const TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              ValueListenableBuilder(
                valueListenable: isLiked,
                builder: (context, value, child) {
                  return isLiked.value
                      ? const SizedBox()
                      : Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.5),
                              borderRadius: const BorderRadius.all(
                                Radius.circular(8),
                              ),
                            ),
                            height: 260,
                            width: 150,
                          ),
                        );
                },
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
                                valueListenable: isLiked,
                                builder: (context, value, child) {
                                  return isLiked.value
                                      ? IconButton(
                                          highlightColor: Color(themeColor),
                                          hoverColor: Colors.transparent,
                                          onPressed: () {
                                            MoviesData().removeFromMoviesList(
                                                moviesList,
                                                moviesList[index]['movieID']);
                                            FirebaseUserData(user: user)
                                                .updateData(
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
                                            MoviesData().addToMoviesList(
                                                moviesList, movieMap);
                                            FirebaseUserData(user: user)
                                                .updateData(
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
                                            // color: Color(themeColor),
                                          ),
                                        );
                                }),
                          ),
                        )
                      : const SizedBox();
                },
              ),
              ValueListenableBuilder(
                valueListenable: isHovering,
                builder: (context, value, child) {
                  MoviesData().addFavoritesFromList(
                    moviesList,
                    favoriteMovies,
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
                                          highlightColor: Color(themeColor),
                                          hoverColor: Colors.transparent,
                                          onPressed: () {
                                            MoviesData().removeFromMoviesList(
                                                favoriteMovies,
                                                moviesList[index]['movieID']);
                                            FirebaseUserData(user: user)
                                                .updateFavoritesData(
                                              favoriteGames,
                                              favoriteMovies,
                                              favoriteSeries,
                                              favoriteBooks,
                                              favoriteActors,
                                            );
                                            isFavorited.value =
                                                !isFavorited.value;
                                          },
                                          icon: const Icon(
                                            Icons.star,
                                            color: Colors.amber,
                                          ),
                                        )
                                      : IconButton(
                                          highlightColor: Color(themeColor),
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
                                            isFavorited.value =
                                                !isFavorited.value;
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
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
