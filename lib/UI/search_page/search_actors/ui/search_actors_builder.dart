import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gnml/Logic/actorpage_logic.dart';
import 'package:gnml/Data/actor_data.dart';
import 'package:gnml/UI/search_page/search_actors/ui/actors_cards_builder.dart';
import 'package:gnml/UI/search_page/search_actors/ui/change_actors_pages.dart';
import 'package:gnml/Widgets/circularprogressindicator.dart';

StatefulBuilder searchActorsBuilder(
  User? user,
  List<dynamic> actorsList,
  int themeColor,
  List<dynamic> gamesList,
  List<dynamic> moviesList,
  List<dynamic> seriesList,
  List<dynamic> booksList,
  int pageIndexActors,
  String searchText,
) {
  return StatefulBuilder(
    builder: (context, setState) {
      return FutureBuilder<int>(
          future: ActorPageLogic().getSearchResultsTotalPage(searchText),
          builder: (context, snapshot) {
            int? totalPages = snapshot.data;
            return FutureBuilder<List<dynamic>>(
              future: ActorsData().searchActors(searchText, pageIndexActors),
              builder: (context, snapshot) {
                var data = snapshot.data;
                if (snapshot.hasData &&
                    snapshot.connectionState == ConnectionState.done) {
                  return PageView.builder(
                    itemBuilder: (context, index) {
                      return Column(
                        children: [
                          actorCardsBuilder(data, actorsList, themeColor, user,
                              gamesList, moviesList, seriesList, booksList),
                          changeActorsPage(
                              pageIndexActors, setState, totalPages),
                        ],
                      );
                    },
                  );
                } else if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const CustomCPI();
                } else {
                  return const Center(
                    child: Text("No result"),
                  );
                }
              },
            );
          });
    },
  );
}
