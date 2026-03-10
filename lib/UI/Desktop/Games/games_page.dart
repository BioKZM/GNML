import 'package:flutter/material.dart';
import 'package:vault/Helper/theme_helper.dart';
import 'package:vault/Logic/gamepage_logic.dart';
import 'package:vault/UI/Desktop/Details/game_detail_page.dart';
import 'package:vault/Widgets/content_builder.dart';
import 'package:vault/Widgets/content_section.dart';
import 'package:vault/Widgets/generic_content_card.dart';
import 'package:provider/provider.dart';

class GamesPage extends StatefulWidget {
  const GamesPage({Key? key}) : super(key: key);

  @override
  State<GamesPage> createState() => _GamesPageState();
}

class _GamesPageState extends State<GamesPage>
    with AutomaticKeepAliveClientMixin {
  late PageController _popularController;
  late PageController _newlyReleasedController;
  late PageController _comingSoonController;
  late PageController _mostlyAnticipatedController;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _popularController = PageController();
    _newlyReleasedController = PageController();
    _comingSoonController = PageController();
    _mostlyAnticipatedController = PageController();
  }

  @override
  void dispose() {
    _popularController.dispose();
    _newlyReleasedController.dispose();
    _comingSoonController.dispose();
    _mostlyAnticipatedController.dispose();
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
              "Popular Games",
              GamePageLogic().getPopularGameList("popularRightNow"),
              _popularController,
              themeColor,
            ),
            _buildSection(
              "Newly Released",
              GamePageLogic().getPopularGameList("newlyReleased"),
              _newlyReleasedController,
              themeColor,
            ),
            _buildSection(
              "Coming Soon",
              GamePageLogic().getPopularGameList("comingSoon"),
              _comingSoonController,
              themeColor,
            ),
            _buildSection(
              "Mostly Anticipated",
              GamePageLogic().getPopularGameList("mostlyAnticipated"),
              _mostlyAnticipatedController,
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
                type: ContentType.games,
                themeColor: themeColor,
                detailPage: GameDetailPage(gameID: item.id),
              );
            },
          );
        },
      ),
    );
  }
}
