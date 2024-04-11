import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gnml/UI/library_page/ui/card_view/widget/get_games_from_library.dart';

Card gameCardsTile(
  User? user,
  List<dynamic> gamesList,
  int supportedLength,
  BuildContext context,
  int themeColor,
  List<dynamic> moviesList,
  List<dynamic> seriesList,
  List<dynamic> booksList,
  List<dynamic> actorsList,
  // Animation<double> animation,
) {
  return Card(
    color: Colors.grey.withOpacity(0.2),
    child: Theme(
      data: ThemeData(
        highlightColor: Colors.transparent,
        hoverColor: Colors.transparent,
        splashColor: Colors.transparent,
      ),
      child: ExpansionTile(
        initiallyExpanded: true,
        textColor: Colors.white,
        collapsedTextColor: Colors.white,
        collapsedIconColor: Colors.white,
        iconColor: Colors.white,
        title: const Text(
          "Games",
          style: TextStyle(
            color: Colors.white,
            fontFamily: "RobotoBold",
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        children: List.generate(
          (gamesList.length / supportedLength).ceil(),
          (rowIndex) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(
                supportedLength,
                (colIndex) {
                  final index = rowIndex * supportedLength + colIndex;
                  if (index < gamesList.length) {
                    return getGamesFromLibrary(
                        gamesList,
                        index,
                        context,
                        themeColor,
                        user,
                        moviesList,
                        seriesList,
                        booksList,
                        actorsList);
                  } else {
                    return const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: GridTile(
                        child: Column(
                          children: [
                            SizedBox(
                              height: 225,
                              width: 150,
                            )
                          ],
                        ),
                      ),
                    );
                  }
                },
              ),
            );
          },
        ),
      ),
    ),
  );
}
