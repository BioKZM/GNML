import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:gnml/Data/Model/game_model.dart';
import 'package:gnml/Logic/gamepage_logic.dart';
import 'package:gnml/UI/Desktop/Games/ui/newly_released/newly_released_card.dart';
import 'package:gnml/Widgets/shimmerCard.dart';

StatefulBuilder newlyReleasedBuilder(
  User? user,
  List<dynamic> gamesList,
  Map<String, dynamic> favoritesList,
  int themeColor,
  List<dynamic> moviesList,
  List<dynamic> seriesList,
  List<dynamic> booksList,
  List<dynamic> actorsList,
  PageController pageControllerNewlyReleased,
) {
  return StatefulBuilder(builder: (context, setState) {
    ValueNotifier<int> pageIndex = ValueNotifier<int>(1);
    return Expanded(
      child: FutureBuilder<List<GameModel>>(
          future: GamePageLogic().getPopularGameList(
            "newlyReleased",
          ),
          builder: (context, snapshot) {
            if (snapshot.hasData &&
                snapshot.connectionState == ConnectionState.done) {
              var data = snapshot.data;
              int totalPages = (data!.length / 20).ceil();
              return Column(
                children: [
                  SizedBox(
                    height: 1500,
                    child: newlyReleasedCards(
                        user,
                        pageControllerNewlyReleased,
                        totalPages,
                        data,
                        gamesList,
                        favoritesList,
                        themeColor,
                        moviesList,
                        seriesList,
                        booksList,
                        actorsList,
                        pageIndex),
                  ),
                  ValueListenableBuilder(
                      valueListenable: pageIndex,
                      builder: (context, value, child) {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: IconButton(
                                icon: const Icon(
                                  FluentIcons.arrow_left_16_filled,
                                  color: Colors.white,
                                ),
                                onPressed: () {
                                  if (pageIndex.value > 1) {
                                    pageControllerNewlyReleased.previousPage(
                                      duration:
                                          const Duration(milliseconds: 500),
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
                                  FluentIcons.arrow_right_16_filled,
                                  color: Colors.white,
                                ),
                                onPressed: () {
                                  if (pageIndex.value < totalPages) {
                                    pageControllerNewlyReleased.nextPage(
                                      duration:
                                          const Duration(milliseconds: 500),
                                      curve: Curves.ease,
                                    );
                                    pageIndex.value += 1;
                                  }
                                },
                              ),
                            ),
                          ],
                        );
                      }),
                ],
              );
            } else {
              bool connectionBool = true;
              if (snapshot.connectionState == ConnectionState.done) {
                connectionBool = false;
              }
              return connectionBool
                  ? const ShimmerEffect()
                  : Center(
                      child: Card(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                  'An error occurred while loading data. Click to try again'),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: IconButton(
                                icon: const Icon(Icons.refresh),
                                onPressed: () {
                                  setState(() {});
                                },
                              ),
                            )
                          ],
                        ),
                      ),
                    );
            }
          }),
    );
  });
}
