import 'dart:developer';

// import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:context_menus/context_menus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gnml/Helper/theme_helper.dart';
import 'package:gnml/UI/Details/actors_detail_page.dart';
import 'package:gnml/UI/Details/books_detail_page.dart';
import 'package:gnml/UI/Details/game_detail_page.dart';
import 'package:gnml/UI/Details/movie_detail_page.dart';
import 'package:gnml/UI/Details/serie_detail_page.dart';
import 'package:gnml/Widgets/circularprogressindicator.dart';
import 'package:provider/provider.dart';

enum Views { listview, cardview }

enum Sort { atoz, ztoa, dateup, datedown }

class LibraryPage extends StatefulWidget {
  const LibraryPage({super.key});

  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
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
                              Padding(
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
                                      icon:
                                          Icon(FluentIcons.apps_list_24_filled),
                                    ),
                                  ],
                                  selected: <Views>{buttonView},
                                  onSelectionChanged:
                                      (Set<Views> newSelection) {
                                    setState(() {
                                      buttonView = newSelection.first;
                                    });
                                  },
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                    top: 8, right: 8.0, bottom: 8),
                                child: SegmentedButton<Sort>(
                                  showSelectedIcon: false,
                                  segments: [
                                    ButtonSegment<Sort>(
                                      value: Sort.atoz,
                                      icon: Tooltip(
                                        message: "A to Z",
                                        child: SvgPicture.asset(
                                            "assets/images/atoz.svg"),
                                      ),
                                    ),
                                    ButtonSegment<Sort>(
                                        value: Sort.ztoa,
                                        icon: Tooltip(
                                          message: "Z to A",
                                          child: SvgPicture.asset(
                                              "assets/images/ztoa.svg"),
                                        )),
                                    ButtonSegment<Sort>(
                                        value: Sort.dateup,
                                        icon: Tooltip(
                                          message: "Newest",
                                          child: SvgPicture.asset(
                                              "assets/images/datedown.svg"),
                                        )),
                                    ButtonSegment<Sort>(
                                        value: Sort.datedown,
                                        icon: Tooltip(
                                          message: "Oldest",
                                          child: SvgPicture.asset(
                                              "assets/images/dateup.svg"),
                                        )),
                                  ],
                                  selected: <Sort>{buttonSort},
                                  onSelectionChanged: (Set<Sort> newSelection) {
                                    setState(() {
                                      buttonSort = newSelection.first;
                                    });
                                  },
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                      Builder(
                        builder: (context) {
                          if (buttonView == Views.cardview) {
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
                            } else if (buttonSort == Sort.dateup) {
                              gamesList = gamesList.reversed.toList();
                              seriesList = seriesList.reversed.toList();
                              moviesList = moviesList.reversed.toList();
                              booksList = booksList.reversed.toList();
                              actorsList = actorsList.reversed.toList();
                            }

                            return Column(
                              children: [
                                Card(
                                  // color: Colors.transparent,
                                  color: Colors.grey.withOpacity(0.2),
                                  child: Theme(
                                    data: ThemeData(
                                      highlightColor: Colors.transparent,
                                      hoverColor: Colors.transparent,
                                      splashColor: Colors.transparent,
                                    ),
                                    child: ExpansionTile(
                                      initiallyExpanded: true,
                                      textColor: Colors.white,
                                      collapsedTextColor: Colors.white,
                                      collapsedIconColor: Colors.white,
                                      iconColor: Colors.white,
                                      title: const Text(
                                        "Games",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontFamily: "RobotoBold",
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20,
                                        ),
                                      ),
                                      children: List.generate(
                                        (gamesList.length / supportedLength)
                                            .ceil(),
                                        (rowIndex) {
                                          return Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: List.generate(
                                              supportedLength,
                                              (colIndex) {
                                                final index =
                                                    rowIndex * supportedLength +
                                                        colIndex;
                                                if (index < gamesList.length) {
                                                  Map<String, dynamic> gameMap =
                                                      {
                                                    "gameID": gamesList[index]
                                                        ['gameID'],
                                                    "imageURL": gamesList[index]
                                                        ['imageURL'],
                                                    "gameName": gamesList[index]
                                                        ['gameName'],
                                                  };
                                                  ValueNotifier<bool>
                                                      isHovering =
                                                      ValueNotifier<bool>(
                                                          false);
                                                  ValueNotifier<bool>
                                                      isFavorite =
                                                      ValueNotifier<bool>(true);
                                                  return Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            4.0),
                                                    child: MouseRegion(
                                                      cursor: SystemMouseCursors
                                                          .click,
                                                      onEnter: (event) =>
                                                          isHovering.value =
                                                              true,
                                                      onExit: (event) =>
                                                          isHovering.value =
                                                              false,
                                                      child: GestureDetector(
                                                        onTap: () =>
                                                            Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                            builder: (context) =>
                                                                GameDetailPage(
                                                              gameID: gamesList[
                                                                      index]
                                                                  ['gameID'],
                                                            ),
                                                          ),
                                                        ),
                                                        child: GridTile(
                                                          child: Stack(
                                                            children: [
                                                              Card(
                                                                shape:
                                                                    const RoundedRectangleBorder(
                                                                  side:
                                                                      BorderSide(
                                                                    color: Colors
                                                                        .transparent,
                                                                  ),
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .all(
                                                                    Radius
                                                                        .circular(
                                                                            8),
                                                                  ),
                                                                ),
                                                                color: Colors
                                                                    .transparent,
                                                                child: Column(
                                                                  children: [
                                                                    SizedBox(
                                                                      height:
                                                                          225,
                                                                      width:
                                                                          150,
                                                                      child:
                                                                          ClipRRect(
                                                                        borderRadius: const BorderRadius
                                                                            .only(
                                                                            topLeft:
                                                                                Radius.circular(8),
                                                                            topRight: Radius.circular(8)),
                                                                        child:
                                                                            Image(
                                                                          fit: BoxFit
                                                                              .fill,
                                                                          image:
                                                                              NetworkImage("${gamesList[index]['imageURL'].substring(0, 42)}t_cover_big${gamesList[index]['imageURL'].substring(52)}"),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    SizedBox(
                                                                      width:
                                                                          150,
                                                                      child:
                                                                          Padding(
                                                                        padding: const EdgeInsets
                                                                            .all(
                                                                            8.0),
                                                                        child:
                                                                            Tooltip(
                                                                          message:
                                                                              gamesList[index]['gameName'],
                                                                          child:
                                                                              Text(
                                                                            gamesList[index]['gameName'],
                                                                            softWrap:
                                                                                true,
                                                                            overflow:
                                                                                TextOverflow.ellipsis,
                                                                            textAlign:
                                                                                TextAlign.center,
                                                                            style:
                                                                                const TextStyle(color: Colors.white),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                              ValueListenableBuilder(
                                                                valueListenable:
                                                                    isFavorite,
                                                                builder:
                                                                    (context,
                                                                        value,
                                                                        child) {
                                                                  return isFavorite
                                                                          .value
                                                                      ? const SizedBox()
                                                                      : Padding(
                                                                          padding: const EdgeInsets
                                                                              .all(
                                                                              4.0),
                                                                          child:
                                                                              Container(
                                                                            decoration:
                                                                                BoxDecoration(
                                                                              color: Colors.black.withOpacity(0.5),
                                                                              borderRadius: const BorderRadius.all(
                                                                                Radius.circular(8),
                                                                              ),
                                                                            ),
                                                                            height:
                                                                                260,
                                                                            width:
                                                                                150,
                                                                          ),
                                                                        );
                                                                },
                                                              ),
                                                              ValueListenableBuilder(
                                                                valueListenable:
                                                                    isHovering,
                                                                builder:
                                                                    (context,
                                                                        value,
                                                                        child) {
                                                                  return isHovering
                                                                          .value
                                                                      ? Positioned(
                                                                          top:
                                                                              5,
                                                                          right:
                                                                              5,
                                                                          child:
                                                                              Card(
                                                                            elevation:
                                                                                0,
                                                                            color: const Color.fromARGB(
                                                                                125,
                                                                                0,
                                                                                0,
                                                                                0),
                                                                            child: ValueListenableBuilder(
                                                                                valueListenable: isFavorite,
                                                                                builder: (context, value, child) {
                                                                                  return isFavorite.value
                                                                                      ? IconButton(
                                                                                          highlightColor: Color(themeColor),
                                                                                          hoverColor: Colors.transparent,
                                                                                          onPressed: () {
                                                                                            gamesList.removeWhere((element) => element['gameID'] == gamesList[index]['gameID']);
                                                                                            updateData(gamesList, moviesList, seriesList, booksList, actorsList);
                                                                                            isFavorite.value = !isFavorite.value;
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
                                                                                            gamesList.add(gameMap);
                                                                                            updateData(gamesList, moviesList, seriesList, booksList, actorsList);
                                                                                            isFavorite.value = !isFavorite.value;
                                                                                          },
                                                                                          icon: const Icon(
                                                                                            Icons.favorite_outline,
                                                                                            color: Colors.white,
                                                                                            // color: Color(themeColor),
                                                                                          ),
                                                                                        );
                                                                                }),
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
                                                } else {
                                                  return const Padding(
                                                    padding:
                                                        EdgeInsets.all(8.0),
                                                    child: GridTile(
                                                      child: Column(
                                                        children: [
                                                          SizedBox(
                                                            height: 225,
                                                            width: 150,
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                  );
                                                }
                                              },
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                Card(
                                  color: Colors.grey.withOpacity(0.2),
                                  child: Theme(
                                    data: ThemeData(
                                      highlightColor: Colors.transparent,
                                      hoverColor: Colors.transparent,
                                      splashColor: Colors.transparent,
                                    ),
                                    child: ExpansionTile(
                                      initiallyExpanded: true,
                                      textColor: Colors.white,
                                      collapsedTextColor: Colors.white,
                                      collapsedIconColor: Colors.white,
                                      iconColor: Colors.white,
                                      title: const Text(
                                        "Movies",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontFamily: "RobotoBold",
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20,
                                        ),
                                      ),
                                      children: List.generate(
                                        (moviesList.length / supportedLength)
                                            .ceil(),
                                        (rowIndex) {
                                          return Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: List.generate(
                                              supportedLength,
                                              (colIndex) {
                                                final index =
                                                    rowIndex * supportedLength +
                                                        colIndex;
                                                if (index < moviesList.length) {
                                                  Map<String, dynamic>
                                                      movieMap = {
                                                    "movieID": moviesList[index]
                                                        ['movieID'],
                                                    "imageURL":
                                                        moviesList[index]
                                                            ['imageURL'],
                                                    "movieName":
                                                        moviesList[index]
                                                            ['movieName'],
                                                  };
                                                  ValueNotifier<bool>
                                                      isHovering =
                                                      ValueNotifier<bool>(
                                                          false);
                                                  ValueNotifier<bool>
                                                      isFavorite =
                                                      ValueNotifier<bool>(true);
                                                  return Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: MouseRegion(
                                                      cursor: SystemMouseCursors
                                                          .click,
                                                      onEnter: (event) =>
                                                          isHovering.value =
                                                              true,
                                                      onExit: (event) =>
                                                          isHovering.value =
                                                              false,
                                                      child: GestureDetector(
                                                        onTap: () {
                                                          Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                              builder: (context) =>
                                                                  MovieDetailPage(
                                                                      movieID: moviesList[
                                                                              index]
                                                                          [
                                                                          'movieID']),
                                                            ),
                                                          );
                                                        },
                                                        child: Stack(
                                                          children: [
                                                            Card(
                                                              color: Colors
                                                                  .transparent,
                                                              shape:
                                                                  const RoundedRectangleBorder(
                                                                side:
                                                                    BorderSide(
                                                                  color: Colors
                                                                      .transparent,
                                                                ),
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .all(
                                                                  Radius
                                                                      .circular(
                                                                          8),
                                                                ),
                                                              ),
                                                              child: GridTile(
                                                                child: Column(
                                                                  children: [
                                                                    SizedBox(
                                                                      height:
                                                                          225,
                                                                      width:
                                                                          150,
                                                                      child:
                                                                          ClipRRect(
                                                                        borderRadius:
                                                                            const BorderRadius.only(
                                                                          topLeft:
                                                                              Radius.circular(8),
                                                                          topRight:
                                                                              Radius.circular(8),
                                                                        ),
                                                                        child:
                                                                            Image(
                                                                          fit: BoxFit
                                                                              .fill,
                                                                          image:
                                                                              NetworkImage(
                                                                            "${moviesList[index]['imageURL'].substring(0, 27)}w300${moviesList[index]['imageURL'].substring(35)}",
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    SizedBox(
                                                                      width:
                                                                          150,
                                                                      child:
                                                                          Padding(
                                                                        padding: const EdgeInsets
                                                                            .all(
                                                                            8.0),
                                                                        child:
                                                                            Tooltip(
                                                                          message:
                                                                              moviesList[index]['movieName'],
                                                                          child:
                                                                              Text(
                                                                            moviesList[index]['movieName'],
                                                                            softWrap:
                                                                                true,
                                                                            overflow:
                                                                                TextOverflow.ellipsis,
                                                                            textAlign:
                                                                                TextAlign.center,
                                                                            style:
                                                                                const TextStyle(color: Colors.white),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                            ValueListenableBuilder(
                                                              valueListenable:
                                                                  isFavorite,
                                                              builder: (context,
                                                                  value,
                                                                  child) {
                                                                return isFavorite
                                                                        .value
                                                                    ? const SizedBox()
                                                                    : Padding(
                                                                        padding: const EdgeInsets
                                                                            .all(
                                                                            4.0),
                                                                        child:
                                                                            Container(
                                                                          decoration:
                                                                              BoxDecoration(
                                                                            color:
                                                                                Colors.black.withOpacity(0.5),
                                                                            borderRadius:
                                                                                const BorderRadius.all(
                                                                              Radius.circular(8),
                                                                            ),
                                                                          ),
                                                                          height:
                                                                              260,
                                                                          width:
                                                                              150,
                                                                        ),
                                                                      );
                                                              },
                                                            ),
                                                            ValueListenableBuilder(
                                                              valueListenable:
                                                                  isHovering,
                                                              builder: (context,
                                                                  value,
                                                                  child) {
                                                                return isHovering
                                                                        .value
                                                                    ? Positioned(
                                                                        top: 5,
                                                                        right:
                                                                            5,
                                                                        child:
                                                                            Card(
                                                                          elevation:
                                                                              0,
                                                                          color: const Color
                                                                              .fromARGB(
                                                                              125,
                                                                              0,
                                                                              0,
                                                                              0),
                                                                          child: ValueListenableBuilder(
                                                                              valueListenable: isFavorite,
                                                                              builder: (context, value, child) {
                                                                                return isFavorite.value
                                                                                    ? IconButton(
                                                                                        highlightColor: Color(themeColor),
                                                                                        hoverColor: Colors.transparent,
                                                                                        onPressed: () {
                                                                                          moviesList.removeWhere((element) => element['movieID'] == moviesList[index]['movieID']);
                                                                                          updateData(gamesList, moviesList, seriesList, booksList, actorsList);
                                                                                          isFavorite.value = !isFavorite.value;
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
                                                                                          moviesList.add(movieMap);
                                                                                          updateData(gamesList, moviesList, seriesList, booksList, actorsList);
                                                                                          isFavorite.value = !isFavorite.value;
                                                                                        },
                                                                                        icon: const Icon(
                                                                                          Icons.favorite_outline,
                                                                                          color: Colors.white,
                                                                                          // color: Color(themeColor),
                                                                                        ),
                                                                                      );
                                                                              }),
                                                                        ),
                                                                      )
                                                                    : const SizedBox();
                                                              },
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                } else {
                                                  return const Padding(
                                                    padding:
                                                        EdgeInsets.all(8.0),
                                                    child: GridTile(
                                                      child: Column(
                                                        children: [
                                                          SizedBox(
                                                            height: 225,
                                                            width: 150,
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                  );
                                                }
                                              },
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                Card(
                                  color: Colors.grey.withOpacity(0.2),
                                  child: Theme(
                                    data: ThemeData(
                                      highlightColor: Colors.transparent,
                                      hoverColor: Colors.transparent,
                                      splashColor: Colors.transparent,
                                    ),
                                    child: ExpansionTile(
                                      initiallyExpanded: true,
                                      textColor: Colors.white,
                                      collapsedTextColor: Colors.white,
                                      collapsedIconColor: Colors.white,
                                      iconColor: Colors.white,
                                      title: const Text(
                                        "Series",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontFamily: "RobotoBold",
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20,
                                        ),
                                      ),
                                      children: List.generate(
                                        (seriesList.length / supportedLength)
                                            .ceil(),
                                        (rowIndex) {
                                          return Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: List.generate(
                                              supportedLength,
                                              (colIndex) {
                                                final index =
                                                    rowIndex * supportedLength +
                                                        colIndex;
                                                if (index < seriesList.length) {
                                                  Map<String, dynamic>
                                                      serieMap = {
                                                    "serieID": seriesList[index]
                                                        ['serieID'],
                                                    "imageURL":
                                                        seriesList[index]
                                                            ['imageURL'],
                                                    "serieName":
                                                        seriesList[index]
                                                            ['serieName'],
                                                  };
                                                  ValueNotifier<bool>
                                                      isHovering =
                                                      ValueNotifier<bool>(
                                                          false);
                                                  ValueNotifier<bool>
                                                      isFavorite =
                                                      ValueNotifier<bool>(true);
                                                  return Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: MouseRegion(
                                                      cursor: SystemMouseCursors
                                                          .click,
                                                      onEnter: (event) =>
                                                          isHovering.value =
                                                              true,
                                                      onExit: (event) =>
                                                          isHovering.value =
                                                              false,
                                                      child: GestureDetector(
                                                        onTap: () {
                                                          Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                              builder: (context) =>
                                                                  SerieDetailPage(
                                                                      serieID: seriesList[
                                                                              index]
                                                                          [
                                                                          'serieID']),
                                                            ),
                                                          );
                                                        },
                                                        child: Stack(
                                                          children: [
                                                            Card(
                                                              color: Colors
                                                                  .transparent,
                                                              shape:
                                                                  const RoundedRectangleBorder(
                                                                side:
                                                                    BorderSide(
                                                                  color: Colors
                                                                      .transparent,
                                                                ),
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .all(
                                                                  Radius
                                                                      .circular(
                                                                          8),
                                                                ),
                                                              ),
                                                              child: GridTile(
                                                                child: Column(
                                                                  children: [
                                                                    SizedBox(
                                                                      height:
                                                                          225,
                                                                      width:
                                                                          150,
                                                                      child:
                                                                          ClipRRect(
                                                                        borderRadius:
                                                                            const BorderRadius.only(
                                                                          topLeft:
                                                                              Radius.circular(8),
                                                                          topRight:
                                                                              Radius.circular(8),
                                                                        ),
                                                                        child:
                                                                            Image(
                                                                          fit: BoxFit
                                                                              .fill,
                                                                          image:
                                                                              NetworkImage(
                                                                            "${seriesList[index]['imageURL'].substring(0, 27)}w300${seriesList[index]['imageURL'].substring(35)}",
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    SizedBox(
                                                                      width:
                                                                          150,
                                                                      child:
                                                                          Padding(
                                                                        padding: const EdgeInsets
                                                                            .all(
                                                                            8.0),
                                                                        child:
                                                                            Tooltip(
                                                                          message:
                                                                              seriesList[index]['serieName'],
                                                                          child:
                                                                              Text(
                                                                            seriesList[index]['serieName'],
                                                                            softWrap:
                                                                                true,
                                                                            overflow:
                                                                                TextOverflow.ellipsis,
                                                                            textAlign:
                                                                                TextAlign.center,
                                                                            style:
                                                                                const TextStyle(color: Colors.white),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                            ValueListenableBuilder(
                                                              valueListenable:
                                                                  isFavorite,
                                                              builder: (context,
                                                                  value,
                                                                  child) {
                                                                return isFavorite
                                                                        .value
                                                                    ? const SizedBox()
                                                                    : Padding(
                                                                        padding: const EdgeInsets
                                                                            .all(
                                                                            4.0),
                                                                        child:
                                                                            Container(
                                                                          decoration:
                                                                              BoxDecoration(
                                                                            color:
                                                                                Colors.black.withOpacity(0.5),
                                                                            borderRadius:
                                                                                const BorderRadius.all(
                                                                              Radius.circular(8),
                                                                            ),
                                                                          ),
                                                                          height:
                                                                              260,
                                                                          width:
                                                                              150,
                                                                        ),
                                                                      );
                                                              },
                                                            ),
                                                            ValueListenableBuilder(
                                                              valueListenable:
                                                                  isHovering,
                                                              builder: (context,
                                                                  value,
                                                                  child) {
                                                                return isHovering
                                                                        .value
                                                                    ? Positioned(
                                                                        top: 5,
                                                                        right:
                                                                            5,
                                                                        child:
                                                                            Card(
                                                                          elevation:
                                                                              0,
                                                                          color: const Color
                                                                              .fromARGB(
                                                                              125,
                                                                              0,
                                                                              0,
                                                                              0),
                                                                          child: ValueListenableBuilder(
                                                                              valueListenable: isFavorite,
                                                                              builder: (context, value, child) {
                                                                                return isFavorite.value
                                                                                    ? IconButton(
                                                                                        highlightColor: Color(themeColor),
                                                                                        hoverColor: Colors.transparent,
                                                                                        onPressed: () {
                                                                                          seriesList.removeWhere((element) => element['serieID'] == seriesList[index]['serieID']);
                                                                                          updateData(gamesList, moviesList, seriesList, booksList, actorsList);
                                                                                          isFavorite.value = !isFavorite.value;
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
                                                                                          seriesList.add(serieMap);
                                                                                          updateData(gamesList, moviesList, seriesList, booksList, actorsList);
                                                                                          isFavorite.value = !isFavorite.value;
                                                                                        },
                                                                                        icon: const Icon(
                                                                                          Icons.favorite_outline,
                                                                                          color: Colors.white,
                                                                                          // color: Color(themeColor),
                                                                                        ),
                                                                                      );
                                                                              }),
                                                                        ),
                                                                      )
                                                                    : const SizedBox();
                                                              },
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                } else {
                                                  return const Padding(
                                                    padding:
                                                        EdgeInsets.all(8.0),
                                                    child: GridTile(
                                                      child: Column(
                                                        children: [
                                                          SizedBox(
                                                            height: 225,
                                                            width: 150,
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                  );
                                                }
                                              },
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                Card(
                                  color: Colors.grey.withOpacity(0.2),
                                  child: Theme(
                                    data: ThemeData(
                                      highlightColor: Colors.transparent,
                                      hoverColor: Colors.transparent,
                                      splashColor: Colors.transparent,
                                    ),
                                    child: ExpansionTile(
                                      initiallyExpanded: true,
                                      textColor: Colors.white,
                                      collapsedTextColor: Colors.white,
                                      collapsedIconColor: Colors.white,
                                      iconColor: Colors.white,
                                      title: const Text(
                                        "Books",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontFamily: "RobotoBold",
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20,
                                        ),
                                      ),
                                      children: List.generate(
                                        (booksList.length / supportedLength)
                                            .ceil(),
                                        (rowIndex) {
                                          return Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: List.generate(
                                              supportedLength,
                                              (colIndex) {
                                                final index =
                                                    rowIndex * supportedLength +
                                                        colIndex;

                                                if (index < booksList.length) {
                                                  Map<String, dynamic> bookMap =
                                                      {
                                                    "bookID": booksList[index]
                                                        ['bookID'],
                                                    "imageURL": booksList[index]
                                                        ['imageURL'],
                                                    "bookName": booksList[index]
                                                        ['bookName'],
                                                  };
                                                  ValueNotifier<bool>
                                                      isHovering =
                                                      ValueNotifier<bool>(
                                                          false);
                                                  ValueNotifier<bool>
                                                      isFavorite =
                                                      ValueNotifier<bool>(true);
                                                  return Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: MouseRegion(
                                                      cursor: SystemMouseCursors
                                                          .click,
                                                      onEnter: (event) =>
                                                          isHovering.value =
                                                              true,
                                                      onExit: (event) =>
                                                          isHovering.value =
                                                              false,
                                                      child: GestureDetector(
                                                        onTap: () {
                                                          Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                              builder: (context) =>
                                                                  BooksDetailPage(
                                                                bookID: booksList[
                                                                        index]
                                                                    ['bookID'],
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                        child: Stack(
                                                          children: [
                                                            Card(
                                                              color: Colors
                                                                  .transparent,
                                                              shape:
                                                                  const RoundedRectangleBorder(
                                                                side:
                                                                    BorderSide(
                                                                  color: Colors
                                                                      .transparent,
                                                                ),
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .all(
                                                                  Radius
                                                                      .circular(
                                                                          8),
                                                                ),
                                                              ),
                                                              child: GridTile(
                                                                child: Column(
                                                                  children: [
                                                                    SizedBox(
                                                                      height:
                                                                          225,
                                                                      width:
                                                                          150,
                                                                      child:
                                                                          ClipRRect(
                                                                        borderRadius:
                                                                            const BorderRadius.only(
                                                                          topLeft:
                                                                              Radius.circular(8),
                                                                          topRight:
                                                                              Radius.circular(8),
                                                                        ),
                                                                        child:
                                                                            Image(
                                                                          fit: BoxFit
                                                                              .fill,
                                                                          image:
                                                                              NetworkImage(
                                                                            booksList[index]['imageURL'].toString(),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    SizedBox(
                                                                      width:
                                                                          150,
                                                                      child:
                                                                          Padding(
                                                                        padding: const EdgeInsets
                                                                            .all(
                                                                            8.0),
                                                                        child:
                                                                            Tooltip(
                                                                          message:
                                                                              booksList[index]['bookName'],
                                                                          child:
                                                                              Text(
                                                                            booksList[index]['bookName'],
                                                                            softWrap:
                                                                                true,
                                                                            overflow:
                                                                                TextOverflow.ellipsis,
                                                                            textAlign:
                                                                                TextAlign.center,
                                                                            style:
                                                                                const TextStyle(color: Colors.white),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                            ValueListenableBuilder(
                                                              valueListenable:
                                                                  isFavorite,
                                                              builder: (context,
                                                                  value,
                                                                  child) {
                                                                return isFavorite
                                                                        .value
                                                                    ? const SizedBox()
                                                                    : Padding(
                                                                        padding: const EdgeInsets
                                                                            .all(
                                                                            4.0),
                                                                        child:
                                                                            Container(
                                                                          decoration:
                                                                              BoxDecoration(
                                                                            color:
                                                                                Colors.black.withOpacity(0.5),
                                                                            borderRadius:
                                                                                const BorderRadius.all(
                                                                              Radius.circular(8),
                                                                            ),
                                                                          ),
                                                                          height:
                                                                              260,
                                                                          width:
                                                                              150,
                                                                        ),
                                                                      );
                                                              },
                                                            ),
                                                            ValueListenableBuilder(
                                                              valueListenable:
                                                                  isHovering,
                                                              builder: (context,
                                                                  value,
                                                                  child) {
                                                                return isHovering
                                                                        .value
                                                                    ? Positioned(
                                                                        top: 5,
                                                                        right:
                                                                            5,
                                                                        child:
                                                                            Card(
                                                                          elevation:
                                                                              0,
                                                                          color: const Color
                                                                              .fromARGB(
                                                                              125,
                                                                              0,
                                                                              0,
                                                                              0),
                                                                          child: ValueListenableBuilder(
                                                                              valueListenable: isFavorite,
                                                                              builder: (context, value, child) {
                                                                                return isFavorite.value
                                                                                    ? IconButton(
                                                                                        highlightColor: Color(themeColor),
                                                                                        hoverColor: Colors.transparent,
                                                                                        onPressed: () {
                                                                                          booksList.removeWhere((element) => element['bookID'] == booksList[index]['bookID']);
                                                                                          updateData(gamesList, moviesList, seriesList, booksList, actorsList);
                                                                                          isFavorite.value = !isFavorite.value;
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
                                                                                          booksList.add(bookMap);
                                                                                          updateData(gamesList, moviesList, seriesList, booksList, actorsList);
                                                                                          isFavorite.value = !isFavorite.value;
                                                                                        },
                                                                                        icon: const Icon(
                                                                                          Icons.favorite_outline,
                                                                                          color: Colors.white,
                                                                                          // color: Color(themeColor),
                                                                                        ),
                                                                                      );
                                                                              }),
                                                                        ),
                                                                      )
                                                                    : const SizedBox();
                                                              },
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                } else {
                                                  return const Padding(
                                                    padding:
                                                        EdgeInsets.all(8.0),
                                                    child: GridTile(
                                                      child: Column(
                                                        children: [
                                                          SizedBox(
                                                            height: 225,
                                                            width: 150,
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                  );
                                                }
                                              },
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                Card(
                                  color: Colors.grey.withOpacity(0.2),
                                  child: Theme(
                                    data: ThemeData(
                                      highlightColor: Colors.transparent,
                                      hoverColor: Colors.transparent,
                                      splashColor: Colors.transparent,
                                    ),
                                    child: ExpansionTile(
                                      initiallyExpanded: true,
                                      textColor: Colors.white,
                                      collapsedTextColor: Colors.white,
                                      collapsedIconColor: Colors.white,
                                      iconColor: Colors.white,
                                      title: const Text(
                                        "Actors",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontFamily: "RobotoBold",
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20,
                                        ),
                                      ),
                                      children: List.generate(
                                        (actorsList.length / supportedLength)
                                            .ceil(),
                                        (rowIndex) {
                                          return Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: List.generate(
                                              supportedLength,
                                              (colIndex) {
                                                final index =
                                                    rowIndex * supportedLength +
                                                        colIndex;
                                                if (index < actorsList.length) {
                                                  Map<String, dynamic>
                                                      actorMap = {
                                                    "actorID": actorsList[index]
                                                        ['actorID'],
                                                    "imageURL":
                                                        actorsList[index]
                                                            ['imageURL'],
                                                    "actorName":
                                                        actorsList[index]
                                                            ['actorName'],
                                                  };
                                                  ValueNotifier<bool>
                                                      isHovering =
                                                      ValueNotifier<bool>(
                                                          false);
                                                  ValueNotifier<bool>
                                                      isFavorite =
                                                      ValueNotifier<bool>(true);
                                                  return Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: MouseRegion(
                                                      cursor: SystemMouseCursors
                                                          .click,
                                                      onEnter: (event) =>
                                                          isHovering.value =
                                                              true,
                                                      onExit: (event) =>
                                                          isHovering.value =
                                                              false,
                                                      child: GestureDetector(
                                                        onTap: () {
                                                          Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                              builder: (context) =>
                                                                  ActorDetailPage(
                                                                actorID: actorsList[
                                                                        index]
                                                                    ['actorID'],
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                        child: Stack(
                                                          children: [
                                                            Card(
                                                              color: Colors
                                                                  .transparent,
                                                              shape:
                                                                  const RoundedRectangleBorder(
                                                                side:
                                                                    BorderSide(
                                                                  color: Colors
                                                                      .transparent,
                                                                ),
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .all(
                                                                  Radius
                                                                      .circular(
                                                                          8),
                                                                ),
                                                              ),
                                                              child: GridTile(
                                                                child: Column(
                                                                  children: [
                                                                    SizedBox(
                                                                      height:
                                                                          225,
                                                                      width:
                                                                          150,
                                                                      child:
                                                                          ClipRRect(
                                                                        borderRadius:
                                                                            const BorderRadius.only(
                                                                          topLeft:
                                                                              Radius.circular(8),
                                                                          topRight:
                                                                              Radius.circular(8),
                                                                        ),
                                                                        child:
                                                                            Image(
                                                                          fit: BoxFit
                                                                              .fill,
                                                                          image:
                                                                              NetworkImage(
                                                                            "${actorsList[index]['imageURL'].substring(0, 27)}w300${actorsList[index]['imageURL'].substring(35)}",
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    SizedBox(
                                                                      width:
                                                                          150,
                                                                      child:
                                                                          Padding(
                                                                        padding: const EdgeInsets
                                                                            .all(
                                                                            8.0),
                                                                        child:
                                                                            Tooltip(
                                                                          message:
                                                                              actorsList[index]['actorName'],
                                                                          child:
                                                                              Text(
                                                                            actorsList[index]['actorName'],
                                                                            softWrap:
                                                                                true,
                                                                            overflow:
                                                                                TextOverflow.ellipsis,
                                                                            textAlign:
                                                                                TextAlign.center,
                                                                            style:
                                                                                const TextStyle(color: Colors.white),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                            ValueListenableBuilder(
                                                              valueListenable:
                                                                  isFavorite,
                                                              builder: (context,
                                                                  value,
                                                                  child) {
                                                                return isFavorite
                                                                        .value
                                                                    ? const SizedBox()
                                                                    : Padding(
                                                                        padding: const EdgeInsets
                                                                            .all(
                                                                            4.0),
                                                                        child:
                                                                            Container(
                                                                          decoration:
                                                                              BoxDecoration(
                                                                            color:
                                                                                Colors.black.withOpacity(0.5),
                                                                            borderRadius:
                                                                                const BorderRadius.all(
                                                                              Radius.circular(8),
                                                                            ),
                                                                          ),
                                                                          height:
                                                                              260,
                                                                          width:
                                                                              150,
                                                                        ),
                                                                      );
                                                              },
                                                            ),
                                                            ValueListenableBuilder(
                                                              valueListenable:
                                                                  isHovering,
                                                              builder: (context,
                                                                  value,
                                                                  child) {
                                                                return isHovering
                                                                        .value
                                                                    ? Positioned(
                                                                        top: 5,
                                                                        right:
                                                                            5,
                                                                        child:
                                                                            Card(
                                                                          elevation:
                                                                              0,
                                                                          color: const Color
                                                                              .fromARGB(
                                                                              125,
                                                                              0,
                                                                              0,
                                                                              0),
                                                                          child: ValueListenableBuilder(
                                                                              valueListenable: isFavorite,
                                                                              builder: (context, value, child) {
                                                                                return isFavorite.value
                                                                                    ? IconButton(
                                                                                        highlightColor: Color(themeColor),
                                                                                        hoverColor: Colors.transparent,
                                                                                        onPressed: () {
                                                                                          actorsList.removeWhere((element) => element['actorID'] == actorsList[index]['actorID']);
                                                                                          updateData(gamesList, moviesList, seriesList, booksList, actorsList);
                                                                                          isFavorite.value = !isFavorite.value;
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
                                                                                          actorsList.add(actorMap);
                                                                                          updateData(gamesList, moviesList, seriesList, booksList, actorsList);
                                                                                          isFavorite.value = !isFavorite.value;
                                                                                        },
                                                                                        icon: const Icon(
                                                                                          Icons.favorite_outline,
                                                                                          color: Colors.white,
                                                                                          // color: Color(themeColor),
                                                                                        ),
                                                                                      );
                                                                              }),
                                                                        ),
                                                                      )
                                                                    : const SizedBox();
                                                              },
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                } else {
                                                  return const Padding(
                                                    padding:
                                                        EdgeInsets.all(8.0),
                                                    child: GridTile(
                                                      child: Column(
                                                        children: [
                                                          SizedBox(
                                                            height: 225,
                                                            width: 150,
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                  );
                                                }
                                              },
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                              ],
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
                            return Column(
                              children: [
                                Card(
                                  color: Colors.grey.withOpacity(0.2),
                                  child: Theme(
                                    data: ThemeData(
                                      highlightColor: Colors.transparent,
                                      hoverColor: Colors.transparent,
                                      splashColor: Colors.transparent,
                                    ),
                                    child: ExpansionTile(
                                      initiallyExpanded: true,
                                      textColor: Colors.white,
                                      collapsedTextColor: Colors.white,
                                      collapsedIconColor: Colors.white,
                                      iconColor: Colors.white,
                                      title: const Text(
                                        "Games",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontFamily: "RobotoBold",
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20,
                                        ),
                                      ),
                                      children: getGames(gamesList, context),
                                    ),
                                  ),
                                ),
                                Card(
                                  color: Colors.grey.withOpacity(0.2),
                                  child: Theme(
                                    data: ThemeData(
                                      highlightColor: Colors.transparent,
                                      hoverColor: Colors.transparent,
                                      splashColor: Colors.transparent,
                                    ),
                                    child: ExpansionTile(
                                      initiallyExpanded: true,
                                      textColor: Colors.white,
                                      collapsedTextColor: Colors.white,
                                      collapsedIconColor: Colors.white,
                                      iconColor: Colors.white,
                                      title: const Text(
                                        "Movies",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontFamily: "RobotoBold",
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20,
                                        ),
                                      ),
                                      children: getMovies(moviesList, context),
                                    ),
                                  ),
                                ),
                                Card(
                                  color: Colors.grey.withOpacity(0.2),
                                  child: Theme(
                                    data: ThemeData(
                                      highlightColor: Colors.transparent,
                                      hoverColor: Colors.transparent,
                                      splashColor: Colors.transparent,
                                    ),
                                    child: ExpansionTile(
                                      initiallyExpanded: true,
                                      textColor: Colors.white,
                                      collapsedTextColor: Colors.white,
                                      collapsedIconColor: Colors.white,
                                      iconColor: Colors.white,
                                      title: const Text(
                                        "Series",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontFamily: "RobotoBold",
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20,
                                        ),
                                      ),
                                      children: getSeries(seriesList, context),
                                    ),
                                  ),
                                ),
                                Card(
                                  color: Colors.grey.withOpacity(0.2),
                                  child: Theme(
                                    data: ThemeData(
                                      highlightColor: Colors.transparent,
                                      hoverColor: Colors.transparent,
                                      splashColor: Colors.transparent,
                                    ),
                                    child: ExpansionTile(
                                      initiallyExpanded: true,
                                      textColor: Colors.white,
                                      collapsedTextColor: Colors.white,
                                      collapsedIconColor: Colors.white,
                                      iconColor: Colors.white,
                                      title: const Text(
                                        "Books",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontFamily: "RobotoBold",
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20,
                                        ),
                                      ),
                                      children: getBooks(booksList, context),
                                    ),
                                  ),
                                ),
                                Card(
                                  color: Colors.grey.withOpacity(0.2),
                                  child: Theme(
                                    data: ThemeData(
                                      highlightColor: Colors.transparent,
                                      hoverColor: Colors.transparent,
                                      splashColor: Colors.transparent,
                                    ),
                                    child: ExpansionTile(
                                      initiallyExpanded: true,
                                      textColor: Colors.white,
                                      collapsedTextColor: Colors.white,
                                      collapsedIconColor: Colors.white,
                                      iconColor: Colors.white,
                                      title: const Text(
                                        "Actors",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontFamily: "RobotoBold",
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20,
                                        ),
                                      ),
                                      children: getActors(actorsList, context),
                                    ),
                                  ),
                                ),
                              ],
                            );
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
}

List<Widget> getGames(gamesList, context) {
  List<Widget> gamesWidgetList = [];
  if (gamesList.isEmpty) {
    gamesWidgetList.add(
      const Padding(
        padding: EdgeInsets.all(8.0),
        child: Text("Nothing here"),
      ),
    );
  }
  for (var x in gamesList) {
    String url = x['imageURL'];
    String modifiedURL = "${url.substring(0, 42)}t_micro${url.substring(52)}";
    gamesWidgetList.add(
      GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => GameDetailPage(gameID: x['gameID']),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: ListTile(
              title: Text(
                x['gameName'],
                style: const TextStyle(
                    color: Colors.white,
                    fontFamily: "RobotoBold",
                    fontWeight: FontWeight.w100),
              ),
              leading: Image(
                width: 25,
                fit: BoxFit.fill,
                image: CachedNetworkImageProvider(
                  modifiedURL,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  return gamesWidgetList;
}

List<Widget> getMovies(moviesList, context) {
  List<Widget> moviesWidgetList = [];
  if (moviesList.isEmpty) {
    moviesWidgetList.add(
      const Padding(
        padding: EdgeInsets.all(8.0),
        child: Text("Nothing here"),
      ),
    );
  }
  for (var x in moviesList) {
    String url = x['imageURL'];
    String modifiedURL = "${url.substring(0, 27)}w45${url.substring(35)}";
    moviesWidgetList.add(
      MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MovieDetailPage(movieID: x['movieID']),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: ListTile(
              title: Text(
                x['movieName'],
                style: const TextStyle(
                    color: Colors.white,
                    fontFamily: "RobotoBold",
                    fontWeight: FontWeight.w100),
              ),
              leading: Image(
                width: 25,
                fit: BoxFit.fill,
                image: CachedNetworkImageProvider(
                  modifiedURL,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  return moviesWidgetList;
}

List<Widget> getSeries(seriesList, context) {
  List<Widget> seriesWidgetList = [];
  if (seriesList.isEmpty) {
    seriesWidgetList.add(
      const Padding(
        padding: EdgeInsets.all(8.0),
        child: Text("Nothing here"),
      ),
    );
  }
  for (var x in seriesList) {
    String url = x['imageURL'];
    String modifiedURL = "${url.substring(0, 27)}w45${url.substring(35)}";
    seriesWidgetList.add(
      MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SerieDetailPage(serieID: x['serieID']),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: ListTile(
              title: Text(
                x['serieName'],
                style: const TextStyle(
                    color: Colors.white,
                    fontFamily: "RobotoBold",
                    fontWeight: FontWeight.w100),
              ),
              leading: Image(
                width: 25,
                fit: BoxFit.fill,
                image: CachedNetworkImageProvider(
                  modifiedURL,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  return seriesWidgetList;
}

List<Widget> getBooks(booksList, context) {
  List<Widget> booksWidgetList = [];
  if (booksList.isEmpty) {
    booksWidgetList.add(
      const Padding(
        padding: EdgeInsets.all(8.0),
        child: Text("Nothing here"),
      ),
    );
  }
  for (var x in booksList) {
    String url = x['imageURL'];
    booksWidgetList.add(
      MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BooksDetailPage(bookID: x['bookID']),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: ListTile(
              title: Text(
                x['bookName'],
                style: const TextStyle(
                    color: Colors.white,
                    fontFamily: "RobotoBold",
                    fontWeight: FontWeight.w100),
              ),
              leading: Image(
                width: 25,
                fit: BoxFit.fill,
                image: CachedNetworkImageProvider(
                  url,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  return booksWidgetList;
}

List<Widget> getActors(actorsList, context) {
  List<Widget> actorsWidgetList = [];
  if (actorsList.isEmpty) {
    actorsWidgetList.add(
      const Padding(
        padding: EdgeInsets.all(8.0),
        child: Text("Nothing here"),
      ),
    );
  }

  for (var x in actorsList) {
    String url = x['imageURL'];
    String modifiedURL = "${url.substring(0, 27)}w45${url.substring(35)}";
    actorsWidgetList.add(
      MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ActorDetailPage(actorID: x['actorID']),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: ListTile(
              title: Text(
                x['actorName'],
                style: const TextStyle(
                    color: Colors.white,
                    fontFamily: "RobotoBold",
                    fontWeight: FontWeight.w100),
              ),
              leading: Image(
                width: 25,
                fit: BoxFit.fill,
                image: CachedNetworkImageProvider(
                  modifiedURL,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  return actorsWidgetList;
}

int getSupportedLength(context) {
  int supportedLength = 4;
  int deviceWidth = MediaQuery.of(context).size.width.toInt();
  // print(deviceWidth);
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
