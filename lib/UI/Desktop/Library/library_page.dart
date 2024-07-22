// import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gnml/Data/firebase_user_data.dart';
import 'package:gnml/Helper/theme_helper.dart';
import 'package:gnml/UI/Desktop/Library/ui/card_view/actor_cards.dart';
import 'package:gnml/UI/Desktop/Library/ui/card_view/book_cards.dart';
import 'package:gnml/UI/Desktop/Library/ui/card_view/favorite_cards.dart';
import 'package:gnml/UI/Desktop/Library/ui/card_view/game_cards.dart';
import 'package:gnml/UI/Desktop/Library/ui/card_view/movie_cards.dart';
import 'package:gnml/UI/Desktop/Library/ui/card_view/serie_cards.dart';
import 'package:gnml/UI/Desktop/Library/ui/list_view/actor_lists.dart';
import 'package:gnml/UI/Desktop/Library/ui/list_view/book_lists.dart';
import 'package:gnml/UI/Desktop/Library/ui/list_view/game_lists.dart';
import 'package:gnml/UI/Desktop/Library/ui/list_view/movie_lists.dart';
import 'package:gnml/UI/Desktop/Library/ui/list_view/serie_lists.dart';
import 'package:gnml/Widgets/circularprogressindicator.dart';
import 'package:provider/provider.dart';

enum Views { listview, cardview }

enum Sort { atoz, ztoa, dateup, datedown }

