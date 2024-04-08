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

  void addFavoritesToActorsList(List<dynamic> actorsList, List<dynamic> data,
      int innerIndex, ValueNotifier<bool> isFavorite) {
    for (var x in actorsList) {
      if (x['actorID'] == data[innerIndex].id) {
        isFavorite.value = true;
      }
    }
  }

  Map<String, dynamic> getActorMap(
      int actorID, List<dynamic> data, int innerIndex) {
    Map<String, dynamic> actorMap = {
      "actorID": actorID,
      "imageURL": data[innerIndex].imageURL.toString(),
      "actorName": data[innerIndex].name,
    };
    return actorMap;
  }

  Map<String, dynamic> getActorMapLibrary(
      int actorID, List<dynamic> data, int innerIndex) {
    Map<String, dynamic> actorMap = {
      "actorID": actorID,
      "imageURL": data[innerIndex]['imageURL'],
      "actorName": data[innerIndex]['actorName'],
    };
    return actorMap;
  }
}
