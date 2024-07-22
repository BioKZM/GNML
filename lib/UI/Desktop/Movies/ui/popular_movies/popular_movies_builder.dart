import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gnml/Data/Model/movie_model.dart';
import 'package:gnml/Logic/moviepage_logic.dart';
import 'package:gnml/UI/Desktop/Movies/ui/popular_movies/widget/popular_movies_card.dart';
import 'package:gnml/Widgets/shimmerSmallCard.dart';

StatefulBuilder popularMoviesBuilder(
  User? user,
  List<dynamic> moviesList,
  Map<String, dynamic> favoritesList,
  int themeColor,
  List<dynamic> gamesList,
  List<dynamic> seriesList,
  List<dynamic> booksList,
  List<dynamic> actorsList,
  PageController pageController,
) {
  return StatefulBuilder(builder: (context, setState) {
    return Expanded(
      child: SizedBox(
        height: 200,
        width: double.infinity,
        child: FutureBuilder<List<MovieModel>>(
          future: MoviePageLogic().getPopularMovies(),
          builder: (context, snapshot) {
            if (snapshot.hasData &&
                snapshot.connectionState == ConnectionState.done) {
              var data = snapshot.data;
              return popularMoviesCards(
                  user,
                  data,
                  moviesList,
                  favoritesList,
                  themeColor,
                  gamesList,
                  seriesList,
                  booksList,
                  actorsList,
                  pageController);
            } else {
              bool connectionBool = true;
              if (snapshot.connectionState == ConnectionState.done) {
                connectionBool = false;
              }
              return Center(
                  child: connectionBool
                      ? const ShimmerEffectSmall()
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
                        ));
            }
          },
        ),
      ),
    );
  });
}
