import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gnml/Data/firebase_user_data.dart';
import 'package:gnml/Data/series_data.dart';
import 'package:gnml/UI/Details/serie_detail_page.dart';

ListView popularSeriesCards(
    User? user,
    PageController pageController,
    List<dynamic>? data,
    List<dynamic> seriesList,
    int themeColor,
    List<dynamic> gamesList,
    List<dynamic> moviesList,
    List<dynamic> booksList,
    List<dynamic> actorsList) {
  return ListView.builder(
    controller: pageController,
    scrollDirection: Axis.horizontal,
    itemCount: data?.length,
    itemBuilder: (context, index) {
      ValueNotifier<bool> isHovering = ValueNotifier<bool>(false);
      ValueNotifier<bool> isFavorite = ValueNotifier<bool>(false);
      int serieID = SeriesData().getSerieID(data, index);
      return SizedBox(
        child: Padding(
          padding: const EdgeInsets.all(5.3),
          child: MouseRegion(
            onEnter: (event) => isHovering.value = true,
            onExit: (event) => isHovering.value = false,
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SerieDetailPage(serieID: serieID),
                  ),
                );
              },
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
                        SizedBox(
                          height: 140,
                          width: 110,
                          child: ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(12),
                              topRight: Radius.circular(12),
                            ),
                            child: Image(
                              fit: BoxFit.cover,
                              image: NetworkImage(
                                data![index].imageURL.toString(),
                              ),
                            ),
                          ),
                        ),
                        Tooltip(
                          message: data[index].name,
                          child: SizedBox(
                            width: 100,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                data[index].name.toString(),
                                softWrap: true,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                              ),
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
                                color: const Color.fromARGB(125, 0, 0, 0),
                                child: ValueListenableBuilder(
                                  valueListenable: isFavorite,
                                  builder: (context, value, child) {
                                    Map<String, dynamic> serieMap = SeriesData()
                                        .getSeriesMap(
                                            data[index].id, data, index);
                                    SeriesData().addFavoritesToSeriesList(
                                        seriesList, data, index, isFavorite);
                                    return isFavorite.value
                                        ? IconButton(
                                            highlightColor: Color(themeColor),
                                            hoverColor: Colors.transparent,
                                            onPressed: () {
                                              SeriesData().removeFromSeriesList(
                                                  seriesList, data[index].id);
                                              FirebaseUserData(user: user)
                                                  .updateData(
                                                      gamesList,
                                                      moviesList,
                                                      seriesList,
                                                      booksList,
                                                      actorsList);
                                              isFavorite.value =
                                                  !isFavorite.value;
                                            },
                                            icon: Icon(
                                              Icons.favorite,
                                              color: Color(themeColor),
                                            ),
                                          )
                                        : IconButton(
                                            highlightColor: Color(themeColor),
                                            hoverColor: Colors.transparent,
                                            onPressed: () {
                                              SeriesData().addSeriesToList(
                                                  seriesList, serieMap);
                                              FirebaseUserData(user: user)
                                                  .updateData(
                                                      gamesList,
                                                      moviesList,
                                                      seriesList,
                                                      booksList,
                                                      actorsList);
                                              isFavorite.value =
                                                  !isFavorite.value;
                                            },
                                            icon: const Icon(
                                              Icons.favorite_outline,
                                              color: Colors.white,
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
        ),
      );
    },
  );
}
