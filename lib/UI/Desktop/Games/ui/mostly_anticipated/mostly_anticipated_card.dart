import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gnml/Data/Model/game_model.dart';
import 'package:gnml/UI/Desktop/Details/game_detail_page.dart';
import 'package:gnml/UI/Desktop/Games/data/games_page_data.dart';
import 'package:gnml/UI/Desktop/Games/widget/FavoritesWidget.dart';
import 'package:gnml/UI/Desktop/Games/widget/InfoWidget.dart';
import 'package:gnml/UI/Desktop/Games/widget/LikeWidget.dart';

Column mostlyAnticipatedCard(
    User? user,
    int totalPages,
    List<GameModel> data,
    List<dynamic> gamesList,
    Map<String, dynamic> favoritesList,
    int themeColor,
    List<dynamic> moviesList,
    List<dynamic> seriesList,
    List<dynamic> booksList,
    List<dynamic> actorsList,
    ValueNotifier<int> pageIndex,
    pageControllerMostlyAnticipated) {
  return Column(
    children: [
      SizedBox(
        height: 1500,
        child: PageView.builder(
            itemCount: totalPages,
            controller: pageControllerMostlyAnticipated,
            itemBuilder: (context, index) {
              List<GameModel> pageData =
                  GamesPageData().setPageIndex(index, data);
              List<dynamic> favoriteGames = favoritesList['games'];
              List<dynamic> favoriteMovies = favoritesList['movies'];
              List<dynamic> favoriteSeries = favoritesList['series'];
              List<dynamic> favoriteBooks = favoritesList['books'];
              List<dynamic> favoriteActors = favoritesList['actors'];
              return GridView.builder(
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 400),
                itemCount: pageData.length,
                itemBuilder: (context, innerIndex) {
                  // ignore: prefer_typing_uninitialized_variables
                  ValueNotifier<bool> isHovering = ValueNotifier<bool>(false);
                  ValueNotifier<bool> isLiked = ValueNotifier<bool>(false);
                  ValueNotifier<bool> isFavorited = ValueNotifier<bool>(false);
                  // ignore: prefer_typing_uninitialized_variables
                  var imageId =
                      GamesPageData().getImageID(pageData, innerIndex);
                  // ignore: prefer_typing_uninitialized_variables
                  var dateTime =
                      GamesPageData().getDateTime(pageData, innerIndex);
                  int gameID = GamesPageData().getGameID(pageData, innerIndex);

                  return MouseRegion(
                    onEnter: (event) => isHovering.value = true,
                    onExit: (event) => isHovering.value = false,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                GameDetailPage(gameID: gameID),
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
                                                  image:
                                                      CachedNetworkImageProvider(
                                                    """https://${pageData[innerIndex].url}""",
                                                  ),
                                                ),
                                              ),
                                            ),
                                            // Tooltip(
                                            //   message:
                                            //       pageData[innerIndex].name,
                                            //   child: SizedBox(
                                            //     width: 180,
                                            //     child: Column(
                                            //       children: [
                                            //         Padding(
                                            //           padding:
                                            //               const EdgeInsets.all(
                                            //                   4.0),
                                            //           child: Text(
                                            //             pageData[innerIndex]
                                            //                 .name
                                            //                 .toString(),
                                            //             softWrap: true,
                                            //             overflow: TextOverflow
                                            //                 .ellipsis,
                                            //             textAlign:
                                            //                 TextAlign.center,
                                            //           ),
                                            //         ),
                                            //         Padding(
                                            //           padding:
                                            //               const EdgeInsets.only(
                                            //                   bottom: 4.0),
                                            //           child: Text(
                                            //             dateTime.toString(),
                                            //             softWrap: true,
                                            //             overflow: TextOverflow
                                            //                 .ellipsis,
                                            //             textAlign:
                                            //                 TextAlign.center,
                                            //             style: const TextStyle(
                                            //                 fontSize: 12),
                                            //           ),
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
                                        imageId: imageId,
                                        pageData: pageData,
                                        data: data,
                                        innerIndex: innerIndex,
                                        gamesList: gamesList,
                                        moviesList: moviesList,
                                        seriesList: seriesList,
                                        booksList: booksList,
                                        actorsList: actorsList,
                                        user: user,
                                        themeColor: themeColor,
                                      ),
                                      FavoritesWidget(
                                        isHovering: isHovering,
                                        favoriteGames: favoriteGames,
                                        pageData: pageData,
                                        isFavorited: isFavorited,
                                        favoriteMovies: favoriteMovies,
                                        favoriteSeries: favoriteSeries,
                                        favoriteBooks: favoriteBooks,
                                        favoriteActors: favoriteActors,
                                        imageId: imageId,
                                        innerIndex: innerIndex,
                                        user: user,
                                      ),
                                      InfoWidget(
                                        isHovering: isHovering,
                                        pageData: pageData,
                                        dateTime: dateTime,
                                        innerIndex: innerIndex,
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
              );
            }),
      ),
      // ValueListenableBuilder(
      //     valueListenable: pageIndex,
      //     builder: (context, value, child) {
      //       return Row(
      //         mainAxisAlignment: MainAxisAlignment.end,
      //         children: [
      //           Padding(
      //             padding: const EdgeInsets.all(8.0),
      //             child: IconButton(
      //               icon: const Icon(
      //                 FluentIcons.arrow_left_16_filled,
      //                 color: Colors.white,
      //               ),
      //               onPressed: () {
      //                 if (pageIndex.value > 1) {
      //                   pageControllerMostlyAnticipated.previousPage(
      //                     duration: const Duration(milliseconds: 500),
      //                     curve: Curves.ease,
      //                   );
      //                   pageIndex.value -= 1;
      //                 }
      //               },
      //             ),
      //           ),
      //           Padding(
      //             padding: const EdgeInsets.all(8.0),
      //             child: Text("${pageIndex.value}/$totalPages"),
      //           ),
      //           Padding(
      //             padding: const EdgeInsets.all(8.0),
      //             child: IconButton(
      //               icon: const Icon(
      //                 FluentIcons.arrow_right_16_filled,
      //                 color: Colors.white,
      //               ),
      //               onPressed: () {
      //                 if (pageIndex.value < totalPages) {
      //                   pageControllerMostlyAnticipated.nextPage(
      //                     duration: const Duration(milliseconds: 500),
      //                     curve: Curves.ease,
      //                   );
      //                   pageIndex.value += 1;
      //                 }
      //               },
      //             ),
      //           ),
      //         ],
      //       );
      //     }),
    ],
  );
}
