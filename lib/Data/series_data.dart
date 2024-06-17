import 'package:flutter/material.dart';
import 'package:gnml/Logic/seriespage_logic.dart';

class SeriesData {
  Future<List<dynamic>> searchSeries(String query, int page) async {
    return await SeriesPageLogic().searchSeries(query, page);
  }

  String getSerieReleaseDate(data) {
    String date = data.first_air_date;
    if (date == "") {
      return "Unknown";
    }

    String day = date.substring(8);
    date = date.substring(0, 7);
    String month = date.substring(5);
    date = date.substring(0, 4);
    String year = date;
    switch (month) {
      case "01":
        month = "January";
      case "02":
        month = "February";
      case "03":
        month = "March";
      case "04":
        month = "April";
      case "05":
        month = "May";
      case "06":
        month = "June";
      case "07":
        month = "July";
      case "08":
        month = "August";
      case "09":
        month = "September";
      case "10":
        month = "October";
      case "11":
        month = "November";
      case "12":
        month = "December";
    }
    return "$day $month $year";
  }

  void addToSeriesList(
      List<dynamic> seriesList, Map<String, dynamic> serieMap) {
    seriesList.add(serieMap);
  }

  void removeFromSeriesList(List<dynamic> seriesList, int serieID) {
    seriesList.removeWhere((element) => element['serieID'] == serieID);
  }

  void addFavoritesFromData(List<dynamic> seriesList, List<dynamic> data,
      int innerIndex, ValueNotifier<bool> isFavorite) {
    for (var x in seriesList) {
      if (x['serieID'] == data[innerIndex].id) {
        isFavorite.value = true;
      }
    }
  }

  void addFavoritesFromList(
      List<dynamic> seriesList,
      List<dynamic>? favoriteSeries,
      int index,
      ValueNotifier<bool> isFavorited) {
    for (var x in favoriteSeries!) {
      if (x['serieID'] == seriesList[index]['serieID']) {
        isFavorited.value = true;
      }
    }
  }

  Map<String, dynamic> getSeriesMap(
      int serieID, List<dynamic> data, int innerIndex) {
    Map<String, dynamic> serieMap = {
      "serieID": serieID,
      "imageURL": data[innerIndex].imageURL.toString(),
      "serieName": data[innerIndex].name,
    };
    return serieMap;
  }

  int getSerieID(List<dynamic>? data, int innerIndex) {
    var serieID = 0;
    if (data![innerIndex].id != null) {
      serieID = data[innerIndex].id!;
    }
    return serieID;
  }

  Map<String, dynamic> getSerieMapLibrary(List<dynamic> seriesList, int index) {
    Map<String, dynamic> serieMap = {
      "serieID": seriesList[index]['serieID'],
      "imageURL": seriesList[index]['imageURL'],
      "serieName": seriesList[index]['serieName'],
    };
    return serieMap;
  }
}
