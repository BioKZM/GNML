import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gnml/Data/firebase_user_data.dart';
import 'package:gnml/Data/series_data.dart';
import 'package:gnml/UI/Desktop/Details/serie_detail_page.dart';

PageView topRatedSeriesCards(
  User? user,
  List<dynamic>? data,
  List<dynamic> seriesList,
  Map<String, dynamic> favoritesList,
  int themeColor,
  List<dynamic> gamesList,
  List<dynamic> moviesList,
  List<dynamic> booksList,
  List<dynamic> actorsList,
  StateSetter setState,
  int? totalPages,
  int pageIndexTopRated,
) {
  return PageView.builder(
    itemBuilder: (context, index) {
      List<dynamic> favoriteGames = favoritesList['games'];
      List<dynamic> favoriteMovies = favoritesList['movies'];
      List<dynamic> favoriteSeries = favoritesList['series'];
      List<dynamic> favoriteBooks = favoritesList['books'];
      List<dynamic> favoriteActors = favoritesList['actors'];
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
                ValueNotifier<bool> isLiked = ValueNotifier<bool>(false);
                ValueNotifier<bool> isFavorited = ValueNotifier<bool>(false);
                var serieID = 0;
                if (data![innerIndex].id != null) {
                  serieID = data[innerIndex].id!;
                }
                return MouseRegion(
                  onEnter: (event) => isHovering.value = true,
                  onExit: (event) => isHovering.value = false,
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              SerieDetailPage(serieID: serieID),
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
                                                  image: NetworkImage(
                                                    data[innerIndex]
                                                        .imageURL
                                                        .toString(),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          Tooltip(
                                            message: data[innerIndex].name,
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
                                                          .name
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
                                                        SeriesData()
                                                            .getSerieReleaseDate(
                                                                data[
                                                                    innerIndex]),
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
                                                    valueListenable: isLiked,
                                                    builder: (context, value,
                                                        child) {
                                                      Map<String, dynamic>
                                                          serieMap =
                                                          SeriesData()
                                                              .getSeriesMap(
                                                                  data[innerIndex]
                                                                      .id,
                                                                  data,
                                                                  innerIndex);
                                                      SeriesData()
                                                          .addFavoritesFromData(
                                                              seriesList,
                                                              data,
                                                              innerIndex,
                                                              isLiked);
                                                      return isLiked.value
                                                          ? IconButton(
                                                              highlightColor:
                                                                  Color(
                                                                      themeColor),
                                                              hoverColor: Colors
                                                                  .transparent,
                                                              onPressed: () {
                                                                SeriesData().removeFromSeriesList(
                                                                    seriesList,
                                                                    data[innerIndex]
                                                                        .id);
                                                                FirebaseUserData(
                                                                        user:
                                                                            user)
                                                                    .updateData(
                                                                        gamesList,
                                                                        moviesList,
                                                                        seriesList,
                                                                        booksList,
                                                                        actorsList);
                                                                isLiked.value =
                                                                    !isLiked
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
                                                                SeriesData()
                                                                    .addToSeriesList(
                                                                        seriesList,
                                                                        serieMap);
                                                                FirebaseUserData(
                                                                        user:
                                                                            user)
                                                                    .updateData(
                                                                        gamesList,
                                                                        moviesList,
                                                                        seriesList,
                                                                        booksList,
                                                                        actorsList);
                                                                isLiked.value =
                                                                    !isLiked
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
                                                    valueListenable: isLiked,
                                                    builder: (context, value,
                                                        child) {
                                                      Map<String, dynamic>
                                                          serieMap =
                                                          SeriesData()
                                                              .getSeriesMap(
                                                                  serieID,
                                                                  data,
                                                                  innerIndex);
                                                      SeriesData()
                                                          .addFavoritesFromData(
                                                              seriesList,
                                                              data,
                                                              innerIndex,
                                                              isLiked);
                                                      return isLiked.value
                                                          ? IconButton(
                                                              highlightColor:
                                                                  Color(
                                                                      themeColor),
                                                              hoverColor: Colors
                                                                  .transparent,
                                                              onPressed: () {
                                                                SeriesData().removeFromSeriesList(
                                                                    seriesList,
                                                                    data[innerIndex]
                                                                        .id);
                                                                FirebaseUserData(
                                                                        user:
                                                                            user)
                                                                    .updateData(
                                                                        gamesList,
                                                                        moviesList,
                                                                        seriesList,
                                                                        booksList,
                                                                        actorsList);
                                                                isLiked.value =
                                                                    !isLiked
                                                                        .value;
                                                              },
                                                              icon: const Icon(
                                                                Icons.favorite,
                                                                color: Colors
                                                                    .amber,
                                                              ),
                                                            )
                                                          : IconButton(
                                                              highlightColor:
                                                                  Colors.amber,
                                                              hoverColor: Colors
                                                                  .transparent,
                                                              onPressed: () {
                                                                SeriesData()
                                                                    .addToSeriesList(
                                                                        seriesList,
                                                                        serieMap);
                                                                FirebaseUserData(
                                                                        user:
                                                                            user)
                                                                    .updateData(
                                                                        gamesList,
                                                                        moviesList,
                                                                        seriesList,
                                                                        booksList,
                                                                        actorsList);
                                                                isLiked.value =
                                                                    !isLiked
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
                                    ValueListenableBuilder(
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
                                                  color: const Color.fromARGB(
                                                      125, 0, 0, 0),
                                                  child: ValueListenableBuilder(
                                                      valueListenable:
                                                          isFavorited,
                                                      builder: (context, value,
                                                          child) {
                                                        return isFavorited.value
                                                            ? IconButton(
                                                                highlightColor:
                                                                    Colors
                                                                        .amber,
                                                                hoverColor: Colors
                                                                    .transparent,
                                                                onPressed: () {
                                                                  SeriesData().removeFromSeriesList(
                                                                      favoriteSeries,
                                                                      seriesList[
                                                                              index]
                                                                          [
                                                                          'serieID']);
                                                                  FirebaseUserData(
                                                                          user:
                                                                              user)
                                                                      .updateFavoritesData(
                                                                    favoriteGames,
                                                                    favoriteMovies,
                                                                    favoriteSeries,
                                                                    favoriteBooks,
                                                                    favoriteActors,
                                                                  );
                                                                  isFavorited
                                                                          .value =
                                                                      !isFavorited
                                                                          .value;
                                                                },
                                                                icon:
                                                                    const Icon(
                                                                  Icons.star,
                                                                  color: Colors
                                                                      .amber,
                                                                ),
                                                              )
                                                            : IconButton(
                                                                highlightColor:
                                                                    Colors
                                                                        .amber,
                                                                hoverColor: Colors
                                                                    .transparent,
                                                                onPressed: () {
                                                                  Map<String,
                                                                          dynamic>
                                                                      serieMap =
                                                                      SeriesData().getSeriesMap(
                                                                          data[index]
                                                                              .id,
                                                                          data,
                                                                          index);
                                                                  SeriesData().addToSeriesList(
                                                                      favoriteSeries,
                                                                      serieMap);
                                                                  FirebaseUserData(
                                                                          user:
                                                                              user)
                                                                      .updateFavoritesData(
                                                                    favoriteGames,
                                                                    favoriteMovies,
                                                                    favoriteSeries,
                                                                    favoriteBooks,
                                                                    favoriteActors,
                                                                  );
                                                                  isFavorited
                                                                          .value =
                                                                      !isFavorited
                                                                          .value;
                                                                },
                                                                icon:
                                                                    const Icon(
                                                                  Icons
                                                                      .star_outline,
                                                                  color: Colors
                                                                      .white,
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
