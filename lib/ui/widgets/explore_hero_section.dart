import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:vault/data/model/base_content_model.dart';

class ExploreHeroSection<T extends BaseContentModel> extends StatefulWidget {
  final Future<List<T>> future;
  final int themeColor;
  final String label;
  final Widget Function(T item) detailPageBuilder;
  final String Function(T item)? descriptionBuilder;

  const ExploreHeroSection({
    super.key,
    required this.future,
    required this.themeColor,
    required this.label,
    required this.detailPageBuilder,
    this.descriptionBuilder,
  });

  @override
  State<ExploreHeroSection<T>> createState() => _ExploreHeroSectionState<T>();
}

class _ExploreHeroSectionState<T extends BaseContentModel>
    extends State<ExploreHeroSection<T>> {
  late final PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Color(widget.themeColor);

    return SizedBox(
      height: 400,
      child: FutureBuilder<List<T>>(
        future: widget.future,
        builder: (context, snapshot) {
          final items = (snapshot.data ?? <T>[]).take(4).toList();
          final hasData = items.isNotEmpty;
          final slides = hasData ? items : List<T>.empty(growable: false);

          return Skeletonizer(
            enabled: snapshot.connectionState != ConnectionState.done,
            child: Row(
              children: [
                Expanded(
                  flex: 6,
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Stack(
                      children: [
                        if (hasData)
                          PageView.builder(
                            controller: _pageController,
                            onPageChanged: (index) {
                              setState(() {
                                _currentIndex = index;
                              });
                            },
                            itemCount: slides.length,
                            itemBuilder: (context, index) {
                              final item = slides[index];
                              return _buildHeroCard(
                                  context, item, primaryColor);
                            },
                          )
                        else
                          _buildPlaceholderHero(primaryColor),
                        Positioned(
                          bottom: 16,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.4),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.1),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: List.generate(
                                  hasData ? slides.length : 3,
                                  (index) {
                                    return AnimatedContainer(
                                      duration:
                                          const Duration(milliseconds: 300),
                                      margin: const EdgeInsets.symmetric(
                                        horizontal: 4,
                                      ),
                                      height: 8,
                                      width: _currentIndex == index ? 24 : 8,
                                      decoration: BoxDecoration(
                                        color: _currentIndex == index
                                            ? primaryColor
                                            : Colors.white.withValues(
                                                alpha: 0.5,
                                              ),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  flex: 4,
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1A1A),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.05),
                      ),
                    ),
                    child: hasData
                        ? _buildSidePanel(
                            context, slides[_currentIndex], primaryColor)
                        : _buildPlaceholderPanel(primaryColor),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeroCard(BuildContext context, T item, Color primaryColor) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => widget.detailPageBuilder(item),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          image: item.imageURL != null
              ? DecorationImage(
                  image: CachedNetworkImageProvider(item.imageURL!),
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                )
              : null,
          color: const Color(0xFF1E1E1E),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                const Color(0xFF121212).withValues(alpha: 0.95),
                const Color(0xFF121212).withValues(alpha: 0.7),
                const Color(0xFF121212).withValues(alpha: 0.1),
              ],
              stops: const [0.0, 0.4, 1.0],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    widget.label.toUpperCase(),
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  item.title ?? 'Unknown Title',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.orbitron(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  _descriptionFor(item),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    color: Colors.white70,
                    fontSize: 16,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSidePanel(BuildContext context, T item, Color primaryColor) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Explore ${widget.label}',
          style: GoogleFonts.inter(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          _descriptionFor(item),
          maxLines: 4,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.inter(
            color: Colors.white70,
            fontSize: 12,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => widget.detailPageBuilder(item),
              ),
            );
          },
          icon: const Icon(Icons.explore, color: Colors.white),
          label: const Text(
            'Open Details',
            style: TextStyle(color: Colors.white),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPlaceholderHero(Color primaryColor) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: const Color(0xFF1E1E1E),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              const Color(0xFF121212).withValues(alpha: 0.95),
              const Color(0xFF121212).withValues(alpha: 0.7),
              const Color(0xFF121212).withValues(alpha: 0.1),
            ],
            stops: const [0.0, 0.4, 1.0],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 80,
                height: 24,
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: 280,
                height: 32,
                color: Colors.white.withValues(alpha: 0.08),
              ),
              const SizedBox(height: 12),
              Container(
                width: 340,
                height: 16,
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholderPanel(Color primaryColor) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 140,
          height: 20,
          color: Colors.white.withValues(alpha: 0.08),
        ),
        const SizedBox(height: 12),
        Container(
          width: 220,
          height: 14,
          color: Colors.white.withValues(alpha: 0.08),
        ),
        const SizedBox(height: 8),
        Container(
          width: 200,
          height: 14,
          color: Colors.white.withValues(alpha: 0.08),
        ),
        const SizedBox(height: 16),
        Container(
          width: 140,
          height: 42,
          decoration: BoxDecoration(
            color: primaryColor,
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ],
    );
  }

  String _descriptionFor(T item) {
    if (widget.descriptionBuilder != null) {
      return widget.descriptionBuilder!(item);
    }
    final title = item.title ?? widget.label;
    return '$title is waiting for a closer look. Start here and keep building your collection.';
  }
}