class LibraryPage extends StatefulWidget {
  const LibraryPage({super.key});

  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
  }

  User? user = FirebaseAuth.instance.currentUser;
  Views buttonView = Views.cardview;
  Sort buttonSort = Sort.atoz;

  Future<DocumentSnapshot> getData() async {
    CollectionReference collectionReference =
        FirebaseFirestore.instance.collection('brews');

    DocumentReference documentReference =
        collectionReference.doc('${user!.email}');
    DocumentSnapshot documentSnapshot = await documentReference.get();
    return documentSnapshot;
  }

  Future<void> updateData(
      List games, List movies, List series, List books, List actors) async {
    CollectionReference collectionReference =
        FirebaseFirestore.instance.collection('brews');
    DocumentReference documentReference =
        collectionReference.doc('${user!.email}');

    Map<String, dynamic> updatedData = {
      "library": {
        "games": games,
        "movies": movies,
        "series": series,
        "books": books,
        "actors": actors,
      }
    };

    await documentReference.update(updatedData);
  }

  @override
  Widget build(BuildContext context) {
    int themeColor = Provider.of<ThemeProvider>(context).color;
    return NotificationListener<SizeChangedLayoutNotification>(
      onNotification: (notification) {
        build(context);
        return true;
      },
      child: Scaffold(
        body: FutureBuilder(
          future: getData(),
          builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
            int supportedLength = getSupportedLength(context);
            if (snapshot.hasData &&
                snapshot.connectionState == ConnectionState.done) {
              Map<String, dynamic> list =
                  snapshot.data!.data() as Map<String, dynamic>;

              List gamesList = list['library']['games'];
              List moviesList = list['library']['movies'];
              List seriesList = list['library']['series'];
              List booksList = list['library']['books'];
              List actorsList = list['library']['actors'];
              Map<String, dynamic>? favoritesList = list['favorites'];
              if (favoritesList == null) {
                FirebaseUserData(user: user).createFavoritesList();
              }
              List favoriteGamesList = favoritesList!['games'];

              // print(favoriteGamesList.runtimeType);
              // print(gamesList.runtimeType);

              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(bottom: 30.0),
                            child: Text(
                              "Library",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 50),
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              IconButton(
                                icon: const Icon(
                                    FluentIcons.arrow_clockwise_32_filled),
                                onPressed: () {
                                  setState(() {});
                                },
                              ),
                              setViewWidgets(),
                              sortingWidgets(),
                            ],
                          )
                        ],
                      ),
                      Builder(
                        builder: (context) {
                          if (buttonView == Views.cardview) {
                            if (buttonSort == Sort.atoz) {
                              favoriteGamesList.sort((a, b) =>
                                  a['gameName'].compareTo(b['gameName']));
                              // favoritesList['movies'].sort((a, b) =>
                              //     a['movieName'].compareTo(b['movieName']));
                              // favoritesList['series'].sort((a, b) =>
                              //     a['serieName'].compareTo(b['serieName']));
                              // favoritesList['books'].sort((a, b) =>
                              //     a['bookName'].compareTo(b['bookName']));
                              // favoritesList['actors'].sort((a, b) =>
                              //     a['actorName'].compareTo(b['actorName']));

                              gamesList.sort((a, b) =>
                                  a['gameName'].compareTo(b['gameName']));
                              moviesList.sort((a, b) =>
                                  a['movieName'].compareTo(b['movieName']));
                              seriesList.sort((a, b) =>
                                  a['serieName'].compareTo(b['serieName']));
                              booksList.sort((a, b) =>
                                  a['bookName'].compareTo(b['bookName']));
                              actorsList.sort((a, b) =>
                                  a['actorName'].compareTo(b['actorName']));
                            } else if (buttonSort == Sort.ztoa) {
                              gamesList.sort((a, b) =>
                                  a['gameName'].compareTo(b['gameName']));
                              moviesList.sort((a, b) =>
                                  a['movieName'].compareTo(b['movieName']));
                              seriesList.sort((a, b) =>
                                  a['serieName'].compareTo(b['serieName']));
                              booksList.sort((a, b) =>
                                  a['bookName'].compareTo(b['bookName']));
                              actorsList.sort((a, b) =>
                                  a['actorName'].compareTo(b['actorName']));

                              gamesList = gamesList.reversed.toList();
                              seriesList = seriesList.reversed.toList();
                              moviesList = moviesList.reversed.toList();
                              booksList = booksList.reversed.toList();
                              actorsList = actorsList.reversed.toList();
                            } else if (buttonSort == Sort.dateup) {
                              gamesList = gamesList.reversed.toList();
                              seriesList = seriesList.reversed.toList();
                              moviesList = moviesList.reversed.toList();
                              booksList = booksList.reversed.toList();
                              actorsList = actorsList.reversed.toList();
                            }

                            return cardView(
                              gamesList,
                              supportedLength,
                              context,
                              themeColor,
                              moviesList,
                              seriesList,
                              booksList,
                              actorsList,
                              favoritesList,
                            );
                          } else {
                            if (buttonSort == Sort.atoz) {
                              gamesList.sort((a, b) =>
                                  a['gameName'].compareTo(b['gameName']));
                              moviesList.sort((a, b) =>
                                  a['movieName'].compareTo(b['movieName']));
                              seriesList.sort((a, b) =>
                                  a['serieName'].compareTo(b['serieName']));
                              booksList.sort((a, b) =>
                                  a['bookName'].compareTo(b['bookName']));
                              actorsList.sort((a, b) =>
                                  a['actorName'].compareTo(b['actorName']));
                            } else if (buttonSort == Sort.ztoa) {
                              gamesList.sort((a, b) =>
                                  a['gameName'].compareTo(b['gameName']));

                              moviesList.sort((a, b) =>
                                  a['movieName'].compareTo(b['movieName']));
                              seriesList.sort((a, b) =>
                                  a['serieName'].compareTo(b['serieName']));
                              booksList.sort((a, b) =>
                                  a['bookName'].compareTo(b['bookName']));
                              actorsList.sort((a, b) =>
                                  a['actorName'].compareTo(b['actorName']));

                              gamesList = gamesList.reversed.toList();
                              seriesList = seriesList.reversed.toList();
                              moviesList = moviesList.reversed.toList();
                              booksList = booksList.reversed.toList();
                              actorsList = actorsList.reversed.toList();
                            } else if (buttonSort == Sort.datedown) {
                              gamesList = gamesList.reversed.toList();
                              seriesList = seriesList.reversed.toList();
                              moviesList = moviesList.reversed.toList();
                              booksList = booksList.reversed.toList();
                              actorsList = actorsList.reversed.toList();
                            }
                            return listView(gamesList, context, moviesList,
                                seriesList, booksList, actorsList);
                          }
                        },
                      )
                    ],
                  ),
                ),
              );
            } else {
              return const CustomCPI();
            }
          },
        ),
      ),
    );
  }

  Column listView(
      List<dynamic> gamesList,
      BuildContext context,
      List<dynamic> moviesList,
      List<dynamic> seriesList,
      List<dynamic> booksList,
      List<dynamic> actorsList) {
    return Column(
      children: [
        gameListsTile(gamesList, context),
        movieListsTile(moviesList, context),
        serieListsTile(seriesList, context),
        bookListsTile(booksList, context),
        actorListsTile(actorsList, context),
      ],
    );
  }

  Column cardView(
      List<dynamic> gamesList,
      int supportedLength,
      BuildContext context,
      int themeColor,
      List<dynamic> moviesList,
      List<dynamic> seriesList,
      List<dynamic> booksList,
      List<dynamic> actorsList,
      Map<String, dynamic>? favoritesList) {
    return Column(
      children: [
        favoriteCardsTile(
          user,
          favoritesList,
          supportedLength,
          context,
          themeColor,
        ),
        gameCardsTile(
          user,
          favoritesList!,
          gamesList,
          supportedLength,
          context,
          themeColor,
          moviesList,
          seriesList,
          booksList,
          actorsList,
        ),
        movieCardsTile(
          user,
          favoritesList,
          moviesList,
          supportedLength,
          context,
          themeColor,
          gamesList,
          seriesList,
          booksList,
          actorsList,
        ),
        serieCardsTile(
          user,
          favoritesList,
          seriesList,
          supportedLength,
          context,
          themeColor,
          gamesList,
          moviesList,
          booksList,
          actorsList,
        ),
        bookCardsTile(
          user,
          favoritesList,
          booksList,
          supportedLength,
          context,
          themeColor,
          gamesList,
          moviesList,
          seriesList,
          actorsList,
        ),
        actorCardsTile(
          user,
          favoritesList,
          actorsList,
          supportedLength,
          context,
          themeColor,
          gamesList,
          moviesList,
          seriesList,
          booksList,
        ),
      ],
    );
  }

  Padding sortingWidgets() {
    return Padding(
      padding: const EdgeInsets.only(top: 8, right: 8.0, bottom: 8),
      child: SegmentedButton<Sort>(
        showSelectedIcon: false,
        segments: [
          ButtonSegment<Sort>(
            value: Sort.atoz,
            icon: Tooltip(
              message: "A to Z",
              child: SvgPicture.asset("assets/images/atoz.svg"),
            ),
          ),
          ButtonSegment<Sort>(
              value: Sort.ztoa,
              icon: Tooltip(
                message: "Z to A",
                child: SvgPicture.asset("assets/images/ztoa.svg"),
              )),
          ButtonSegment<Sort>(
              value: Sort.dateup,
              icon: Tooltip(
                message: "Newest",
                child: SvgPicture.asset("assets/images/datedown.svg"),
              )),
          ButtonSegment<Sort>(
              value: Sort.datedown,
              icon: Tooltip(
                message: "Oldest",
                child: SvgPicture.asset("assets/images/dateup.svg"),
              )),
        ],
        selected: <Sort>{buttonSort},
        onSelectionChanged: (Set<Sort> newSelection) {
          setState(() {
            buttonSort = newSelection.first;
          });
        },
      ),
    );
  }

  Padding setViewWidgets() {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: SegmentedButton<Views>(
        showSelectedIcon: false,
        segments: const [
          ButtonSegment<Views>(
            value: Views.cardview,
            icon: Icon(FluentIcons.grid_24_filled),
          ),
          ButtonSegment<Views>(
            value: Views.listview,
            icon: Icon(FluentIcons.apps_list_24_filled),
          ),
        ],
        selected: <Views>{buttonView},
        onSelectionChanged: (Set<Views> newSelection) {
          setState(() {
            buttonView = newSelection.first;
          });
        },
      ),
    );
  }
}

int getSupportedLength(context) {
  int supportedLength = 4;
  int deviceWidth = MediaQuery.of(context).size.width.toInt();
  if (deviceWidth < 1024) {
    supportedLength = 4;
  } else if (deviceWidth >= 1024 && deviceWidth < 1128) {
    supportedLength = 5;
  } else if (deviceWidth >= 1128 && deviceWidth < 1366) {
    supportedLength = 6;
  } else if (deviceWidth > 1366 && deviceWidth < 1440) {
    supportedLength = 7;
  } else {
    supportedLength = 8;
  }
  return supportedLength;
}
