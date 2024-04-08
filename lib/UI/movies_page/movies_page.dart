import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gnml/Helper/theme_helper.dart';
import 'package:gnml/UI/movies_page/ui/now_playing/now_playing.dart';
import 'package:gnml/UI/movies_page/ui/popular_movies/popular_movies.dart';
import 'package:gnml/UI/movies_page/ui/top_rated/top_rated.dart';
import 'package:gnml/UI/movies_page/ui/upcoming/upcoming.dart';
import 'package:gnml/Widgets/circularprogressindicator.dart';
import 'package:provider/provider.dart';

class MoviesPage extends StatefulWidget {
  const MoviesPage({Key? key}) : super(key: key);

  @override
  State<MoviesPage> createState() => _MoviesPageState();
}

class _MoviesPageState extends State<MoviesPage> {
  User? user = FirebaseAuth.instance.currentUser;

  bool boolean = false;
  late PageController _pageController;
  int pageIndexNowPlaying = 1;
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
                    popularMovies(user, moviesList, themeColor, gamesList,
                        seriesList, booksList, actorsList, _pageController),
                    nowPlayingMovies(user, moviesList, themeColor, gamesList,
                        seriesList, booksList, actorsList, pageIndexNowPlaying),
                    topRatedMovies(user, moviesList, themeColor, gamesList,
                        seriesList, booksList, actorsList, pageIndexTopRated),
                    upcomingMovies(user, moviesList, themeColor, gamesList,
                        seriesList, booksList, actorsList, pageIndexUpcoming),
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
