import 'package:flutter/material.dart';
import 'package:vault/Helper/theme_helper.dart';
import 'package:vault/Logic/seriespage_logic.dart';
import 'package:vault/UI/Desktop/Details/serie_detail_page.dart';
import 'package:vault/Widgets/content_builder.dart';
import 'package:vault/Widgets/content_section.dart';
import 'package:vault/Widgets/generic_content_card.dart';
import 'package:provider/provider.dart';

class SeriesPage extends StatefulWidget {
  const SeriesPage({Key? key}) : super(key: key);

  @override
  State<SeriesPage> createState() => _SeriesPageState();
}

class _SeriesPageState extends State<SeriesPage>
    with AutomaticKeepAliveClientMixin {
  late PageController _popularController;
  late PageController _onAirController;
  late PageController _topRatedController;
  late PageController _airingTodayController;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _popularController = PageController();
    _onAirController = PageController();
    _topRatedController = PageController();
    _airingTodayController = PageController();
  }

  @override
  void dispose() {
    _popularController.dispose();
    _onAirController.dispose();
    _topRatedController.dispose();
    _airingTodayController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final themeColor = Provider.of<ThemeProvider>(context).color;
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
              "Popular Series",
              SeriesPageLogic().getPopularSeries(),
              _popularController,
              themeColor,
            ),
            _buildSection(
              "On The Air",
              SeriesPageLogic().getOnTheAirSeries(1),
              _onAirController,
              themeColor,
            ),
            _buildSection(
              "Airing Today",
              SeriesPageLogic().getAiringTodaySeries(1),
              _airingTodayController,
              themeColor,
            ),
            _buildSection(
              "Top Rated Series",
              SeriesPageLogic().getTopRatedSeries(1),
              _topRatedController,
              themeColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    String title,
    Future<List<dynamic>> future,
    PageController controller,
    int themeColor,
  ) {
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
                type: ContentType.series,
                themeColor: themeColor,
                detailPage: SerieDetailPage(serieID: item.id!),
              );
            },
          );
        },
      ),
    );
  }
}
