import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:vault/Data/Model/game_model.dart';
import 'package:vault/Helper/rating_helper.dart';
import 'package:vault/Helper/theme_helper.dart';
import 'package:vault/Logic/gamepage_logic.dart';
import 'package:vault/Widgets/custom_app_window.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vault/Providers/library_provider.dart';
import 'package:vault/Helper/content_type.dart';

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
  // User? user = FirebaseAuth.instance.currentUser; // Removed as part of cleanup
  // bool isLiked = false; // Managed by Provider
  bool isFavorited = false;
  String? connectionText;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    int themeColor = Provider.of<ThemeProvider>(context).color;
    // Removed getData and updateData functions
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

            // Simplified FutureBuilder replacement with Consumer
            return Consumer<LibraryProvider>(
                builder: (context, libraryProvider, child) {
              bool isLiked =
                  libraryProvider.isInLibrary(ContentType.games, widget.gameID);

              return Scaffold(
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
                    color: Colors.black.withValues(alpha: 0.7),
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: 45,
                              width: MediaQuery.of(context).size.width,
                              child: CustomAppWindow(isExitable: true),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.fromLTRB(64, 96, 64, 48),
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
                                                      const BorderRadius.all(
                                                          Radius.circular(12)),
                                                  child: Image(
                                                      image: NetworkImage(
                                                          "https://images.igdb.com/igdb/image/upload/t_original/$imageId.png"),
                                                      fit: BoxFit.fill),
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  right: 16.0),
                                              child: StatefulBuilder(
                                                  builder: (context, setState) {
                                                return Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Card(
                                                      color: Colors.grey
                                                          .withValues(
                                                              alpha: 0.3),
                                                      child: IconButton(
                                                        highlightColor:
                                                            Color(themeColor),
                                                        hoverColor:
                                                            Colors.transparent,
                                                        icon: isLiked
                                                            ? Tooltip(
                                                                message:
                                                                    "Remove from Library",
                                                                child: Icon(
                                                                    Icons
                                                                        .favorite,
                                                                    color: Color(
                                                                        themeColor)),
                                                              )
                                                            : const Tooltip(
                                                                message:
                                                                    "Add to Library",
                                                                child: Icon(Icons
                                                                    .favorite_outline),
                                                              ),
                                                        onPressed: () {
                                                          if (isLiked) {
                                                            libraryProvider
                                                                .removeFromLibrary(
                                                              ContentType.games,
                                                              widget.gameID,
                                                            );
                                                          } else {
                                                            libraryProvider
                                                                .addOrUpdateItem(
                                                              type: ContentType
                                                                  .games,
                                                              id: widget.gameID,
                                                              title: data.name,
                                                              imageUrl:
                                                                  "https://images.igdb.com/igdb/image/upload/t_original/$imageId.png",
                                                              extra: {
                                                                "id": widget
                                                                    .gameID,
                                                                "type": "game",
                                                                "title":
                                                                    data.name,
                                                                "imageURL":
                                                                    "https://images.igdb.com/igdb/image/upload/t_original/$imageId.png",
                                                                "folder":
                                                                    "library",
                                                              },
                                                            );
                                                          }
                                                          // setState handled by Consumer
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
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 64),
                                          child: SizedBox(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text('${data.name}',
                                                    style: const TextStyle(
                                                        fontSize: 50,
                                                        fontFamily:
                                                            'RobotoBold')),
                                                Text(dateTime,
                                                    style: TextStyle(
                                                        color: Colors
                                                            .grey.shade400)),
                                                const Divider(
                                                    color: Colors.transparent),
                                                const Divider(
                                                    color: Colors.transparent),
                                                Text(
                                                  summary!,
                                                  style: const TextStyle(
                                                    fontFamily: "RobotoMedium",
                                                  ),
                                                ),
                                                const Divider(
                                                    color: Colors.transparent),
                                                const Divider(
                                                    color: Colors.transparent),
                                                Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    const Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          "Genres:",
                                                          style: TextStyle(
                                                            fontFamily:
                                                                "RobotoLight",
                                                          ),
                                                        ),
                                                        Text(
                                                          "Tags:",
                                                          style: TextStyle(
                                                            fontFamily:
                                                                "RobotoLight",
                                                          ),
                                                        ),
                                                        Text(
                                                          "Developers:",
                                                          style: TextStyle(
                                                            fontFamily:
                                                                "RobotoLight",
                                                          ),
                                                        ),
                                                        Text(
                                                          "Publishers:",
                                                          style: TextStyle(
                                                            fontFamily:
                                                                "RobotoLight",
                                                          ),
                                                        ),
                                                        Text(
                                                          "Platforms:",
                                                          style: TextStyle(
                                                            fontFamily:
                                                                "RobotoLight",
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
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
                                                              children: devList,
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
                                                      const EdgeInsets.only(
                                                          top: 100),
                                                  child: Card(
                                                    color: Colors.grey
                                                        .withValues(alpha: 0.2),
                                                    child: Theme(
                                                      data: ThemeData(
                                                        highlightColor:
                                                            Colors.transparent,
                                                        hoverColor:
                                                            Colors.transparent,
                                                        splashColor:
                                                            Colors.transparent,
                                                      ),
                                                      child: ExpansionTile(
                                                        textColor: Colors.white,
                                                        collapsedTextColor:
                                                            Colors.white,
                                                        collapsedIconColor:
                                                            Colors.white,
                                                        iconColor: Colors.white,
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
                                                                    .all(24.0),
                                                            child: Text(
                                                              storyline!,
                                                              style:
                                                                  const TextStyle(
                                                                fontFamily:
                                                                    "RobotoLight",
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 16),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      const Padding(
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                                vertical: 16.0),
                                                        child: Text(
                                                            "Screenshots",
                                                            style: TextStyle(
                                                                fontFamily:
                                                                    'RobotoBold',
                                                                fontSize: 24)),
                                                      ),
                                                      SizedBox(
                                                        height: 250,
                                                        child: ListView.builder(
                                                          scrollDirection:
                                                              Axis.horizontal,
                                                          itemCount: data
                                                                  .screenshots_list
                                                                  ?.length ??
                                                              0,
                                                          itemBuilder:
                                                              (context, index) {
                                                            var imageId =
                                                                data.screenshots_list![
                                                                    index];
                                                            return Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .only(
                                                                      right:
                                                                          16.0),
                                                              child: ClipRRect(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            12),
                                                                child: Image
                                                                    .network(
                                                                  "https://images.igdb.com/igdb/image/upload/t_screenshot_med/$imageId.png",
                                                                  fit: BoxFit
                                                                      .cover,
                                                                ),
                                                              ),
                                                            );
                                                          },
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      TableCell(
                                        child: Container(
                                          color: Colors.transparent,
                                          child: Card(
                                            color: Colors.transparent,
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                RatingHelper.getRating(data),
                                                const SizedBox(height: 32),
                                                const Text("Language Support",
                                                    style: TextStyle(
                                                        fontFamily:
                                                            'RobotoBold',
                                                        fontSize: 20)),
                                                const SizedBox(height: 16),
                                                getLanguageTable(data),
                                                const SizedBox(height: 32),
                                                const Text("Websites",
                                                    style: TextStyle(
                                                        fontFamily:
                                                            'RobotoBold',
                                                        fontSize: 20)),
                                                const SizedBox(height: 16),
                                                getWebsitesList(data),
                                              ],
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
                      ? Skeletonizer(
                          enabled: true,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  height: 220,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.06),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                const Text('Loading title'),
                                const SizedBox(height: 8),
                                const Text('Loading subtitle'),
                              ],
                            ),
                          ),
                        )
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
            child: Text(
              "${x['name']}",
              style: const TextStyle(
                fontFamily: "RobotoLight",
              ),
            ),
          ),
        );

        platformList.add(const Text(
          "—",
          style: TextStyle(
            fontFamily: "RobotoLight",
          ),
        ));
      } else {
        platformList.add(
          Text(
            x['name'],
            style: const TextStyle(
              fontFamily: "RobotoLight",
            ),
          ),
        );
      }
      index += 1;
    }
  } else {
    platformList.add(
      Text(
        "Unknown",
        style: TextStyle(
          fontFamily: "RobotoLight",
          color: Colors.grey.shade600,
        ),
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
            Text(
              x['company']['name'],
              style: const TextStyle(
                fontFamily: "RobotoLight",
              ),
            ),
          );

          devList.add(const Text("—"));
        } else {
          devList.add(
            Text(
              x['company']['name'],
              style: const TextStyle(
                fontFamily: "RobotoLight",
              ),
            ),
          );
        }
        index += 1;
      }
    }
  } else {
    devList.add(
      Text(
        "Unknown",
        style:
            TextStyle(fontFamily: "RobotoLight", color: Colors.grey.shade600),
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
            Text(
              x['company']['name'],
              style: const TextStyle(
                fontFamily: "RobotoLight",
              ),
            ),
          );

          publisherList.add(const Text(
            "—",
            style: TextStyle(
              fontFamily: "RobotoLight",
            ),
          ));
        } else {
          publisherList.add(
            Text(
              x['company']['name'],
              style: const TextStyle(
                fontFamily: "RobotoLight",
              ),
            ),
          );
        }
        index += 1;
      }
    }
    if (publisherList.isEmpty) {
      publisherList.add(
        Text(
          "Unknown",
          style:
              TextStyle(fontFamily: "RobotoLight", color: Colors.grey.shade600),
        ),
      );
    }
  } else {
    publisherList.add(
      Text(
        "Unknown",
        style: TextStyle(
          fontFamily: "RobotoLight",
          color: Colors.grey.shade600,
        ),
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
          Text(
            x['name'],
            style: const TextStyle(
              fontFamily: "RobotoLight",
            ),
          ),
        );

        genreList.add(const Text("—"));
      } else {
        genreList.add(
          Text(
            x['name'],
            style: const TextStyle(
              fontFamily: "RobotoLight",
            ),
          ),
        );
      }

      index += 1;
    }
  } else {
    genreList.add(
      Text(
        "Unknown",
        style:
            TextStyle(fontFamily: "RobotoLight", color: Colors.grey.shade600),
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
          Text(
            x['name'],
            style: const TextStyle(
              fontFamily: "RobotoLight",
            ),
          ),
        );

        themesList.add(const Text(
          "—",
          style: TextStyle(
            fontFamily: "RobotoLight",
          ),
        ));
      } else {
        themesList.add(
          Text(
            x['name'],
            style: const TextStyle(
              fontFamily: "RobotoLight",
            ),
          ),
        );
      }

      index += 1;
    }
  } else {
    themesList.add(
      Text(
        "Unknown",
        style:
            TextStyle(fontFamily: "RobotoLight", color: Colors.grey.shade600),
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
  if (data.websites != null) {
    for (var x in data.websites) {
      String url = x['url'];
      if (url.contains("wikipedia")) continue;

      String label = "Website";
      IconData icon = Icons.link;

      if (url.contains("facebook")) {
        label = "Facebook";
        icon = Icons.facebook;
      } else if (url.contains("twitter") || url.contains("x.com")) {
        label = "Twitter";
        icon = Icons.alternate_email;
      } else if (url.contains("instagram")) {
        label = "Instagram";
        icon = Icons.camera_alt;
      } else if (url.contains("twitch")) {
        label = "Twitch";
        icon = Icons.videogame_asset;
      } else if (url.contains("reddit")) {
        label = "Reddit";
        icon = Icons.forum;
      } else if (url.contains("discord")) {
        label = "Discord";
        icon = Icons.chat;
      } else {
        try {
          var uri = Uri.parse(url);
          label = uri.host.replaceFirst("www.", "");
          if (label.isEmpty) label = "Link";
        } catch (e) {
          label = "Link";
        }
      }

      webSitesList.add(
        Padding(
          padding: const EdgeInsets.only(right: 8.0, bottom: 8.0),
          child: ActionChip(
            avatar: Icon(icon, size: 16, color: Colors.white70),
            label: Text(label, style: const TextStyle(color: Colors.white)),
            backgroundColor: Colors.white.withValues(alpha: 0.1),
            side: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
            onPressed: () {
              launchUrl(
                Uri.parse(url),
              );
            },
          ),
        ),
      );
    }
  }

  return Wrap(
    children: webSitesList,
  );
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
              color: Colors.grey.withValues(alpha: 0.3),
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
              color: Colors.grey.withValues(alpha: 0.3),
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
