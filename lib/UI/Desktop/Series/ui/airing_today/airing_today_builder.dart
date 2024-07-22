import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:gnml/Logic/seriespage_logic.dart';
import 'package:gnml/UI/Desktop/Series/ui/airing_today/airing_today_card.dart';
import 'package:gnml/Widgets/shimmerCard.dart';

Expanded airingTodaySeriesBuilder(
    User? user,
    List<dynamic> seriesList,
    Map<String, dynamic> favoritesList,
    int themeColor,
    List<dynamic> gamesList,
    List<dynamic> moviesList,
    List<dynamic> booksList,
    List<dynamic> actorsList,
    int pageIndexAiringToday) {
  return Expanded(
    child: StatefulBuilder(
      builder: (context, setState) {
        return FutureBuilder<int>(
            future: SeriesPageLogic().getAiringTodaySeriesTotalPages(),
            builder: (context, snapshot) {
              int? totalPages = snapshot.data;
              return FutureBuilder<List<dynamic>>(
                future: SeriesPageLogic()
                    .getAiringTodaySeries(pageIndexAiringToday),
                builder: (context, snapshot) {
                  var data = snapshot.data;

                  if (snapshot.hasData &&
                      snapshot.connectionState == ConnectionState.done) {
                    return Column(
                      children: [
                        SizedBox(
                          height: 1500,
                          child: airingTodaySeriesCards(
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
                            pageIndexAiringToday,
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
                                  if (pageIndexAiringToday > 1) {
                                    setState(() => pageIndexAiringToday -= 1);
                                  }
                                },
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                  "${pageIndexAiringToday.toString()}/$totalPages"),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: IconButton(
                                icon: const Icon(
                                  FluentIcons.arrow_right_16_filled,
                                  color: Colors.white,
                                ),
                                onPressed: () {
                                  if (pageIndexAiringToday < totalPages!) {
                                    setState(() {
                                      pageIndexAiringToday += 1;
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
