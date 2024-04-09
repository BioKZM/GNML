import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gnml/Logic/seriespage_logic.dart';
import 'package:gnml/UI/series_page/ui/on_air/widget/on_air_card.dart';
import 'package:gnml/Widgets/shimmer.dart';

Expanded onAirSeriesBuilder(
  User? user,
  List<dynamic> seriesList,
  int themeColor,
  List<dynamic> gamesList,
  List<dynamic> moviesList,
  List<dynamic> booksList,
  List<dynamic> actorsList,
  int pageIndexOnTheAir,
) {
  return Expanded(
    child: StatefulBuilder(
      builder: (context, setState) {
        return FutureBuilder<int>(
            future: SeriesPageLogic().getOnTheAirSeriesTotalPages(),
            builder: (context, snapshot) {
              int? totalPages = snapshot.data;
              return FutureBuilder<List<dynamic>>(
                future: SeriesPageLogic().getOnTheAirSeries(pageIndexOnTheAir),
                builder: (context, snapshot) {
                  var data = snapshot.data;
                  if (snapshot.hasData &&
                      snapshot.connectionState == ConnectionState.done) {
                    return onAirSeriesCards(
                      user,
                      data,
                      seriesList,
                      themeColor,
                      gamesList,
                      moviesList,
                      booksList,
                      actorsList,
                      pageIndexOnTheAir,
                      setState,
                      totalPages,
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
                },
              );
            });
      },
    ),
  );
}
