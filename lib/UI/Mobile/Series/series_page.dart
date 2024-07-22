import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gnml/Helper/theme_helper.dart';
import 'package:gnml/UI/Desktop/Series/ui/airing_today/airing_today.dart';
import 'package:gnml/UI/Desktop/Series/ui/on_air/on_air.dart';
import 'package:gnml/UI/Desktop/Series/ui/popular_series/popular_series.dart';
import 'package:gnml/UI/Desktop/Series/ui/top_rated/top_rated.dart';
import 'package:gnml/Widgets/circularprogressindicator.dart';
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
            Map<String, dynamic> favoritesList = list['favorites'];
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
                  popularSeries(
                      user,
                      seriesList,
                      favoritesList,
                      themeColor,
                      gamesList,
                      moviesList,
                      booksList,
                      actorsList,
                      _pageController),
                  onAirSeries(
                      user,
                      seriesList,
                      favoritesList,
                      themeColor,
                      gamesList,
                      moviesList,
                      booksList,
                      actorsList,
                      pageIndexOnTheAir),
                  topRatedSeries(
                      user,
                      seriesList,
                      favoritesList,
                      themeColor,
                      gamesList,
                      moviesList,
                      booksList,
                      actorsList,
                      pageIndexTopRated),
                  airingTodaySeries(
                      user,
                      seriesList,
                      favoritesList,
                      themeColor,
                      gamesList,
                      moviesList,
                      booksList,
                      actorsList,
                      pageIndexOnTheAir),
                ],
              ),
            );
          } else {
            return const CustomCPI();
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
