import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vault/data/model/anime_model.dart';

import 'package:vault/Helper/theme_helper.dart';
import 'package:vault/Logic/animepage_logic.dart';
import 'package:vault/ui/Desktop/Details/anime_detail_page.dart';
import 'package:vault/ui/widgets/circularprogressindicator.dart';
import 'package:vault/ui/widgets/content_builder.dart';
import 'package:vault/ui/widgets/content_section.dart';
import 'package:vault/ui/widgets/explore_hero_section.dart';
import 'package:vault/ui/widgets/generic_content_card.dart';

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

  late PageController _topController;
  late PageController _freshController;
  late PageController _communityController;
  late PageController _moreController;
  late Future<List<AnimeModel>> _topAnimeFuture;
  late Future<List<AnimeModel>> _freshAnimeFuture;
  late Future<List<AnimeModel>> _communityAnimeFuture;
  late Future<List<AnimeModel>> _moreAnimeFuture;

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
    _topController = PageController();
    _freshController = PageController();
    _communityController = PageController();
    _moreController = PageController();
    _topAnimeFuture = _safeTopAnimes(page: 1, limit: 20);
    _freshAnimeFuture = _safeTopAnimes(page: 2, limit: 20);
    _communityAnimeFuture = _safeTopAnimes(page: 3, limit: 20);
    _moreAnimeFuture = _safeTopAnimes(page: 4, limit: 20);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _topController.dispose();
    _freshController.dispose();
    _communityController.dispose();
    _moreController.dispose();
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
        _isLoading = false;
        _isLoadingMore = false;
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

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _query = '';
      _page = 1;
      _hasNextPage = false;
      _isLoading = false;
      _isLoadingMore = false;
      _items.clear();
    });
  }

  Future<List<AnimeModel>> _safeTopAnimes({
    required int page,
    required int limit,
  }) {
    return _logic
        .getTopAnimes(page: page, limit: limit)
        .catchError((_) => <AnimeModel>[]);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final themeColor = Provider.of<ThemeProvider>(context).color;

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: SingleChildScrollView(
        controller: _query.isEmpty ? null : _scrollController,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: ExploreHeroSection(
                future: _topAnimeFuture,
                themeColor: themeColor,
                label: 'Anime',
                detailPageBuilder: (item) => AnimeDetailPage(animeId: item.id!),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
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
                        suffixIcon: _query.isNotEmpty
                            ? IconButton(
                                onPressed: _clearSearch,
                                icon: const Icon(
                                  Icons.close,
                                  color: Colors.white54,
                                ),
                              )
                            : null,
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
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(_query.isEmpty ? 'Search' : 'Refresh'),
                  ),
                ],
              ),
            ),
            if (_query.isEmpty) ...[
              _buildSection(
                'Top Anime',
                _topAnimeFuture,
                _topController,
                themeColor,
              ),
              _buildSection(
                'Fresh Picks',
                _freshAnimeFuture,
                _freshController,
                themeColor,
              ),
              _buildSection(
                'Community Favorites',
                _communityAnimeFuture,
                _communityController,
                themeColor,
              ),
              _buildSection(
                'More To Watch',
                _moreAnimeFuture,
                _moreController,
                themeColor,
              ),
            ] else ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Search Results',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                ),
              ),
              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 48),
                  child: Center(child: CustomCPI()),
                )
              else if (_items.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 48),
                  child: Center(
                    child: Text(
                      'No anime found for this search.',
                      style: TextStyle(color: Colors.white54),
                    ),
                  ),
                )
              else
                Stack(
                  children: [
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
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
                  ],
                ),
              if (!_isLoading && !_isLoadingMore && _hasNextPage)
                Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: OutlinedButton(
                    onPressed: _loadMore,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: BorderSide(
                        color: Color(themeColor).withValues(alpha: 0.7),
                      ),
                    ),
                    child: const Text('Load more'),
                  ),
                ),
            ],
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
                type: ContentType.anime,
                themeColor: themeColor,
                detailPage: AnimeDetailPage(animeId: item.id!),
              );
            },
          );
        },
      ),
    );
  }
}
