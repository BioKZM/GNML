import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gnml/UI/Details/serie_detail_page.dart';
import 'package:gnml/Data/series_data.dart';
import 'package:gnml/UI/search_page/search_series/ui/widget/series_cards.dart';

Expanded seriesCardBuilder(
    List<dynamic>? data,
    List<dynamic> seriesList,
    int themeColor,
    User? user,
    List<dynamic> gamesList,
    List<dynamic> moviesList,
    List<dynamic> booksList,
    List<dynamic> actorsList) {
  return Expanded(
    child: SizedBox(
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 350,
        ),
        itemCount: data?.length,
        itemBuilder: (context, innerIndex) {
          ValueNotifier<bool> isHovering = ValueNotifier<bool>(false);
          ValueNotifier<bool> isFavorite = ValueNotifier<bool>(false);
          int serieID = SeriesData().getSerieID(data, innerIndex);
          return MouseRegion(
            onEnter: (event) => isHovering.value = true,
            onExit: (event) => isHovering.value = false,
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SerieDetailPage(serieID: serieID),
                  ),
                );
              },
              child: seriesCards(
                  data!,
                  innerIndex,
                  isHovering,
                  isFavorite,
                  serieID,
                  seriesList,
                  themeColor,
                  user,
                  gamesList,
                  moviesList,
                  booksList,
                  actorsList),
            ),
          );
        },
      ),
    ),
  );
}
