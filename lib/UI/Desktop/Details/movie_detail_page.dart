import 'dart:convert';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:vault/Data/Model/movie_model.dart';
import 'package:vault/Helper/rating_helper.dart';
import 'package:vault/Helper/content_type.dart';
import 'package:vault/Helper/theme_helper.dart';
import 'package:vault/Logic/moviepage_logic.dart';
import 'package:vault/UI/Desktop/Details/actors_detail_page.dart';
import 'package:vault/Providers/library_provider.dart';
import 'package:vault/Widgets/custom_app_window.dart';
import 'package:provider/provider.dart';

class MovieDetailPage extends StatefulWidget {
  final int movieID;
  const MovieDetailPage({
    super.key,
    required this.movieID,
  });

  @override
  State<MovieDetailPage> createState() => _MovieDetailPageState();
}

class _MovieDetailPageState extends State<MovieDetailPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    int themeColor = Provider.of<ThemeProvider>(context).color;
    return FutureBuilder<List<MovieModel>>(
        future: MoviePageLogic().getMovieDetails(widget.movieID),
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
                  ContentType.movies,
                  widget.movieID,
                );
                return Scaffold(
                  // appBar: AppBar(
                  //   title: const Text("Movie Details"),
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
                                                      .withValues(alpha: 0.3),
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
                                                          ContentType.movies,
                                                          widget.movieID,
                                                        );
                                                      } else {
                                                        libraryProvider
                                                            .addOrUpdateItem(
                                                          type: ContentType
                                                              .movies,
                                                          id: widget.movieID,
                                                          title: data.title,
                                                          imageUrl:
                                                              data.imageURL,
                                                          extra: {
                                                            "id":
                                                                widget.movieID,
                                                            "type": "movie",
                                                            "title": data.title,
                                                            "imageURL":
                                                                data.imageURL,
                                                            "folder": "library",
                                                          },
                                                        );
                                                      }
                                                    },
                                                  ),
                                                ),
                                              ),
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
                                                  Text('${data.title}',
                                                      style: const TextStyle(
                                                          fontSize: 50,
                                                          fontFamily:
                                                              'RobotoBold')),
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
                                                  Text(overview!),
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
                                                            "Release Date:",
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
                                                            "Production Companies:",
                                                            style: TextStyle(
                                                              fontFamily:
                                                                  "RobotoLight",
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(left: 16),
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Row(
                                                              children: [
                                                                Text(
                                                                  getReleaseDate(
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
                                                                    getCompanyList(
                                                                        data),
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
                                                          height: 300,
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
                                                                                data.credits!['crew'][index]['name'],
                                                                                maxLines: 1,
                                                                                overflow: TextOverflow.ellipsis,
                                                                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                                                              ),
                                                                              Text(
                                                                                data.credits!['crew'][index]['job'],
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
                                                          child: Text(
                                                              "Images (May contain spoilers)",
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
                                                                .images?.length,
                                                            itemBuilder:
                                                                (context,
                                                                    index) {
                                                              if (data.images ==
                                                                  []) {
                                                                return const Center(
                                                                  child: Text(
                                                                      "Nothing Here"),
                                                                );
                                                              } else {
                                                                var filePath =
                                                                    data.images![
                                                                            index]
                                                                        [
                                                                        'file_path'];
                                                                return Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .only(
                                                                          right:
                                                                              16.0),
                                                                  child:
                                                                      ClipRRect(
                                                                    borderRadius:
                                                                        const BorderRadius
                                                                            .all(
                                                                            Radius.circular(12)),
                                                                    child: Image
                                                                        .network(
                                                                      "https://image.tmdb.org/t/p/w500/${filePath?.substring(1)}",
                                                                      fit: BoxFit
                                                                          .cover,
                                                                    ),
                                                                  ),
                                                                );
                                                              }
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
                                              getIcons(data),
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
                title: const Text("Movie Details"),
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

String getReleaseDate(data) {
  String date = data.release_date;
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
        genreList.add(Text(
          x['name'],
          style: const TextStyle(
            fontFamily: "RobotoLight",
          ),
        ));

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
        style: TextStyle(
          fontFamily: "RobotoLight",
          color: Colors.grey.shade600,
        ),
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
        companyList.add(
          const Text(
            "—",
            style: TextStyle(
              fontFamily: "RobotoLight",
            ),
          ),
        );
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
