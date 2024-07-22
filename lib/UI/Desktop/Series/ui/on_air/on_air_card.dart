import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gnml/Data/series_data.dart';
import 'package:gnml/UI/Desktop/Details/serie_detail_page.dart';
import 'package:gnml/UI/Desktop/Series/widget/FavoritesWidget.dart';
import 'package:gnml/UI/Desktop/Series/widget/InfoWidget.dart';
import 'package:gnml/UI/Desktop/Series/widget/LikeWidget.dart';

PageView onAirSeriesCards(
  User? user,
  List<dynamic>? data,
  List<dynamic> seriesList,
  Map<String, dynamic> favoritesList,
  int themeColor,
  List<dynamic> gamesList,
  List<dynamic> moviesList,
  List<dynamic> booksList,
  List<dynamic> actorsList,
  int pageIndexOnTheAir,
  StateSetter setState,
  int? totalPages,
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
            height: 1500,
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 400,
              ),
              itemCount: data?.length,
              itemBuilder: (context, innerIndex) {
                ValueNotifier<bool> isHovering = ValueNotifier<bool>(false);
                ValueNotifier<bool> isLiked = ValueNotifier<bool>(false);
                ValueNotifier<bool> isFavorited = ValueNotifier<bool>(false);
                int serieID = SeriesData().getSerieID(data, innerIndex);
                return MouseRegion(
                  onEnter: (event) => isHovering.value = true,
                  onExit: (event) => isHovering.value = false,
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
                              width: 400,
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
                                          Radius.circular(0),
                                        ),
                                      ),
                                      child: Column(
                                        children: [
                                          Expanded(
                                            child: SizedBox(
                                              // height: 240,
                                              width: 400,
                                              child: Image(
                                                fit: BoxFit.fill,
                                                image: NetworkImage(
                                                  data![innerIndex]
                                                      .imageURL
                                                      .toString(),
                                                ),
                                              ),
                                            ),
                                          ),
                                          // Tooltip(
                                          //   message: data[innerIndex].name,
                                          //   child: SizedBox(
                                          //     width: 180,
                                          //     child: Column(
                                          //       children: [
                                          //         Padding(
                                          //           padding:
                                          //               const EdgeInsets.all(
                                          //                   4.0),
                                          //           child: Text(
                                          //             data[innerIndex]
                                          //                 .name
                                          //                 .toString(),
                                          //             softWrap: true,
                                          //             overflow:
                                          //                 TextOverflow.ellipsis,
                                          //             textAlign:
                                          //                 TextAlign.center,
                                          //           ),
                                          //         ),
                                          //         Padding(
                                          //           padding:
                                          //               const EdgeInsets.only(
                                          //                   bottom: 4.0),
                                          //           child: Text(
                                          //               SeriesData()
                                          //                   .getSerieReleaseDate(
                                          //                 data[innerIndex],
                                          //               ),
                                          //               softWrap: true,
                                          //               overflow: TextOverflow
                                          //                   .ellipsis,
                                          //               textAlign:
                                          //                   TextAlign.center,
                                          //               style: const TextStyle(
                                          //                   fontSize: 12)),
                                          //         ),
                                          //       ],
                                          //     ),
                                          //   ),
                                          // ),
                                        ],
                                      ),
                                    ),
                                    LikeWidget(
                                      isHovering: isHovering,
                                      isLiked: isLiked,
                                      data: data,
                                      innerIndex: innerIndex,
                                      gamesList: gamesList,
                                      moviesList: moviesList,
                                      seriesList: seriesList,
                                      booksList: booksList,
                                      actorsList: actorsList,
                                      themeColor: themeColor,
                                      user: user,
                                    ),
                                    FavoritesWidget(
                                      isHovering: isHovering,
                                      favoriteSeries: favoriteSeries,
                                      isFavorited: isFavorited,
                                      favoriteGames: favoriteGames,
                                      favoriteMovies: favoriteMovies,
                                      favoriteBooks: favoriteBooks,
                                      favoriteActors: favoriteActors,
                                      data: data,
                                      index: index,
                                      innerIndex: innerIndex,
                                      user: user,
                                      seriesList: seriesList,
                                    ),
                                    InfoWidget(
                                      isHovering: isHovering,
                                      data: data,
                                      innerIndex: innerIndex,
                                    )
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
