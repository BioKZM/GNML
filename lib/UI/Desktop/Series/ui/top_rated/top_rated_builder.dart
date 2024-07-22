import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:gnml/Logic/seriespage_logic.dart';
import 'package:gnml/UI/Desktop/Series/ui/top_rated/top_rated_card.dart';
import 'package:gnml/Widgets/shimmerCard.dart';

Expanded topRatedSeriesBuilder(
    User? user,
    List<dynamic> seriesList,
    Map<String, dynamic> favoritesList,
    int themeColor,
    List<dynamic> gamesList,
    List<dynamic> moviesList,
    List<dynamic> booksList,
    List<dynamic> actorsList,
    int pageIndexTopRated) {
  return Expanded(
    child: StatefulBuilder(
      builder: (context, setState) {
        return FutureBuilder<int>(
            future: SeriesPageLogic().getTopRatedSeriesTotalPages(),
            builder: (context, snapshot) {
              int? totalPages = snapshot.data;
              return FutureBuilder<List<dynamic>>(
                future: SeriesPageLogic().getTopRatedSeries(pageIndexTopRated),
                builder: (context, snapshot) {
                  var data = snapshot.data;

                  if (snapshot.hasData &&
                      snapshot.connectionState == ConnectionState.done) {
                    return Column(
                      children: [
                        SizedBox(
                          height: 1500,
                          child: topRatedSeriesCards(
                            user,
                            data,
                            seriesList,
                            favoritesList,
                            themeColor,
                            gamesList,
                            moviesList,
                            booksList,
                            actorsList,
                            setState,
                            totalPages,
                            pageIndexTopRated,
                          ),
                        ),
                        Row(
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
                                  if (pageIndexTopRated > 1) {
                                    setState(() => pageIndexTopRated -= 1);
                                  }
                                },
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                  "${pageIndexTopRated.toString()}/$totalPages"),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: IconButton(
                                icon: const Icon(
                                  FluentIcons.arrow_right_16_filled,
                                  color: Colors.white,
                                ),
                                onPressed: () {
                                  if (pageIndexTopRated < totalPages!) {
                                    setState(() {
                                      pageIndexTopRated += 1;
                                    });
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
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
                },
              );
            });
      },
    ),
  );
}
