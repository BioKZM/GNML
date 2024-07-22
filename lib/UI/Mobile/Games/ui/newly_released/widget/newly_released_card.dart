import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gnml/Data/Model/game_model.dart';
import 'package:gnml/Data/games_data.dart';
import 'package:gnml/UI/Desktop/Details/game_detail_page.dart';
import 'package:gnml/UI/Desktop/Games/data/games_page_data.dart';
import 'package:gnml/Data/firebase_user_data.dart';

Column newlyReleasedCards(
    User? user,
    PageController pageControllerNewlyReleased,
    int totalPages,
    List<GameModel> data,
    List<dynamic> gamesList,
    Map<String, dynamic> favoritesList,
    int themeColor,
    List<dynamic> moviesList,
    List<dynamic> seriesList,
    List<dynamic> booksList,
    List<dynamic> actorsList,
    ValueNotifier<int> pageIndex) {
  return Column(
    children: [
      SizedBox(
        height: 950,
        child: PageView.builder(
            controller: pageControllerNewlyReleased,
            itemCount: totalPages,
            itemBuilder: (context, int index) {
              List<GameModel> pageData =
                  GamesPageData().setPageIndex(index, data);
              List<dynamic> favoriteGames = favoritesList['games'];
              List<dynamic> favoriteMovies = favoritesList['movies'];
              List<dynamic> favoriteSeries = favoritesList['series'];
              List<dynamic> favoriteBooks = favoritesList['books'];
              List<dynamic> favoriteActors = favoritesList['actors'];
              return GridView.builder(
                // gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                //     crossAxisCount: 6),
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 350),
                shrinkWrap: true,
                itemCount: pageData.length,
                itemBuilder: (context, innerIndex) {
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
                    onHover: (event) => isHovering.value = true,
                    onExit: (event) => isHovering.value = false,
                    cursor: SystemMouseCursors.click,
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
                                                    topLeft:
                                                        Radius.circular(12),
                                                    topRight:
                                                        Radius.circular(12),
                                                  ),
                                                  child: Image(
                                                    fit: BoxFit.fill,
                                                    image:
                                                        CachedNetworkImageProvider(
                                                      """https://${pageData[innerIndex].url}""",
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Tooltip(
                                              message:
                                                  pageData[innerIndex].name,
                                              child: SizedBox(
                                                width: 180,
                                                child: Column(
                                                  children: [
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              4.0),
                                                      child: Text(
                                                        pageData[innerIndex]
                                                            .name
                                                            .toString(),
                                                        softWrap: true,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        textAlign:
                                                            TextAlign.center,
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              bottom: 4.0),
                                                      child: Text(
                                                        dateTime.toString(),
                                                        softWrap: true,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: const TextStyle(
                                                            fontSize: 12),
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
                                                    color: const Color.fromARGB(
                                                        125, 0, 0, 0),
                                                    child:
                                                        ValueListenableBuilder(
                                                            valueListenable:
                                                                isLiked,
                                                            builder: (context,
                                                                value, child) {
                                                              Map<String,
                                                                      dynamic>
                                                                  gameMap =
                                                                  GamesPageData().getGameMap(
                                                                      pageData,
                                                                      innerIndex,
                                                                      imageId);
                                                              GamesPageData()
                                                                  .addLikesFromGamesList(
                                                                      gamesList,
                                                                      pageData,
                                                                      innerIndex,
                                                                      isLiked);
                                                              return isLiked
                                                                      .value
                                                                  ? IconButton(
                                                                      highlightColor:
                                                                          Color(
                                                                              themeColor),
                                                                      hoverColor:
                                                                          Colors
                                                                              .transparent,
                                                                      onPressed:
                                                                          () {
                                                                        GamesPageData().removeFromGamesList(
                                                                            gamesList,
                                                                            pageData,
                                                                            innerIndex);
                                                                        FirebaseUserData(user: user).updateData(
                                                                            gamesList,
                                                                            moviesList,
                                                                            seriesList,
                                                                            booksList,
                                                                            actorsList);
                                                                        isLiked.value =
                                                                            !isLiked.value;
                                                                      },
                                                                      icon:
                                                                          Icon(
                                                                        Icons
                                                                            .favorite,
                                                                        color: Color(
                                                                            themeColor),
                                                                      ),
                                                                    )
                                                                  : IconButton(
                                                                      highlightColor:
                                                                          Color(
                                                                              themeColor),
                                                                      hoverColor:
                                                                          Colors
                                                                              .transparent,
                                                                      onPressed:
                                                                          () {
                                                                        GamesPageData().addToGamesList(
                                                                            gamesList,
                                                                            gameMap);
                                                                        FirebaseUserData(user: user).updateData(
                                                                            gamesList,
                                                                            moviesList,
                                                                            seriesList,
                                                                            booksList,
                                                                            actorsList);
                                                                        isLiked.value =
                                                                            !isLiked.value;
                                                                      },
                                                                      icon:
                                                                          const Icon(
                                                                        Icons
                                                                            .favorite_outline,
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
                                      ValueListenableBuilder(
                                        valueListenable: isHovering,
                                        builder: (context, value, child) {
                                          GamesData().addFavoritesFromData(
                                            favoriteGames,
                                            pageData,
                                            innerIndex,
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
                                                    child:
                                                        ValueListenableBuilder(
                                                            valueListenable:
                                                                isFavorited,
                                                            builder: (context,
                                                                value, child) {
                                                              return isFavorited
                                                                      .value
                                                                  ? IconButton(
                                                                      highlightColor:
                                                                          Colors
                                                                              .amber,
                                                                      hoverColor:
                                                                          Colors
                                                                              .transparent,
                                                                      onPressed:
                                                                          () {
                                                                        GamesData().removeFromGameList(
                                                                            favoriteGames,
                                                                            pageData[innerIndex].id);
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
                                                                      icon:
                                                                          const Icon(
                                                                        Icons
                                                                            .star,
                                                                        color: Colors
                                                                            .amber,
                                                                      ),
                                                                    )
                                                                  : IconButton(
                                                                      highlightColor:
                                                                          Colors
                                                                              .amber,
                                                                      hoverColor:
                                                                          Colors
                                                                              .transparent,
                                                                      onPressed:
                                                                          () {
                                                                        Map<String, dynamic> gameMap = GamesPageData().getGameMap(
                                                                            pageData,
                                                                            innerIndex,
                                                                            imageId);
                                                                        GamesData().addToGamesList(
                                                                            favoriteGames,
                                                                            gameMap);
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
              );
            }),
      ),
      ValueListenableBuilder(
          valueListenable: pageIndex,
          builder: (context, value, child) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: IconButton(
                    icon: const Icon(
                      Icons.arrow_circle_left_outlined,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      if (pageIndex.value > 1) {
                        pageControllerNewlyReleased.jumpToPage(1);
                        pageIndex.value = 1;
                      }
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: IconButton(
                    icon: const Icon(
                      Icons.arrow_left,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      if (pageIndex.value > 1) {
                        pageControllerNewlyReleased.previousPage(
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.ease,
                        );
                        pageIndex.value -= 1;
                      }
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("${pageIndex.value}/$totalPages"),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: IconButton(
                    icon: const Icon(
                      Icons.arrow_right,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      if (pageIndex.value < totalPages) {
                        pageControllerNewlyReleased.nextPage(
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.ease,
                        );
                        pageIndex.value += 1;
                      }
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: IconButton(
                    icon: const Icon(
                      Icons.arrow_circle_right_outlined,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      if (pageIndex.value < totalPages) {
                        pageControllerNewlyReleased.jumpToPage(totalPages);
                        pageIndex.value = totalPages;
                      }
                    },
                  ),
                ),
              ],
            );
          }),
    ],
  );
}
