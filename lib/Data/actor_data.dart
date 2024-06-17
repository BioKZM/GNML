import 'package:flutter/material.dart';
import 'package:gnml/Logic/actorpage_logic.dart';

class ActorsData {
  Future<List<dynamic>> searchActors(String query, int page) async {
    return await ActorPageLogic().searchActors(query, page);
  }

  List<dynamic> addToActorsList(
      List<dynamic> actorsList, Map<String, dynamic> actorMap) {
    actorsList.add(actorMap);
    return actorsList;
  }

  void removeFromActorsList(List<dynamic> actorsList, int actorID) {
    actorsList.removeWhere(
      (element) => element['actorID'] == actorID,
    );
  }

  void addLikesFromActorsList(List<dynamic> actorsList, List<dynamic> data,
      int innerIndex, ValueNotifier<bool> isFavorite) {
    for (var x in actorsList) {
      if (x['actorID'] == data[innerIndex].id) {
        isFavorite.value = true;
      }
    }
  }

  void addFavoritesFromActorsList(
      List<dynamic> actorsList,
      List<dynamic>? favoriteActors,
      int index,
      ValueNotifier<bool> isFavorited) {
    for (var x in favoriteActors!) {
      if (x['actorID'] == actorsList[index]['actorID']) {
        isFavorited.value = true;
      }
    }
  }

  Map<String, dynamic> getActorMap(List<dynamic> actorsList, int index) {
    Map<String, dynamic> actorMap = {
      "actorID": actorsList[index]['actorID'],
      "imageURL": actorsList[index]['imageURL'],
      "actorName": actorsList[index]['actorName'],
    };
    return actorMap;
  }

  Map<String, dynamic> getActorMapSearch(List<dynamic> data, int index) {
    Map<String, dynamic> actorMap = {
      "actorID": data[index].id,
      "imageURL": data[index].imageURL,
      "actorName": data[index].name,
    };
    return actorMap;
  }

  // Map<String, dynamic> getActorMapLibrary(
  //     int actorID, List<dynamic> data, int innerIndex) {
  //   Map<String, dynamic> actorMap = {
  //     "actorID": actorID,
  //     "imageURL": data[innerIndex]['imageURL'],
  //     "actorName": data[innerIndex]['actorName'],
  //   };
  //   return actorMap;
  // }
}
