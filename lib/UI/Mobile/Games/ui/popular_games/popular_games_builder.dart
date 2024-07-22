import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gnml/Data/Model/game_model.dart';
import 'package:gnml/Logic/gamepage_logic.dart';
import 'package:gnml/UI/Desktop/Details/game_detail_page.dart';
import 'package:gnml/UI/Desktop/Games/data/games_page_data.dart';
import 'package:gnml/UI/Desktop/Games/ui/popular_games/popular_games_card.dart';
import 'package:gnml/Widgets/circularprogressindicator.dart';

StatefulBuilder popularGamesBuilder(
    PageController pageController,
    List<dynamic> gamesList,
    Map<String, dynamic> favoritesList,
    int themeColor,
    User? user,
    List<dynamic> moviesList,
    List<dynamic> seriesList,
    List<dynamic> booksList,
    List<dynamic> actorsList) {
  return StatefulBuilder(builder: (context, setState) {
    return Expanded(
      child: SizedBox(
        height: 200,
        width: double.infinity,
        child: FutureBuilder<List<GameModel>>(
          future: GamePageLogic().getPopularGameList(
            "popularRightNow",
          ),
          builder: (context, snapshot) {
            if (snapshot.hasData &&
                snapshot.connectionState == ConnectionState.done) {
              var data = snapshot.data;
              return ListView.builder(
                controller: pageController,
                scrollDirection: Axis.horizontal,
                itemCount: data?.length,
                itemBuilder: (context, index) {
                  ValueNotifier<bool> isHovering = ValueNotifier<bool>(false);
                  ValueNotifier<bool> isLiked = ValueNotifier<bool>(false);
                  ValueNotifier<bool> isFavorited = ValueNotifier<bool>(false);
                  String? imageId = GamesPageData().getImageID(data, index);
                  int gameID = GamesPageData().getGameID(data, index);
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
                                builder: (context) =>
                                    GameDetailPage(gameID: gameID),
                              ),
                            );
                          },
                          child: popularGamesCard(
                              imageId,
                              data,
                              index,
                              isHovering,
                              isLiked,
                              isFavorited,
                              gamesList,
                              favoritesList,
                              themeColor,
                              user,
                              moviesList,
                              seriesList,
                              booksList,
                              actorsList),
                        ),
                      ),
                    ),
                  );
                },
              );
            } else {
              bool connectionBool = true;
              if (snapshot.connectionState == ConnectionState.done) {
                connectionBool = false;
              }
              return Center(
                  child: connectionBool
                      ? const CustomCPI()
                      : Card(
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
                        ));
            }
          },
        ),
      ),
    );
  });
}
