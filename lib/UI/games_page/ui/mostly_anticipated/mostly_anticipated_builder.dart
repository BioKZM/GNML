import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gnml/Data/Model/game_model.dart';
import 'package:gnml/Logic/gamepage_logic.dart';
import 'package:gnml/UI/games_page/ui/mostly_anticipated/widget/mostly_anticipated_card.dart';
import 'package:gnml/Widgets/shimmer.dart';

StatefulBuilder mostlyAnticipatedBuilder(
  User? user,
  List<dynamic> gamesList,
  int themeColor,
  List<dynamic> moviesList,
  List<dynamic> seriesList,
  List<dynamic> booksList,
  List<dynamic> actorsList,
  PageController pageControllerMostlyAnticipated,
) {
  return StatefulBuilder(builder: (context, setState) {
    ValueNotifier<int> pageIndex = ValueNotifier<int>(1);
    return Expanded(
      child: FutureBuilder<List<GameModel>>(
          future: GamePageLogic().getPopularGameList(
            "mostlyAnticipated",
          ),
          builder: (context, snapshot) {
            if (snapshot.hasData &&
                snapshot.connectionState == ConnectionState.done) {
              var data = snapshot.data;
              int totalPages = (data!.length / 15).ceil();
              return mostlyAnticipatedCard(
                  user,
                  totalPages,
                  data,
                  gamesList,
                  themeColor,
                  moviesList,
                  seriesList,
                  booksList,
                  actorsList,
                  pageIndex,
                  pageControllerMostlyAnticipated);
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
                                  'Veriler yüklenirken bir hata oluştu. Yeniden denemek için tıkla'),
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
