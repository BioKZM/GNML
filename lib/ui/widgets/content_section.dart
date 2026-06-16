import 'package:flutter/material.dart';

class ContentSection extends StatelessWidget {
  final String title;
  final Widget child;
  final PageController? pageController;
  final VoidCallback? onRefresh;

  const ContentSection({
    Key? key,
    required this.title,
    required this.child,
    this.pageController,
    this.onRefresh,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 2, bottom: 14),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.04),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.06),
                    ),
                  ),
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (onRefresh != null) ...[
                  const SizedBox(width: 10),
                  IconButton(
                    onPressed: onRefresh,
                    icon: const Icon(Icons.refresh, size: 18),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ],
            ),
          ),
          Row(
            children: [
              if (pageController != null)
                _buildSectionArrow(
                  icon: Icons.arrow_left,
                  onPressed: () {
                    pageController!.previousPage(
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.ease,
                    );
                  },
                ),
              Expanded(child: child),
              if (pageController != null)
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: _buildSectionArrow(
                    icon: Icons.arrow_right,
                    onPressed: () {
                      pageController!.nextPage(
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.ease,
                      );
                    },
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionArrow({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: 40,
      height: 40,
      margin: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: IconButton(
        icon: Icon(icon, size: 18),
        onPressed: onPressed,
      ),
    );
  }
}
