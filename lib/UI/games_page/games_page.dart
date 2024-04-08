import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gnml/Helper/theme_helper.dart';
import 'package:gnml/UI/games_page/ui/coming_soon/coming_soon.dart';
import 'package:gnml/UI/games_page/ui/mostly_anticipated/mostly_anticipated.dart';
import 'package:gnml/UI/games_page/ui/newly_released/newly_released.dart';
import 'package:gnml/UI/games_page/ui/popular_games/popular_games.dart';
import 'package:gnml/Widgets/circularprogressindicator.dart';
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
                    popularGames(
                      user,
                      gamesList,
                      themeColor,
                      moviesList,
                      seriesList,
                      booksList,
                      actorsList,
                      _pageController,
                    ),
                    newlyReleased(
                        user,
                        gamesList,
                        themeColor,
                        moviesList,
                        seriesList,
                        booksList,
                        actorsList,
                        pageControllerNewlyReleased),
                    comingSoon(
                        user,
                        gamesList,
                        themeColor,
                        moviesList,
                        seriesList,
                        booksList,
                        actorsList,
                        pageControllerComingSoon),
                    mostlyAnticipated(
                      user,
                      gamesList,
                      themeColor,
                      moviesList,
                      seriesList,
                      booksList,
                      actorsList,
                      pageControllerMostlyAnticipated,
                    ),
                  ],
                ),
              );
            } else {
              return const CustomCPI();
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
