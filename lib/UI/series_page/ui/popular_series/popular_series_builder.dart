import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gnml/Data/Model/serie_model.dart';
import 'package:gnml/Logic/seriespage_logic.dart';
import 'package:gnml/UI/series_page/ui/popular_series/widget/popular_series_card.dart';
import 'package:gnml/Widgets/circularprogressindicator.dart';

StatefulBuilder popularSeriesBuilder(
    User? user,
    PageController pageController,
    List<dynamic> seriesList,
    int themeColor,
    List<dynamic> gamesList,
    List<dynamic> moviesList,
    List<dynamic> booksList,
    List<dynamic> actorsList) {
  return StatefulBuilder(builder: (context, setState) {
    return Expanded(
      child: SizedBox(
        height: 200,
        width: double.infinity,
        child: FutureBuilder<List<SerieModel>>(
          future: SeriesPageLogic().getPopularSeries(),
          builder: (context, snapshot) {
            if (snapshot.hasData &&
                snapshot.connectionState == ConnectionState.done) {
              var data = snapshot.data;
              return popularSeriesCards(
                user,
                pageController,
                data,
                seriesList,
                themeColor,
                gamesList,
                moviesList,
                booksList,
                actorsList,
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
