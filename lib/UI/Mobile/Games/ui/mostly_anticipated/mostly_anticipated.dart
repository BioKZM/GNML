import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gnml/UI/Desktop/Games/ui/mostly_anticipated/mostly_anticipated_builder.dart';

Padding mostlyAnticipated(
    User? user,
    List<dynamic> gamesList,
    Map<String, dynamic> favoritesList,
    int themeColor,
    List<dynamic> moviesList,
    List<dynamic> seriesList,
    List<dynamic> booksList,
    List<dynamic> actorsList,
    PageController pageControllerMostlyAnticipated) {
  return Padding(
    padding: const EdgeInsets.all(24),
    child: SizedBox(
      width: double.infinity,
      height: 1100,
      child: Card(
        elevation: 5,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Card(
                    color:
                        const Color.fromARGB(255, 0, 116, 0).withOpacity(0.5),
                    elevation: 0,
                    child: const Padding(
                      padding: EdgeInsets.fromLTRB(16, 4, 16, 4),
                      child: Text(
                        "Mostly Anticipated",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    )),
              ),
            ),
            mostlyAnticipatedBuilder(
              user,
              gamesList,
              favoritesList,
              themeColor,
              moviesList,
              seriesList,
              booksList,
              actorsList,
              pageControllerMostlyAnticipated,
            ),
          ],
        ),
      ),
    ),
  );
}
