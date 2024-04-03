import 'dart:convert';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gnml/Data/Model/movie_model.dart';
import 'package:gnml/Helper/theme_helper.dart';
import 'package:gnml/Logic/moviepage_logic.dart';
import 'package:gnml/UI/Details/actors_detail_page.dart';
import 'package:gnml/Widgets/circularprogressindicator.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

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
  User? user = FirebaseAuth.instance.currentUser;
  bool boolean = false;
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

    PageController pageController = PageController(initialPage: 0);
    PageController pageController2 = PageController(
      initialPage: 0,
    );
    PageController pageController3 = PageController(
      initialPage: 0,
    );
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
            return FutureBuilder(
                future: getData(),
                builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                  if (snapshot.hasData &&
                      snapshot.connectionState == ConnectionState.done) {
                    Map<String, dynamic> list =
                        snapshot.data!.data() as Map<String, dynamic>;
                    List gamesList = list['library']['games'];
                    List moviesList = list['library']['movies'];
                    List seriesList = list['library']['series'];
                    List booksList = list['library']['books'];
                    List actorsList = list['library']['actors'];
                    Map<String, dynamic> movieMap = {
                      "movieID": widget.movieID,
                      "imageURL": data.imageURL,
                      "movieName": data.title,
                    };
                    for (var x in moviesList) {
                      if (x['movieID'] == widget.movieID) {
                        boolean = true;
                      }
                    }
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
                          color: Colors.black.withOpacity(0.7),
                          child: SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            child: BackdropFilter(
                              filter:
                                  ImageFilter.blur(sigmaX: 100, sigmaY: 100),
                              child: Column(
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
                                            "Movie Details",
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
                                                                data.imageURL
                                                                    .toString()),
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
                                                      return Card(
                                                        color: Colors.grey
                                                            .withOpacity(0.3),
                                                        child: IconButton(
                                                          highlightColor:
                                                              Color(themeColor),
                                                          hoverColor: Colors
                                                              .transparent,
                                                          icon: boolean
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
                                                            if (boolean) {
                                                              moviesList.removeWhere(
                                                                  (element) =>
                                                                      element[
                                                                          'movieID'] ==
                                                                      widget
                                                                          .movieID);
                                                              updateData(
                                                                  gamesList,
                                                                  moviesList,
                                                                  seriesList,
                                                                  booksList,
                                                                  actorsList);
                                                            } else {
                                                              moviesList.add(
                                                                  movieMap);
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
                                                      );
                                                    }),
                                                  ),
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
                                                      Text('${data.title}',
                                                          style: const TextStyle(
                                                              fontSize: 50,
                                                              fontFamily:
                                                                  'RobotoBold')),
                                                      Text(
                                                        tagline!,
                                                      ),
                                                      const Divider(
                                                          color: Colors
                                                              .transparent),
                                                      const Divider(
                                                          color: Colors
                                                              .transparent),
                                                      Text(overview!),
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
                                                              Text(
                                                                  "Release Date:"),
                                                              Text("Genres:"),
                                                              Text(
                                                                  "Production Companies:"),
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
                                                                Row(
                                                                  children: [
                                                                    Text(
                                                                      getReleaseDate(
                                                                          data),
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
                                                                "Cast",
                                                                style: TextStyle(
                                                                    fontFamily:
                                                                        'RobotoBold'),
                                                              ),
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
                                                                              420,
                                                                          child:
                                                                              ListView.builder(
                                                                            controller:
                                                                                pageController,
                                                                            itemCount:
                                                                                data.credits!['cast'].length,
                                                                            scrollDirection:
                                                                                Axis.horizontal,
                                                                            itemBuilder:
                                                                                (context, index) {
                                                                              var starPhoto = data.credits!['cast'][index]['profile_path'];

                                                                              if (starPhoto != null) {
                                                                                starPhoto = starPhoto.substring(1);
                                                                              }
                                                                              return Padding(
                                                                                padding: const EdgeInsets.all(16.0),
                                                                                child: GestureDetector(
                                                                                  onTap: () {
                                                                                    Navigator.push(
                                                                                      context,
                                                                                      MaterialPageRoute(
                                                                                        builder: (context) => ActorDetailPage(actorID: data.credits!['cast'][index]['id']),
                                                                                      ),
                                                                                    );
                                                                                  },
                                                                                  child: Card(
                                                                                    color: const Color.fromARGB(255, 17, 17, 17),
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
                                                                                          height: 300,
                                                                                          width: 243,
                                                                                          child: ClipRRect(
                                                                                            borderRadius: const BorderRadius.only(
                                                                                              topLeft: Radius.circular(12),
                                                                                              topRight: Radius.circular(12),
                                                                                            ),
                                                                                            child: Image(
                                                                                              fit: BoxFit.fill,
                                                                                              image: NetworkImage("https://image.tmdb.org/t/p/original/$starPhoto"),
                                                                                            ),
                                                                                          ),
                                                                                        ),
                                                                                        Padding(
                                                                                          padding: const EdgeInsets.only(top: 8.0),
                                                                                          child: SizedBox(
                                                                                            width: 243,
                                                                                            child: FittedBox(
                                                                                              fit: BoxFit.scaleDown,
                                                                                              child: Text(
                                                                                                data.credits!['cast'][index]['name'],
                                                                                                softWrap: true,
                                                                                                textAlign: TextAlign.center,
                                                                                                style: const TextStyle(
                                                                                                  fontSize: 22,
                                                                                                  color: Colors.white,
                                                                                                  fontWeight: FontWeight.bold,
                                                                                                ),
                                                                                              ),
                                                                                            ),
                                                                                          ),
                                                                                        ),
                                                                                        Padding(
                                                                                          padding: const EdgeInsets.only(top: 8.0),
                                                                                          child: SizedBox(
                                                                                            width: 243,
                                                                                            child: FittedBox(
                                                                                              fit: BoxFit.scaleDown,
                                                                                              child: Text(
                                                                                                data.credits!['cast'][index]['character'],
                                                                                                softWrap: true,
                                                                                                textAlign: TextAlign.center,
                                                                                                style: const TextStyle(fontSize: 15, color: Colors.white),
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
                                                                "Crew",
                                                                style: TextStyle(
                                                                    fontFamily:
                                                                        'RobotoBold'),
                                                              ),
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
                                                                          pageController2
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
                                                                              420,
                                                                          child:
                                                                              ListView.builder(
                                                                            controller:
                                                                                pageController2,
                                                                            itemCount:
                                                                                data.credits!['crew'].length,
                                                                            scrollDirection:
                                                                                Axis.horizontal,
                                                                            itemBuilder:
                                                                                (context, index) {
                                                                              var starPhoto = data.credits!['crew'][index]['profile_path'];

                                                                              if (starPhoto != null) {
                                                                                starPhoto = starPhoto.substring(1);
                                                                              }
                                                                              return Padding(
                                                                                padding: const EdgeInsets.all(16.0),
                                                                                child: GestureDetector(
                                                                                  onTap: () {
                                                                                    Navigator.push(
                                                                                      context,
                                                                                      MaterialPageRoute(
                                                                                        builder: (context) => ActorDetailPage(actorID: data.credits!['crew'][index]['id']),
                                                                                      ),
                                                                                    );
                                                                                  },
                                                                                  child: Card(
                                                                                    color: const Color.fromARGB(255, 17, 17, 17),
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
                                                                                          height: 300,
                                                                                          width: 243,
                                                                                          child: ClipRRect(
                                                                                            borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
                                                                                            child: Image(
                                                                                              fit: BoxFit.fill,
                                                                                              image: NetworkImage("https://image.tmdb.org/t/p/original/$starPhoto"),
                                                                                            ),
                                                                                          ),
                                                                                        ),
                                                                                        Padding(
                                                                                          padding: const EdgeInsets.only(top: 8.0),
                                                                                          child: SizedBox(
                                                                                            width: 243,
                                                                                            child: FittedBox(
                                                                                              fit: BoxFit.scaleDown,
                                                                                              child: Text(
                                                                                                data.credits!['crew'][index]['name'],
                                                                                                softWrap: true,
                                                                                                textAlign: TextAlign.center,
                                                                                                style: const TextStyle(
                                                                                                  fontSize: 22,
                                                                                                  color: Colors.white,
                                                                                                  fontWeight: FontWeight.bold,
                                                                                                ),
                                                                                              ),
                                                                                            ),
                                                                                          ),
                                                                                        ),
                                                                                        Padding(
                                                                                          padding: const EdgeInsets.only(top: 8.0),
                                                                                          child: SizedBox(
                                                                                            width: 243,
                                                                                            child: FittedBox(
                                                                                              fit: BoxFit.scaleDown,
                                                                                              child: Text(
                                                                                                data.credits!['crew'][index]['job'],
                                                                                                softWrap: true,
                                                                                                textAlign: TextAlign.center,
                                                                                                style: const TextStyle(fontSize: 15, color: Colors.white),
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
                                                                          pageController2
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
                                                                          color:
                                                                              Colors.white,
                                                                        ),
                                                                        onPressed:
                                                                            () {
                                                                          pageController3
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
                                                                              600,
                                                                          width:
                                                                              800,
                                                                          child:
                                                                              PageView.builder(
                                                                            controller:
                                                                                pageController3,
                                                                            itemCount:
                                                                                data.images?.length,
                                                                            scrollDirection:
                                                                                Axis.horizontal,
                                                                            itemBuilder:
                                                                                (context, index) {
                                                                              if (data.images == []) {
                                                                                return const Center(
                                                                                  child: Text("Nothing Here"),
                                                                                );
                                                                              } else {
                                                                                var filePath = data.images![index]['file_path'];
                                                                                return Padding(
                                                                                  padding: const EdgeInsets.all(16.0),
                                                                                  child: ClipRRect(
                                                                                    borderRadius: const BorderRadius.all(Radius.circular(12)),
                                                                                    child: Image(
                                                                                      fit: BoxFit.fill,
                                                                                      image: NetworkImage("https://image.tmdb.org/t/p/original/${filePath?.substring(1)}"),
                                                                                    ),
                                                                                  ),
                                                                                );
                                                                              }
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
                                                                          pageController3
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
                                                          getRating(data)
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
                title: const Text("Movie Details"),
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

List<Widget> getCompanyList(data) {
  int index = 0;
  List<Widget> companyList = [];

  if (data.genres != null) {
    for (var x in data.production_companies) {
      if (data.production_companies.length > 1 && index == 0 ||
          index < data.production_companies.length - 1) {
        companyList.add(
          Text(x['name']),
        );
        companyList.add(
          const Text("—"),
        );
      } else {
        companyList.add(
          Text(x['name']),
        );
      }

      index += 1;
    }
  } else {
    companyList.add(
      Text(
        "Unknown",
        style: TextStyle(color: Colors.grey.shade600),
      ),
    );
  }

  return companyList;
}

Widget getRating(data) {
  var metaRating = (data.vote_average * 10).ceil();

  Color metaRatingColor = Colors.transparent;
  String metaRatingText = "";
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
  Widget ratingWidget = Column(
    children: [
      const Text("User Ratings", style: TextStyle(fontSize: 24)),
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Stack(
          children: [
            Stack(
              children: [
                SizedBox(
                  height: 150,
                  width: 150,
                  child: CircularProgressIndicator(
                    value: 1,
                    color: Colors.white.withAlpha(50),
                    strokeWidth: 16,
                  ),
                ),
                SizedBox(
                  height: 150,
                  width: 150,
                  child: CircularProgressIndicator(
                    value: metaRating / 100,
                    color: metaRatingColor,
                    strokeWidth: 16,
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
                      style: const TextStyle(fontSize: 32),
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
    ],
  );
  return ratingWidget;
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
