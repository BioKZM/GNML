import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gnml/Data/firebase_user_data.dart';
import 'package:gnml/Data/movies_data.dart';
import 'package:gnml/UI/Details/movie_detail_page.dart';

PageView upcomingMoviesCards(
  User? user,
  List<dynamic>? data,
  List<dynamic> moviesList,
  int themeColor,
  List<dynamic> gamesList,
  List<dynamic> seriesList,
  List<dynamic> booksList,
  List<dynamic> actorsList,
  StateSetter setState,
  int? totalPages,
  int pageIndexUpcoming,
) {
  return PageView.builder(
    itemBuilder: (context, index) {
      return Column(
        children: [
          SizedBox(
            height: 1200,
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 300,
              ),
              itemCount: data?.length,
              itemBuilder: (context, innerIndex) {
                ValueNotifier<bool> isHovering = ValueNotifier<bool>(false);
                ValueNotifier<bool> isFavorite = ValueNotifier<bool>(false);
                var movieID = 0;
                if (data![innerIndex].id != null) {
                  movieID = data[innerIndex].id!;
                }
                return MouseRegion(
                  onEnter: (event) => isHovering.value = true,
                  onExit: (event) => isHovering.value = false,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              MovieDetailPage(movieID: movieID),
                        ),
                      );
                    },
                    child: Padding(
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
                                                borderRadius:
                                                    const BorderRadius.only(
                                                  topLeft: Radius.circular(12),
                                                  topRight: Radius.circular(12),
                                                ),
                                                child: Image(
                                                  fit: BoxFit.fill,
                                                  image:
                                                      CachedNetworkImageProvider(
                                                          data[innerIndex]
                                                              .imageURL
                                                              .toString()),
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
                                                    padding:
                                                        const EdgeInsets.all(
                                                            4.0),
                                                    child: Text(
                                                      data[innerIndex]
                                                          .title
                                                          .toString(),
                                                      softWrap: true,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      textAlign:
                                                          TextAlign.center,
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            bottom: 4.0),
                                                    child: Text(
                                                        getReleaseDate(
                                                            data[innerIndex]),
                                                        softWrap: true,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: const TextStyle(
                                                            fontSize: 12)),
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
                                                  color: const Color.fromARGB(
                                                      125, 0, 0, 0),
                                                  child: ValueListenableBuilder(
                                                    valueListenable: isFavorite,
                                                    builder: (context, value,
                                                        child) {
                                                      Map<String, dynamic>
                                                          movieMap =
                                                          MoviesData()
                                                              .getMovieMap(data,
                                                                  innerIndex);
                                                      MoviesData()
                                                          .addFavoritesToMoviesList(
                                                              moviesList,
                                                              data,
                                                              innerIndex,
                                                              isFavorite);
                                                      return isFavorite.value
                                                          ? IconButton(
                                                              highlightColor:
                                                                  Color(
                                                                      themeColor),
                                                              hoverColor: Colors
                                                                  .transparent,
                                                              onPressed: () {
                                                                MoviesData()
                                                                    .removeFromMoviesList(
                                                                  moviesList,
                                                                  data[innerIndex]
                                                                      .id,
                                                                );
                                                                FirebaseUserData(
                                                                        user:
                                                                            user)
                                                                    .updateData(
                                                                  gamesList,
                                                                  moviesList,
                                                                  seriesList,
                                                                  booksList,
                                                                  actorsList,
                                                                );
                                                                isFavorite
                                                                        .value =
                                                                    !isFavorite
                                                                        .value;
                                                              },
                                                              icon: Icon(
                                                                Icons.favorite,
                                                                color: Color(
                                                                    themeColor),
                                                              ),
                                                            )
                                                          : IconButton(
                                                              highlightColor:
                                                                  Color(
                                                                      themeColor),
                                                              hoverColor: Colors
                                                                  .transparent,
                                                              onPressed: () {
                                                                MoviesData()
                                                                    .addToMoviesList(
                                                                        moviesList,
                                                                        movieMap);
                                                                FirebaseUserData(
                                                                        user:
                                                                            user)
                                                                    .updateData(
                                                                        gamesList,
                                                                        moviesList,
                                                                        seriesList,
                                                                        booksList,
                                                                        actorsList);
                                                                isFavorite
                                                                        .value =
                                                                    !isFavorite
                                                                        .value;
                                                              },
                                                              icon: const Icon(
                                                                Icons
                                                                    .favorite_outline,
                                                                color: Colors
                                                                    .white,
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
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      );
    },
  );
}
