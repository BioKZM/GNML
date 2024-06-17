import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gnml/Data/Model/game_model.dart';
import 'package:gnml/Logic/gamepage_logic.dart';
import 'package:gnml/UI/Games/ui/coming_soon/widget/coming_soon_card.dart';
import 'package:gnml/Widgets/shimmer.dart';

StatefulBuilder comingSoonBuilder(
  User? user,
  List<dynamic> gamesList,
  Map<String, dynamic> favoritesList,
  int themeColor,
  List<dynamic> moviesList,
  List<dynamic> seriesList,
  List<dynamic> booksList,
  List<dynamic> actorsList,
  PageController pageControllerComingSoon,
) {
  return StatefulBuilder(builder: (context, setState) {
    ValueNotifier<int> pageIndex = ValueNotifier<int>(1);
    return Expanded(
      child: FutureBuilder<List<GameModel>>(
          future: GamePageLogic().getPopularGameList(
            "comingSoon",
          ),
          builder: (context, snapshot) {
            if (snapshot.hasData &&
                snapshot.connectionState == ConnectionState.done) {
              var data = snapshot.data;
              int totalPages = (data!.length / 15).ceil();
              return comingSoonCards(
                  user,
                  totalPages,
                  pageControllerComingSoon,
                  data,
                  gamesList,
                  favoritesList,
                  themeColor,
                  moviesList,
                  seriesList,
                  booksList,
                  actorsList,
                  pageIndex);
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
