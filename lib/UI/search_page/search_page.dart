import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:gnml/Helper/theme_helper.dart';
import 'package:gnml/Data/firebase_user_data.dart';
import 'package:gnml/UI/search_page/search_actors/ui/search_actors_builder.dart';
import 'package:gnml/UI/search_page/search_books/ui/search_books_builder.dart';
import 'package:gnml/UI/search_page/search_games/ui/search_games_builder.dart';
import 'package:gnml/UI/search_page/search_movies/ui/search_movies_builder.dart';
import 'package:gnml/UI/search_page/search_series/ui/search_series_builder.dart';
import 'package:gnml/Widgets/circularprogressindicator.dart';
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
  late PageController searchGamesController;
  String searchText = "";
  int pageIndexMovies = 1;
  int pageIndexSeries = 1;
  int pageIndexActors = 1;

  @override
  void initState() {
    super.initState();
    searchGamesController = PageController(
      initialPage: 0,
    );
  }

  Future<void> updateData(
    List games,
    List movies,
    List series,
    List books,
    List actors,
  ) async {
    CollectionReference collectionReference =
        FirebaseFirestore.instance.collection('brews');
    DocumentReference documentReference =
        collectionReference.doc('${user?.email}');
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
                          return StatefulBuilder(builder: (context, snapshot) {
                            ValueNotifier<int> pageIndex =
                                ValueNotifier<int>(1);
                            if (buttonView == Buttons.games) {
                              return searchGamesBuilder(
                                user,
                                gamesList,
                                themeColor,
                                moviesList,
                                seriesList,
                                booksList,
                                actorsList,
                                pageIndex,
                                searchGamesController,
                                searchText,
                              );
                            } else if (buttonView == Buttons.movies) {
                              return searchMoviesBuilder(
                                user,
                                moviesList,
                                themeColor,
                                gamesList,
                                seriesList,
                                booksList,
                                actorsList,
                                pageIndexMovies,
                                searchText,
                              );
                            } else if (buttonView == Buttons.series) {
                              return searchSeriesBuilder(
                                  user,
                                  seriesList,
                                  themeColor,
                                  gamesList,
                                  moviesList,
                                  booksList,
                                  actorsList,
                                  pageIndexSeries,
                                  searchText);
                            } else if (buttonView == Buttons.actors) {
                              return searchActorsBuilder(
                                  user,
                                  actorsList,
                                  themeColor,
                                  gamesList,
                                  moviesList,
                                  seriesList,
                                  booksList,
                                  pageIndexActors,
                                  searchText);
                            } else if (buttonView == Buttons.books) {
                              return searchBooksBuilder(
                                  user,
                                  booksList,
                                  themeColor,
                                  gamesList,
                                  moviesList,
                                  seriesList,
                                  actorsList,
                                  searchText);
                            } else {
                              return const Center();
                            }
                          });
                        } else {
                          return const CustomCPI();
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



// Future<List<GameModel>> searchGames(String searchText) async {
//   return await GamePageLogic().searchGames(searchText);
// }
