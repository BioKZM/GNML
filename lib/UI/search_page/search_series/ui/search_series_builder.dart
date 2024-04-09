import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gnml/Logic/seriespage_logic.dart';
import 'package:gnml/Data/series_data.dart';
import 'package:gnml/UI/search_page/search_series/ui/change_series_pages.dart';
import 'package:gnml/UI/search_page/search_series/ui/series_card_builder.dart';
import 'package:gnml/Widgets/circularprogressindicator.dart';

StatefulBuilder searchSeriesBuilder(
  User? user,
  List<dynamic> seriesList,
  int themeColor,
  List<dynamic> gamesList,
  List<dynamic> moviesList,
  List<dynamic> booksList,
  List<dynamic> actorsList,
  int pageIndexSeries,
  String searchText,
) {
  return StatefulBuilder(
    builder: (context, setState) {
      return FutureBuilder<int>(
          future: SeriesPageLogic().getSearchResultsTotalPage(searchText),
          builder: (context, snapshot) {
            int? totalPages = snapshot.data;
            return FutureBuilder<List<dynamic>>(
              future: SeriesData().searchSeries(searchText, pageIndexSeries),
              builder: (context, snapshot) {
                var data = snapshot.data;
                if (snapshot.hasData &&
                    snapshot.connectionState == ConnectionState.done) {
                  return PageView.builder(
                    itemBuilder: (context, index) {
                      return Column(
                        children: [
                          seriesCardBuilder(data, seriesList, themeColor, user,
                              gamesList, moviesList, booksList, actorsList),
                          changeSeriesPages(
                              pageIndexSeries, setState, totalPages),
                        ],
                      );
                    },
                  );
                } else {
                  return const CustomCPI();
                }
              },
            );
          });
    },
  );
}
