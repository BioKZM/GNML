import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vault/Helper/theme_helper.dart';
import 'package:vault/Logic/animepage_logic.dart';
import 'package:vault/UI/Desktop/Details/anime_detail_page.dart';
import 'package:vault/Widgets/circularprogressindicator.dart';
import 'package:vault/Widgets/generic_content_card.dart';

class AnimesPage extends StatefulWidget {
  const AnimesPage({super.key});

  @override
  State<AnimesPage> createState() => _AnimesPageState();
}

class _AnimesPageState extends State<AnimesPage>
    with AutomaticKeepAliveClientMixin {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final AnimePageLogic _logic = AnimePageLogic();

  String _query = '';
  int _page = 1;
  bool _hasNextPage = false;
  bool _isLoading = false;
  bool _isLoadingMore = false;
  final List<dynamic> _items = [];

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_hasNextPage || _isLoadingMore || _isLoading) return;
    if (!_scrollController.hasClients) return;

    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 400) {
      _loadMore();
    }
  }

  Future<void> _search() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) {
      setState(() {
        _query = '';
        _page = 1;
        _hasNextPage = false;
        _items.clear();
      });
      return;
    }

    setState(() {
      _query = query;
      _page = 1;
      _isLoading = true;
      _hasNextPage = false;
      _items.clear();
    });

    final result = await _logic.searchAnime(query: _query, page: _page);
    if (!mounted) return;
    setState(() {
      _items.addAll(result.items);
      _hasNextPage = result.hasNextPage;
      _page = result.currentPage;
      _isLoading = false;
    });
  }

  Future<void> _loadMore() async {
    if (_query.isEmpty) return;
    setState(() => _isLoadingMore = true);

    final nextPage = _page + 1;
    final result = await _logic.searchAnime(query: _query, page: nextPage);
    if (!mounted) return;
    setState(() {
      _items.addAll(result.items);
      _hasNextPage = result.hasNextPage;
      _page = result.currentPage;
      _isLoadingMore = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final themeColor = Provider.of<ThemeProvider>(context).color;

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Search anime...',
                      hintStyle: const TextStyle(color: Colors.white38),
                      filled: true,
                      fillColor: const Color(0xFF1A1A1A),
                      prefixIcon:
                          const Icon(Icons.search, color: Colors.white54),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onSubmitted: (_) => _search(),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _search,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(themeColor),
                    foregroundColor: Colors.white,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Search'),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CustomCPI())
                : _items.isEmpty
                    ? const Center(
                        child: Text(
                          'Search for an anime to begin.',
                          style: TextStyle(color: Colors.white54),
                        ),
                      )
                    : Stack(
                        children: [
                          GridView.builder(
                            controller: _scrollController,
                            padding: const EdgeInsets.all(16),
                            gridDelegate:
                                const SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent: 220,
                              childAspectRatio: 0.7,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                            ),
                            itemCount: _items.length,
                            itemBuilder: (context, index) {
                              final item = _items[index];
                              return GenericContentCard(
                                item: item,
                                type: ContentType.anime,
                                themeColor: themeColor,
                                detailPage: AnimeDetailPage(animeId: item.id),
                              );
                            },
                          ),
                          if (_isLoadingMore)
                            const Positioned(
                              left: 0,
                              right: 0,
                              bottom: 24,
                              child: Center(child: CustomCPI()),
                            ),
                          if (!_isLoadingMore && _hasNextPage)
                            Positioned(
                              left: 0,
                              right: 0,
                              bottom: 24,
                              child: Center(
                                child: OutlinedButton(
                                  onPressed: _loadMore,
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.white,
                                    side: BorderSide(
                                      color: Color(themeColor)
                                          .withValues(alpha: 0.7),
                                    ),
                                  ),
                                  child: const Text('Daha fazla yükle'),
                                ),
                              ),
                            ),
                        ],
                      ),
          ),
        ],
      ),
    );
  }
}

