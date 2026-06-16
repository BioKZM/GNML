import 'package:flutter/material.dart';
import 'package:vault/ui/widgets/home_showcase/home_hero_category.dart';

class HomeHeroCategoryCard extends StatelessWidget {
  final HomeHeroCategory category;
  final bool isActive;
  final Color primaryColor;
  final VoidCallback onTap;

  const HomeHeroCategoryCard({
    super.key,
    required this.category,
    required this.isActive,
    required this.primaryColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(9),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        width: 34,
        height: 34,
        padding: EdgeInsets.zero,
        decoration: BoxDecoration(
          color: isActive
              ? primaryColor.withValues(alpha: 0.20)
              : Colors.white.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(9),
          border: Border.all(
            color: isActive
                ? primaryColor.withValues(alpha: 0.45)
                : Colors.white.withValues(alpha: 0.07),
          ),
        ),
        child: Center(
          child: Icon(
            category.icon,
            size: 15,
            color: isActive ? primaryColor : Colors.white70,
          ),
        ),
      ),
    );
  }
}
