import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gnml/Data/firebase_user_data.dart';
import 'package:gnml/Data/series_data.dart';
import 'package:gnml/UI/Details/serie_detail_page.dart';

PageView airingTodaySeriesCards(
  User? user,
  List<dynamic>? data,
  List<dynamic> seriesList,
  int themeColor,
  List<dynamic> gamesList,
  List<dynamic> moviesList,
  List<dynamic> booksList,
  List<dynamic> actorsList,
  StateSetter setState,
  int? totalPages,
  int pageIndexAiringToday,
) {
  return PageView.builder(
    itemBuilder: (context, index) {
      return Column(
        children: [
          SizedBox(
            height: 1200,
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 300,
              ),
              itemCount: data?.length,
              itemBuilder: (context, innerIndex) {
                ValueNotifier<bool> isHovering = ValueNotifier<bool>(false);
                ValueNotifier<bool> isFavorite = ValueNotifier<bool>(false);
                int serieID = SeriesData().getSerieID(data, innerIndex);
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SerieDetailPage(serieID: serieID),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: double.infinity,
                            width: 180,
                            child: GridTile(
                              child: Stack(
                                children: [
                                  Card(
                                    elevation: 0,
                                    shape: const RoundedRectangleBorder(
                                      side: BorderSide(
                                        color: Colors.transparent,
                                      ),
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(12),
                                      ),
                                    ),
                                    child: Column(
                                      children: [
                                        Expanded(
                                          child: SizedBox(
                                            height: 240,
                                            width: 180,
                                            child: ClipRRect(
                                              borderRadius:
                                                  const BorderRadius.only(
                                                topLeft: Radius.circular(12),
                                                topRight: Radius.circular(12),
                                              ),
                                              child: Image(
                                                fit: BoxFit.fill,
                                                image: NetworkImage(
                                                  data![innerIndex]
                                                      .imageURL
                                                      .toString(),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Tooltip(
                                          message: data[innerIndex].name,
                                          child: SizedBox(
                                            width: 180,
                                            child: Column(
                                              children: [
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.all(4.0),
                                                  child: Text(
                                                    data[innerIndex]
                                                        .name
                                                        .toString(),
                                                    softWrap: true,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          bottom: 4.0),
                                                  child: Text(
                                                      SeriesData()
                                                          .getSerieReleaseDate(
                                                        data[innerIndex],
                                                      ),
                                                      softWrap: true,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: const TextStyle(
                                                          fontSize: 12)),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  ValueListenableBuilder(
                                    valueListenable: isHovering,
                                    builder: (context, value, child) {
                                      return isHovering.value
                                          ? Positioned(
                                              top: 5,
                                              right: 5,
                                              child: Card(
                                                elevation: 0,
                                                color: const Color.fromARGB(
                                                    125, 0, 0, 0),
                                                child: ValueListenableBuilder(
                                                  valueListenable: isFavorite,
                                                  builder:
                                                      (context, value, child) {
                                                    Map<String, dynamic>
                                                        serieMap = SeriesData()
                                                            .getSeriesMap(
                                                                data[innerIndex]
                                                                    .id,
                                                                data,
                                                                innerIndex);
                                                    SeriesData()
                                                        .addFavoritesToSeriesList(
                                                            seriesList,
                                                            data,
                                                            innerIndex,
                                                            isFavorite);
                                                    return isFavorite.value
                                                        ? IconButton(
                                                            highlightColor:
                                                                Color(
                                                                    themeColor),
                                                            hoverColor: Colors
                                                                .transparent,
                                                            onPressed: () {
                                                              SeriesData()
                                                                  .removeFromSeriesList(
                                                                      seriesList,
                                                                      data[innerIndex]
                                                                          .id);
                                                              FirebaseUserData(
                                                                      user:
                                                                          user)
                                                                  .updateData(
                                                                      gamesList,
                                                                      moviesList,
                                                                      seriesList,
                                                                      booksList,
                                                                      actorsList);
                                                              isFavorite.value =
                                                                  !isFavorite
                                                                      .value;
                                                            },
                                                            icon: Icon(
                                                              Icons.favorite,
                                                              color: Color(
                                                                  themeColor),
                                                            ),
                                                          )
                                                        : IconButton(
                                                            highlightColor:
                                                                Color(
                                                                    themeColor),
                                                            hoverColor: Colors
                                                                .transparent,
                                                            onPressed: () {
                                                              SeriesData()
                                                                  .addSeriesToList(
                                                                      seriesList,
                                                                      serieMap);
                                                              FirebaseUserData(
                                                                      user:
                                                                          user)
                                                                  .updateData(
                                                                      gamesList,
                                                                      moviesList,
                                                                      seriesList,
                                                                      booksList,
                                                                      actorsList);
                                                              isFavorite.value =
                                                                  !isFavorite
                                                                      .value;
                                                            },
                                                            icon: const Icon(
                                                              Icons
                                                                  .favorite_outline,
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                          );
                                                  },
                                                ),
                                              ),
                                            )
                                          : const SizedBox();
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                );
              },
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
                    if (pageIndexAiringToday > 1) {
                      setState(() => pageIndexAiringToday = 1);
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
                    if (pageIndexAiringToday > 1) {
                      setState(() => pageIndexAiringToday -= 1);
                    }
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text("${pageIndexAiringToday.toString()}/$totalPages"),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: IconButton(
                  icon: const Icon(
                    Icons.arrow_right,
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
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: IconButton(
                  icon: const Icon(
                    Icons.arrow_circle_right_outlined,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    if (pageIndexAiringToday < totalPages!) {
                      setState(() {
                        pageIndexAiringToday = totalPages;
                      });
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      );
    },
  );
}
