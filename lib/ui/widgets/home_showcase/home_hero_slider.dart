import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vault/ui/widgets/home_showcase/home_hero_category.dart';
import 'package:vault/ui/widgets/home_showcase/home_hero_category_card.dart';
import 'package:vault/ui/widgets/home_showcase/home_hero_slide_data.dart';
import 'package:vault/ui/widgets/home_showcase/home_hero_thumb_card.dart';
import 'package:vault/ui/widgets/home_showcase/showcase_image_url.dart';

class HomeHeroSlider extends StatefulWidget {
  final Color primaryColor;
  final List<HomeHeroSlideData> slides;

  const HomeHeroSlider({
    super.key,
    required this.primaryColor,
    required this.slides,
  });

  @override
  State<HomeHeroSlider> createState() => _HomeHeroSliderState();
}

class _HomeHeroSliderState extends State<HomeHeroSlider> {
  late final PageController _controller;
  Timer? _timer;
  int _currentIndex = 0;
  HomeHeroCategory _activeCategory = HomeHeroCategory.games;
  int _progressSeed = 0;

  @override
  void initState() {
    super.initState();
    _controller = PageController();
    _activeCategory = _firstAvailableCategory(widget.slides);
    _startTimer();
  }

  @override
  void didUpdateWidget(covariant HomeHeroSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.slides.length != widget.slides.length ||
        !_slidesForCategory(widget.slides, _activeCategory).isNotEmpty) {
      _currentIndex = 0;
      _activeCategory = _firstAvailableCategory(widget.slides);
      _startTimer();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer(const Duration(seconds: 6), () {
      final visibleSlides = _slidesForCategory(widget.slides, _activeCategory);
      if (!_controller.hasClients || visibleSlides.length <= 1) return;
      final next = (_currentIndex + 1) % visibleSlides.length;
      _controller.animateToPage(
        next,
        duration: const Duration(milliseconds: 700),
        curve: Curves.easeInOutCubic,
      );
    });
  }

  void _jumpToIndex(int index) {
    if (!_controller.hasClients) return;
    _timer?.cancel();
    if (index == _currentIndex) {
      setState(() {
        _progressSeed++;
      });
      _startTimer();
      return;
    }
    _controller.animateToPage(
      index,
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOutCubic,
    );
  }

  List<HomeHeroSlideData> _slidesForCategory(
    List<HomeHeroSlideData> slides,
    HomeHeroCategory category,
  ) {
    return slides.where((slide) => slide.category == category).take(5).toList();
  }

  HomeHeroCategory _firstAvailableCategory(List<HomeHeroSlideData> slides) {
    for (final category in HomeHeroCategory.values) {
      if (_slidesForCategory(slides, category).isNotEmpty) {
        return category;
      }
    }
    return HomeHeroCategory.games;
  }

  void _selectCategory(
    List<HomeHeroSlideData> slides,
    HomeHeroCategory category,
  ) {
    final visibleSlides = _slidesForCategory(slides, category);
    if (visibleSlides.isEmpty) return;
    setState(() {
      _activeCategory = category;
      _currentIndex = 0;
      _progressSeed++;
    });
    if (_controller.hasClients) {
      _controller.jumpToPage(0);
    }
    _startTimer();
  }

  Widget _buildImage(String imageUrl) {
    if (kIsWeb) {
      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
        alignment: Alignment.topCenter,
        errorBuilder: (context, error, stackTrace) => Container(
          alignment: Alignment.center,
          color: Colors.grey[850],
          child: const Icon(
            Icons.image_not_supported_rounded,
            color: Colors.white38,
          ),
        ),
      );
    }

    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: BoxFit.cover,
      alignment: Alignment.topCenter,
      placeholder: (context, url) => Container(
        color: Colors.grey[850],
        alignment: Alignment.center,
        child: const SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
      errorWidget: (context, url, error) => Container(
        alignment: Alignment.center,
        color: Colors.grey[850],
        child: const Icon(
          Icons.image_not_supported_rounded,
          color: Colors.white38,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final allSlides = widget.slides.isEmpty
        ? <HomeHeroSlideData>[HomeHeroSlideData.skeleton()]
        : widget.slides;
    final visibleSlides = _slidesForCategory(allSlides, _activeCategory);
    final slides = visibleSlides.isEmpty
        ? <HomeHeroSlideData>[HomeHeroSlideData.skeleton()]
        : visibleSlides;
    final current = slides[_currentIndex.clamp(0, slides.length - 1)];

    return Column(
      children: [
        SizedBox(
          height: 560,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              PageView.builder(
                controller: _controller,
                itemCount: slides.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                    _progressSeed++;
                  });
                  _startTimer();
                },
                itemBuilder: (context, index) {
                  final slide = slides[index];
                  final imageUrl = optimizeShowcaseImageUrl(slide.imageUrl);
                  final hasImage = imageUrl.isNotEmpty && !imageUrl.endsWith('/null');
                  return GestureDetector(
                    onTap: slide.onOpen == null
                        ? null
                        : () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => slide.onOpen!(),
                              ),
                            );
                          },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: const Color(0xFF1E1E1E),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.08),
                        ),
                      ),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          if (hasImage)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: _buildImage(imageUrl),
                            ),
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              gradient: LinearGradient(
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                                colors: [
                                  const Color(0xFF121212).withValues(alpha: 0.98),
                                  const Color(0xFF121212).withValues(alpha: 0.78),
                                  const Color(0xFF121212).withValues(alpha: 0.18),
                                ],
                                stops: const [0.0, 0.48, 1.0],
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(48, 84, 48, 40),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: widget.primaryColor,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    slide.subtitle.toUpperCase(),
                                    style: GoogleFonts.inter(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 11,
                                      letterSpacing: 1.5,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 18),
                                Text(
                                  slide.title,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.orbitron(
                                    color: Colors.white,
                                    fontSize: 48,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                const SizedBox(height: 18),
                                SizedBox(
                                  width: 720,
                                  child: Text(
                                    slide.description,
                                    maxLines: 5,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.inter(
                                      color: Colors.white70,
                                      fontSize: 16,
                                      height: 1.55,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 24),
                                ElevatedButton.icon(
                                  onPressed: current.onOpen == null
                                      ? null
                                      : () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => current.onOpen!(),
                                            ),
                                          );
                                        },
                                  icon: const Icon(
                                    Icons.open_in_new_rounded,
                                    color: Colors.white,
                                  ),
                                  label: const Text(
                                    'Open Details',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: widget.primaryColor,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 22,
                                      vertical: 16,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              Positioned(
                top: 14,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.24),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: HomeHeroCategory.values.asMap().entries.map((entry) {
                        final index = entry.key;
                        final category = entry.value;
                        return Padding(
                          padding: EdgeInsets.only(
                            right: index == HomeHeroCategory.values.length - 1 ? 0 : 6,
                          ),
                          child: HomeHeroCategoryCard(
                            category: category,
                            isActive: _activeCategory == category,
                            primaryColor: widget.primaryColor,
                            onTap: () => _selectCategory(allSlides, category),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        SizedBox(
          height: 128,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(slides.length, (index) {
              final slide = slides[index];
              return Padding(
                padding: EdgeInsets.only(
                  right: index == slides.length - 1 ? 0 : 12,
                ),
                child: SizedBox(
                  width: 164,
                  child: HomeHeroThumbCard(
                    slide: slide,
                    isActive: _currentIndex == index,
                    primaryColor: widget.primaryColor,
                    progressSeed: _progressSeed,
                    onTap: () => _jumpToIndex(index),
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}
