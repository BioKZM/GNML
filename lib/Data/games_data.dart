import 'package:flutter/material.dart';
import 'package:gnml/Data/Model/game_model.dart';
import 'package:intl/intl.dart';

class GamesData {
  getGameImageID(List<GameModel> pageData, int innerIndex) {
    var imageId;
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
    var dateTime;
    if (pageData[innerIndex].first_release_date == 0) {
      dateTime = "Bilinmiyor";
    } else {
      dateTime = DateTime.fromMillisecondsSinceEpoch(
          pageData[innerIndex].first_release_date! * 1000);
      dateTime = DateFormat('dd.MM.yyyy').format(dateTime);
    }
    return dateTime;
  }

  void addFavoritesFromData(List<dynamic> gamesList, List<GameModel> pageData,
      int innerIndex, ValueNotifier<bool> isFavorite) {
    for (var x in gamesList) {
      if (x['gameID'] == pageData[innerIndex].id) {
        isFavorite.value = true;
      }
    }
  }

  void addFavoritesFromList(
      List<dynamic> gamesList,
      List<dynamic>? favoriteGames,
      int index,
      ValueNotifier<bool> isFavorited) {
    for (var x in favoriteGames!) {
      if (x['gameID'] == gamesList[index]['gameID']) {
        isFavorited.value = true;
      }
    }
  }

  void removeFromGameList(List<dynamic> gamesList, int? gameID) {
    gamesList.removeWhere((element) => element['gameID'] == gameID);
  }

  Map<String, dynamic> getGameMap(
      List<GameModel> pageData, int innerIndex, imageId) {
    Map<String, dynamic> gameMap = {
      "gameID": pageData[innerIndex].id,
      "imageURL":
          "https://images.igdb.com/igdb/image/upload/t_original/$imageId.png",
      "gameName": pageData[innerIndex].name,
    };
    return gameMap;
  }

  void addToGamesList(List<dynamic> gamesList, Map<String, dynamic> gameMap) {
    gamesList.add(gameMap);
  }

  Widget gameCategoryCard(int? category) {
    Widget text = const Text("");
    Color color = Colors.transparent;
    switch (category) {
      case 0:
        text = const Text("Main Game");
        color = Colors.pink.withOpacity(0.7);
      case 1:
        text = const Text("DLC");
        color = Colors.red.withOpacity(0.7);
      case 2:
        text = const Text("Expansion");
        color = Colors.orange.withOpacity(0.7);
      case 3:
        text = const Text("Bundle");
        color = Colors.deepOrange.withOpacity(0.7);
      case 4:
        text = const Text("Standalone Expansion");
        color = Colors.yellow.withOpacity(0.7);
      case 5:
        text = const Text("Mod");
        color = Colors.lime.withOpacity(0.7);
      case 6:
        text = const Text("Episode");
        color = Colors.lightGreen.withOpacity(0.7);
      case 7:
        text = const Text("Season");
        color = Colors.green.withOpacity(0.7);
      case 8:
        text = const Text("Remake");
        color = Colors.teal.withOpacity(0.7);
      case 9:
        text = const Text("Remaster");
        color = Colors.lightBlue.withOpacity(0.7);
      case 10:
        text = const Text("Expanded Game");
        color = Colors.deepOrange.withOpacity(0.7);
      case 11:
        text = const Text("Port");
        color = Colors.blue.withOpacity(0.7);
      case 12:
        text = const Text("Fork");
        color = Colors.purple.withOpacity(0.7);
      case 13:
        text = const Text("Pack");
        color = Colors.deepPurple.withOpacity(0.7);
      case 14:
        text = const Text("Update");
        color = Colors.brown.withOpacity(0.7);
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

  Map<String, dynamic> getGameMapLibrary(List<dynamic> gamesList, int index) {
    Map<String, dynamic> gameMap = {
      "gameID": gamesList[index]['gameID'],
      "imageURL": gamesList[index]['imageURL'],
      "gameName": gamesList[index]['gameName'],
    };
    return gameMap;
  }
}
