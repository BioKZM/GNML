import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gnml/Data/firebase_user_data.dart';
import 'package:gnml/Helper/theme_helper.dart';
import 'package:gnml/UI/Movies/ui/now_playing/now_playing.dart';
import 'package:gnml/UI/Movies/ui/popular_movies/popular_movies.dart';
import 'package:gnml/UI/Movies/ui/top_rated/top_rated.dart';
import 'package:gnml/UI/Movies/ui/upcoming/upcoming.dart';
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

  @override
  Widget build(BuildContext context) {
    int themeColor = Provider.of<ThemeProvider>(context).color;
    return Scaffold(
      body: FutureBuilder(
          future: FirebaseUserData(user: user).getData(),
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
                    popularMovies(
                        user,
                        moviesList,
                        themeColor,
                        favoritesList,
                        gamesList,
                        seriesList,
                        booksList,
                        actorsList,
                        _pageController),
                    nowPlayingMovies(
                        user,
                        moviesList,
                        favoritesList,
                        themeColor,
                        gamesList,
                        seriesList,
                        booksList,
                        actorsList,
                        pageIndexNowPlaying),
                    topRatedMovies(
                        user,
                        moviesList,
                        favoritesList,
                        themeColor,
                        gamesList,
                        seriesList,
                        booksList,
                        actorsList,
                        pageIndexTopRated),
                    upcomingMovies(
                        user,
                        moviesList,
                        favoritesList,
                        themeColor,
                        gamesList,
                        seriesList,
                        booksList,
                        actorsList,
                        pageIndexUpcoming),
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
