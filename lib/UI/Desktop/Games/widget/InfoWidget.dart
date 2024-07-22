import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:gnml/Data/Model/game_model.dart';

class InfoWidget extends StatelessWidget {
  const InfoWidget({
    super.key,
    required this.isHovering,
    required this.pageData,
    required this.dateTime,
    required this.innerIndex,
  });

  final ValueNotifier<bool> isHovering;
  final List<GameModel> pageData;
  final String dateTime;
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
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                pageData[innerIndex].name.toString(),
                                style: const TextStyle(fontSize: 18),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(dateTime,
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
