import 'package:vault/Logic/moviepage_logic.dart';

class MoviesData {
  Future<List<dynamic>> searchMovies(String query, int page) async {
    return await MoviePageLogic().searchMovies(query, page);
  }

  String getMovieReleaseDate(data) {
    String date = data.release_date;
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

  int getMovieID(List<dynamic>? data, int innerIndex) {
    var movieID = 0;
    if (data![innerIndex].id != null) {
      movieID = data[innerIndex].id!;
    }
    return movieID;
  }
}
