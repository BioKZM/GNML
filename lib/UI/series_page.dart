import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gnml/Data/Model/serie_model.dart';
import 'package:gnml/Helper/theme_helper.dart';
import 'package:gnml/Logic/seriespage_logic.dart';
import 'package:gnml/UI/Details/serie_detail_page.dart';
import 'package:gnml/Widgets/circularprogressindicator.dart';
import 'package:gnml/Widgets/shimmer.dart';
import 'package:provider/provider.dart';

class SeriesPage extends StatefulWidget {
  const SeriesPage({Key? key}) : super(key: key);

  @override
  State<SeriesPage> createState() => _SeriesPageState();
}

class _SeriesPageState extends State<SeriesPage> {
  User? user = FirebaseAuth.instance.currentUser;
  bool boolean = false;
  late PageController _pageController;
  int pageIndexOnTheAir = 1;
  int pageIndexTopRated = 1;
  int pageIndexUpcoming = 1;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
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
        builder: (context, snapshot) {
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
                    color: Colors.blue.withOpacity(0.5),
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
                                child: Text(
                                  "Popular Series",
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
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
                                    duration: const Duration(milliseconds: 500),
                                    curve: Curves.ease,
                                  );
                                },
                              ),
                              StatefulBuilder(builder: (context, setState) {
                                return Expanded(
                                  child: SizedBox(
                                    height: 200,
                                    width: double.infinity,
                                    child: FutureBuilder<List<SerieModel>>(
                                      future:
                                          SeriesPageLogic().getPopularSeries(),
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
                                              var serieID = 0;
                                              if (data?[index].id != null) {
                                                serieID = data![index].id!;
                                              }
                                              return SizedBox(
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(5.3),
                                                  child: MouseRegion(
                                                    onEnter: (event) =>
                                                        isHovering.value = true,
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
                                                                    serieID:
                                                                        serieID),
                                                          ),
                                                        );
                                                      },
                                                      child: Stack(
                                                        children: [
                                                          Card(
                                                            elevation: 0,
                                                            shape:
                                                                const RoundedRectangleBorder(
                                                              side: BorderSide(
                                                                color: Colors
                                                                    .transparent,
                                                              ),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .all(
                                                                Radius.circular(
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
                                                                      topLeft: Radius
                                                                          .circular(
                                                                              12),
                                                                      topRight:
                                                                          Radius.circular(
                                                                              12),
                                                                    ),
                                                                    child:
                                                                        Image(
                                                                      fit: BoxFit
                                                                          .cover,
                                                                      image:
                                                                          NetworkImage(
                                                                        data![index]
                                                                            .imageURL
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
                                                                    width: 100,
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
                                                                value, child) {
                                                              return isHovering
                                                                      .value
                                                                  ? Positioned(
                                                                      top: 5,
                                                                      right: 5,
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
                                                                            Map<String, dynamic>
                                                                                serieMap =
                                                                                {
                                                                              "serieID": data[index].id,
                                                                              "imageURL": data[index].imageURL.toString(),
                                                                              "serieName": data[index].name,
                                                                            };
                                                                            for (var x
                                                                                in seriesList) {
                                                                              if (x['serieID'] == data[index].id) {
                                                                                isFavorite.value = true;
                                                                              }
                                                                            }
                                                                            return isFavorite.value
                                                                                ? IconButton(
                                                                                    highlightColor: Color(themeColor),
                                                                                    hoverColor: Colors.transparent,
                                                                                    onPressed: () {
                                                                                      seriesList.removeWhere((element) => element['serieID'] == data[index].id);
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
                                                                  Icons
                                                                      .refresh),
                                                              onPressed: () {
                                                                setState(() {});
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
                      height: 1350,
                      child: Card(
                        elevation: 5,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Card(
                                  color: Colors.blue.withOpacity(0.5),
                                  elevation: 0,
                                  child: const Padding(
                                    padding: EdgeInsets.fromLTRB(16, 4, 16, 4),
                                    child: Text(
                                      "On Air",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: StatefulBuilder(
                                builder: (context, setState) {
                                  return FutureBuilder<int>(
                                      future: SeriesPageLogic()
                                          .getOnTheAirSeriesTotalPages(),
                                      builder: (context, snapshot) {
                                        int? totalPages = snapshot.data;
                                        return FutureBuilder<List<dynamic>>(
                                          future: SeriesPageLogic()
                                              .getOnTheAirSeries(
                                                  pageIndexOnTheAir),
                                          builder: (context, snapshot) {
                                            var data = snapshot.data;
                                            if (snapshot.hasData &&
                                                snapshot.connectionState ==
                                                    ConnectionState.done) {
                                              return PageView.builder(
                                                itemBuilder: (context, index) {
                                                  return Column(
                                                    children: [
                                                      SizedBox(
                                                        height: 1200,
                                                        child: GridView.builder(
                                                          gridDelegate:
                                                              const SliverGridDelegateWithMaxCrossAxisExtent(
                                                            maxCrossAxisExtent:
                                                                300,
                                                          ),
                                                          itemCount:
                                                              data?.length,
                                                          itemBuilder: (context,
                                                              innerIndex) {
                                                            ValueNotifier<bool>
                                                                isHovering =
                                                                ValueNotifier<
                                                                        bool>(
                                                                    false);
                                                            ValueNotifier<bool>
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
                                                              child:
                                                                  GestureDetector(
                                                                onTap: () {
                                                                  Navigator
                                                                      .push(
                                                                    context,
                                                                    MaterialPageRoute(
                                                                      builder: (context) =>
                                                                          SerieDetailPage(
                                                                              serieID: serieID),
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
                                                                                                child: Text(getReleaseDate(data[innerIndex]), softWrap: true, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12)),
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
                                                                                                    "serieID": data[innerIndex].id,
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
                                                                                                            seriesList.removeWhere((element) => element['serieID'] == data[innerIndex].id);
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
                                                                if (pageIndexOnTheAir >
                                                                    1) {
                                                                  setState(() =>
                                                                      pageIndexOnTheAir =
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
                                                                if (pageIndexOnTheAir >
                                                                    1) {
                                                                  setState(() =>
                                                                      pageIndexOnTheAir -=
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
                                                                "${pageIndexOnTheAir.toString()}/$totalPages"),
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
                                                                if (pageIndexOnTheAir <
                                                                    totalPages!) {
                                                                  setState(() {
                                                                    pageIndexOnTheAir +=
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
                                                                if (pageIndexOnTheAir <
                                                                    totalPages!) {
                                                                  setState(() {
                                                                    pageIndexOnTheAir =
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
                                                      ),
                                                    );
                                            }
                                          },
                                        );
                                      });
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: SizedBox(
                      width: double.infinity,
                      height: 1350,
                      child: Card(
                        elevation: 5,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Card(
                                  color: Colors.blue.withOpacity(0.5),
                                  elevation: 0,
                                  child: const Padding(
                                    padding: EdgeInsets.fromLTRB(16, 4, 16, 4),
                                    child: Text(
                                      "Top Rated",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: StatefulBuilder(
                                builder: (context, setState) {
                                  return FutureBuilder<int>(
                                      future: SeriesPageLogic()
                                          .getTopRatedSeriesTotalPages(),
                                      builder: (context, snapshot) {
                                        int? totalPages = snapshot.data;
                                        return FutureBuilder<List<dynamic>>(
                                          future: SeriesPageLogic()
                                              .getTopRatedSeries(
                                                  pageIndexTopRated),
                                          builder: (context, snapshot) {
                                            var data = snapshot.data;

                                            if (snapshot.hasData &&
                                                snapshot.connectionState ==
                                                    ConnectionState.done) {
                                              return PageView.builder(
                                                itemBuilder: (context, index) {
                                                  return Column(
                                                    children: [
                                                      SizedBox(
                                                        height: 1200,
                                                        child: GridView.builder(
                                                          gridDelegate:
                                                              const SliverGridDelegateWithMaxCrossAxisExtent(
                                                            maxCrossAxisExtent:
                                                                300,
                                                          ),
                                                          itemCount:
                                                              data?.length,
                                                          itemBuilder: (context,
                                                              innerIndex) {
                                                            ValueNotifier<bool>
                                                                isHovering =
                                                                ValueNotifier<
                                                                        bool>(
                                                                    false);
                                                            ValueNotifier<bool>
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
                                                                      builder: (context) =>
                                                                          SerieDetailPage(
                                                                              serieID: serieID),
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
                                                                                                child: Text(getReleaseDate(data[innerIndex]), softWrap: true, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12)),
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
                                                                                                    "serieID": data[innerIndex].id,
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
                                                                                                            seriesList.removeWhere((element) => element['serieID'] == data[innerIndex].id);
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
                                                                if (pageIndexTopRated >
                                                                    1) {
                                                                  setState(() =>
                                                                      pageIndexTopRated =
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
                                                                if (pageIndexTopRated >
                                                                    1) {
                                                                  setState(() =>
                                                                      pageIndexTopRated -=
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
                                                                "${pageIndexTopRated.toString()}/$totalPages"),
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
                                                                if (pageIndexTopRated <
                                                                    totalPages!) {
                                                                  setState(() {
                                                                    pageIndexTopRated +=
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
                                                                if (pageIndexTopRated <
                                                                    totalPages!) {
                                                                  setState(() {
                                                                    pageIndexTopRated =
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
                                                      ),
                                                    );
                                            }
                                          },
                                        );
                                      });
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: SizedBox(
                      width: double.infinity,
                      height: 1350,
                      child: Card(
                        elevation: 5,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Card(
                                  color: Colors.blue.withOpacity(0.5),
                                  elevation: 0,
                                  child: const Padding(
                                    padding: EdgeInsets.fromLTRB(16, 4, 16, 4),
                                    child: Text(
                                      "Airing Today",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: StatefulBuilder(
                                builder: (context, setState) {
                                  return FutureBuilder<int>(
                                      future: SeriesPageLogic()
                                          .getAiringTodaySeriesTotalPages(),
                                      builder: (context, snapshot) {
                                        int? totalPages = snapshot.data;
                                        return FutureBuilder<List<dynamic>>(
                                          future: SeriesPageLogic()
                                              .getAiringTodaySeries(
                                                  pageIndexUpcoming),
                                          builder: (context, snapshot) {
                                            var data = snapshot.data;

                                            if (snapshot.hasData &&
                                                snapshot.connectionState ==
                                                    ConnectionState.done) {
                                              return PageView.builder(
                                                itemBuilder: (context, index) {
                                                  return Column(
                                                    children: [
                                                      SizedBox(
                                                        height: 1200,
                                                        child: GridView.builder(
                                                          gridDelegate:
                                                              const SliverGridDelegateWithMaxCrossAxisExtent(
                                                            maxCrossAxisExtent:
                                                                300,
                                                          ),
                                                          itemCount:
                                                              data?.length,
                                                          itemBuilder: (context,
                                                              innerIndex) {
                                                            ValueNotifier<bool>
                                                                isHovering =
                                                                ValueNotifier<
                                                                        bool>(
                                                                    false);
                                                            ValueNotifier<bool>
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
                                                            return GestureDetector(
                                                              onTap: () {
                                                                Navigator.push(
                                                                  context,
                                                                  MaterialPageRoute(
                                                                    builder: (context) =>
                                                                        SerieDetailPage(
                                                                            serieID:
                                                                                serieID),
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
                                                                                              child: Text(getReleaseDate(data[innerIndex]), softWrap: true, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12)),
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
                                                                                                  "serieID": data[innerIndex].id,
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
                                                                                                          seriesList.removeWhere((element) => element['serieID'] == data[innerIndex].id);
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
                                                            );
                                                          },
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
                                                                if (pageIndexUpcoming >
                                                                    1) {
                                                                  setState(() =>
                                                                      pageIndexUpcoming =
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
                                                                if (pageIndexUpcoming >
                                                                    1) {
                                                                  setState(() =>
                                                                      pageIndexUpcoming -=
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
                                                                "${pageIndexUpcoming.toString()}/$totalPages"),
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
                                                                if (pageIndexUpcoming <
                                                                    totalPages!) {
                                                                  setState(() {
                                                                    pageIndexUpcoming +=
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
                                                                if (pageIndexUpcoming <
                                                                    totalPages!) {
                                                                  setState(() {
                                                                    pageIndexUpcoming =
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
                                                      ),
                                                    );
                                            }
                                          },
                                        );
                                      });
                                },
                              ),
                            ),
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
        },
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}

String getReleaseDate(data) {
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
