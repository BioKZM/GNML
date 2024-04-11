import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gnml/Data/firebase_user_data.dart';
import 'package:gnml/Data/movies_data.dart';
import 'package:gnml/UI/Details/movie_detail_page.dart';

ListView popularMoviesCards(
  User? user,
  List<dynamic>? data,
  List<dynamic> moviesList,
  int themeColor,
  List<dynamic> gamesList,
  List<dynamic> seriesList,
  List<dynamic> booksList,
  List<dynamic> actorsList,
  PageController pageController,
) {
  return ListView.builder(
    controller: pageController,
    scrollDirection: Axis.horizontal,
    itemCount: data?.length,
    itemBuilder: (context, index) {
      ValueNotifier<bool> isHovering = ValueNotifier<bool>(false);
      ValueNotifier<bool> isFavorite = ValueNotifier<bool>(false);
      var movieID = 0;
      if (data?[index].id != null) {
        movieID = data![index].id!;
      }
      return SizedBox(
        child: Padding(
          padding: const EdgeInsets.all(5.3),
          child: MouseRegion(
            onEnter: (event) => isHovering.value = true,
            onExit: (event) => isHovering.value = false,
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MovieDetailPage(movieID: movieID),
                  ),
                );
              },
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
                        SizedBox(
                          height: 140,
                          width: 110,
                          child: ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(12),
                              topRight: Radius.circular(12),
                            ),
                            child: Image(
                              fit: BoxFit.cover,
                              image: CachedNetworkImageProvider(
                                data![index].imageURL.toString(),
                              ),
                            ),
                          ),
                        ),
                        Tooltip(
                          message: data[index].title,
                          child: SizedBox(
                            width: 100,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                data[index].title.toString(),
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
                                    Map<String, dynamic> movieMap =
                                        MoviesData().getMovieMap(data, index);
                                    MoviesData().addFavoritesToMoviesList(
                                        moviesList, data, index, isFavorite);
                                    return isFavorite.value
                                        ? IconButton(
                                            highlightColor: Color(themeColor),
                                            hoverColor: Colors.transparent,
                                            onPressed: () {
                                              MoviesData().removeFromMoviesList(
                                                  moviesList, data[index].id);
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
        ),
      );
    },
  );
}
