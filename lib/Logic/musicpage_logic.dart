import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:gnml/Data/Model/music_model.dart';
import 'package:http/http.dart' as http;

class MusicPageLogic {
  late String spotifyID;
  late String spotifySecret;

  MusicPageLogic() {
    spotifyID = dotenv.get("SPOTIFY_ID");
    spotifySecret = dotenv.get("SPOTIFY_SECRET");
  }
  Future<dynamic> getToken() async {
    var response = await http.post(
      Uri.parse(
        "https://accounts.spotify.com/api/token",
      ),
      headers: {"Content-Type": "application/x-www-form-urlencoded"},
      body:
          "grant_type=client_credentials&client_id=$spotifyID&client_secret=$spotifySecret",
    );
    var responseBody = jsonDecode(response.body);
    return responseBody['access_token'];
  }

  Future<List<MusicModel>> getNewReleases() async {
    List<MusicModel> musicModelList = [];
    await getToken().then(
      (value) async {
        var response = await http.get(
            Uri.parse(
                "https://api.spotify.com/v1/browse/new-releases?limit=50"),
            headers: {
              "Client-ID": spotifyID,
              "Authorization": "Bearer $value"
            });
        var responseBody = jsonDecode(response.body);
        for (Map<String, dynamic> x in responseBody['albums']['items']) {
          MusicModel musicModel = MusicModel.fromJson(x);
          musicModelList.add(musicModel);
        }
      },
    );

    return musicModelList;
  }

  Future<List<MusicModel>> getAlbumTracks(String id) async {
    List<MusicModel> musicModelList = [];
    await getToken().then(
      (value) async {
        var response = await http.get(
            Uri.parse("https://api.spotify.com/v1/albums/$id/tracks"),
            headers: {
              "Client-ID": spotifyID,
              "Authorization": "Bearer $value"
            });
        var responseBody = jsonDecode(response.body);
        for (Map<String, dynamic> x in responseBody['items']) {
          MusicModel musicModel = MusicModel.fromJson(x);
          musicModelList.add(musicModel);
        }
      },
    );

    return musicModelList;
  }

  Future<List<MusicModel>> getMusicDetails(int id) async {
    List<MusicModel> musicModelList = [];
    await getToken().then(
      (value) async {
        var response = await http
            .get(Uri.parse("https://api.spotify.com/v1/tracks/$id"), headers: {
          "Client-ID": spotifyID,
          "Authorization": "Bearer $value"
        });
        var responseBody = jsonDecode(response.body);
        for (Map<String, dynamic> x in responseBody) {
          MusicModel musicModel = MusicModel.fromJson(x);
          musicModelList.add(musicModel);
        }
      },
    );

    return musicModelList;
  }
}
