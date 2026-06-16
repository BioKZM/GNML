import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:vault/Helper/theme_helper.dart';
import 'package:vault/Logic/actorpage_logic.dart';
import 'package:vault/Logic/bookspage_logic.dart';
import 'package:vault/Logic/gamepage_logic.dart';
import 'package:vault/Logic/moviepage_logic.dart';
import 'package:vault/Logic/seriespage_logic.dart';
import 'package:vault/ui/Desktop/Details/actors_detail_page.dart';
import 'package:vault/ui/Desktop/Details/books_detail_page.dart';
import 'package:vault/ui/Desktop/Details/game_detail_page.dart';
import 'package:vault/ui/Desktop/Details/movie_detail_page.dart';
import 'package:vault/ui/Desktop/Details/serie_detail_page.dart';
import 'package:vault/ui/widgets/content_builder.dart';
import 'package:vault/ui/widgets/generic_content_card.dart';
import 'package:provider/provider.dart';

enum Buttons { games, movies, series, actors, books }

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  Buttons buttonView = Buttons.games;
  TextEditingController searchController = TextEditingController();
  String searchText = "";
  int _page = 1;

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
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SegmentedButton<Buttons>(
                    showSelectedIcon: false,
                    segments: const [
                      ButtonSegment(
                          value: Buttons.games,
                          label: Text("Oyunlar"),
                          icon: Icon(FluentIcons.games_24_filled)),
                      ButtonSegment(
                          value: Buttons.movies,
                          label: Text("Filmler"),
                          icon: Icon(FluentIcons.movies_and_tv_24_filled)),
                      ButtonSegment(
                          value: Buttons.series,
                          label: Text("Diziler"),
                          icon: Icon(FluentIcons.video_clip_24_filled)),
                      ButtonSegment(
                          value: Buttons.actors,
                          label: Text("Oyuncular"),
                          icon: Icon(FluentIcons.person_24_filled)),
                      ButtonSegment(
                          value: Buttons.books,
                          label: Text("Kitaplar"),
                          icon: Icon(FluentIcons.book_24_filled)),
                    ],
                    selected: {buttonView},
                    onSelectionChanged: (newSelection) {
                      setState(() {
                        buttonView = newSelection.first;
                        searchText = "";
                        searchController.clear();
                        _page = 1;
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
                          labelText: 'Ara',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                        onSubmitted: (value) => setState(() {
                          searchText = value;
                          _page = 1;
                        }),
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
              child: Card(
                elevation: 5,
                child: searchText.isEmpty
                    ? const Center(child: Text("Search for something..."))
                    : _buildSearchResults(themeColor),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults(int themeColor) {
    Future<List<dynamic>> future;
    ContentType type;
    Widget Function(dynamic) detailPageBuilder;

    switch (buttonView) {
      case Buttons.games:
        future = GamePageLogic().searchGames(searchText);
        type = ContentType.games;
        detailPageBuilder = (item) => GameDetailPage(gameID: item.id);
        break;
      case Buttons.movies:
        future = MoviePageLogic().searchMovies(searchText, _page);
        type = ContentType.movies;
        detailPageBuilder = (item) => MovieDetailPage(movieID: item.id);
        break;
      case Buttons.series:
        future = SeriesPageLogic().searchSeries(searchText, _page);
        type = ContentType.series;
        detailPageBuilder = (item) => SerieDetailPage(serieID: item.id);
        break;
      case Buttons.actors:
        future = ActorPageLogic().searchActors(searchText, _page);
        type = ContentType.actors;
        detailPageBuilder = (item) => ActorDetailPage(actorID: item.id);
        break;
      case Buttons.books:
        future = BooksPageLogic().searchBooks(searchText);
        type = ContentType.books;
        detailPageBuilder = (item) => BooksDetailPage(bookID: item.id);
        break;
    }

    return ContentBuilder(
      future: future,
      onRetry: () => setState(() {}),
      builder: (context, data) {
        if (data.isEmpty) return const Center(child: Text("No results found"));
        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 200,
            childAspectRatio: 0.7,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: data.length,
          itemBuilder: (context, index) {
            final item = data[index];
            return GenericContentCard(
              item: item,
              type: type,
              themeColor: themeColor,
              detailPage: detailPageBuilder(item),
            );
          },
        );
      },
    );
  }
}

// Future<List<GameModel>> searchGames(String searchText) async {
//   return await GamePageLogic().searchGames(searchText);
// }
