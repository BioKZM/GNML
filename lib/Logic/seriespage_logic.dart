import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:vault/data/model/serie_model.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SeriesPageLogic {
  String tmdbKey = dotenv.get("TMDB_KEY");

  Future<List<SerieModel>> getAiringTodaySeries(int page) async {
    List<SerieModel> serieModelList = [];
    final response = await http.get(
      Uri.parse(
          "https://api.themoviedb.org/3/tv/airing_today?api_key=$tmdbKey&page=$page"),
    );
    if (response.statusCode == 200) {
      var responseBody = jsonDecode(response.body);
      for (Map<String, dynamic> x in responseBody['results']) {
        SerieModel serieModel = SerieModel.fromJson(x);
        serieModelList.add(serieModel);
      }
    } else {
      throw Exception("Failed to load airing today series");
    }

    return serieModelList;
  }

  Future<int> getAiringTodaySeriesTotalPages() async {
    int totalPages = 0;
    final response = await http.get(
        Uri.parse(
            "https://api.themoviedb.org/3/tv/airing_today?api_key=$tmdbKey"),
        headers: {});
    if (response.statusCode == 200) {
      var responseBody = jsonDecode(response.body);
      totalPages = responseBody['total_pages'];
    } else {
      throw Exception("Failed to load airing today series total pages");
    }

    return totalPages;
  }

  Future<List<SerieModel>> getPopularSeries() async {
    List<SerieModel> serieModelList = <SerieModel>[];
    final response = await http.get(
        Uri.parse("https://api.themoviedb.org/3/tv/popular?api_key=$tmdbKey"),
        headers: {});
    if (response.statusCode == 200) {
      var responseBody = jsonDecode(response.body);
      for (Map<String, dynamic> x in responseBody['results']) {
        SerieModel serieModel = SerieModel.fromJson(x);
        serieModelList.add(serieModel);
      }
    } else {
      throw Exception("Failed to load popular series");
    }
    return serieModelList;
  }

  Future<int> getPopularMoviesTotalPages() async {
    int totalPages = 0;
    final response = await http.get(
        Uri.parse("https://api.themoviedb.org/3/tv/popular?api_key=$tmdbKey"),
        headers: {});
    if (response.statusCode == 200) {
      var responseBody = jsonDecode(response.body);
      totalPages = responseBody['total_pages'];
    } else {
      throw Exception("Failed to load popular series total pages");
    }
    return totalPages;
  }

  Future<List<SerieModel>> getTopRatedSeries(int page) async {
    List<SerieModel> serieModelList = <SerieModel>[];
    final response = await http.get(
        Uri.parse(
            "https://api.themoviedb.org/3/tv/top_rated?api_key=$tmdbKey&page=$page"),
        headers: {});
    if (response.statusCode == 200) {
      var responseBody = jsonDecode(response.body);
      for (Map<String, dynamic> x in responseBody['results']) {
        SerieModel serieModel = SerieModel.fromJson(x);
        serieModelList.add(serieModel);
      }
    } else {
      throw Exception("Failed to load top rated series");
    }
    return serieModelList;
  }

  Future<int> getTopRatedSeriesTotalPages() async {
    int totalPages = 0;
    final response = await http.get(
        Uri.parse("https://api.themoviedb.org/3/tv/top_rated?api_key=$tmdbKey"),
        headers: {});
    if (response.statusCode == 200) {
      var responseBody = jsonDecode(response.body);
      totalPages = responseBody['total_pages'];
    } else {
      throw Exception("Failed to load top rated series total pages");
    }
    return totalPages;
  }

  Future<List<SerieModel>> getOnTheAirSeries(int page) async {
    List<SerieModel> serieModelList = <SerieModel>[];
    final response = await http.get(
        Uri.parse(
            "https://api.themoviedb.org/3/tv/on_the_air?api_key=$tmdbKey&page=$page"),
        headers: {});
    if (response.statusCode == 200) {
      var responseBody = jsonDecode(response.body);
      for (Map<String, dynamic> x in responseBody['results']) {
        SerieModel serieModel = SerieModel.fromJson(x);
        serieModelList.add(serieModel);
      }
    } else {
      throw Exception("Failed to load on the air series");
    }
    return serieModelList;
  }

  Future<int> getOnTheAirSeriesTotalPages() async {
    int totalPages = 0;
    final response = await http.get(
        Uri.parse(
            "https://api.themoviedb.org/3/tv/on_the_air?api_key=$tmdbKey"),
        headers: {});
    if (response.statusCode == 200) {
      var responseBody = jsonDecode(response.body);
      totalPages = responseBody['total_pages'];
    } else {
      throw Exception("Failed to load on the air series total pages");
    }
    return totalPages;
  }

  Future<List<SerieModel>> getSerieDetails(int serieID) async {
    final box = Hive.box('content_cache');
    final cacheKey = 'serie_details_$serieID';
    final cached = box.get(cacheKey);
    if (cached is SerieModel) {
      return [cached];
    }

    List<SerieModel> serieModelList = <SerieModel>[];
    final response = await http.get(
        Uri.parse(
            "https://api.themoviedb.org/3/tv/$serieID?api_key=$tmdbKey&append_to_response=credits,images,watch/providers"),
        headers: {});
    if (response.statusCode == 200) {
      var responseBody = jsonDecode(response.body);
      for (Map<String, dynamic> x in [responseBody]) {
        SerieModel serieModel = SerieModel.fromJson(x);
        serieModelList.add(serieModel);
        box.put(cacheKey, serieModel);
      }
    } else {
      throw Exception("Failed to load serie details");
    }
    return serieModelList;
  }

  Future<Map<String, dynamic>?> getSerieRawDetails(int serieID) async {
    final box = Hive.box('content_cache');
    final cacheKey = 'serie_raw_$serieID';
    final cached = box.get(cacheKey);
    if (cached is Map) {
      return Map<String, dynamic>.from(cached);
    }

    final response = await http.get(
      Uri.parse(
        "https://api.themoviedb.org/3/tv/$serieID?api_key=$tmdbKey&append_to_response=credits,images,watch/providers,videos",
      ),
      headers: {},
    );
    if (response.statusCode != 200) {
      return null;
    }

    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    await box.put(cacheKey, responseBody);
    return responseBody;
  }

  Future<List<Map<String, dynamic>>> getSeasonDetails(
    int serieID,
    List<int> seasonNumbers,
  ) async {
    final box = Hive.box('content_cache');
    final output = <Map<String, dynamic>>[];

    for (final seasonNumber in seasonNumbers) {
      final cacheKey = 'serie_season_${serieID}_$seasonNumber';
      final cached = box.get(cacheKey);
      if (cached is Map) {
        output.add(Map<String, dynamic>.from(cached));
        continue;
      }

      final response = await http.get(
        Uri.parse(
          "https://api.themoviedb.org/3/tv/$serieID/season/$seasonNumber?api_key=$tmdbKey",
        ),
        headers: {},
      );

      if (response.statusCode != 200) continue;

      final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
      output.add(responseBody);
      await box.put(cacheKey, responseBody);
    }

    return output;
  }

  Future<List<SerieModel>> searchSeries(String query, int page) async {
    List<SerieModel> serieModelList = <SerieModel>[];
    final response = await http.get(
        Uri.parse(
            "https://api.themoviedb.org/3/search/tv?api_key=$tmdbKey&query=$query&page=$page"),
        headers: {});
    if (response.statusCode == 200) {
      var responseBody = jsonDecode(response.body);
      for (Map<String, dynamic> x in responseBody['results']) {
        SerieModel serieModel = SerieModel.fromJson(x);
        serieModelList.add(serieModel);
      }
    } else {
      throw Exception("Failed to load search results");
    }
    return serieModelList;
  }

  Future<int> getSearchResultsTotalPage(String query) async {
    int totalPages = 0;
    final response = await http.get(
        Uri.parse(
            "https://api.themoviedb.org/3/search/tv?api_key=$tmdbKey&query=$query"),
        headers: {});
    if (response.statusCode == 200) {
      var responseBody = jsonDecode(response.body);
      totalPages = responseBody['total_pages'];
    } else {
      throw Exception("Failed to load search results total pages");
    }
    return totalPages;
  }
}
