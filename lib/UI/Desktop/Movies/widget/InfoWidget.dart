import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:gnml/UI/Desktop/Details/movie_detail_page.dart';

class InfoWidget extends StatelessWidget {
  const InfoWidget({
    super.key,
    required this.isHovering,
    required this.data,
    required this.innerIndex,
  });

  final ValueNotifier<bool> isHovering;
  final data;
  final int innerIndex;
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: isHovering,
      builder: (context, value, child) {
        return isHovering.value
            ? Positioned(
                bottom: -1,
                child: SizedBox(
                  height: 110,
                  width: 354,
                  child: Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(0)),
                    elevation: 0,
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 400, sigmaY: 400),
                      blendMode: BlendMode.exclusion,
                      child: Container(
                        color: Colors.black,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                data[innerIndex].title.toString(),
                                style: const TextStyle(fontSize: 18),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(getReleaseDate(data[innerIndex]),
                                  style: const TextStyle(fontSize: 12)),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              )
            : const SizedBox();
      },
    );
  }
}
