import 'package:flutter/material.dart';
import 'package:vault/data/model/game_model.dart';
import 'package:intl/intl.dart';

class GamesData {
  getGameImageID(List<GameModel> pageData, int innerIndex) {
    String? imageId;
    if (pageData[innerIndex].image_id == "0") {
      imageId = "null";
    } else {
      imageId = pageData[innerIndex].image_id;
    }
    return imageId;
  }

  int getGameID(List<GameModel> pageData, int innerIndex) {
    var gameID = 0;
    if (pageData[innerIndex].id != null) {
      gameID = pageData[innerIndex].id!;
    }
    return gameID;
  }

  getGameReleaseDate(List<GameModel> pageData, int innerIndex) {
    dynamic dateTime;
    if (pageData[innerIndex].first_release_date == 0) {
      dateTime = "Bilinmiyor";
    } else {
      dateTime = DateTime.fromMillisecondsSinceEpoch(
          pageData[innerIndex].first_release_date! * 1000);
      dateTime = DateFormat('dd.MM.yyyy').format(dateTime);
    }
    return dateTime;
  }

  Widget gameCategoryCard(int? category) {
    Widget text = const Text("");
    Color color = Colors.transparent;
    switch (category) {
      case 0:
        text = const Text("Main Game");
        color = Colors.pink.withValues(alpha: 0.7);
      case 1:
        text = const Text("DLC");
        color = Colors.red.withValues(alpha: 0.7);
      case 2:
        text = const Text("Expansion");
        color = Colors.orange.withValues(alpha: 0.7);
      case 3:
        text = const Text("Bundle");
        color = Colors.deepOrange.withValues(alpha: 0.7);
      case 4:
        text = const Text("Standalone Expansion");
        color = Colors.yellow.withValues(alpha: 0.7);
      case 5:
        text = const Text("Mod");
        color = Colors.lime.withValues(alpha: 0.7);
      case 6:
        text = const Text("Episode");
        color = Colors.lightGreen.withValues(alpha: 0.7);
      case 7:
        text = const Text("Season");
        color = Colors.green.withValues(alpha: 0.7);
      case 8:
        text = const Text("Remake");
        color = Colors.teal.withValues(alpha: 0.7);
      case 9:
        text = const Text("Remaster");
        color = Colors.lightBlue.withValues(alpha: 0.7);
      case 10:
        text = const Text("Expanded Game");
        color = Colors.deepOrange.withValues(alpha: 0.7);
      case 11:
        text = const Text("Port");
        color = Colors.blue.withValues(alpha: 0.7);
      case 12:
        text = const Text("Fork");
        color = Colors.purple.withValues(alpha: 0.7);
      case 13:
        text = const Text("Pack");
        color = Colors.deepPurple.withValues(alpha: 0.7);
      case 14:
        text = const Text("Update");
        color = Colors.brown.withValues(alpha: 0.7);
      default:
        text = const Text("");
        color = Colors.transparent;
    }
    Widget gameCategoryCard = Card(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(5)),
      ),
      elevation: 0,
      color: color,
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: text,
      ),
    );
    return gameCategoryCard;
  }
}
