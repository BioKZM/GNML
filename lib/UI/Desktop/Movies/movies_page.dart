import 'package:flutter/material.dart';
import 'package:vault/Helper/theme_helper.dart';
import 'package:vault/Logic/moviepage_logic.dart';
import 'package:vault/UI/Desktop/Details/movie_detail_page.dart';
import 'package:vault/Widgets/content_builder.dart';
import 'package:vault/Widgets/content_section.dart';
import 'package:vault/Widgets/generic_content_card.dart';
import 'package:provider/provider.dart';

class MoviesPage extends StatefulWidget {
  const MoviesPage({Key? key}) : super(key: key);

  @override
  State<MoviesPage> createState() => _MoviesPageState();
}

class _MoviesPageState extends State<MoviesPage>
    with AutomaticKeepAliveClientMixin {
  late PageController _popularController;
  late PageController _nowPlayingController;
  late PageController _upcomingController;
  late PageController _topRatedController;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _popularController = PageController();
    _nowPlayingController = PageController();
    _upcomingController = PageController();
    _topRatedController = PageController();
  }

  @override
  void dispose() {
    _popularController.dispose();
    _nowPlayingController.dispose();
    _upcomingController.dispose();
    _topRatedController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    int themeColor = Provider.of<ThemeProvider>(context).color;
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  onPressed: () => setState(() {}),
                  icon: const Icon(Icons.refresh),
                ),
              ],
            ),
            _buildSection(
              "Popular Movies",
              MoviePageLogic().getPopularMovies(),
              _popularController,
              themeColor,
            ),
            _buildSection(
              "Now Playing",
              MoviePageLogic().getNowPlayingMovies(1),
              _nowPlayingController,
              themeColor,
            ),
            _buildSection(
              "Upcoming Movies",
              MoviePageLogic().getUpcomingMovies(1),
              _upcomingController,
              themeColor,
            ),
            _buildSection(
              "Top Rated Movies",
              MoviePageLogic().getTopRatedMovies(1),
              _topRatedController,
              themeColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, Future<List<dynamic>> future,
      PageController controller, int themeColor) {
    return ContentSection(
      title: title,
      pageController: controller,
      child: ContentBuilder(
        future: future,
        onRetry: () => setState(() {}),
        builder: (context, data) {
          return ListView.builder(
            controller: controller,
            scrollDirection: Axis.horizontal,
            itemCount: data.length,
            itemBuilder: (context, index) {
              final item = data[index];
              return GenericContentCard(
                item: item,
                type: ContentType.movies,
                themeColor: themeColor,
                detailPage: MovieDetailPage(movieID: item.id!),
              );
            },
          );
        },
      ),
    );
  }
}
