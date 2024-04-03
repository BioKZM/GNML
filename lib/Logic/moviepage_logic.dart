import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:gnml/Data/Model/movie_model.dart';
import 'package:http/http.dart' as http;

class MoviePageLogic {
  late String tmdbKey;
  MoviePageLogic() {
    tmdbKey = dotenv.get("TMDB_KEY");
  }
  Future<List<dynamic>> getNowPlayingMovies(int page) async {
    List<dynamic> movieModelList = [];
    await http.get(
        Uri.parse(
            "https://api.themoviedb.org/3/movie/now_playing?api_key=$tmdbKey&page=$page"),
        headers: {}).then(
      (value) async {
        var responseBody = jsonDecode(value.body);
        for (Map<String, dynamic> x in responseBody['results']) {
          MovieModel movieModel = MovieModel.fromJson(x);
          movieModelList.add(movieModel);
        }
      },
    );

    return movieModelList;
  }

  Future<int> getNowPlayingMoviesTotalPages() async {
    int totalPages = 0;
    await http.get(
        Uri.parse(
            "https://api.themoviedb.org/3/movie/now_playing?api_key=$tmdbKey"),
        headers: {}).then(
      (value) async {
        var responseBody = jsonDecode(value.body);
        totalPages = responseBody['total_pages'];
      },
    );

    return totalPages;
  }

  Future<List<MovieModel>> getPopularMovies() async {
    List<MovieModel> movieModelList = <MovieModel>[];
    await http.get(
        Uri.parse(
            "https://api.themoviedb.org/3/movie/popular?api_key=$tmdbKey"),
        headers: {}).then((value) {
      var responseBody = jsonDecode(value.body);
      for (Map<String, dynamic> x in responseBody['results']) {
        MovieModel movieModel = MovieModel.fromJson(x);
        movieModelList.add(movieModel);
      }
    });
    return movieModelList;
  }

  Future<int> getPopularMoviesTotalPages() async {
    int totalPages = 0;
    await http.get(
        Uri.parse(
            "https://api.themoviedb.org/3/movie/popular?api_key=$tmdbKey"),
        headers: {}).then(
      (value) async {
        var responseBody = jsonDecode(value.body);
        totalPages = responseBody['total_pages'];
      },
    );

    return totalPages;
  }

  Future<List<MovieModel>> getTopRatedMovies(int page) async {
    List<MovieModel> movieModelList = <MovieModel>[];
    await http.get(
        Uri.parse(
            "https://api.themoviedb.org/3/movie/top_rated?api_key=$tmdbKey&page=$page"),
        headers: {}).then((value) {
      var responseBody = jsonDecode(value.body);
      for (Map<String, dynamic> x in responseBody['results']) {
        MovieModel movieModel = MovieModel.fromJson(x);
        movieModelList.add(movieModel);
      }
    });
    return movieModelList;
  }

  Future<int> getTopRatedMoviesTotalPages() async {
    int totalPages = 0;
    await http.get(
        Uri.parse(
            "https://api.themoviedb.org/3/movie/top_rated?api_key=$tmdbKey"),
        headers: {}).then(
      (value) async {
        var responseBody = jsonDecode(value.body);
        totalPages = responseBody['total_pages'];
      },
    );

    return totalPages;
  }

  Future<List<MovieModel>> getUpcomingMovies(int page) async {
    List<MovieModel> movieModelList = <MovieModel>[];
    await http.get(
        Uri.parse(
            "https://api.themoviedb.org/3/movie/upcoming?api_key=$tmdbKey&page=$page"),
        headers: {}).then((value) {
      var responseBody = jsonDecode(value.body);
      for (Map<String, dynamic> x in responseBody['results']) {
        MovieModel movieModel = MovieModel.fromJson(x);
        movieModelList.add(movieModel);
      }
    });
    return movieModelList;
  }

  Future<int> getUpcomingMoviesTotalPages() async {
    int totalPages = 0;
    await http.get(
        Uri.parse(
            "https://api.themoviedb.org/3/movie/upcoming?api_key=$tmdbKey"),
        headers: {}).then(
      (value) async {
        var responseBody = jsonDecode(value.body);
        totalPages = responseBody['total_pages'];
      },
    );

    return totalPages;
  }

  Future<List<MovieModel>> getMovieDetails(int movieID) async {
    List<MovieModel> movieModelList = <MovieModel>[];
    await http.get(
        Uri.parse(
            "https://api.themoviedb.org/3/movie/$movieID?api_key=$tmdbKey&append_to_response=credits,images,watch/providers"),
        headers: {}).then((value) {
      var responseBody = jsonDecode(value.body);
      for (Map<String, dynamic> x in [responseBody]) {
        MovieModel movieModel = MovieModel.fromJson(x);
        movieModelList.add(movieModel);
      }
    });
    return movieModelList;
  }

  Future<List<MovieModel>> searchMovies(String query, int page) async {
    List<MovieModel> movieModelList = <MovieModel>[];
    await http.get(
        Uri.parse(
            "https://api.themoviedb.org/3/search/movie?api_key=$tmdbKey&query=$query&page=$page"),
        headers: {}).then((value) {
      var responseBody = jsonDecode(value.body);
      for (Map<String, dynamic> x in responseBody['results']) {
        MovieModel movieModel = MovieModel.fromJson(x);
        movieModelList.add(movieModel);
      }
    });
    return movieModelList;
  }

  Future<int> getSearchResultsTotalPage(String query) async {
    int totalPages = 0;
    await http.get(
        Uri.parse(
            "https://api.themoviedb.org/3/search/movie?api_key=$tmdbKey&query=$query"),
        headers: {}).then(
      (value) async {
        var responseBody = jsonDecode(value.body);
        totalPages = responseBody['total_pages'];
      },
    );

    return totalPages;
  }
}
