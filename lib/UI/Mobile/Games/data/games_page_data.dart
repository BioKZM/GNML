import 'package:flutter/material.dart';
import 'package:gnml/Data/Model/game_model.dart';
import 'package:intl/intl.dart';

class GamesPageData {
  void addToGamesList(List<dynamic> gamesList, Map<String, dynamic> gameMap) {
    gamesList.add(gameMap);
  }

  void removeFromGamesList(
      List<dynamic> gamesList, List<GameModel>? data, int index) {
    gamesList.removeWhere((element) => element['gameID'] == data![index].id);
  }

  void addLikesFromGamesList(List<dynamic> gamesList, List<GameModel>? data,
      int index, ValueNotifier<bool> isLiked) {
    for (var x in gamesList) {
      if (x['gameID'] == data![index].id) {
        isLiked.value = true;
      }
    }
  }

  Map<String, dynamic> getGameMap(
      List<GameModel>? data, int index, String? imageId) {
    Map<String, dynamic> gameMap = {
      "gameID": data![index].id,
      "imageURL":
          "https://images.igdb.com/igdb/image/upload/t_original/$imageId.png",
      "gameName": data[index].name,
    };
    return gameMap;
  }

  int getGameID(List<GameModel>? data, int index) {
    var gameID = 0;
    if (data![index].id != null) {
      gameID = data[index].id!;
    }
    return gameID;
  }

  String? getImageID(List<GameModel>? data, int index) {
    String? imageId;
    if (data![index].image_id == "0") {
      imageId = "null";
    } else {
      imageId = data[index].image_id;
    }
    return imageId;
  }

  List<GameModel> setPageIndex(int index, List<GameModel> data) {
    final int startIndex = index * 15;
    final int endIndex = (index + 1) * 15;
    final pageData = data.sublist(
      startIndex,
      endIndex.clamp(0, data.length),
    );
    return pageData;
  }

  getDateTime(List<GameModel> pageData, int innerIndex) {
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
}
