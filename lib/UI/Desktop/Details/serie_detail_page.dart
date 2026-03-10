import 'dart:convert';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:vault/Data/Model/serie_model.dart';
import 'package:vault/Helper/rating_helper.dart';
import 'package:vault/Helper/content_type.dart';
import 'package:vault/Helper/theme_helper.dart';
import 'package:vault/Logic/seriespage_logic.dart';
import 'package:vault/UI/Desktop/Details/actors_detail_page.dart';
import 'package:vault/Providers/library_provider.dart';
import 'package:vault/Widgets/custom_app_window.dart';
import 'package:provider/provider.dart';

class SerieDetailPage extends StatefulWidget {
  final int serieID;
  const SerieDetailPage({
    super.key,
    required this.serieID,
  });

  @override
  State<SerieDetailPage> createState() => _SerieDetailPageState();
}

class _SerieDetailPageState extends State<SerieDetailPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    int themeColor = Provider.of<ThemeProvider>(context).color;
    final pageController3 = PageController(initialPage: 0);
    return FutureBuilder<List<SerieModel>>(
        future: SeriesPageLogic().getSerieDetails(widget.serieID),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            var data = snapshot.data![0];
            String? tagline = data.tagline;
            String? overview = data.overview;
            tagline = utf8
                .decode(data.tagline.toString().runes.toList(),
                    allowMalformed: true)
                .replaceAll("�", "");
            overview = utf8
                .decode(data.overview.toString().runes.toList(),
                    allowMalformed: true)
                .replaceAll("�", "");
            return Consumer<LibraryProvider>(
              builder: (context, libraryProvider, child) {
                final isLiked = libraryProvider.isInLibrary(
                  ContentType.series,
                  widget.serieID,
                );
                return Scaffold(
                  // appBar: AppBar(
                  //   title: const Text("Serie Details"),
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
                        image: NetworkImage(data.imageURL.toString()),
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
                                                            Radius.circular(
                                                                12)),
                                                    child: Image(
                                                        image: NetworkImage(data
                                                            .imageURL
                                                            .toString()),
                                                        fit: BoxFit.fill),
                                                  ),
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    right: 16.0),
                                                child: Card(
                                                  color: Colors.grey
                                                      .withValues(alpha: 0.2),
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
                                                              Icons.favorite,
                                                              color: Color(
                                                                  themeColor),
                                                            ),
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
                                                          ContentType.series,
                                                          widget.serieID,
                                                        );
                                                      } else {
                                                        libraryProvider
                                                            .addOrUpdateItem(
                                                          type: ContentType
                                                              .series,
                                                          id: widget.serieID,
                                                          title: data.name,
                                                          imageUrl:
                                                              data.imageURL,
                                                          extra: {
                                                            "id":
                                                                widget.serieID,
                                                            "type": "serie",
                                                            "title": data.name,
                                                            "imageURL":
                                                                data.imageURL,
                                                            "folder": "library",
                                                          },
                                                        );
                                                      }
                                                    },
                                                  ),
                                                ),
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
                                                  Text(
                                                    '${data.name}',
                                                    style: const TextStyle(
                                                        fontSize: 50,
                                                        fontFamily:
                                                            'RobotoBold'),
                                                  ),
                                                  Text(
                                                    tagline!,
                                                    style: TextStyle(
                                                        color: Colors
                                                            .grey.shade400),
                                                  ),
                                                  const Divider(
                                                      color:
                                                          Colors.transparent),
                                                  const Divider(
                                                      color:
                                                          Colors.transparent),
                                                  Text(
                                                    overview!,
                                                  ),
                                                  const Divider(
                                                      color:
                                                          Colors.transparent),
                                                  const Divider(
                                                      color:
                                                          Colors.transparent),
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
                                                          Text(
                                                            "First Air Date:",
                                                            style: TextStyle(
                                                              fontFamily:
                                                                  "RobotoLight",
                                                            ),
                                                          ),
                                                          Text(
                                                            "Genres:",
                                                            style: TextStyle(
                                                              fontFamily:
                                                                  "RobotoLight",
                                                            ),
                                                          ),
                                                          Text(
                                                            "Created By:",
                                                            style: TextStyle(
                                                              fontFamily:
                                                                  "RobotoLight",
                                                            ),
                                                          ),
                                                          Text(
                                                            "Type:",
                                                            style: TextStyle(
                                                              fontFamily:
                                                                  "RobotoLight",
                                                            ),
                                                          ),
                                                          Text(
                                                            "Status:",
                                                            style: TextStyle(
                                                              fontFamily:
                                                                  "RobotoLight",
                                                            ),
                                                          ),
                                                          Text(
                                                            "Seasons:",
                                                            style: TextStyle(
                                                              fontFamily:
                                                                  "RobotoLight",
                                                            ),
                                                          ),
                                                          Text(
                                                            "Episodes:",
                                                            style: TextStyle(
                                                              fontFamily:
                                                                  "RobotoLight",
                                                            ),
                                                          ),
                                                          Text(
                                                            "Production Companies:",
                                                            style: TextStyle(
                                                              fontFamily:
                                                                  "RobotoLight",
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      Expanded(
                                                        child: SizedBox(
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .only(
                                                                    left: 16),
                                                            child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Row(
                                                                  children: [
                                                                    Text(
                                                                      getFirstAirDate(
                                                                          data),
                                                                      style:
                                                                          const TextStyle(
                                                                        fontFamily:
                                                                            "RobotoLight",
                                                                      ),
                                                                    ),
                                                                  ],
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
                                                                        getGenreList(
                                                                            data),
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
                                                                        getCreatedByList(
                                                                            data),
                                                                  ),
                                                                ),
                                                                Row(
                                                                  children: [
                                                                    Text(
                                                                      data.type
                                                                          .toString(),
                                                                      style:
                                                                          const TextStyle(
                                                                        fontFamily:
                                                                            "RobotoLight",
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                                Row(
                                                                  children: [
                                                                    Text(
                                                                      data.status
                                                                          .toString(),
                                                                      style:
                                                                          const TextStyle(
                                                                        fontFamily:
                                                                            "RobotoLight",
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                                Row(
                                                                  children: [
                                                                    Text(
                                                                      data.number_of_seasons
                                                                          .toString(),
                                                                      style:
                                                                          const TextStyle(
                                                                        fontFamily:
                                                                            "RobotoLight",
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                                Row(
                                                                  children: [
                                                                    Text(
                                                                      data.number_of_episodes
                                                                          .toString(),
                                                                      style:
                                                                          const TextStyle(
                                                                        fontFamily:
                                                                            "RobotoLight",
                                                                      ),
                                                                    ),
                                                                  ],
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
                                                                        getCompanyList(
                                                                            data),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            top: 100),
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        const Padding(
                                                          padding: EdgeInsets
                                                              .symmetric(
                                                                  vertical:
                                                                      16.0),
                                                          child: Text("Cast",
                                                              style: TextStyle(
                                                                  fontFamily:
                                                                      'RobotoBold',
                                                                  fontSize:
                                                                      24)),
                                                        ),
                                                        SizedBox(
                                                          height: 350,
                                                          child:
                                                              ListView.builder(
                                                            scrollDirection:
                                                                Axis.horizontal,
                                                            itemCount: data
                                                                .credits![
                                                                    'cast']
                                                                .length,
                                                            itemBuilder:
                                                                (context,
                                                                    index) {
                                                              var starPhoto =
                                                                  data.credits![
                                                                              'cast']
                                                                          [
                                                                          index]
                                                                      [
                                                                      'profile_path'];

                                                              if (starPhoto !=
                                                                  null) {
                                                                starPhoto =
                                                                    starPhoto
                                                                        .substring(
                                                                            1);
                                                              }
                                                              return Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .only(
                                                                        right:
                                                                            16.0),
                                                                child:
                                                                    GestureDetector(
                                                                  onTap: () {
                                                                    Navigator
                                                                        .push(
                                                                      context,
                                                                      MaterialPageRoute(
                                                                        builder:
                                                                            (context) =>
                                                                                ActorDetailPage(actorID: data.credits!['cast'][index]['id']),
                                                                      ),
                                                                    );
                                                                  },
                                                                  child:
                                                                      Container(
                                                                    width: 160,
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              12),
                                                                      border: Border.all(
                                                                          color:
                                                                              Colors.white10),
                                                                    ),
                                                                    child:
                                                                        Column(
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .start,
                                                                      children: [
                                                                        Expanded(
                                                                          child:
                                                                              ClipRRect(
                                                                            borderRadius:
                                                                                const BorderRadius.vertical(top: Radius.circular(12)),
                                                                            child: starPhoto != null
                                                                                ? Image.network(
                                                                                    "https://image.tmdb.org/t/p/w500/$starPhoto",
                                                                                    fit: BoxFit.cover,
                                                                                    width: double.infinity,
                                                                                    errorBuilder: (context, error, stackTrace) => const Center(child: Icon(Icons.person, size: 50, color: Colors.white24)),
                                                                                  )
                                                                                : const Center(child: Icon(Icons.person, size: 50, color: Colors.white24)),
                                                                          ),
                                                                        ),
                                                                        Padding(
                                                                          padding: const EdgeInsets
                                                                              .all(
                                                                              8.0),
                                                                          child:
                                                                              Column(
                                                                            crossAxisAlignment:
                                                                                CrossAxisAlignment.start,
                                                                            children: [
                                                                              Text(
                                                                                data.credits!['cast'][index]['name'] ?? "",
                                                                                maxLines: 1,
                                                                                overflow: TextOverflow.ellipsis,
                                                                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                                                              ),
                                                                              Text(
                                                                                data.credits!['cast'][index]['character'] ?? "",
                                                                                maxLines: 1,
                                                                                overflow: TextOverflow.ellipsis,
                                                                                style: const TextStyle(color: Colors.grey, fontSize: 12),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ),
                                                              );
                                                            },
                                                          ),
                                                        ),
                                                      ],
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
                                                                  vertical:
                                                                      16.0),
                                                          child: Text("Crew",
                                                              style: TextStyle(
                                                                  fontFamily:
                                                                      'RobotoBold',
                                                                  fontSize:
                                                                      24)),
                                                        ),
                                                        SizedBox(
                                                          height: 300,
                                                          child:
                                                              ListView.builder(
                                                            scrollDirection:
                                                                Axis.horizontal,
                                                            itemCount: data
                                                                .credits![
                                                                    'crew']
                                                                .length,
                                                            itemBuilder:
                                                                (context,
                                                                    index) {
                                                              var starPhoto =
                                                                  data.credits![
                                                                              'crew']
                                                                          [
                                                                          index]
                                                                      [
                                                                      'profile_path'];

                                                              if (starPhoto !=
                                                                  null) {
                                                                starPhoto =
                                                                    starPhoto
                                                                        .substring(
                                                                            1);
                                                              }
                                                              return Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .only(
                                                                        right:
                                                                            16.0),
                                                                child:
                                                                    GestureDetector(
                                                                  onTap: () {
                                                                    Navigator
                                                                        .push(
                                                                      context,
                                                                      MaterialPageRoute(
                                                                        builder:
                                                                            (context) =>
                                                                                ActorDetailPage(actorID: data.credits!['crew'][index]['id']),
                                                                      ),
                                                                    );
                                                                  },
                                                                  child:
                                                                      Container(
                                                                    width: 160,
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              12),
                                                                      border: Border.all(
                                                                          color:
                                                                              Colors.white10),
                                                                    ),
                                                                    child:
                                                                        Column(
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .start,
                                                                      children: [
                                                                        Expanded(
                                                                          child:
                                                                              ClipRRect(
                                                                            borderRadius:
                                                                                const BorderRadius.vertical(top: Radius.circular(12)),
                                                                            child: starPhoto != null
                                                                                ? Image.network(
                                                                                    "https://image.tmdb.org/t/p/w500/$starPhoto",
                                                                                    fit: BoxFit.cover,
                                                                                    width: double.infinity,
                                                                                    errorBuilder: (context, error, stackTrace) => const Center(child: Icon(Icons.person, size: 50, color: Colors.white24)),
                                                                                  )
                                                                                : const Center(child: Icon(Icons.person, size: 50, color: Colors.white24)),
                                                                          ),
                                                                        ),
                                                                        Padding(
                                                                          padding: const EdgeInsets
                                                                              .all(
                                                                              8.0),
                                                                          child:
                                                                              Column(
                                                                            crossAxisAlignment:
                                                                                CrossAxisAlignment.start,
                                                                            children: [
                                                                              Text(
                                                                                data.credits!['crew'][index]['name'] ?? "",
                                                                                maxLines: 1,
                                                                                overflow: TextOverflow.ellipsis,
                                                                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                                                              ),
                                                                              Text(
                                                                                data.credits!['crew'][index]['job'] ?? "",
                                                                                maxLines: 1,
                                                                                overflow: TextOverflow.ellipsis,
                                                                                style: const TextStyle(color: Colors.grey, fontSize: 12),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ),
                                                              );
                                                            },
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            top: 16),
                                                    child: Card(
                                                      color: Colors.grey
                                                          .withValues(
                                                              alpha: 0.2),
                                                      child: Theme(
                                                        data: ThemeData(
                                                          highlightColor: Colors
                                                              .transparent,
                                                          hoverColor: Colors
                                                              .transparent,
                                                          splashColor: Colors
                                                              .transparent,
                                                        ),
                                                        child: ExpansionTile(
                                                          textColor:
                                                              Colors.white,
                                                          collapsedTextColor:
                                                              Colors.white,
                                                          collapsedIconColor:
                                                              Colors.white,
                                                          iconColor:
                                                              Colors.white,
                                                          title: const Text(
                                                              "Images (May contain spoilers)",
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
                                                                      color: Colors
                                                                          .white,
                                                                    ),
                                                                    onPressed:
                                                                        () {
                                                                      pageController3
                                                                          .previousPage(
                                                                        duration:
                                                                            const Duration(milliseconds: 500),
                                                                        curve: Curves
                                                                            .ease,
                                                                      );
                                                                    },
                                                                  ),
                                                                  Expanded(
                                                                    child:
                                                                        SizedBox(
                                                                      height:
                                                                          600,
                                                                      width:
                                                                          800,
                                                                      child: PageView
                                                                          .builder(
                                                                        controller:
                                                                            pageController3,
                                                                        itemCount: data
                                                                            .images
                                                                            ?.length,
                                                                        scrollDirection:
                                                                            Axis.horizontal,
                                                                        itemBuilder:
                                                                            (context,
                                                                                index) {
                                                                          var filePath =
                                                                              data.images![index]['file_path'];
                                                                          return Padding(
                                                                            padding:
                                                                                const EdgeInsets.all(16.0),
                                                                            child:
                                                                                ClipRRect(
                                                                              borderRadius: const BorderRadius.all(Radius.circular(12)),
                                                                              child: Image(
                                                                                fit: BoxFit.fill,
                                                                                image: NetworkImage("https://image.tmdb.org/t/p/original/${filePath?.substring(1)}"),
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
                                                                      color: Colors
                                                                          .white,
                                                                    ),
                                                                    onPressed:
                                                                        () {
                                                                      pageController3
                                                                          .nextPage(
                                                                        duration:
                                                                            const Duration(milliseconds: 500),
                                                                        curve: Curves
                                                                            .ease,
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
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                        TableCell(
                                          child: Column(
                                            children: [
                                              Container(
                                                height: 350,
                                                width: double.maxFinite,
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
                                                    children: [
                                                      RatingHelper.getRating(
                                                          data)
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              getIcons(data)
                                            ],
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
              },
            );
          } else {
            bool connectionBool = true;
            if (snapshot.connectionState == ConnectionState.done) {
              connectionBool = false;
            }
            return Scaffold(
              appBar: AppBar(
                title: const Text("Serie Details"),
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
                                    setState(() {});
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

String getFirstAirDate(data) {
  String date = data.first_air_date;
  String day = date.substring(8);
  date = date.substring(0, 7);
  String month = date.substring(5);
  date = date.substring(0, 4);
  String year = date;
  switch (month) {
    case "01":
      month = "January";
    case "02":
      month = "February";
    case "03":
      month = "March";
    case "04":
      month = "April";
    case "05":
      month = "May";
    case "06":
      month = "June";
    case "07":
      month = "July";
    case "08":
      month = "August";
    case "09":
      month = "September";
    case "10":
      month = "October";
    case "11":
      month = "November";
    case "12":
      month = "December";
  }
  return "$day $month $year";
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

        genreList.add(const Text(
          "—",
          style: TextStyle(
            fontFamily: "RobotoLight",
          ),
        ));
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

List<Widget> getCompanyList(data) {
  int index = 0;
  List<Widget> companyList = [];

  if (data.genres != null) {
    for (var x in data.production_companies) {
      if (data.production_companies.length > 1 && index == 0 ||
          index < data.production_companies.length - 1) {
        companyList.add(
          Text(
            x['name'],
            style: const TextStyle(
              fontFamily: "RobotoLight",
            ),
          ),
        );

        companyList.add(const Text(
          "—",
          style: TextStyle(
            fontFamily: "RobotoLight",
          ),
        ));
      } else {
        companyList.add(
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
    companyList.add(
      Text(
        "Unknown",
        style:
            TextStyle(fontFamily: "RobotoLight", color: Colors.grey.shade600),
      ),
    );
  }

  return companyList;
}

List<Widget> getCreatedByList(data) {
  int index = 0;
  List<Widget> createdByList = [];

  if (data.genres != null) {
    for (var x in data.created_by) {
      if (data.created_by.length > 1 && index == 0 ||
          index < data.created_by.length - 1) {
        createdByList.add(
          Text(
            x['name'],
            style: const TextStyle(
              fontFamily: "RobotoLight",
            ),
          ),
        );

        createdByList.add(const Text(
          "—",
          style: TextStyle(
            fontFamily: "RobotoLight",
          ),
        ));
      } else {
        createdByList.add(
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
    createdByList.add(
      Text(
        "Unknown",
        style:
            TextStyle(fontFamily: "RobotoLight", color: Colors.grey.shade600),
      ),
    );
  }

  return createdByList;
}

Widget getIcons(data) {
  List<Widget> providerIcons = [];
  Set<String> providersSet = {};
  if (!data.providers.isEmpty) {
    for (var x in data.providers.entries) {
      if (x.value['flatrate'] != null) {
        for (var y in x.value['flatrate']) {
          if (!providersSet.contains(y['provider_name'])) {
            providerIcons.add(
              Tooltip(
                message: "${y['provider_name']}",
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Image(
                    height: 32,
                    width: 32,
                    image: CachedNetworkImageProvider(
                      "https://image.tmdb.org/t/p/w45${y['logo_path']}",
                    ),
                  ),
                ),
              ),
            );
          }
          providersSet.add(y['provider_name']);
        }
        return Card(
          color: Colors.transparent,
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(4.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  // crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: EdgeInsets.all(2.0),
                      child: Text("Available Platforms"),
                    ),
                    Padding(
                      padding: EdgeInsets.all(2.0),
                      child: Text(
                        "(Provided by JustWatch)",
                        style: TextStyle(fontSize: 9),
                      ),
                    )
                  ],
                ),
              ),
              Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: providerIcons),
            ],
          ),
        );
      }
    }
  }
  return const SizedBox();
}
