import 'package:flutter/gestures.dart';
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
    return Listener(
      onPointerSignal: (pointerSignal) {
        if (pointerSignal is PointerScrollEvent) {
          if (pageController != null && pageController!.hasClients) {
            final double scrollDelta = pointerSignal.scrollDelta.dy;
            if (scrollDelta > 0) {
              pageController!.nextPage(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOut);
            } else if (scrollDelta < 0) {
              pageController!.previousPage(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOut);
            }
          }
        }
      },
      child: Card(
        elevation: 5,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Card(
                  elevation: 0,
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        if (onRefresh != null)
                          IconButton(
                            onPressed: onRefresh,
                            icon: const Icon(Icons.refresh, size: 18),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              Row(
                children: [
                  if (pageController != null)
                    IconButton(
                      icon: const Icon(Icons.arrow_left),
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
                      child: IconButton(
                        icon: const Icon(Icons.arrow_right),
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
        ),
      ),
    );
  }
}
