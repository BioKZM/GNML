import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gnml/UI/Desktop/Details/actors_detail_page.dart';
import 'package:gnml/UI/Desktop/Search/search_actors/ui/widgets/actors_cards.dart';

Expanded actorCardsBuilder(
  List<dynamic>? data,
  List<dynamic> actorsList,
  int themeColor,
  User? user,
  List<dynamic> gamesList,
  List<dynamic> moviesList,
  List<dynamic> seriesList,
  List<dynamic> booksList,
  Map<String, dynamic> favoritesList,
) {
  return Expanded(
    child: SizedBox(
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 350,
        ),
        itemCount: data?.length,
        itemBuilder: (context, innerIndex) {
          ValueNotifier<bool> isHovering = ValueNotifier<bool>(false);
          ValueNotifier<bool> isLiked = ValueNotifier<bool>(false);
          ValueNotifier<bool> isFavorited = ValueNotifier<bool>(false);
          int actorID = getActorID(data, innerIndex);
          return MouseRegion(
            onEnter: (event) => isHovering.value = true,
            onExit: (event) => isHovering.value = false,
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ActorDetailPage(actorID: actorID),
                  ),
                );
              },
              child: actorsCards(
                  data!,
                  innerIndex,
                  isHovering,
                  isLiked,
                  isFavorited,
                  actorID,
                  actorsList,
                  themeColor,
                  user,
                  gamesList,
                  moviesList,
                  seriesList,
                  booksList,
                  favoritesList),
            ),
          );
        },
      ),
    ),
  );
}

int getActorID(List<dynamic>? data, int innerIndex) {
  var actorID = 0;
  if (data![innerIndex].id != null) {
    actorID = data[innerIndex].id!;
  }
  return actorID;
}
