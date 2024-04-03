import 'dart:convert';
import 'package:gnml/Data/Model/serie_model.dart';
import 'package:http/http.dart' as http;

class SeriesPageLogic {
  Future<List<SerieModel>> getAiringTodaySeries(int page) async {
    List<SerieModel> serieModelList = [];
    await http.get(
        Uri.parse(
            "https://api.themoviedb.org/3/tv/airing_today?api_key=c3efd62e6893e03061fc02bb91852858&page=$page"),
        headers: {}).then(
      (value) async {
        var responseBody = jsonDecode(value.body);
        for (Map<String, dynamic> x in responseBody['results']) {
          SerieModel serieModel = SerieModel.fromJson(x);
          serieModelList.add(serieModel);
        }
      },
    );

    return serieModelList;
  }

  Future<int> getAiringTodaySeriesTotalPages() async {
    int totalPages = 0;
    await http.get(
        Uri.parse(
            "https://api.themoviedb.org/3/tv/airing_today?api_key=c3efd62e6893e03061fc02bb91852858"),
        headers: {}).then(
      (value) async {
        var responseBody = jsonDecode(value.body);
        totalPages = responseBody['total_pages'];
      },
    );

    return totalPages;
  }

  Future<List<SerieModel>> getPopularSeries() async {
    List<SerieModel> serieModelList = <SerieModel>[];
    await http.get(
        Uri.parse(
            "https://api.themoviedb.org/3/tv/popular?api_key=c3efd62e6893e03061fc02bb91852858"),
        headers: {}).then((value) {
      var responseBody = jsonDecode(value.body);
      for (Map<String, dynamic> x in responseBody['results']) {
        SerieModel serieModel = SerieModel.fromJson(x);
        serieModelList.add(serieModel);
      }
    });
    return serieModelList;
  }

  Future<int> getPopularMoviesTotalPages() async {
    int totalPages = 0;
    await http.get(
        Uri.parse(
            "https://api.themoviedb.org/3/tv/popular?api_key=c3efd62e6893e03061fc02bb91852858"),
        headers: {}).then(
      (value) async {
        var responseBody = jsonDecode(value.body);
        totalPages = responseBody['total_pages'];
      },
    );

    return totalPages;
  }

  Future<List<SerieModel>> getTopRatedSeries(int page) async {
    List<SerieModel> serieModelList = <SerieModel>[];
    await http.get(
        Uri.parse(
            "https://api.themoviedb.org/3/tv/top_rated?api_key=c3efd62e6893e03061fc02bb91852858&page=$page"),
        headers: {}).then((value) {
      var responseBody = jsonDecode(value.body);
      for (Map<String, dynamic> x in responseBody['results']) {
        SerieModel serieModel = SerieModel.fromJson(x);
        serieModelList.add(serieModel);
      }
    });
    return serieModelList;
  }

  Future<int> getTopRatedSeriesTotalPages() async {
    int totalPages = 0;
    await http.get(
        Uri.parse(
            "https://api.themoviedb.org/3/tv/top_rated?api_key=c3efd62e6893e03061fc02bb91852858"),
        headers: {}).then(
      (value) async {
        var responseBody = jsonDecode(value.body);
        totalPages = responseBody['total_pages'];
      },
    );

    return totalPages;
  }

  Future<List<SerieModel>> getOnTheAirSeries(int page) async {
    List<SerieModel> serieModelList = <SerieModel>[];
    await http.get(
        Uri.parse(
            "https://api.themoviedb.org/3/tv/on_the_air?api_key=c3efd62e6893e03061fc02bb91852858&page=$page"),
        headers: {}).then((value) {
      var responseBody = jsonDecode(value.body);
      for (Map<String, dynamic> x in responseBody['results']) {
        SerieModel serieModel = SerieModel.fromJson(x);
        serieModelList.add(serieModel);
      }
    });
    return serieModelList;
  }

  Future<int> getOnTheAirSeriesTotalPages() async {
    int totalPages = 0;
    await http.get(
        Uri.parse(
            "https://api.themoviedb.org/3/tv/on_the_air?api_key=c3efd62e6893e03061fc02bb91852858"),
        headers: {}).then(
      (value) async {
        var responseBody = jsonDecode(value.body);
        totalPages = responseBody['total_pages'];
      },
    );

    return totalPages;
  }

  Future<List<SerieModel>> getSerieDetails(int serieID) async {
    List<SerieModel> serieModelList = <SerieModel>[];
    await http.get(
        Uri.parse(
            "https://api.themoviedb.org/3/tv/$serieID?api_key=c3efd62e6893e03061fc02bb91852858&append_to_response=credits,images,watch/providers"),
        headers: {}).then((value) {
      var responseBody = jsonDecode(value.body);
      for (Map<String, dynamic> x in [responseBody]) {
        SerieModel serieModel = SerieModel.fromJson(x);
        serieModelList.add(serieModel);
      }
    });
    return serieModelList;
  }

  Future<List<SerieModel>> searchSeries(String query, int page) async {
    List<SerieModel> serieModelList = <SerieModel>[];
    await http.get(
        Uri.parse(
            "https://api.themoviedb.org/3/search/tv?api_key=c3efd62e6893e03061fc02bb91852858&query=$query&page=$page"),
        headers: {}).then((value) {
      var responseBody = jsonDecode(value.body);
      for (Map<String, dynamic> x in responseBody['results']) {
        SerieModel serieModel = SerieModel.fromJson(x);
        serieModelList.add(serieModel);
      }
    });
    return serieModelList;
  }

  Future<int> getSearchResultsTotalPage(String query) async {
    int totalPages = 0;
    await http.get(
        Uri.parse(
            "https://api.themoviedb.org/3/search/tv?api_key=c3efd62e6893e03061fc02bb91852858&query=$query"),
        headers: {}).then(
      (value) async {
        var responseBody = jsonDecode(value.body);
        totalPages = responseBody['total_pages'];
      },
    );

    return totalPages;
  }
}
