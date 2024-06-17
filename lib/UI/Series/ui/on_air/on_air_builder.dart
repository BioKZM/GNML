import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gnml/Logic/seriespage_logic.dart';
import 'package:gnml/UI/Series/ui/on_air/widget/on_air_card.dart';
import 'package:gnml/Widgets/shimmer.dart';

Expanded onAirSeriesBuilder(
  User? user,
  List<dynamic> seriesList,
  Map<String, dynamic> favoritesList,
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
                    return Column(
                      children: [
                        SizedBox(
                          height: 1200,
                          child: onAirSeriesCards(
                            user,
                            data,
                            seriesList,
                            favoritesList,
                            themeColor,
                            gamesList,
                            moviesList,
                            booksList,
                            actorsList,
                            pageIndexOnTheAir,
                            setState,
                            totalPages,
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: IconButton(
                                icon: const Icon(
                                  Icons.arrow_circle_left_outlined,
                                  color: Colors.white,
                                ),
                                onPressed: () {
                                  if (pageIndexOnTheAir > 1) {
                                    setState(() => pageIndexOnTheAir = 1);
                                  }
                                },
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: IconButton(
                                icon: const Icon(
                                  Icons.arrow_left,
                                  color: Colors.white,
                                ),
                                onPressed: () {
                                  if (pageIndexOnTheAir > 1) {
                                    setState(() => pageIndexOnTheAir -= 1);
                                  }
                                },
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                  "${pageIndexOnTheAir.toString()}/$totalPages"),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: IconButton(
                                icon: const Icon(
                                  Icons.arrow_right,
                                  color: Colors.white,
                                ),
                                onPressed: () {
                                  if (pageIndexOnTheAir < totalPages!) {
                                    setState(() {
                                      pageIndexOnTheAir += 1;
                                    });
                                  }
                                },
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: IconButton(
                                icon: const Icon(
                                  Icons.arrow_circle_right_outlined,
                                  color: Colors.white,
                                ),
                                onPressed: () {
                                  if (pageIndexOnTheAir < totalPages!) {
                                    setState(() {
                                      pageIndexOnTheAir = totalPages;
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
