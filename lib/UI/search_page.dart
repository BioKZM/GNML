import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:gnml/Data/Model/book_model.dart';
import 'package:gnml/Data/Model/game_model.dart';
import 'package:gnml/Helper/theme_helper.dart';
import 'package:gnml/Logic/actorpage_logic.dart';
import 'package:gnml/Logic/gamepage_logic.dart';
import 'package:gnml/Logic/moviepage_logic.dart';
import 'package:gnml/UI/Details/actors_detail_page.dart';
import 'package:gnml/UI/Details/books_detail_page.dart';
import 'package:gnml/UI/Details/game_detail_page.dart';
import 'package:gnml/UI/Details/movie_detail_page.dart';
import 'package:gnml/UI/Details/serie_detail_page.dart';
import 'package:gnml/Widgets/circularprogressindicator.dart';
import 'package:intl/intl.dart';
import 'package:gnml/Logic/seriespage_logic.dart';
import 'package:gnml/Logic/bookspage_logic.dart';
import 'package:provider/provider.dart';

enum Buttons { games, movies, series, actors, books }

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  User? user = FirebaseAuth.instance.currentUser;
  bool boolean = false;
  Buttons buttonView = Buttons.games;
  TextEditingController searchController = TextEditingController();
  String searchText = "";
  int pageIndexMovies = 1;
  int pageIndexSeries = 1;
  int pageIndexActors = 1;

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
      body: Column(
        children: [
          Card(
            elevation: 5,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 16, left: 16),
                  child: SegmentedButton<Buttons>(
                    showSelectedIcon: false,
                    segments: const <ButtonSegment<Buttons>>[
                      ButtonSegment<Buttons>(
                        value: Buttons.games,
                        label: Text("Games"),
                        icon: Icon(FluentIcons.games_24_filled),
                      ),
                      ButtonSegment<Buttons>(
                        value: Buttons.movies,
                        label: Text("Movies"),
                        icon: Icon(FluentIcons.movies_and_tv_24_filled),
                      ),
                      ButtonSegment<Buttons>(
                        value: Buttons.series,
                        label: Text("Series"),
                        icon: Icon(FluentIcons.video_clip_24_filled),
                      ),
                      ButtonSegment<Buttons>(
                        value: Buttons.actors,
                        label: Text("Actors"),
                        icon: Icon(FluentIcons.person_24_filled),
                      ),
                      ButtonSegment<Buttons>(
                        value: Buttons.books,
                        label: Text("Books"),
                        icon: Icon(FluentIcons.book_24_filled),
                      ),
                    ],
                    selected: <Buttons>{buttonView},
                    onSelectionChanged: (Set<Buttons> newSelection) {
                      setState(() {
                        buttonView = newSelection.first;
                        searchText = "";
                        searchController.clear();
                      });
                    },
                  ),
                ),
                Container(
                  constraints: const BoxConstraints(maxWidth: 500),
                  child: Padding(
                    padding:
                        const EdgeInsets.only(top: 4, bottom: 4, right: 16),
                    child: Card(
                      child: TextField(
                        controller: searchController,
                        decoration: InputDecoration(
                          labelText: 'Search',
                          hintText: '',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        onSubmitted: (value) {
                          setState(() {
                            searchText = value;
                          });
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 16),
              child: SizedBox(
                width: double.infinity,
                child: Card(
                  elevation: 5,
                  child: FutureBuilder(
                      future: getData(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.done) {
                          Map<String, dynamic> list =
                              snapshot.data!.data() as Map<String, dynamic>;
                          List gamesList = list['library']['games'];
                          List moviesList = list['library']['movies'];
                          List seriesList = list['library']['series'];
                          List booksList = list['library']['books'];
                          List actorsList = list['library']['actors'];
                          return StatefulBuilder(builder: (context, snapshot) {
                            if (buttonView == Buttons.games) {
                              return FutureBuilder(
                                future: GamePageLogic().searchGames(searchText),
                                builder: (context, snapshot) {
                                  if (snapshot.hasData &&
                                      snapshot.connectionState ==
                                          ConnectionState.done) {
                                    var data = snapshot.data;
                                    return ListView.builder(
                                      itemCount: data?.length,
                                      itemBuilder: (context, index) {
                                        // ignore: prefer_typing_uninitialized_variables
                                        var dateTime;
                                        if (data![index].first_release_date ==
                                            0) {
                                          dateTime = "Unknown";
                                        } else {
                                          dateTime = DateTime
                                              .fromMillisecondsSinceEpoch(
                                                  data[index]
                                                          .first_release_date! *
                                                      1000);
                                          dateTime = DateFormat('yyyy')
                                              .format(dateTime);
                                        }

                                        List<Widget> platformsWidget = [];
                                        if (data[index].platforms != null) {
                                          for (var x = 0;
                                              x < data[index].platforms!.length;
                                              x++) {
                                            platformsWidget.add(
                                              Text(
                                                  "${data[index].platforms![x]['name']}"),
                                            );
                                            platformsWidget
                                                .add(const VerticalDivider());
                                          }
                                        }
                                        var gameID = 0;
                                        if (data[index].id != null) {
                                          gameID = data[index].id!;
                                        }

                                        return GestureDetector(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    GameDetailPage(
                                                        gameID: gameID),
                                              ),
                                            );
                                          },
                                          child: Column(
                                            children: [
                                              ListTile(
                                                leading: SizedBox(
                                                  width: 40,
                                                  height: double.maxFinite,
                                                  child: Image(
                                                    fit: BoxFit.fill,
                                                    image: NetworkImage(
                                                      """https://${data[index].url}""",
                                                    ),
                                                  ),
                                                ),
                                                title: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 4),
                                                  child: Text(
                                                    "${data[index].name.toString()} (${(dateTime.toString())})",
                                                    style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ),
                                                subtitle: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 4.0),
                                                      child: Wrap(
                                                          children:
                                                              platformsWidget),
                                                    ),
                                                    Row(
                                                      children: [
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  top: 4.0),
                                                          child:
                                                              gameCategoryCard(
                                                                  data[index]
                                                                      .category),
                                                        )
                                                      ],
                                                    )
                                                  ],
                                                ),
                                              ),
                                              const Divider()
                                            ],
                                          ),
                                        );
                                      },
                                    );
                                  } else if (!snapshot.hasData &&
                                      snapshot.connectionState ==
                                          ConnectionState.done) {
                                    return const Center(
                                      child: Text("No Result"),
                                    );
                                  } else {
                                    return const CustomCPI();
                                  }
                                },
                              );
                            } else if (buttonView == Buttons.movies) {
                              return StatefulBuilder(
                                builder: (context, setState) {
                                  return FutureBuilder<int>(
                                      future: MoviePageLogic()
                                          .getSearchResultsTotalPage(
                                              searchText),
                                      builder: (context, snapshot) {
                                        int? totalPages = snapshot.data;
                                        return FutureBuilder<List<dynamic>>(
                                          future: searchMovies(
                                              searchText, pageIndexMovies),
                                          builder: (context, snapshot) {
                                            var data = snapshot.data;

                                            if (snapshot.hasData &&
                                                snapshot.connectionState ==
                                                    ConnectionState.done) {
                                              return PageView.builder(
                                                itemBuilder: (context, index) {
                                                  return Column(
                                                    children: [
                                                      Expanded(
                                                        child: SizedBox(
                                                          child:
                                                              GridView.builder(
                                                            gridDelegate:
                                                                const SliverGridDelegateWithMaxCrossAxisExtent(
                                                              maxCrossAxisExtent:
                                                                  350,
                                                            ),
                                                            itemCount:
                                                                data?.length,
                                                            itemBuilder:
                                                                (context,
                                                                    innerIndex) {
                                                              ValueNotifier<
                                                                      bool>
                                                                  isHovering =
                                                                  ValueNotifier<
                                                                          bool>(
                                                                      false);
                                                              ValueNotifier<
                                                                      bool>
                                                                  isFavorite =
                                                                  ValueNotifier<
                                                                          bool>(
                                                                      false);
                                                              var movieID = 0;
                                                              if (data![innerIndex]
                                                                      .id !=
                                                                  null) {
                                                                movieID = data[
                                                                        innerIndex]
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
                                                                    Navigator
                                                                        .push(
                                                                      context,
                                                                      MaterialPageRoute(
                                                                        builder:
                                                                            (context) =>
                                                                                MovieDetailPage(movieID: movieID),
                                                                      ),
                                                                    );
                                                                  },
                                                                  child:
                                                                      Padding(
                                                                    padding:
                                                                        const EdgeInsets
                                                                            .all(
                                                                            8.0),
                                                                    child:
                                                                        Column(
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
                                                                                              borderRadius: const BorderRadius.only(
                                                                                                topLeft: Radius.circular(12),
                                                                                                topRight: Radius.circular(12),
                                                                                              ),
                                                                                              child: Image(
                                                                                                fit: BoxFit.fill,
                                                                                                image: NetworkImage(
                                                                                                  data[innerIndex].imageURL.toString(),
                                                                                                ),
                                                                                              ),
                                                                                            ),
                                                                                          ),
                                                                                        ),
                                                                                        Tooltip(
                                                                                          message: data[innerIndex].title,
                                                                                          child: SizedBox(
                                                                                            width: 180,
                                                                                            child: Column(
                                                                                              children: [
                                                                                                Padding(
                                                                                                  padding: const EdgeInsets.all(4.0),
                                                                                                  child: Text(
                                                                                                    data[innerIndex].title.toString(),
                                                                                                    softWrap: true,
                                                                                                    overflow: TextOverflow.ellipsis,
                                                                                                    textAlign: TextAlign.center,
                                                                                                  ),
                                                                                                ),
                                                                                                Padding(
                                                                                                  padding: const EdgeInsets.only(bottom: 4.0),
                                                                                                  child: Text(
                                                                                                    getMovieReleaseDate(data[innerIndex]),
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
                                                                                                    Map<String, dynamic> movieMap = {
                                                                                                      "movieID": data[innerIndex].id,
                                                                                                      "imageURL": data[innerIndex].imageURL.toString(),
                                                                                                      "movieName": data[innerIndex].title,
                                                                                                    };
                                                                                                    for (var x in moviesList) {
                                                                                                      if (x['movieID'] == data[innerIndex].id) {
                                                                                                        isFavorite.value = true;
                                                                                                      }
                                                                                                    }
                                                                                                    return isFavorite.value
                                                                                                        ? IconButton(
                                                                                                            highlightColor: Color(themeColor),
                                                                                                            hoverColor: Colors.transparent,
                                                                                                            onPressed: () {
                                                                                                              moviesList.removeWhere((element) => element['movieID'] == data[innerIndex].id);
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
                                                                ),
                                                              );
                                                            },
                                                          ),
                                                        ),
                                                      ),
                                                      Row(
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
                                                                color: Colors
                                                                    .white,
                                                              ),
                                                              onPressed: () {
                                                                if (pageIndexMovies >
                                                                    1) {
                                                                  setState(() =>
                                                                      pageIndexMovies =
                                                                          1);
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
                                                                    .arrow_left,
                                                                color: Colors
                                                                    .white,
                                                              ),
                                                              onPressed: () {
                                                                if (pageIndexMovies >
                                                                    1) {
                                                                  setState(() =>
                                                                      pageIndexMovies -=
                                                                          1);
                                                                }
                                                              },
                                                            ),
                                                          ),
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(8.0),
                                                            child: Text(
                                                                "${pageIndexMovies.toString()}/$totalPages"),
                                                          ),
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(8.0),
                                                            child: IconButton(
                                                              icon: const Icon(
                                                                Icons
                                                                    .arrow_right,
                                                                color: Colors
                                                                    .white,
                                                              ),
                                                              onPressed: () {
                                                                if (pageIndexMovies <
                                                                    totalPages!) {
                                                                  setState(() {
                                                                    pageIndexMovies +=
                                                                        1;
                                                                  });
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
                                                                color: Colors
                                                                    .white,
                                                              ),
                                                              onPressed: () {
                                                                if (pageIndexMovies <
                                                                    totalPages!) {
                                                                  setState(() {
                                                                    pageIndexMovies =
                                                                        totalPages;
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
                                            } else {
                                              return const CustomCPI();
                                            }
                                          },
                                        );
                                      });
                                },
                              );
                            } else if (buttonView == Buttons.series) {
                              return StatefulBuilder(
                                builder: (context, setState) {
                                  return FutureBuilder<int>(
                                      future: SeriesPageLogic()
                                          .getSearchResultsTotalPage(
                                              searchText),
                                      builder: (context, snapshot) {
                                        int? totalPages = snapshot.data;
                                        return FutureBuilder<List<dynamic>>(
                                          future: searchSeries(
                                              searchText, pageIndexSeries),
                                          builder: (context, snapshot) {
                                            var data = snapshot.data;
                                            if (snapshot.hasData &&
                                                snapshot.connectionState ==
                                                    ConnectionState.done) {
                                              return PageView.builder(
                                                itemBuilder: (context, index) {
                                                  return Column(
                                                    children: [
                                                      Expanded(
                                                        child: SizedBox(
                                                          child:
                                                              GridView.builder(
                                                            gridDelegate:
                                                                const SliverGridDelegateWithMaxCrossAxisExtent(
                                                              maxCrossAxisExtent:
                                                                  350,
                                                            ),
                                                            itemCount:
                                                                data?.length,
                                                            itemBuilder:
                                                                (context,
                                                                    innerIndex) {
                                                              ValueNotifier<
                                                                      bool>
                                                                  isHovering =
                                                                  ValueNotifier<
                                                                          bool>(
                                                                      false);
                                                              ValueNotifier<
                                                                      bool>
                                                                  isFavorite =
                                                                  ValueNotifier<
                                                                          bool>(
                                                                      false);
                                                              var serieID = 0;
                                                              if (data![innerIndex]
                                                                      .id !=
                                                                  null) {
                                                                serieID = data[
                                                                        innerIndex]
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
                                                                    Navigator
                                                                        .push(
                                                                      context,
                                                                      MaterialPageRoute(
                                                                        builder:
                                                                            (context) =>
                                                                                SerieDetailPage(serieID: serieID),
                                                                      ),
                                                                    );
                                                                  },
                                                                  child:
                                                                      Padding(
                                                                    padding:
                                                                        const EdgeInsets
                                                                            .all(
                                                                            8.0),
                                                                    child:
                                                                        Column(
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
                                                                                              borderRadius: const BorderRadius.only(
                                                                                                topLeft: Radius.circular(12),
                                                                                                topRight: Radius.circular(12),
                                                                                              ),
                                                                                              child: Image(
                                                                                                fit: BoxFit.fill,
                                                                                                image: NetworkImage(
                                                                                                  data[innerIndex].imageURL.toString(),
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
                                                                                                  padding: const EdgeInsets.all(4.0),
                                                                                                  child: Text(
                                                                                                    data[innerIndex].name.toString(),
                                                                                                    softWrap: true,
                                                                                                    overflow: TextOverflow.ellipsis,
                                                                                                    textAlign: TextAlign.center,
                                                                                                  ),
                                                                                                ),
                                                                                                Padding(
                                                                                                  padding: const EdgeInsets.only(bottom: 4.0),
                                                                                                  child: Text(
                                                                                                    getSerieReleaseDate(data[innerIndex]),
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
                                                                                                    Map<String, dynamic> serieMap = {
                                                                                                      "serieID": serieID,
                                                                                                      "imageURL": data[innerIndex].imageURL.toString(),
                                                                                                      "serieName": data[innerIndex].name,
                                                                                                    };
                                                                                                    for (var x in seriesList) {
                                                                                                      if (x['serieID'] == data[innerIndex].id) {
                                                                                                        isFavorite.value = true;
                                                                                                      }
                                                                                                    }
                                                                                                    return isFavorite.value
                                                                                                        ? IconButton(
                                                                                                            highlightColor: Color(themeColor),
                                                                                                            hoverColor: Colors.transparent,
                                                                                                            onPressed: () {
                                                                                                              seriesList.removeWhere((element) => element['serieID'] == serieID);
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
                                                                ),
                                                              );
                                                            },
                                                          ),
                                                        ),
                                                      ),
                                                      Row(
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
                                                                color: Colors
                                                                    .white,
                                                              ),
                                                              onPressed: () {
                                                                if (pageIndexSeries >
                                                                    1) {
                                                                  setState(() =>
                                                                      pageIndexSeries =
                                                                          1);
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
                                                                    .arrow_left,
                                                                color: Colors
                                                                    .white,
                                                              ),
                                                              onPressed: () {
                                                                if (pageIndexSeries >
                                                                    1) {
                                                                  setState(() =>
                                                                      pageIndexSeries -=
                                                                          1);
                                                                }
                                                              },
                                                            ),
                                                          ),
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(8.0),
                                                            child: Text(
                                                                "${pageIndexSeries.toString()}/$totalPages"),
                                                          ),
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(8.0),
                                                            child: IconButton(
                                                              icon: const Icon(
                                                                Icons
                                                                    .arrow_right,
                                                                color: Colors
                                                                    .white,
                                                              ),
                                                              onPressed: () {
                                                                if (pageIndexSeries <
                                                                    totalPages!) {
                                                                  setState(() {
                                                                    pageIndexSeries +=
                                                                        1;
                                                                  });
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
                                                                color: Colors
                                                                    .white,
                                                              ),
                                                              onPressed: () {
                                                                if (pageIndexSeries <
                                                                    totalPages!) {
                                                                  setState(() {
                                                                    pageIndexSeries =
                                                                        totalPages;
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
                                            } else {
                                              return const CustomCPI();
                                            }
                                          },
                                        );
                                      });
                                },
                              );
                            } else if (buttonView == Buttons.actors) {
                              return StatefulBuilder(
                                builder: (context, setState) {
                                  return FutureBuilder<int>(
                                      future: ActorPageLogic()
                                          .getSearchResultsTotalPage(
                                              searchText),
                                      builder: (context, snapshot) {
                                        int? totalPages = snapshot.data;
                                        return FutureBuilder<List<dynamic>>(
                                          future: searchActors(
                                              searchText, pageIndexActors),
                                          builder: (context, snapshot) {
                                            var data = snapshot.data;
                                            if (snapshot.hasData &&
                                                snapshot.connectionState ==
                                                    ConnectionState.done) {
                                              return PageView.builder(
                                                itemBuilder: (context, index) {
                                                  return Column(
                                                    children: [
                                                      Expanded(
                                                        child: SizedBox(
                                                          child:
                                                              GridView.builder(
                                                            gridDelegate:
                                                                const SliverGridDelegateWithMaxCrossAxisExtent(
                                                              maxCrossAxisExtent:
                                                                  350,
                                                            ),
                                                            itemCount:
                                                                data?.length,
                                                            itemBuilder:
                                                                (context,
                                                                    innerIndex) {
                                                              ValueNotifier<
                                                                      bool>
                                                                  isHovering =
                                                                  ValueNotifier<
                                                                          bool>(
                                                                      false);
                                                              ValueNotifier<
                                                                      bool>
                                                                  isFavorite =
                                                                  ValueNotifier<
                                                                          bool>(
                                                                      false);
                                                              var actorID = 0;
                                                              if (data![innerIndex]
                                                                      .id !=
                                                                  null) {
                                                                actorID = data[
                                                                        innerIndex]
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
                                                                    Navigator
                                                                        .push(
                                                                      context,
                                                                      MaterialPageRoute(
                                                                        builder:
                                                                            (context) =>
                                                                                ActorDetailPage(actorID: actorID),
                                                                      ),
                                                                    );
                                                                  },
                                                                  child:
                                                                      Padding(
                                                                    padding:
                                                                        const EdgeInsets
                                                                            .all(
                                                                            8.0),
                                                                    child:
                                                                        Column(
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
                                                                                              borderRadius: const BorderRadius.only(
                                                                                                topLeft: Radius.circular(12),
                                                                                                topRight: Radius.circular(12),
                                                                                              ),
                                                                                              child: Image(
                                                                                                fit: BoxFit.fill,
                                                                                                image: NetworkImage(
                                                                                                  data[innerIndex].imageURL.toString(),
                                                                                                ),
                                                                                              ),
                                                                                            ),
                                                                                          ),
                                                                                        ),
                                                                                        Tooltip(
                                                                                          message: data[innerIndex].name,
                                                                                          child: SizedBox(
                                                                                            width: 180,
                                                                                            child: Padding(
                                                                                              padding: const EdgeInsets.all(4.0),
                                                                                              child: Text(
                                                                                                data[innerIndex].name.toString(),
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
                                                                                                    Map<String, dynamic> actorMap = {
                                                                                                      "actorID": actorID,
                                                                                                      "imageURL": data[innerIndex].imageURL.toString(),
                                                                                                      "actorName": data[innerIndex].name,
                                                                                                    };
                                                                                                    for (var x in actorsList) {
                                                                                                      if (x['actorID'] == data[innerIndex].id) {
                                                                                                        isFavorite.value = true;
                                                                                                      }
                                                                                                    }
                                                                                                    return isFavorite.value
                                                                                                        ? IconButton(
                                                                                                            highlightColor: Color(themeColor),
                                                                                                            hoverColor: Colors.transparent,
                                                                                                            onPressed: () {
                                                                                                              actorsList.removeWhere(
                                                                                                                (element) => element['actorID'] == actorID,
                                                                                                              );
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
                                                                ),
                                                              );
                                                            },
                                                          ),
                                                        ),
                                                      ),
                                                      Row(
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
                                                                color: Colors
                                                                    .white,
                                                              ),
                                                              onPressed: () {
                                                                if (pageIndexMovies >
                                                                    1) {
                                                                  setState(() =>
                                                                      pageIndexMovies =
                                                                          1);
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
                                                                    .arrow_left,
                                                                color: Colors
                                                                    .white,
                                                              ),
                                                              onPressed: () {
                                                                if (pageIndexMovies >
                                                                    1) {
                                                                  setState(() =>
                                                                      pageIndexMovies -=
                                                                          1);
                                                                }
                                                              },
                                                            ),
                                                          ),
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(8.0),
                                                            child: Text(
                                                                "${pageIndexMovies.toString()}/$totalPages"),
                                                          ),
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(8.0),
                                                            child: IconButton(
                                                              icon: const Icon(
                                                                Icons
                                                                    .arrow_right,
                                                                color: Colors
                                                                    .white,
                                                              ),
                                                              onPressed: () {
                                                                if (pageIndexMovies <
                                                                    totalPages!) {
                                                                  setState(() {
                                                                    pageIndexMovies +=
                                                                        1;
                                                                  });
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
                                                                color: Colors
                                                                    .white,
                                                              ),
                                                              onPressed: () {
                                                                if (pageIndexMovies <
                                                                    totalPages!) {
                                                                  setState(() {
                                                                    pageIndexMovies =
                                                                        totalPages;
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
                                            } else {
                                              return const CustomCPI();
                                            }
                                          },
                                        );
                                      });
                                },
                              );
                            } else if (buttonView == Buttons.books) {
                              return FutureBuilder<List<BookModel>>(
                                future:
                                    BooksPageLogic().searchBooks(searchText),
                                builder: (context, snapshot) {
                                  var data = snapshot.data;

                                  if (snapshot.hasData &&
                                      snapshot.connectionState ==
                                          ConnectionState.done) {
                                    return GridView.builder(
                                      itemCount: data?.length,
                                      gridDelegate:
                                          const SliverGridDelegateWithMaxCrossAxisExtent(
                                        maxCrossAxisExtent: 300,
                                      ),
                                      itemBuilder: (context, index) {
                                        ValueNotifier<bool> isHovering =
                                            ValueNotifier<bool>(false);
                                        ValueNotifier<bool> isFavorite =
                                            ValueNotifier<bool>(false);
                                        String bookID = data![index]
                                            .id
                                            .toString()
                                            .substring(7);
                                        print(bookID);
                                        print(data[index].title);

                                        return MouseRegion(
                                          onEnter: (event) =>
                                              isHovering.value = true,
                                          onExit: (event) =>
                                              isHovering.value = false,
                                          cursor: SystemMouseCursors.click,
                                          child: GestureDetector(
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      BooksDetailPage(
                                                          bookID: bookID),
                                                ),
                                              );
                                            },
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
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
                                                                  Expanded(
                                                                    child:
                                                                        SizedBox(
                                                                      height:
                                                                          240,
                                                                      width:
                                                                          180,
                                                                      child:
                                                                          ClipRRect(
                                                                        borderRadius:
                                                                            const BorderRadius.only(
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
                                                                              NetworkImage(
                                                                            data[index].imageURL.toString(),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  Tooltip(
                                                                    message: data[
                                                                            index]
                                                                        .title,
                                                                    child:
                                                                        SizedBox(
                                                                      width:
                                                                          180,
                                                                      child:
                                                                          Column(
                                                                        children: [
                                                                          Padding(
                                                                            padding:
                                                                                const EdgeInsets.all(4.0),
                                                                            child:
                                                                                Text(
                                                                              data[index].title.toString(),
                                                                              softWrap: true,
                                                                              overflow: TextOverflow.ellipsis,
                                                                              textAlign: TextAlign.center,
                                                                            ),
                                                                          ),
                                                                          Padding(
                                                                            padding:
                                                                                const EdgeInsets.only(bottom: 4.0),
                                                                            child:
                                                                                getBookReleaseDate(data[index]),
                                                                          ),
                                                                        ],
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
                                                                          child:
                                                                              ValueListenableBuilder(
                                                                            valueListenable:
                                                                                isFavorite,
                                                                            builder: (context,
                                                                                value,
                                                                                child) {
                                                                              Map<String, dynamic> bookMap = {
                                                                                "bookID": bookID,
                                                                                "imageURL": data[index].imageURL.toString(),
                                                                                "bookName": data[index].title,
                                                                              };
                                                                              for (var x in booksList) {
                                                                                if (x['bookID'] == bookID) {
                                                                                  isFavorite.value = true;
                                                                                }
                                                                              }
                                                                              return isFavorite.value
                                                                                  ? IconButton(
                                                                                      highlightColor: Color(themeColor),
                                                                                      hoverColor: Colors.transparent,
                                                                                      onPressed: () {
                                                                                        booksList.removeWhere((element) => element['bookID'] == bookID);
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
                                          ),
                                        );
                                      },
                                    );
                                  } else if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const CustomCPI();
                                  } else {
                                    return const Center();
                                  }
                                },
                              );
                            } else {
                              return const Center();
                            }
                          });
                        } else {
                          return CustomCPI();
                        }
                      }),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Widget gameCategoryCard(int? category) {
  Widget text = const Text("");
  Color color = Colors.transparent;
  switch (category) {
    case 0:
      text = const Text("Main Game");
      color = Colors.pink.withOpacity(0.7);
    case 1:
      text = const Text("DLC");
      color = Colors.red.withOpacity(0.7);
    case 2:
      text = const Text("Expansion");
      color = Colors.orange.withOpacity(0.7);
    case 3:
      text = const Text("Bundle");
      color = Colors.deepOrange.withOpacity(0.7);
    case 4:
      text = const Text("Standalone Expansion");
      color = Colors.yellow.withOpacity(0.7);
    case 5:
      text = const Text("Mod");
      color = Colors.lime.withOpacity(0.7);
    case 6:
      text = const Text("Episode");
      color = Colors.lightGreen.withOpacity(0.7);
    case 7:
      text = const Text("Season");
      color = Colors.green.withOpacity(0.7);
    case 8:
      text = const Text("Remake");
      color = Colors.teal.withOpacity(0.7);
    case 9:
      text = const Text("Remaster");
      color = Colors.lightBlue.withOpacity(0.7);
    case 10:
      text = const Text("Expanded Game");
      color = Colors.deepOrange.withOpacity(0.7);
    case 11:
      text = const Text("Port");
      color = Colors.blue.withOpacity(0.7);
    case 12:
      text = const Text("Fork");
      color = Colors.purple.withOpacity(0.7);
    case 13:
      text = const Text("Pack");
      color = Colors.deepPurple.withOpacity(0.7);
    case 14:
      text = const Text("Update");
      color = Colors.brown.withOpacity(0.7);
    default:
      text = const Text("");
      color = Colors.transparent;
  }
  Widget gameCategoryCard = Card(
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(5)),
    ),
    elevation: 0,
    color: color,
    child: Padding(
      padding: const EdgeInsets.all(4.0),
      child: text,
    ),
  );
  return gameCategoryCard;
}

Future<List<GameModel>> searchGames(String searchText) async {
  return await GamePageLogic().searchGames(searchText);
}

Future<List<dynamic>> searchMovies(String query, int page) async {
  return await MoviePageLogic().searchMovies(query, page);
}

Future<List<dynamic>> searchSeries(String query, int page) async {
  return await SeriesPageLogic().searchSeries(query, page);
}

Future<List<dynamic>> searchActors(String query, int page) async {
  return await ActorPageLogic().searchActors(query, page);
}

Future<List<dynamic>> searchBooks(String query, int page) async {
  return await BooksPageLogic().searchBooks(query);
}

String getMovieReleaseDate(data) {
  String date = data.release_date;
  if (date == "") {
    return "Unknown";
  }
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

String getSerieReleaseDate(data) {
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

Widget getBookReleaseDate(data) {
  if (data.publish_year == null) {
    return const Text(
      "Unknown",
      style: TextStyle(color: Colors.grey, fontSize: 12),
      softWrap: true,
      overflow: TextOverflow.ellipsis,
      textAlign: TextAlign.center,
    );
  } else {
    return Text(
      data.publish_year.toString(),
      softWrap: true,
      overflow: TextOverflow.ellipsis,
      textAlign: TextAlign.center,
      style: const TextStyle(fontSize: 12),
    );
  }
}
