import 'package:flutter/material.dart';
import 'package:vault/ui/widgets/home_showcase/home_hero_category.dart';

class HomeHeroSlideData {
  final String title;
  final String subtitle;
  final HomeHeroCategory category;
  final String? imageUrl;
  final String description;
  final int? gameAggregatedRating;
  final int? gameRating;
  final Widget Function()? onOpen;

  const HomeHeroSlideData({
    required this.title,
    required this.subtitle,
    required this.category,
    required this.imageUrl,
    required this.description,
    this.gameAggregatedRating,
    this.gameRating,
    required this.onOpen,
  });

  factory HomeHeroSlideData.skeleton() {
    return const HomeHeroSlideData(
      title: 'Loading',
      subtitle: 'Trending',
      category: HomeHeroCategory.games,
      imageUrl: null,
      description: 'Loading',
      gameAggregatedRating: null,
      gameRating: null,
      onOpen: null,
    );
  }
}
