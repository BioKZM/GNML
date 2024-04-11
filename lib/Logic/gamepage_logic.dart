import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:gnml/Data/Model/game_model.dart';
import 'package:http/http.dart' as http;

class GamePageLogic {
  late int currentUnixTime;
  late int newUnixTime;
  late int pastUnixTime;
  late String igdbID;
  late String igdbSecret;
  late Map<String, dynamic> bodies;

  GamePageLogic() {
    igdbID = dotenv.get("IGDB_ID");
    igdbSecret = dotenv.get("IGDB_SECRET");
    currentUnixTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    newUnixTime = currentUnixTime + const Duration(days: 14).inSeconds;
    pastUnixTime = currentUnixTime - const Duration(days: 120).inSeconds;
    bodies = {
      "newlyReleased":
          """fields cover.*,genres,name,platforms,rating,first_release_date,hypes;sort first_release_date desc;where first_release_date < $currentUnixTime ;limit 500;""",
      "comingSoon":
          """fields cover.*,genres,name,platforms,rating,first_release_date,hypes;sort first_release_date desc;where first_release_date < $newUnixTime & first_release_date > $currentUnixTime  ;limit 500;""",
      "mostlyAnticipated":
          """fields cover.*,genres,name,platforms,rating,first_release_date,hypes;sort hypes desc;where first_release_date > $currentUnixTime;limit 500;""",
      "popularRightNow":
          """fields cover.*, genres,name,platforms,rating,first_release_date,hypes;sort hypes desc;where first_release_date < $currentUnixTime & hypes > 10; limit 500;""",
    };
  }

  Future<List<GameModel>> getGameDetails(int id) async {
    var body = {
      "getDetails":
          """fields id, age_ratings.*, aggregated_rating, artworks.*, category, cover.*, first_release_date, game_engines.*, genres.*,name, platforms.*, player_perspectives.*, rating, release_dates.*,screenshots.*,storyline,summary,tags,themes.*,videos.*,websites.*,language_supports.language.*,language_supports.language_support_type.*, cover.url,cover.image_id,hypes,involved_companies.*,involved_companies.company.*;
where id = $id;"""
    };
    List<GameModel> gameModelList = <GameModel>[];
    await getDataFromAPIWithBody(body['getDetails']!).then((value) {
      for (Map<String, dynamic> x in value) {
        GameModel gameModel = GameModel.fromJson(x);
        gameModelList.add(gameModel);
      }
    });

    return gameModelList;
  }

  Future<List<GameModel>> searchGames(String searchParameter) async {
    var body = {
      "searchGames":
          """fields cover.*, genres,name,platforms.name,category,rating,first_release_date,hypes;search "$searchParameter";limit 500;"""
    };
    List<GameModel> gameModelList = <GameModel>[];
    await getDataFromAPIWithBody(body['searchGames']!).then((value) {
      for (Map<String, dynamic> x in value) {
        GameModel gameModel = GameModel.fromJson(x);
        gameModelList.add(gameModel);
      }
    });

    return gameModelList;
  }

  Future getDataFromAPIWithBody(String key) async {
    var responseBody = generateToken().then(
      (value) async {
        var response = await http.post(
            Uri.parse("https://api.igdb.com/v4/games"),
            body: key,
            headers: {"Client-ID": igdbID, "Authorization": "Bearer $value"});
        var responseBody = jsonDecode(response.body);
        return responseBody;
      },
    );
    return responseBody;
  }

  Future<List<GameModel>> getPopularGameList(String key) async {
    List<GameModel> gameModelList = <GameModel>[];
    await getDataFromAPI(key).then((value) {
      for (Map<String, dynamic> x in value) {
        GameModel gameModel = GameModel.fromJson(x);
        gameModelList.add(gameModel);
      }
    });
    return gameModelList;
  }

  Future getDataFromAPI(String key) async {
    var responseBody = generateToken().then(
      (value) async {
        var response = await http.post(
            Uri.parse("https://api.igdb.com/v4/games"),
            body: bodies[key],
            headers: {"Client-ID": igdbID, "Authorization": "Bearer $value"});
        var responseBody = jsonDecode(response.body);
        return responseBody;
      },
    );
    return responseBody;
  }

  Future generateToken() async {
    var response = await http.post(Uri.parse(
        "https://id.twitch.tv/oauth2/token?client_id=$igdbID&client_secret=$igdbSecret&grant_type=client_credentials"));
    var responseBody = jsonDecode(response.body);
    return responseBody['access_token'];
  }
}
