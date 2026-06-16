import 'package:flutter/material.dart';

enum HomeHeroCategory {
  games('Games', Icons.sports_esports_rounded),
  movies('Movies', Icons.movie_creation_outlined),
  series('Series', Icons.live_tv_rounded),
  animes('Animes', Icons.auto_awesome_rounded);

  final String label;
  final IconData icon;

  const HomeHeroCategory(this.label, this.icon);
}
