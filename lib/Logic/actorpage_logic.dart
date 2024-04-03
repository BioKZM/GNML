import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:gnml/Data/Model/actor_model.dart';
import 'package:http/http.dart' as http;

class ActorPageLogic {
  late String tmdbKey;
  ActorPageLogic() {
    tmdbKey = dotenv.get("TMDB_KEY");
  }
  Future<List<ActorModel>> getActorDetails(int actorID) async {
    List<ActorModel> actorModelList = <ActorModel>[];
    await http.get(
        Uri.parse(
            "https://api.themoviedb.org/3/person/$actorID?api_key=$tmdbKey&append_to_response=movie_credits,tv_credits,images"),
        headers: {}).then((value) {
      var responseBody = jsonDecode(value.body);
      for (Map<String, dynamic> x in [responseBody]) {
        ActorModel actorModel = ActorModel.fromJson(x);
        actorModelList.add(actorModel);
      }
    });
    return actorModelList;
  }

  Future<List<ActorModel>> searchActors(String query, int page) async {
    List<ActorModel> actorModelList = <ActorModel>[];
    await http.get(
        Uri.parse(
            "https://api.themoviedb.org/3/search/person?api_key=$tmdbKey&query=$query&page=$page"),
        headers: {}).then((value) {
      var responseBody = jsonDecode(value.body);
      for (Map<String, dynamic> x in responseBody['results']) {
        ActorModel actorModel = ActorModel.fromJson(x);
        actorModelList.add(actorModel);
      }
    });
    return actorModelList;
  }

  Future<int> getSearchResultsTotalPage(String query) async {
    int totalPages = 0;
    await http.get(
        Uri.parse(
            "https://api.themoviedb.org/3/search/person?api_key=$tmdbKey&query=$query"),
        headers: {}).then(
      (value) async {
        var responseBody = jsonDecode(value.body);
        totalPages = responseBody['total_pages'];
      },
    );

    return totalPages;
  }
}
