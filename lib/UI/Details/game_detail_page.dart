import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gnml/Data/Model/game_model.dart';
import 'package:gnml/Helper/theme_helper.dart';
import 'package:gnml/Logic/gamepage_logic.dart';
import 'package:gnml/Widgets/circularprogressindicator.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class GameDetailPage extends StatefulWidget {
  final int gameID;

  const GameDetailPage({
    super.key,
    required this.gameID,
  });

  @override
  State<GameDetailPage> createState() => _GameDetailPageState();
}

class _GameDetailPageState extends State<GameDetailPage> {
  User? user = FirebaseAuth.instance.currentUser;
  bool boolean = false;
  String? connectionText;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    int themeColor = Provider.of<ThemeProvider>(context).color;
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

    PageController pageController = PageController(
      initialPage: 0,
    );
    return FutureBuilder<List<GameModel>>(
        future: GamePageLogic().getGameDetails(widget.gameID),
        builder: (context, snapshot) {
          if (snapshot.hasData &&
              snapshot.connectionState == ConnectionState.done) {
            var data = snapshot.data![0];
            String dateTime = getDateTime(data);
            List<Widget> platformList = getPlatformList(data);
            List<Widget>? devList = getDeveloperList(data);
            List<Widget>? publisherList = getPublisherList(data);
            List<Widget>? genreList = getGenreList(data);
            List<Widget>? tagsList = getThemesList(data);
            String? summary = data.summary;
            String? storyline = data.storyline;
            summary = utf8
                .decode(data.summary.toString().runes.toList(),
                    allowMalformed: true)
                .replaceAll("�", "");
            storyline = utf8
                .decode(data.storyline.toString().runes.toList(),
                    allowMalformed: true)
                .replaceAll("�", "");

            var imageId = data.image_id;
            if (imageId == "0") {
              imageId = null;
            }
            return FutureBuilder(
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
                    Map<String, dynamic> gameMap = {
                      "gameID": widget.gameID,
                      "imageURL":
                          "https://images.igdb.com/igdb/image/upload/t_original/$imageId.png",
                      "gameName": data.name,
                    };
                    for (var x in gamesList) {
                      if (x['gameID'] == widget.gameID) {
                        boolean = true;
                      }
                    }

                    return Scaffold(
                      // appBar: AppBar(
                      //   title: const Text("Game Details"),
                      //   backgroundColor: Colors.transparent,
                      //   leading: IconButton(
                      //     icon: const Icon(Icons.arrow_back),
                      //     onPressed: () {
                      //       Navigator.of(context).pop();
                      //     },
                      //   ),
                      // ),
                      body: Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: NetworkImage(
                                "https://images.igdb.com/igdb/image/upload/t_original/$imageId.png"),
                            fit: BoxFit.cover,
                          ),
                        ),
                        child: Container(
                          height: double.maxFinite,
                          color: Colors.black.withOpacity(0.7),
                          child: SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            child: BackdropFilter(
                              filter:
                                  ImageFilter.blur(sigmaX: 100, sigmaY: 100),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(left: 12.0),
                                    child: Row(
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.arrow_back),
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                        const Padding(
                                          padding: EdgeInsets.all(8.0),
                                          child: Text(
                                            "Game Details",
                                            style: TextStyle(
                                                fontSize: 32,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        64, 48, 64, 48),
                                    child: Table(
                                      children: [
                                        TableRow(
                                          children: [
                                            TableCell(
                                              child: Column(
                                                children: [
                                                  Card(
                                                    elevation: 0,
                                                    child: SizedBox(
                                                      height: 350,
                                                      child: ClipRRect(
                                                        borderRadius:
                                                            const BorderRadius
                                                                .all(
                                                                Radius.circular(
                                                                    12)),
                                                        child: Image(
                                                            image: NetworkImage(
                                                                "https://images.igdb.com/igdb/image/upload/t_original/$imageId.png"),
                                                            fit: BoxFit.fill),
                                                      ),
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            right: 16.0),
                                                    child: StatefulBuilder(
                                                        builder: (context,
                                                            setState) {
                                                      return Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          Card(
                                                            color: Colors.grey
                                                                .withOpacity(
                                                                    0.3),
                                                            child: IconButton(
                                                              highlightColor:
                                                                  Color(
                                                                      themeColor),
                                                              hoverColor: Colors
                                                                  .transparent,
                                                              icon: boolean
                                                                  ? Tooltip(
                                                                      message:
                                                                          "Remove from Library",
                                                                      child: Icon(
                                                                          Icons
                                                                              .favorite,
                                                                          color:
                                                                              Color(themeColor)),
                                                                    )
                                                                  : const Tooltip(
                                                                      message:
                                                                          "Add to Library",
                                                                      child: Icon(
                                                                          Icons
                                                                              .favorite_outline),
                                                                    ),
                                                              onPressed: () {
                                                                if (boolean) {
                                                                  gamesList.removeWhere((element) =>
                                                                      element[
                                                                          'gameID'] ==
                                                                      widget
                                                                          .gameID);
                                                                  updateData(
                                                                      gamesList,
                                                                      moviesList,
                                                                      seriesList,
                                                                      booksList,
                                                                      actorsList);
                                                                } else {
                                                                  gamesList.add(
                                                                      gameMap);
                                                                  updateData(
                                                                      gamesList,
                                                                      moviesList,
                                                                      seriesList,
                                                                      booksList,
                                                                      actorsList);
                                                                }
                                                                setState(() =>
                                                                    boolean =
                                                                        !boolean);
                                                              },
                                                            ),
                                                          ),
                                                          getIcons(data),
                                                        ],
                                                      );
                                                    }),
                                                  )
                                                ],
                                              ),
                                            ),
                                            TableCell(
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 64),
                                                child: SizedBox(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text('${data.name}',
                                                          style: const TextStyle(
                                                              fontSize: 50,
                                                              fontFamily:
                                                                  'RobotoBold')),
                                                      Text(
                                                        dateTime,
                                                      ),
                                                      const Divider(
                                                          color: Colors
                                                              .transparent),
                                                      const Divider(
                                                          color: Colors
                                                              .transparent),
                                                      Text(summary!),
                                                      const Divider(
                                                          color: Colors
                                                              .transparent),
                                                      const Divider(
                                                          color: Colors
                                                              .transparent),
                                                      Row(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          const Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Text("Genres:"),
                                                              Text("Tags:"),
                                                              Text(
                                                                  "Developers:"),
                                                              Text(
                                                                  "Publishers:"),
                                                              Text(
                                                                  "Platforms:"),
                                                            ],
                                                          ),
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .only(
                                                                    left: 16),
                                                            child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                SizedBox(
                                                                  width: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width /
                                                                      2.4,
                                                                  child: Wrap(
                                                                    spacing: 10,
                                                                    children:
                                                                        genreList,
                                                                  ),
                                                                ),
                                                                SizedBox(
                                                                  width: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width /
                                                                      2.4,
                                                                  child: Wrap(
                                                                    spacing: 10,
                                                                    children:
                                                                        tagsList,
                                                                  ),
                                                                ),
                                                                SizedBox(
                                                                  width: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width /
                                                                      2.4,
                                                                  child: Wrap(
                                                                    spacing: 10,
                                                                    children:
                                                                        devList,
                                                                  ),
                                                                ),
                                                                SizedBox(
                                                                  width: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width /
                                                                      2.4,
                                                                  child: Wrap(
                                                                    spacing: 10,
                                                                    children:
                                                                        publisherList,
                                                                  ),
                                                                ),
                                                                SizedBox(
                                                                  width: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width /
                                                                      2.4,
                                                                  child: Wrap(
                                                                    spacing: 10,
                                                                    children:
                                                                        platformList,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(top: 100),
                                                        child: Card(
                                                          color: Colors.grey
                                                              .withOpacity(0.2),
                                                          child: Theme(
                                                            data: ThemeData(
                                                              highlightColor:
                                                                  Colors
                                                                      .transparent,
                                                              hoverColor: Colors
                                                                  .transparent,
                                                              splashColor: Colors
                                                                  .transparent,
                                                            ),
                                                            child:
                                                                ExpansionTile(
                                                              textColor:
                                                                  Colors.white,
                                                              collapsedTextColor:
                                                                  Colors.white,
                                                              collapsedIconColor:
                                                                  Colors.white,
                                                              iconColor:
                                                                  Colors.white,
                                                              title: const Text(
                                                                "Storyline (May contain spoilers)",
                                                                style: TextStyle(
                                                                    fontFamily:
                                                                        'RobotoBold'),
                                                              ),
                                                              children: [
                                                                Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .all(
                                                                          24.0),
                                                                  child: Text(
                                                                    storyline!,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(top: 16),
                                                        child: Card(
                                                          color: Colors.grey
                                                              .withOpacity(0.2),
                                                          child: Theme(
                                                            data: ThemeData(
                                                              highlightColor:
                                                                  Colors
                                                                      .transparent,
                                                              hoverColor: Colors
                                                                  .transparent,
                                                              splashColor: Colors
                                                                  .transparent,
                                                            ),
                                                            child:
                                                                ExpansionTile(
                                                              textColor:
                                                                  Colors.white,
                                                              collapsedTextColor:
                                                                  Colors.white,
                                                              collapsedIconColor:
                                                                  Colors.white,
                                                              iconColor:
                                                                  Colors.white,
                                                              title: const Text(
                                                                  "Screenshots",
                                                                  style: TextStyle(
                                                                      fontFamily:
                                                                          'RobotoBold')),
                                                              children: [
                                                                SizedBox(
                                                                  child: Row(
                                                                    children: [
                                                                      IconButton(
                                                                        icon:
                                                                            const Icon(
                                                                          Icons
                                                                              .arrow_left,
                                                                          color:
                                                                              Colors.white,
                                                                        ),
                                                                        onPressed:
                                                                            () {
                                                                          pageController
                                                                              .previousPage(
                                                                            duration:
                                                                                const Duration(milliseconds: 500),
                                                                            curve:
                                                                                Curves.ease,
                                                                          );
                                                                        },
                                                                      ),
                                                                      Expanded(
                                                                        child:
                                                                            SizedBox(
                                                                          height:
                                                                              500,
                                                                          width:
                                                                              800,
                                                                          child:
                                                                              PageView.builder(
                                                                            controller:
                                                                                pageController,
                                                                            itemCount:
                                                                                data.screenshots_list?.length,
                                                                            scrollDirection:
                                                                                Axis.horizontal,
                                                                            itemBuilder:
                                                                                (context, index) {
                                                                              var imageId = data.screenshots_list![index];
                                                                              return Padding(
                                                                                padding: const EdgeInsets.all(16.0),
                                                                                child: ClipRRect(
                                                                                  borderRadius: const BorderRadius.all(Radius.circular(12)),
                                                                                  child: Image(
                                                                                    fit: BoxFit.fill,
                                                                                    image: NetworkImage("https://images.igdb.com/igdb/image/upload/t_original/$imageId.png"),
                                                                                  ),
                                                                                ),
                                                                              );
                                                                            },
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      IconButton(
                                                                        icon:
                                                                            const Icon(
                                                                          Icons
                                                                              .arrow_right,
                                                                          color:
                                                                              Colors.white,
                                                                        ),
                                                                        onPressed:
                                                                            () {
                                                                          pageController
                                                                              .nextPage(
                                                                            duration:
                                                                                const Duration(milliseconds: 500),
                                                                            curve:
                                                                                Curves.ease,
                                                                          );
                                                                        },
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(top: 16),
                                                        child: Card(
                                                          color: Colors.grey
                                                              .withOpacity(0.2),
                                                          child: Theme(
                                                            data: ThemeData(
                                                              highlightColor:
                                                                  Colors
                                                                      .transparent,
                                                              hoverColor: Colors
                                                                  .transparent,
                                                              splashColor: Colors
                                                                  .transparent,
                                                            ),
                                                            child:
                                                                ExpansionTile(
                                                              textColor:
                                                                  Colors.white,
                                                              collapsedTextColor:
                                                                  Colors.white,
                                                              collapsedIconColor:
                                                                  Colors.white,
                                                              iconColor:
                                                                  Colors.white,
                                                              title: const Text(
                                                                "Language Support",
                                                                style: TextStyle(
                                                                    fontFamily:
                                                                        'RobotoBold'),
                                                              ),
                                                              children: [
                                                                getLanguageTable(
                                                                    data),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(top: 16),
                                                        child: Card(
                                                          color: Colors.grey
                                                              .withOpacity(0.2),
                                                          child: Theme(
                                                            data: ThemeData(
                                                              highlightColor:
                                                                  Colors
                                                                      .transparent,
                                                              hoverColor: Colors
                                                                  .transparent,
                                                              splashColor: Colors
                                                                  .transparent,
                                                            ),
                                                            child:
                                                                ExpansionTile(
                                                              textColor:
                                                                  Colors.white,
                                                              collapsedTextColor:
                                                                  Colors.white,
                                                              collapsedIconColor:
                                                                  Colors.white,
                                                              iconColor:
                                                                  Colors.white,
                                                              title: const Text(
                                                                "Websites",
                                                                style: TextStyle(
                                                                    fontFamily:
                                                                        'RobotoBold'),
                                                              ),
                                                              children: [
                                                                getWebsitesList(
                                                                    data),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                            TableCell(
                                              child: Container(
                                                height: 350,
                                                color: Colors.transparent,
                                                child: Card(
                                                  color: Colors.transparent,
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [getRating(data)],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                      columnWidths: const {
                                        0: FlexColumnWidth(0.5),
                                        1: FlexColumnWidth(2),
                                        2: FlexColumnWidth(0.5),
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  } else {
                    return const CustomCPI();
                  }
                });
          } else {
            bool connectionBool = true;
            if (snapshot.connectionState == ConnectionState.done) {
              connectionBool = false;
            }
            return Scaffold(
              appBar: AppBar(
                title: const Text("Game Details"),
              ),
              body: Center(
                  child: connectionBool
                      ? const CustomCPI()
                      : Card(
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
                                    setState(() {
                                      connectionText = null;
                                    });
                                  },
                                ),
                              )
                            ],
                          ),
                        )),
            );
          }
        });
  }
}

String getDateTime(data) {
  // ignore: prefer_typing_uninitialized_variables
  var dateTime;
  if (data.first_release_date == 0) {
    dateTime = "Unknown";
  } else {
    dateTime =
        DateTime.fromMillisecondsSinceEpoch(data.first_release_date! * 1000);
    dateTime = DateFormat('dd MMMM yyyy').format(dateTime);
  }
  return dateTime;
}

List<Widget> getPlatformList(data) {
  int index = 0;
  List<Widget>? platformList = [];

  if (data.platforms != null) {
    for (var x in data.platforms!) {
      if (data.platforms.length > 1 && index == 0 ||
          index < data.platforms.length - 1) {
        platformList.add(
          FittedBox(
            child: Text("${x['name']}"),
          ),
        );

        platformList.add(const Text("—"));
      } else {
        platformList.add(
          Text(x['name']),
        );
      }
      index += 1;
    }
  } else {
    platformList.add(
      Text(
        "Unknown",
        style: TextStyle(color: Colors.grey.shade600),
      ),
    );
  }

  return platformList;
}

List<Widget> getDeveloperList(data) {
  int index = 0;
  int devListLength = 0;
  List<dynamic>? involvedCompaniesData = data.involved_companies;
  List<Widget>? devList = [];

  if (involvedCompaniesData != null) {
    for (var x in involvedCompaniesData) {
      if (x['developer'] == true) {
        devListLength += 1;
      }
    }
    for (var x in involvedCompaniesData) {
      if (x['developer'] == true) {
        if (devListLength > 1 && index == 0 || index < devListLength - 1) {
          devList.add(
            Text(x['company']['name']),
          );

          devList.add(const Text("—"));
        } else {
          devList.add(
            Text(x['company']['name']),
          );
        }
        index += 1;
      }
    }
  } else {
    devList.add(
      Text(
        "Unknown",
        style: TextStyle(color: Colors.grey.shade600),
      ),
    );
  }

  return devList;
}

List<Widget> getPublisherList(data) {
  int index = 0;
  int publisherListLength = 0;
  List<dynamic>? involvedCompaniesData = data.involved_companies;
  List<Widget>? publisherList = [];

  if (involvedCompaniesData != null) {
    for (var x in involvedCompaniesData) {
      if (x['publisher'] == true) {
        publisherListLength += 1;
      }
    }
    for (var x in involvedCompaniesData) {
      if (x['publisher'] == true) {
        if (publisherListLength > 1 && index == 0 ||
            index < publisherListLength - 1) {
          publisherList.add(
            Text(x['company']['name']),
          );

          publisherList.add(const Text("—"));
        } else {
          publisherList.add(
            Text(x['company']['name']),
          );
        }
        index += 1;
      }
    }
    if (publisherList.isEmpty) {
      publisherList.add(
        Text(
          "Unknown",
          style: TextStyle(color: Colors.grey.shade600),
        ),
      );
    }
  } else {
    publisherList.add(
      Text(
        "Unknown",
        style: TextStyle(color: Colors.grey.shade600),
      ),
    );
  }
  return publisherList;
}

List<Widget> getGenreList(data) {
  int index = 0;
  List<Widget> genreList = [];

  if (data.genres != null) {
    for (var x in data.genres) {
      if (data.genres.length > 1 && index == 0 ||
          index < data.genres.length - 1) {
        genreList.add(
          Text(x['name']),
        );

        genreList.add(const Text("—"));
      } else {
        genreList.add(
          Text(x['name']),
        );
      }

      index += 1;
    }
  } else {
    genreList.add(
      Text(
        "Unknown",
        style: TextStyle(color: Colors.grey.shade600),
      ),
    );
  }

  return genreList;
}

List<Widget> getThemesList(data) {
  int index = 0;
  List<Widget> themesList = [];

  if (data.themes != null) {
    for (var x in data.themes) {
      if (data.themes.length > 1 && index == 0 ||
          index < data.themes.length - 1) {
        themesList.add(
          Text(x['name']),
        );

        themesList.add(const Text("—"));
      } else {
        themesList.add(
          Text(x['name']),
        );
      }

      index += 1;
    }
  } else {
    themesList.add(
      Text(
        "Unknown",
        style: TextStyle(color: Colors.grey.shade600),
      ),
    );
  }

  return themesList;
}

Widget getLanguageTable(data) {
  List<DataColumn> tableColumns = [
    const DataColumn(
      label: Text(
        "Language",
        style: TextStyle(color: Colors.white, fontFamily: 'RobotoBold'),
      ),
    ),
    const DataColumn(
      label: Text(
        "Interface",
        style: TextStyle(color: Colors.white, fontFamily: 'RobotoBold'),
      ),
    ),
    const DataColumn(
      label: Text(
        "Audio",
        style: TextStyle(color: Colors.white, fontFamily: 'RobotoBold'),
      ),
    ),
    const DataColumn(
      label: Text(
        "Subtitles",
        style: TextStyle(color: Colors.white, fontFamily: 'RobotoBold'),
      ),
    ),
  ];

  List<DataRow> tableRows = [];
  for (var x in data.language_support.entries) {
    List<DataCell> dataCells = [];
    dataCells.add(DataCell(
      Text(
        x.key,
        style: const TextStyle(color: Colors.white, fontFamily: 'HackRegular'),
      ),
    ));
    switch (x.value) {
      case ['Interface', 'Subtitles', 'Audio'] ||
            ['Interface', 'Audio', 'Subtitles'] ||
            ['Subtitles', 'Interface', 'Audio'] ||
            ['Subtitles', 'Audio', 'Interface'] ||
            ['Audio', 'Interface', 'Subtitles'] ||
            ['Audio', 'Subtitles', 'Interface']:
        dataCells.addAll([
          const DataCell(
            Icon(
              Icons.check,
              color: Colors.green,
            ),
          ),
          const DataCell(
            Icon(
              Icons.check,
              color: Colors.green,
            ),
          ),
          const DataCell(
            Icon(
              Icons.check,
              color: Colors.green,
            ),
          ),
        ]);
        tableRows.add(DataRow(cells: dataCells));
      case ['Interface', 'Audio'] || ['Audio', 'Interface']:
        dataCells.addAll([
          const DataCell(
            Icon(
              Icons.check,
              color: Colors.green,
            ),
          ),
          const DataCell(
            Icon(
              Icons.check,
              color: Colors.green,
            ),
          ),
          const DataCell(
            Icon(
              Icons.clear,
              color: Colors.red,
            ),
          ),
        ]);
        tableRows.add(DataRow(cells: dataCells));
      case ["Interface", "Subtitles"] || ["Subtitles", "Interface"]:
        dataCells.addAll([
          const DataCell(
            Icon(
              Icons.check,
              color: Colors.green,
            ),
          ),
          const DataCell(
            Icon(
              Icons.clear,
              color: Colors.red,
            ),
          ),
          const DataCell(
            Icon(
              Icons.check,
              color: Colors.green,
            ),
          ),
        ]);
        tableRows.add(DataRow(cells: dataCells));
      case ["Audio", "Subtitles"] || ["Subtitles", "Audio"]:
        dataCells.addAll([
          const DataCell(
            Icon(
              Icons.clear,
              color: Colors.red,
            ),
          ),
          const DataCell(
            Icon(
              Icons.check,
              color: Colors.green,
            ),
          ),
          const DataCell(
            Icon(
              Icons.check,
              color: Colors.green,
            ),
          ),
        ]);
        tableRows.add(DataRow(cells: dataCells));
      case ["Interface"]:
        dataCells.addAll([
          const DataCell(
            Icon(
              Icons.check,
              color: Colors.green,
            ),
          ),
          const DataCell(
            Icon(
              Icons.clear,
              color: Colors.red,
            ),
          ),
          const DataCell(
            Icon(
              Icons.clear,
              color: Colors.red,
            ),
          ),
        ]);
        tableRows.add(DataRow(cells: dataCells));
      case ["Audio"]:
        dataCells.addAll([
          const DataCell(
            Icon(
              Icons.clear,
              color: Colors.red,
            ),
          ),
          const DataCell(
            Icon(
              Icons.check,
              color: Colors.green,
            ),
          ),
          const DataCell(
            Icon(
              Icons.clear,
              color: Colors.red,
            ),
          ),
        ]);
        tableRows.add(DataRow(cells: dataCells));
      case ["Subtitles"]:
        dataCells.addAll([
          const DataCell(
            Icon(
              Icons.clear,
              color: Colors.red,
            ),
          ),
          const DataCell(
            Icon(
              Icons.clear,
              color: Colors.red,
            ),
          ),
          const DataCell(
            Icon(
              Icons.check,
              color: Colors.green,
            ),
          ),
        ]);
        tableRows.add(DataRow(cells: dataCells));
    }
  }
  Widget languageTable = DataTable(columns: tableColumns, rows: tableRows);

  return languageTable;
}

Widget getWebsitesList(data) {
  List<Widget> webSitesList = [];
  Column webSitesColumn = const Column();
  if (data.websites != null) {
    for (var x in data.websites) {
      webSitesList.add(
        InkWell(
          onTap: () {
            launchUrl(
              Uri.parse(x['url']),
            );
          },
          child: Text(
            "${x['url']}",
            style: const TextStyle(color: Colors.lightBlue),
          ),
        ),
      );
      webSitesList.add(const Divider());
      webSitesColumn = Column(
        children: webSitesList,
      );
    }
  }

  return webSitesColumn;
}

Widget getRating(data) {
  var metaRating = data.aggregated_rating;
  var userRating = data.rating;
  Color metaRatingColor = Colors.transparent;
  Color userRatingColor = Colors.transparent;
  String metaRatingText = "";
  String userRatingText = "";
  if (metaRating == null) {
    metaRatingColor = Colors.grey;
    metaRatingText = "N/A";
    metaRating = 0;
  } else if (metaRating < 20) {
    metaRatingColor = Colors.red;
    metaRatingText = "Bad";
  } else if (metaRating >= 20 && metaRating < 50) {
    metaRatingColor = Colors.orange;
    metaRatingText = "Unlikely";
  } else if (metaRating >= 50 && metaRating < 75) {
    metaRatingColor = Colors.yellow;
    metaRatingText = "Average";
  } else if (metaRating >= 75 && metaRating < 90) {
    metaRatingColor = Colors.lightGreen;
    metaRatingText = "Good";
  } else if (metaRating >= 90) {
    metaRatingColor = Colors.green;
    metaRatingText = "Great";
  }
  if (userRating == null) {
    userRatingColor = Colors.grey;
    userRatingText = "N/A";
    userRating = 0;
  } else if (userRating < 20) {
    userRatingColor = Colors.red;
    userRatingText = "Bad";
  } else if (userRating >= 20 && userRating < 50) {
    userRatingColor = Colors.orange;
    userRatingText = "Unlikely";
  } else if (userRating >= 50 && userRating < 75) {
    userRatingColor = Colors.yellow;
    userRatingText = "Average";
  } else if (userRating >= 75 && userRating < 90) {
    userRatingColor = Colors.lightGreen;
    userRatingText = "Good";
  } else if (userRating >= 90) {
    userRatingColor = Colors.green;
    userRatingText = "Great";
  }
  Widget ratingWidget = Column(
    children: [
      const Text("Meta Ratings", style: TextStyle(fontSize: 16)),
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Stack(
          children: [
            Stack(
              children: [
                SizedBox(
                  height: 100,
                  width: 100,
                  child: CircularProgressIndicator(
                    value: 1,
                    color: Colors.white.withAlpha(50),
                    strokeWidth: 12,
                  ),
                ),
                SizedBox(
                  height: 100,
                  width: 100,
                  child: CircularProgressIndicator(
                    value: metaRating / 100,
                    color: metaRatingColor,
                    strokeWidth: 12,
                    strokeCap: StrokeCap.round,
                  ),
                ),
              ],
            ),
            Positioned.fill(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "$metaRating",
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 25),
                    ),
                    Text(metaRatingText,
                        style: TextStyle(color: metaRatingColor)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      const Text("User Ratings", style: TextStyle(fontSize: 16)),
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Stack(
          children: [
            Stack(
              children: [
                SizedBox(
                  height: 100,
                  width: 100,
                  child: CircularProgressIndicator(
                    value: 1,
                    color: Colors.white.withAlpha(50),
                    strokeWidth: 12,
                  ),
                ),
                SizedBox(
                  height: 100,
                  width: 100,
                  child: CircularProgressIndicator(
                    value: userRating / 100,
                    color: userRatingColor,
                    strokeWidth: 12,
                    strokeCap: StrokeCap.round,
                  ),
                ),
              ],
            ),
            Positioned.fill(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "$userRating",
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 25),
                    ),
                    Text(userRatingText,
                        style: TextStyle(color: userRatingColor)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ],
  );
  return ratingWidget;
}

Widget getIcons(data) {
  List<Widget> storeIcons = [];
  if (data.websites != null) {
    for (var x in data.websites) {
      if (x['url'].contains("store.steampowered.com")) {
        storeIcons.add(
          Tooltip(
            message: "Steam",
            child: Card(
              color: Colors.grey.withOpacity(0.3),
              child: IconButton(
                icon: SvgPicture.asset(
                  "assets/images/steam.svg",
                  height: 24,
                  width: 24,
                ),
                onPressed: () {
                  launchUrl(Uri.parse(x['url']));
                },
              ),
            ),
          ),
        );
      }
      if (x['url'].contains("www.epicgames.com")) {
        storeIcons.add(
          Tooltip(
            message: "Epic Games",
            child: Card(
              color: Colors.grey.withOpacity(0.3),
              child: IconButton(
                icon: SvgPicture.asset(
                  "assets/images/epic-games.svg",
                  height: 24,
                  width: 24,
                ),
                onPressed: () {
                  launchUrl(Uri.parse(x['url']));
                },
              ),
            ),
          ),
        );
      }
    }
  }
  storeIcons.sort(
    (a, b) => a.toString().compareTo(b.toString()),
  );
  return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: storeIcons.reversed.toList());
}
