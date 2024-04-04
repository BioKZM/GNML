import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gnml/Data/Model/game_model.dart';
import 'package:gnml/Helper/theme_helper.dart';
import 'package:gnml/Logic/gamepage_logic.dart';
import 'package:gnml/UI/Details/game_detail_page.dart';
import 'package:gnml/Widgets/circularprogressindicator.dart';
import 'package:gnml/Widgets/shimmer.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class GamesPage extends StatefulWidget {
  const GamesPage({Key? key}) : super(key: key);

  @override
  State<GamesPage> createState() => _GamesPageState();
}

class _GamesPageState extends State<GamesPage> {
  User? user = FirebaseAuth.instance.currentUser;
  bool boolean = false;
  late PageController _pageController;
  late PageController pageControllerNewlyReleased;
  late PageController pageControllerComingSoon;
  late PageController pageControllerMostlyAnticipated;
  int pageIndexNewlyReleased = 1;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      initialPage: 0,
    );
    pageControllerNewlyReleased = PageController(
      initialPage: 0,
    );
    pageControllerComingSoon = PageController(
      initialPage: 0,
    );
    pageControllerMostlyAnticipated = PageController(
      initialPage: 0,
    );
  }

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
    return Scaffold(
      body: FutureBuilder(
          future: getData(),
          builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              Map<String, dynamic> list =
                  snapshot.data!.data() as Map<String, dynamic>;
              List gamesList = list['library']['games'];
              List moviesList = list['library']['movies'];
              List seriesList = list['library']['series'];
              List booksList = list['library']['books'];
              List actorsList = list['library']['actors'];

              return SingleChildScrollView(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          onPressed: () {
                            setState(() {});
                          },
                          icon: const Icon(Icons.refresh),
                        ),
                      ],
                    ),
                    Card(
                      color:
                          const Color.fromARGB(255, 0, 116, 0).withOpacity(0.5),
                      elevation: 5,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(left: 8),
                              child: Card(
                                elevation: 0,
                                child: Padding(
                                  padding: EdgeInsets.only(
                                      left: 16, top: 4, right: 16, bottom: 4),
                                  child: Text("Popular Games",
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold)),
                                ),
                              ),
                            ),
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.arrow_left,
                                  ),
                                  onPressed: () {
                                    _pageController.previousPage(
                                      duration:
                                          const Duration(milliseconds: 500),
                                      curve: Curves.ease,
                                    );
                                  },
                                ),
                                StatefulBuilder(builder: (context, setState) {
                                  return Expanded(
                                    child: SizedBox(
                                      height: 200,
                                      width: double.infinity,
                                      child: FutureBuilder<List<GameModel>>(
                                        future:
                                            GamePageLogic().getPopularGameList(
                                          "popularRightNow",
                                        ),
                                        builder: (context, snapshot) {
                                          if (snapshot.hasData &&
                                              snapshot.connectionState ==
                                                  ConnectionState.done) {
                                            var data = snapshot.data;
                                            return ListView.builder(
                                              controller: _pageController,
                                              scrollDirection: Axis.horizontal,
                                              itemCount: data?.length,
                                              itemBuilder: (context, index) {
                                                ValueNotifier<bool> isHovering =
                                                    ValueNotifier<bool>(false);
                                                ValueNotifier<bool> isFavorite =
                                                    ValueNotifier<bool>(false);
                                                String? imageId;
                                                if (data![index].image_id ==
                                                    "0") {
                                                  imageId = "null";
                                                } else {
                                                  imageId =
                                                      data[index].image_id;
                                                }
                                                var gameID = 0;
                                                if (data[index].id != null) {
                                                  gameID = data[index].id!;
                                                }
                                                return SizedBox(
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            5.3),
                                                    child: MouseRegion(
                                                      onEnter: (event) =>
                                                          isHovering.value =
                                                              true,
                                                      onExit: (event) =>
                                                          isHovering.value =
                                                              false,
                                                      cursor: SystemMouseCursors
                                                          .click,
                                                      child: GestureDetector(
                                                        onTap: () {
                                                          Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                              builder: (context) =>
                                                                  GameDetailPage(
                                                                      gameID:
                                                                          gameID),
                                                            ),
                                                          );
                                                        },
                                                        child: Stack(
                                                          children: [
                                                            Card(
                                                              elevation: 0,
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
                                                                          12),
                                                                ),
                                                              ),
                                                              child: Column(
                                                                children: [
                                                                  SizedBox(
                                                                    height: 140,
                                                                    width: 110,
                                                                    child:
                                                                        ClipRRect(
                                                                      borderRadius:
                                                                          const BorderRadius
                                                                              .only(
                                                                        topLeft:
                                                                            Radius.circular(12),
                                                                        topRight:
                                                                            Radius.circular(12),
                                                                      ),
                                                                      child:
                                                                          Image(
                                                                        fit: BoxFit
                                                                            .fill,
                                                                        image:
                                                                            CachedNetworkImageProvider(
                                                                          "https://images.igdb.com/igdb/image/upload/t_cover_big/$imageId.png"
                                                                              .toString(),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  Tooltip(
                                                                    message: data[
                                                                            index]
                                                                        .name,
                                                                    child:
                                                                        SizedBox(
                                                                      width:
                                                                          100,
                                                                      child:
                                                                          Padding(
                                                                        padding: const EdgeInsets
                                                                            .all(
                                                                            8.0),
                                                                        child:
                                                                            Text(
                                                                          data[index]
                                                                              .name
                                                                              .toString(),
                                                                          softWrap:
                                                                              true,
                                                                          overflow:
                                                                              TextOverflow.ellipsis,
                                                                          textAlign:
                                                                              TextAlign.center,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
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
                                                                                Map<String, dynamic> gameMap = {
                                                                                  "gameID": data[index].id,
                                                                                  "imageURL": "https://images.igdb.com/igdb/image/upload/t_original/$imageId.png",
                                                                                  "gameName": data[index].name,
                                                                                };
                                                                                for (var x in gamesList) {
                                                                                  if (x['gameID'] == data[index].id) {
                                                                                    isFavorite.value = true;
                                                                                  }
                                                                                }
                                                                                return isFavorite.value
                                                                                    ? IconButton(
                                                                                        highlightColor: Color(themeColor),
                                                                                        hoverColor: Colors.transparent,
                                                                                        onPressed: () {
                                                                                          gamesList.removeWhere((element) => element['gameID'] == data[index].id);
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
                                              },
                                            );
                                          } else {
                                            bool connectionBool = true;
                                            if (snapshot.connectionState ==
                                                ConnectionState.done) {
                                              connectionBool = false;
                                            }
                                            return Center(
                                                child: connectionBool
                                                    ? const CustomCPI()
                                                    : Card(
                                                        child: Column(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          children: [
                                                            const Padding(
                                                              padding:
                                                                  EdgeInsets
                                                                      .all(8.0),
                                                              child: Text(
                                                                  'Veriler yüklenirken bir hata oluştu. Yeniden denemek için tıkla'),
                                                            ),
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(8.0),
                                                              child: IconButton(
                                                                icon: const Icon(
                                                                    Icons
                                                                        .refresh),
                                                                onPressed: () {
                                                                  setState(
                                                                      () {});
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
                                }),
                                Padding(
                                  padding: const EdgeInsets.only(left: 8),
                                  child: IconButton(
                                    icon: const Icon(Icons.arrow_right),
                                    onPressed: () {
                                      _pageController.nextPage(
                                        duration:
                                            const Duration(milliseconds: 500),
                                        curve: Curves.ease,
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: SizedBox(
                        width: double.infinity,
                        height: 1100,
                        child: Card(
                          elevation: 5,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Card(
                                    color: const Color.fromARGB(255, 0, 116, 0)
                                        .withOpacity(0.5),
                                    elevation: 0,
                                    child: const Padding(
                                      padding:
                                          EdgeInsets.fromLTRB(16, 4, 16, 4),
                                      child: Text(
                                        "Newly Released",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              StatefulBuilder(builder: (context, setState) {
                                ValueNotifier<int> pageIndex =
                                    ValueNotifier<int>(1);
                                return Expanded(
                                  child: FutureBuilder<List<GameModel>>(
                                      future:
                                          GamePageLogic().getPopularGameList(
                                        "newlyReleased",
                                      ),
                                      builder: (context, snapshot) {
                                        if (snapshot.hasData &&
                                            snapshot.connectionState ==
                                                ConnectionState.done) {
                                          var data = snapshot.data;
                                          int totalPages =
                                              (data!.length / 15).ceil();
                                          return Column(
                                            children: [
                                              SizedBox(
                                                height: 950,
                                                child: PageView.builder(
                                                    controller:
                                                        pageControllerNewlyReleased,
                                                    itemCount: totalPages,
                                                    itemBuilder:
                                                        (context, int index) {
                                                      final int startIndex =
                                                          index * 15;
                                                      final int endIndex =
                                                          (index + 1) * 15;
                                                      final pageData =
                                                          data.sublist(
                                                        startIndex,
                                                        endIndex.clamp(
                                                            0, data.length),
                                                      );
                                                      return GridView.builder(
                                                        gridDelegate:
                                                            const SliverGridDelegateWithMaxCrossAxisExtent(
                                                                maxCrossAxisExtent:
                                                                    350),
                                                        shrinkWrap: true,
                                                        itemCount:
                                                            pageData.length,
                                                        itemBuilder: (context,
                                                            innerIndex) {
                                                          ValueNotifier<bool>
                                                              isHovering =
                                                              ValueNotifier<
                                                                  bool>(false);
                                                          ValueNotifier<bool>
                                                              isFavorite =
                                                              ValueNotifier<
                                                                  bool>(false);

                                                          // ignore: prefer_typing_uninitialized_variables
                                                          var imageId;
                                                          if (pageData[
                                                                      innerIndex]
                                                                  .image_id ==
                                                              "0") {
                                                            imageId = "null";
                                                          } else {
                                                            imageId = pageData[
                                                                    innerIndex]
                                                                .image_id;
                                                          }
                                                          // ignore: prefer_typing_uninitialized_variables
                                                          var dateTime;
                                                          if (pageData[
                                                                      innerIndex]
                                                                  .first_release_date ==
                                                              0) {
                                                            dateTime =
                                                                "Bilinmiyor";
                                                          } else {
                                                            dateTime = DateTime
                                                                .fromMillisecondsSinceEpoch(
                                                                    pageData[innerIndex]
                                                                            .first_release_date! *
                                                                        1000);
                                                            dateTime = DateFormat(
                                                                    'dd.MM.yyyy')
                                                                .format(
                                                                    dateTime);
                                                          }
                                                          var gameID = 0;
                                                          if (pageData[
                                                                      innerIndex]
                                                                  .id !=
                                                              null) {
                                                            gameID = pageData[
                                                                    innerIndex]
                                                                .id!;
                                                          }
                                                          return MouseRegion(
                                                            onHover: (event) =>
                                                                isHovering
                                                                        .value =
                                                                    true,
                                                            onExit: (event) =>
                                                                isHovering
                                                                        .value =
                                                                    false,
                                                            cursor:
                                                                SystemMouseCursors
                                                                    .click,
                                                            child:
                                                                GestureDetector(
                                                              onTap: () {
                                                                Navigator.push(
                                                                  context,
                                                                  MaterialPageRoute(
                                                                    builder: (context) =>
                                                                        GameDetailPage(
                                                                            gameID:
                                                                                gameID),
                                                                  ),
                                                                );
                                                              },
                                                              child: Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .all(
                                                                        8.0),
                                                                child: Column(
                                                                  children: [
                                                                    Expanded(
                                                                      child:
                                                                          SizedBox(
                                                                        height:
                                                                            double.infinity,
                                                                        width:
                                                                            180,
                                                                        child:
                                                                            GridTile(
                                                                          child:
                                                                              Stack(
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
                                                                                          borderRadius: const BorderRadius.only(
                                                                                            topLeft: Radius.circular(12),
                                                                                            topRight: Radius.circular(12),
                                                                                          ),
                                                                                          child: Image(
                                                                                            fit: BoxFit.fill,
                                                                                            image: CachedNetworkImageProvider(
                                                                                              """https://${pageData[innerIndex].url}""",
                                                                                            ),
                                                                                          ),
                                                                                        ),
                                                                                      ),
                                                                                    ),
                                                                                    Tooltip(
                                                                                      message: pageData[innerIndex].name,
                                                                                      child: SizedBox(
                                                                                        width: 180,
                                                                                        child: Column(
                                                                                          children: [
                                                                                            Padding(
                                                                                              padding: const EdgeInsets.all(4.0),
                                                                                              child: Text(
                                                                                                pageData[innerIndex].name.toString(),
                                                                                                softWrap: true,
                                                                                                overflow: TextOverflow.ellipsis,
                                                                                                textAlign: TextAlign.center,
                                                                                              ),
                                                                                            ),
                                                                                            Padding(
                                                                                              padding: const EdgeInsets.only(bottom: 4.0),
                                                                                              child: Text(
                                                                                                dateTime.toString(),
                                                                                                softWrap: true,
                                                                                                overflow: TextOverflow.ellipsis,
                                                                                                textAlign: TextAlign.center,
                                                                                                style: const TextStyle(fontSize: 12),
                                                                                              ),
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
                                                                                            color: const Color.fromARGB(125, 0, 0, 0),
                                                                                            child: ValueListenableBuilder(
                                                                                                valueListenable: isFavorite,
                                                                                                builder: (context, value, child) {
                                                                                                  Map<String, dynamic> gameMap = {
                                                                                                    "gameID": pageData[innerIndex].id,
                                                                                                    "imageURL": "https://images.igdb.com/igdb/image/upload/t_original/$imageId.png",
                                                                                                    "gameName": pageData[innerIndex].name,
                                                                                                  };
                                                                                                  for (var x in gamesList) {
                                                                                                    if (x['gameID'] == pageData[innerIndex].id) {
                                                                                                      isFavorite.value = true;
                                                                                                    }
                                                                                                  }
                                                                                                  return isFavorite.value
                                                                                                      ? IconButton(
                                                                                                          highlightColor: Color(themeColor),
                                                                                                          hoverColor: Colors.transparent,
                                                                                                          onPressed: () {
                                                                                                            gamesList.removeWhere((element) => element['gameID'] == pageData[innerIndex].id);
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
                                                                    )
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                      );
                                                    }),
                                              ),
                                              ValueListenableBuilder(
                                                  valueListenable: pageIndex,
                                                  builder:
                                                      (context, value, child) {
                                                    return Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(8.0),
                                                          child: IconButton(
                                                            icon: const Icon(
                                                              Icons
                                                                  .arrow_circle_left_outlined,
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                            onPressed: () {
                                                              if (pageIndex
                                                                      .value >
                                                                  1) {
                                                                pageControllerNewlyReleased
                                                                    .jumpToPage(
                                                                        1);
                                                                pageIndex
                                                                    .value = 1;
                                                                // setState(() =>
                                                                //     pageIndex.value =
                                                                //         1);
                                                              }
                                                            },
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(8.0),
                                                          child: IconButton(
                                                            icon: const Icon(
                                                              Icons.arrow_left,
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                            onPressed: () {
                                                              if (pageIndex
                                                                      .value >
                                                                  1) {
                                                                pageControllerNewlyReleased
                                                                    .previousPage(
                                                                  duration: const Duration(
                                                                      milliseconds:
                                                                          500),
                                                                  curve: Curves
                                                                      .ease,
                                                                );
                                                                pageIndex
                                                                    .value -= 1;
                                                              }
                                                            },
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(8.0),
                                                          child: Text(
                                                              "${pageIndex.value}/$totalPages"),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(8.0),
                                                          child: IconButton(
                                                            icon: const Icon(
                                                              Icons.arrow_right,
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                            onPressed: () {
                                                              if (pageIndex
                                                                      .value <
                                                                  totalPages) {
                                                                pageControllerNewlyReleased
                                                                    .nextPage(
                                                                  duration: const Duration(
                                                                      milliseconds:
                                                                          500),
                                                                  curve: Curves
                                                                      .ease,
                                                                );
                                                                pageIndex
                                                                    .value += 1;
                                                              }
                                                            },
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(8.0),
                                                          child: IconButton(
                                                            icon: const Icon(
                                                              Icons
                                                                  .arrow_circle_right_outlined,
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                            onPressed: () {
                                                              if (pageIndex
                                                                      .value <
                                                                  totalPages) {
                                                                pageControllerNewlyReleased
                                                                    .jumpToPage(
                                                                        totalPages);
                                                                pageIndex
                                                                        .value =
                                                                    totalPages;
                                                                // setState(() {
                                                                //   pageControllerNewlyReleased
                                                                //       .jumpToPage(
                                                                //           totalPages -
                                                                //               1);
                                                                //   pageIndexNewlyReleased =
                                                                //       totalPages;
                                                                // });
                                                              }
                                                            },
                                                          ),
                                                        ),
                                                      ],
                                                    );
                                                  }),
                                            ],
                                          );
                                        } else {
                                          bool connectionBool = true;
                                          if (snapshot.connectionState ==
                                              ConnectionState.done) {
                                            connectionBool = false;
                                          }
                                          return connectionBool
                                              ? const ShimmerEffect()
                                              : Center(
                                                  child: Card(
                                                    child: Column(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        const Padding(
                                                          padding:
                                                              EdgeInsets.all(
                                                                  8.0),
                                                          child: Text(
                                                              'Veriler yüklenirken bir hata oluştu. Yeniden denemek için tıkla'),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(8.0),
                                                          child: IconButton(
                                                            icon: const Icon(
                                                                Icons.refresh),
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
                                      }),
                                );
                              }),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: SizedBox(
                        width: double.infinity,
                        height: 1100,
                        child: Card(
                          elevation: 5,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Card(
                                      color:
                                          const Color.fromARGB(255, 0, 116, 0)
                                              .withOpacity(0.5),
                                      elevation: 0,
                                      child: const Padding(
                                        padding:
                                            EdgeInsets.fromLTRB(16, 4, 16, 4),
                                        child: Text("Coming Soon",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold)),
                                      )),
                                ),
                              ),
                              StatefulBuilder(builder: (context, setState) {
                                ValueNotifier<int> pageIndex =
                                    ValueNotifier<int>(1);
                                return Expanded(
                                  child: FutureBuilder<List<GameModel>>(
                                      future:
                                          GamePageLogic().getPopularGameList(
                                        "comingSoon",
                                      ),
                                      builder: (context, snapshot) {
                                        if (snapshot.hasData &&
                                            snapshot.connectionState ==
                                                ConnectionState.done) {
                                          var data = snapshot.data;
                                          int totalPages =
                                              (data!.length / 15).ceil();
                                          return Column(
                                            children: [
                                              SizedBox(
                                                height: 950,
                                                child: PageView.builder(
                                                    itemCount: totalPages,
                                                    controller:
                                                        pageControllerComingSoon,
                                                    itemBuilder:
                                                        (context, int index) {
                                                      final int startIndex =
                                                          index * 15;
                                                      final int endIndex =
                                                          (index + 1) * 15;
                                                      final pageData =
                                                          data.sublist(
                                                        startIndex,
                                                        endIndex.clamp(
                                                            0, data.length),
                                                      );
                                                      // print(pageData.length);

                                                      return GridView.builder(
                                                        gridDelegate:
                                                            const SliverGridDelegateWithMaxCrossAxisExtent(
                                                                maxCrossAxisExtent:
                                                                    350),
                                                        itemCount:
                                                            pageData.length,
                                                        itemBuilder:
                                                            (context, index) {
                                                          ValueNotifier<bool>
                                                              isHovering =
                                                              ValueNotifier<
                                                                  bool>(false);
                                                          ValueNotifier<bool>
                                                              isFavorite =
                                                              ValueNotifier<
                                                                  bool>(false);
                                                          // ignore: prefer_typing_uninitialized_variables
                                                          var imageId;
                                                          if (pageData[index]
                                                                  .image_id ==
                                                              "0") {
                                                            imageId = "null";
                                                          } else {
                                                            imageId =
                                                                pageData[index]
                                                                    .image_id;
                                                          }
                                                          // ignore: prefer_typing_uninitialized_variables
                                                          var dateTime;
                                                          if (pageData[index]
                                                                  .first_release_date ==
                                                              0) {
                                                            dateTime =
                                                                "Bilinmiyor";
                                                          } else {
                                                            dateTime = DateTime
                                                                .fromMillisecondsSinceEpoch(
                                                                    pageData[index]
                                                                            .first_release_date! *
                                                                        1000);
                                                            dateTime = DateFormat(
                                                                    'dd.MM.yyyy')
                                                                .format(
                                                                    dateTime);
                                                          }
                                                          var gameID = 0;
                                                          if (pageData[index]
                                                                  .id !=
                                                              null) {
                                                            gameID =
                                                                pageData[index]
                                                                    .id!;
                                                          }

                                                          return MouseRegion(
                                                            onEnter: (event) =>
                                                                isHovering
                                                                        .value =
                                                                    true,
                                                            onExit: (event) =>
                                                                isHovering
                                                                        .value =
                                                                    false,
                                                            cursor:
                                                                SystemMouseCursors
                                                                    .click,
                                                            child:
                                                                GestureDetector(
                                                              onTap: () {
                                                                Navigator.push(
                                                                  context,
                                                                  MaterialPageRoute(
                                                                    builder: (context) =>
                                                                        GameDetailPage(
                                                                            gameID:
                                                                                gameID),
                                                                  ),
                                                                );
                                                              },
                                                              child: Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .all(
                                                                        8.0),
                                                                child: Column(
                                                                  children: [
                                                                    Expanded(
                                                                      child:
                                                                          SizedBox(
                                                                        height:
                                                                            double.infinity,
                                                                        width:
                                                                            180,
                                                                        child:
                                                                            GridTile(
                                                                          child:
                                                                              Stack(
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
                                                                                          borderRadius: const BorderRadius.only(
                                                                                            topLeft: Radius.circular(12),
                                                                                            topRight: Radius.circular(12),
                                                                                          ),
                                                                                          child: Image(
                                                                                            fit: BoxFit.fill,
                                                                                            image: CachedNetworkImageProvider(
                                                                                              """https://${pageData[index].url}""",
                                                                                            ),
                                                                                          ),
                                                                                        ),
                                                                                      ),
                                                                                    ),
                                                                                    Tooltip(
                                                                                      message: pageData[index].name,
                                                                                      child: SizedBox(
                                                                                        width: 180,
                                                                                        child: Column(
                                                                                          children: [
                                                                                            Padding(
                                                                                              padding: const EdgeInsets.all(4.0),
                                                                                              child: Text(
                                                                                                pageData[index].name.toString(),
                                                                                                softWrap: true,
                                                                                                overflow: TextOverflow.ellipsis,
                                                                                                textAlign: TextAlign.center,
                                                                                              ),
                                                                                            ),
                                                                                            Padding(
                                                                                              padding: const EdgeInsets.only(bottom: 4.0),
                                                                                              child: Text(
                                                                                                dateTime.toString(),
                                                                                                softWrap: true,
                                                                                                overflow: TextOverflow.ellipsis,
                                                                                                textAlign: TextAlign.center,
                                                                                                style: const TextStyle(fontSize: 12),
                                                                                              ),
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
                                                                                            color: const Color.fromARGB(125, 0, 0, 0),
                                                                                            child: ValueListenableBuilder(
                                                                                                valueListenable: isFavorite,
                                                                                                builder: (context, value, child) {
                                                                                                  Map<String, dynamic> gameMap = {
                                                                                                    "gameID": pageData[index].id,
                                                                                                    "imageURL": "https://images.igdb.com/igdb/image/upload/t_original/$imageId.png",
                                                                                                    "gameName": pageData[index].name,
                                                                                                  };
                                                                                                  for (var x in gamesList) {
                                                                                                    if (x['gameID'] == pageData[index].id) {
                                                                                                      isFavorite.value = true;
                                                                                                    }
                                                                                                  }
                                                                                                  return isFavorite.value
                                                                                                      ? IconButton(
                                                                                                          highlightColor: Color(themeColor),
                                                                                                          hoverColor: Colors.transparent,
                                                                                                          onPressed: () {
                                                                                                            gamesList.removeWhere((element) => element['gameID'] == pageData[index].id);
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
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                      );
                                                    }),
                                              ),
                                              ValueListenableBuilder(
                                                  valueListenable: pageIndex,
                                                  builder:
                                                      (context, value, child) {
                                                    return Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(8.0),
                                                          child: IconButton(
                                                            icon: const Icon(
                                                              Icons
                                                                  .arrow_circle_left_outlined,
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                            onPressed: () {
                                                              if (pageIndex
                                                                      .value >
                                                                  1) {
                                                                pageControllerComingSoon
                                                                    .jumpToPage(
                                                                        1);
                                                                pageIndex
                                                                    .value = 1;
                                                                // setState(() =>
                                                                //     pageIndex.value =
                                                                //         1);
                                                              }
                                                            },
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(8.0),
                                                          child: IconButton(
                                                            icon: const Icon(
                                                              Icons.arrow_left,
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                            onPressed: () {
                                                              if (pageIndex
                                                                      .value >
                                                                  1) {
                                                                pageControllerComingSoon
                                                                    .previousPage(
                                                                  duration: const Duration(
                                                                      milliseconds:
                                                                          500),
                                                                  curve: Curves
                                                                      .ease,
                                                                );
                                                                pageIndex
                                                                    .value -= 1;
                                                              }
                                                            },
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(8.0),
                                                          child: Text(
                                                              "${pageIndex.value}/$totalPages"),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(8.0),
                                                          child: IconButton(
                                                            icon: const Icon(
                                                              Icons.arrow_right,
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                            onPressed: () {
                                                              if (pageIndex
                                                                      .value <
                                                                  totalPages) {
                                                                pageControllerComingSoon
                                                                    .nextPage(
                                                                  duration: const Duration(
                                                                      milliseconds:
                                                                          500),
                                                                  curve: Curves
                                                                      .ease,
                                                                );
                                                                pageIndex
                                                                    .value += 1;
                                                              }
                                                            },
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(8.0),
                                                          child: IconButton(
                                                            icon: const Icon(
                                                              Icons
                                                                  .arrow_circle_right_outlined,
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                            onPressed: () {
                                                              if (pageIndex
                                                                      .value <
                                                                  totalPages) {
                                                                pageControllerComingSoon
                                                                    .jumpToPage(
                                                                        totalPages);
                                                                pageIndex
                                                                        .value =
                                                                    totalPages;
                                                                // setState(() {
                                                                //   pageControllerNewlyReleased
                                                                //       .jumpToPage(
                                                                //           totalPages -
                                                                //               1);
                                                                //   pageIndexNewlyReleased =
                                                                //       totalPages;
                                                                // });
                                                              }
                                                            },
                                                          ),
                                                        ),
                                                      ],
                                                    );
                                                  }),
                                            ],
                                          );
                                        } else {
                                          bool connectionBool = true;
                                          if (snapshot.connectionState ==
                                              ConnectionState.done) {
                                            connectionBool = false;
                                          }
                                          return connectionBool
                                              ? const ShimmerEffect()
                                              : Center(
                                                  child: Card(
                                                    child: Column(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        const Padding(
                                                          padding:
                                                              EdgeInsets.all(
                                                                  8.0),
                                                          child: Text(
                                                              'Veriler yüklenirken bir hata oluştu. Yeniden denemek için tıkla'),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(8.0),
                                                          child: IconButton(
                                                            icon: const Icon(
                                                                Icons.refresh),
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
                                      }),
                                );
                              }),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: SizedBox(
                        width: double.infinity,
                        height: 1100,
                        child: Card(
                          elevation: 5,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Card(
                                      color:
                                          const Color.fromARGB(255, 0, 116, 0)
                                              .withOpacity(0.5),
                                      elevation: 0,
                                      child: const Padding(
                                        padding:
                                            EdgeInsets.fromLTRB(16, 4, 16, 4),
                                        child: Text(
                                          "Mostly Anticipated",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                      )),
                                ),
                              ),
                              StatefulBuilder(builder: (context, setState) {
                                ValueNotifier<int> pageIndex =
                                    ValueNotifier<int>(1);
                                return Expanded(
                                  child: FutureBuilder<List<GameModel>>(
                                      future:
                                          GamePageLogic().getPopularGameList(
                                        "mostlyAnticipated",
                                      ),
                                      builder: (context, snapshot) {
                                        if (snapshot.hasData &&
                                            snapshot.connectionState ==
                                                ConnectionState.done) {
                                          var data = snapshot.data;
                                          int totalPages =
                                              (data!.length / 15).ceil();
                                          return Column(
                                            children: [
                                              SizedBox(
                                                height: 950,
                                                child: PageView.builder(
                                                    itemCount: totalPages,
                                                    controller:
                                                        pageControllerMostlyAnticipated,
                                                    itemBuilder:
                                                        (context, index) {
                                                      final int startIndex =
                                                          index * 15;
                                                      final int endIndex =
                                                          (index + 1) * 15;
                                                      final pageData =
                                                          data.sublist(
                                                        startIndex,
                                                        endIndex.clamp(
                                                            0, data.length),
                                                      );
                                                      return GridView.builder(
                                                        gridDelegate:
                                                            const SliverGridDelegateWithMaxCrossAxisExtent(
                                                                maxCrossAxisExtent:
                                                                    350),
                                                        itemCount:
                                                            pageData.length,
                                                        itemBuilder:
                                                            (context, index) {
                                                          // ignore: prefer_typing_uninitialized_variables
                                                          ValueNotifier<bool>
                                                              isHovering =
                                                              ValueNotifier<
                                                                  bool>(false);
                                                          ValueNotifier<bool>
                                                              isFavorite =
                                                              ValueNotifier<
                                                                  bool>(false);
                                                          // ignore: prefer_typing_uninitialized_variables
                                                          var imageId;

                                                          if (pageData[index]
                                                                  .image_id ==
                                                              "0") {
                                                            imageId = "null";
                                                          } else {
                                                            imageId =
                                                                pageData[index]
                                                                    .image_id;
                                                          }
                                                          var dateTime;
                                                          if (pageData[index]
                                                                  .first_release_date ==
                                                              0) {
                                                            dateTime =
                                                                "Bilinmiyor";
                                                          } else {
                                                            dateTime = DateTime
                                                                .fromMillisecondsSinceEpoch(
                                                                    pageData[index]
                                                                            .first_release_date! *
                                                                        1000);
                                                            dateTime = DateFormat(
                                                                    'dd.MM.yyyy')
                                                                .format(
                                                                    dateTime);
                                                          }
                                                          var gameID = 0;
                                                          if (pageData[index]
                                                                  .id !=
                                                              null) {
                                                            gameID =
                                                                pageData[index]
                                                                    .id!;
                                                          }

                                                          return MouseRegion(
                                                            onEnter: (event) =>
                                                                isHovering
                                                                        .value =
                                                                    true,
                                                            onExit: (event) =>
                                                                isHovering
                                                                        .value =
                                                                    false,
                                                            child:
                                                                GestureDetector(
                                                              onTap: () {
                                                                Navigator.push(
                                                                  context,
                                                                  MaterialPageRoute(
                                                                    builder: (context) =>
                                                                        GameDetailPage(
                                                                            gameID:
                                                                                gameID),
                                                                  ),
                                                                );
                                                              },
                                                              child: Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .all(
                                                                        8.0),
                                                                child: Column(
                                                                  children: [
                                                                    Expanded(
                                                                      child:
                                                                          SizedBox(
                                                                        height:
                                                                            double.infinity,
                                                                        width:
                                                                            180,
                                                                        child:
                                                                            GridTile(
                                                                          child:
                                                                              Stack(
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
                                                                                          borderRadius: const BorderRadius.only(
                                                                                            topLeft: Radius.circular(12),
                                                                                            topRight: Radius.circular(12),
                                                                                          ),
                                                                                          child: Image(
                                                                                            fit: BoxFit.fill,
                                                                                            image: CachedNetworkImageProvider(
                                                                                              """https://${pageData[index].url}""",
                                                                                            ),
                                                                                          ),
                                                                                        ),
                                                                                      ),
                                                                                    ),
                                                                                    Tooltip(
                                                                                      message: pageData[index].name,
                                                                                      child: SizedBox(
                                                                                        width: 180,
                                                                                        child: Column(
                                                                                          children: [
                                                                                            Padding(
                                                                                              padding: const EdgeInsets.all(4.0),
                                                                                              child: Text(
                                                                                                pageData[index].name.toString(),
                                                                                                softWrap: true,
                                                                                                overflow: TextOverflow.ellipsis,
                                                                                                textAlign: TextAlign.center,
                                                                                              ),
                                                                                            ),
                                                                                            Padding(
                                                                                              padding: const EdgeInsets.only(bottom: 4.0),
                                                                                              child: Text(
                                                                                                dateTime.toString(),
                                                                                                softWrap: true,
                                                                                                overflow: TextOverflow.ellipsis,
                                                                                                textAlign: TextAlign.center,
                                                                                                style: const TextStyle(fontSize: 12),
                                                                                              ),
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
                                                                                            color: const Color.fromARGB(125, 0, 0, 0),
                                                                                            child: ValueListenableBuilder(
                                                                                                valueListenable: isFavorite,
                                                                                                builder: (context, value, child) {
                                                                                                  Map<String, dynamic> gameMap = {
                                                                                                    "gameID": pageData[index].id,
                                                                                                    "imageURL": "https://images.igdb.com/igdb/image/upload/t_original/$imageId.png",
                                                                                                    "gameName": pageData[index].name,
                                                                                                  };
                                                                                                  for (var x in gamesList) {
                                                                                                    if (x['gameID'] == pageData[index].id) {
                                                                                                      isFavorite.value = true;
                                                                                                    }
                                                                                                  }
                                                                                                  return isFavorite.value
                                                                                                      ? IconButton(
                                                                                                          highlightColor: Color(themeColor),
                                                                                                          hoverColor: Colors.transparent,
                                                                                                          onPressed: () {
                                                                                                            gamesList.removeWhere((element) => element['gameID'] == pageData[index].id);
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
                                                                    )
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                      );
                                                    }),
                                              ),
                                              ValueListenableBuilder(
                                                  valueListenable: pageIndex,
                                                  builder:
                                                      (context, value, child) {
                                                    return Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(8.0),
                                                          child: IconButton(
                                                            icon: const Icon(
                                                              Icons
                                                                  .arrow_circle_left_outlined,
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                            onPressed: () {
                                                              if (pageIndex
                                                                      .value >
                                                                  1) {
                                                                pageControllerMostlyAnticipated
                                                                    .jumpToPage(
                                                                        1);
                                                                pageIndex
                                                                    .value = 1;
                                                                // setState(() =>
                                                                //     pageIndex.value =
                                                                //         1);
                                                              }
                                                            },
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(8.0),
                                                          child: IconButton(
                                                            icon: const Icon(
                                                              Icons.arrow_left,
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                            onPressed: () {
                                                              if (pageIndex
                                                                      .value >
                                                                  1) {
                                                                pageControllerMostlyAnticipated
                                                                    .previousPage(
                                                                  duration: const Duration(
                                                                      milliseconds:
                                                                          500),
                                                                  curve: Curves
                                                                      .ease,
                                                                );
                                                                pageIndex
                                                                    .value -= 1;
                                                              }
                                                            },
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(8.0),
                                                          child: Text(
                                                              "${pageIndex.value}/$totalPages"),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(8.0),
                                                          child: IconButton(
                                                            icon: const Icon(
                                                              Icons.arrow_right,
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                            onPressed: () {
                                                              if (pageIndex
                                                                      .value <
                                                                  totalPages) {
                                                                pageControllerMostlyAnticipated
                                                                    .nextPage(
                                                                  duration: const Duration(
                                                                      milliseconds:
                                                                          500),
                                                                  curve: Curves
                                                                      .ease,
                                                                );
                                                                pageIndex
                                                                    .value += 1;
                                                              }
                                                            },
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(8.0),
                                                          child: IconButton(
                                                            icon: const Icon(
                                                              Icons
                                                                  .arrow_circle_right_outlined,
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                            onPressed: () {
                                                              if (pageIndex
                                                                      .value <
                                                                  totalPages) {
                                                                pageControllerMostlyAnticipated
                                                                    .jumpToPage(
                                                                        totalPages);
                                                                pageIndex
                                                                        .value =
                                                                    totalPages;
                                                              }
                                                            },
                                                          ),
                                                        ),
                                                      ],
                                                    );
                                                  }),
                                            ],
                                          );
                                        } else {
                                          bool connectionBool = true;
                                          if (snapshot.connectionState ==
                                              ConnectionState.done) {
                                            connectionBool = false;
                                          }
                                          return connectionBool
                                              ? const ShimmerEffect()
                                              : Center(
                                                  child: Card(
                                                    child: Column(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        const Padding(
                                                          padding:
                                                              EdgeInsets.all(
                                                                  8.0),
                                                          child: Text(
                                                              'Veriler yüklenirken bir hata oluştu. Yeniden denemek için tıkla'),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(8.0),
                                                          child: IconButton(
                                                            icon: const Icon(
                                                                Icons.refresh),
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
                                      }),
                                );
                              }),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            } else {
              return CustomCPI();
            }
          }),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
