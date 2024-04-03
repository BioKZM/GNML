import 'dart:convert';
import 'dart:developer';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:gnml/Data/Model/actor_model.dart';
import 'package:gnml/Helper/theme_helper.dart';
import 'package:gnml/Logic/actorpage_logic.dart';
import 'package:gnml/UI/Details/movie_detail_page.dart';
import 'package:gnml/UI/Details/serie_detail_page.dart';
import 'package:gnml/Widgets/circularprogressindicator.dart';
import 'package:provider/provider.dart';

class ActorDetailPage extends StatefulWidget {
  final int actorID;
  const ActorDetailPage({
    super.key,
    required this.actorID,
  });

  @override
  State<ActorDetailPage> createState() => _ActorDetailPageState();
}

class _ActorDetailPageState extends State<ActorDetailPage> {
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

    PageController pageController = PageController(
      initialPage: 0,
    );
    PageController pageController2 = PageController(
      initialPage: 0,
    );
    PageController pageController3 = PageController(
      initialPage: 0,
    );
    return FutureBuilder<List<ActorModel>>(
        future: ActorPageLogic().getActorDetails(widget.actorID),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            var data = snapshot.data![0];
            data.place_of_birth ??= "Unknown";
            String? biography = data.biography;
            biography = utf8
                .decode(data.biography.toString().runes.toList(),
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
                    Map<String, dynamic> actorMap = {
                      "actorID": widget.actorID,
                      "imageURL": data.imageURL,
                      "actorName": data.name,
                    };
                    for (var x in actorsList) {
                      if (x['actorID'] == widget.actorID) {
                        boolean = true;
                      }
                    }
                    return Scaffold(
                      // appBar: AppBar(
                      //   title: const Text("Actor Details"),
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
                                            "Actor Details",
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
                                                  StatefulBuilder(builder:
                                                      (context, setState) {
                                                    return Card(
                                                      color: Colors.grey
                                                          .withOpacity(0.3),
                                                      child: Tooltip(
                                                        message:
                                                            "Remove from Library",
                                                        child: IconButton(
                                                          highlightColor:
                                                              Color(themeColor),
                                                          hoverColor: Colors
                                                              .transparent,
                                                          icon: boolean
                                                              ? Tooltip(
                                                                  message:
                                                                      "Add to Library",
                                                                  child: Icon(
                                                                    Icons
                                                                        .favorite,
                                                                    color: Color(
                                                                        themeColor),
                                                                  ),
                                                                )
                                                              : const Icon(Icons
                                                                  .favorite_outline),
                                                          onPressed: () {
                                                            if (boolean) {
                                                              actorsList.removeWhere(
                                                                  (element) =>
                                                                      element[
                                                                          'actorID'] ==
                                                                      widget
                                                                          .actorID);
                                                              updateData(
                                                                  gamesList,
                                                                  moviesList,
                                                                  seriesList,
                                                                  booksList,
                                                                  actorsList);
                                                            } else {
                                                              actorsList.add(
                                                                  actorMap);
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
                                                    );
                                                  })
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
                                                      Text(data.name.toString(),
                                                          style: const TextStyle(
                                                              fontSize: 50,
                                                              fontFamily:
                                                                  'RobotoBold')),
                                                      const Divider(
                                                          color: Colors
                                                              .transparent),
                                                      const Divider(
                                                          color: Colors
                                                              .transparent),
                                                      const Divider(
                                                          color: Colors
                                                              .transparent),
                                                      const Divider(
                                                          color: Colors
                                                              .transparent),
                                                      Row(
                                                        children: [
                                                          const Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Text(
                                                                  "Date of Birth:"),
                                                              Text(
                                                                  "Place of Birth:"),
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
                                                                    const Divider(
                                                                      indent:
                                                                          20,
                                                                    ),
                                                                    Text(
                                                                      getBirthday(
                                                                          data),
                                                                    ),
                                                                  ],
                                                                ),
                                                                Row(
                                                                  children: [
                                                                    const Divider(
                                                                      indent:
                                                                          20,
                                                                    ),
                                                                    Text(data
                                                                        .place_of_birth
                                                                        .toString())
                                                                  ],
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      const VerticalDivider(
                                                        indent: 20,
                                                      ),
                                                      Row(
                                                        children: [
                                                          Expanded(
                                                            child: Text(
                                                                biography!),
                                                          ),
                                                        ],
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(
                                                                top: 100.0),
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
                                                                                getCastData(data).length,
                                                                            scrollDirection:
                                                                                Axis.horizontal,
                                                                            itemBuilder:
                                                                                (context, index) {
                                                                              List castData = getCastData(data);
                                                                              var movieFlag = true;
                                                                              var title = castData[index]['title'];

                                                                              if (title == null) {
                                                                                title = castData[index]['name'];
                                                                                movieFlag = false;
                                                                              }
                                                                              // ignore: prefer_typing_uninitialized_variables
                                                                              var character;
                                                                              if (castData[index]['character'] == "") {
                                                                                character = "Unknown";
                                                                              } else {
                                                                                character = castData[index]['character'];
                                                                              }

                                                                              var starPhoto = castData[index]['poster_path'];

                                                                              if (starPhoto != null) {
                                                                                starPhoto = starPhoto.substring(1);
                                                                              }
                                                                              return Padding(
                                                                                padding: const EdgeInsets.all(16.0),
                                                                                child: GestureDetector(
                                                                                  onTap: () {
                                                                                    if (movieFlag == true) {
                                                                                      Navigator.push(
                                                                                        context,
                                                                                        MaterialPageRoute(
                                                                                          builder: (context) => MovieDetailPage(
                                                                                            movieID: castData[index]['id'],
                                                                                          ),
                                                                                        ),
                                                                                      );
                                                                                    } else {
                                                                                      Navigator.push(
                                                                                        context,
                                                                                        MaterialPageRoute(
                                                                                          builder: (context) => SerieDetailPage(
                                                                                            serieID: castData[index]['id'],
                                                                                          ),
                                                                                        ),
                                                                                      );
                                                                                    }
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
                                                                                                title,
                                                                                                softWrap: true,
                                                                                                textAlign: TextAlign.center,
                                                                                                style: const TextStyle(fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold),
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
                                                                                                character,
                                                                                                softWrap: true,
                                                                                                textAlign: TextAlign.center,
                                                                                                style: const TextStyle(
                                                                                                  fontSize: 15,
                                                                                                  color: Colors.white,
                                                                                                ),
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
                                                                .only(top: 8.0),
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
                                                                                getCrewData(data).length,
                                                                            scrollDirection:
                                                                                Axis.horizontal,
                                                                            itemBuilder:
                                                                                (context, index) {
                                                                              List crewData = getCrewData(data);

                                                                              bool movieFlag = true;

                                                                              var title = crewData[index]['title'];

                                                                              if (title == null) {
                                                                                title = crewData[index]['name'];
                                                                                movieFlag = false;
                                                                              }
                                                                              var starPhoto = crewData[index]['poster_path'];

                                                                              var job = crewData[index]['job'];
                                                                              job ??= " ";
                                                                              if (starPhoto != null) {
                                                                                starPhoto = starPhoto.substring(1);
                                                                              }
                                                                              return Padding(
                                                                                padding: const EdgeInsets.all(16.0),
                                                                                child: GestureDetector(
                                                                                  onTap: () {
                                                                                    if (movieFlag == true) {
                                                                                      Navigator.push(
                                                                                        context,
                                                                                        MaterialPageRoute(
                                                                                          builder: (context) => MovieDetailPage(
                                                                                            movieID: crewData[index]['id'],
                                                                                          ),
                                                                                        ),
                                                                                      );
                                                                                    } else {
                                                                                      Navigator.push(
                                                                                        context,
                                                                                        MaterialPageRoute(
                                                                                          builder: (context) => SerieDetailPage(
                                                                                            serieID: crewData[index]['id'],
                                                                                          ),
                                                                                        ),
                                                                                      );
                                                                                    }
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
                                                                                                title,
                                                                                                softWrap: true,
                                                                                                textAlign: TextAlign.center,
                                                                                                style: const TextStyle(fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold),
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
                                                                                                job,
                                                                                                softWrap: true,
                                                                                                textAlign: TextAlign.center,
                                                                                                style: const TextStyle(
                                                                                                  fontSize: 15,
                                                                                                  color: Colors.white,
                                                                                                ),
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
                                                                .only(top: 8),
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
                                                                "Images",
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
                                                                              450,
                                                                          width:
                                                                              300,
                                                                          child:
                                                                              ListView.builder(
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
                                              child: Container(
                                                height: 350,
                                                color: Colors.transparent,
                                                child: const Card(
                                                  elevation: 0,
                                                  color: Colors.transparent,
                                                  child: SizedBox(
                                                      // mainAxisAlignment:
                                                      //     MainAxisAlignment.center,
                                                      // crossAxisAlignment:
                                                      //     CrossAxisAlignment.center,
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
                title: const Text("Actor Details"),
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

String getBirthday(data) {
  if (data.birthday == null) {
    return "Unknown";
  }
  String date = data.birthday;
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

List<dynamic> getCastData(data) {
  List castList = [];
  for (var x in data.movie_credits['cast']) {
    castList.add(x);
  }
  for (var x in data.tv_credits['cast']) {
    castList.add(x);
  }
  return castList;
}

List<dynamic> getCrewData(data) {
  List crewList = [];
  for (var x in data.movie_credits['crew']) {
    crewList.add(x);
  }
  for (var x in data.tv_credits['crew']) {
    crewList.add(x);
  }
  return crewList;
}
