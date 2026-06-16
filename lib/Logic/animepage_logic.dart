import 'dart:convert';

import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:vault/data/model/anime_model.dart';

class AnimeSearchResult {
  final List<AnimeModel> items;
  final bool hasNextPage;
  final int currentPage;

  AnimeSearchResult({
    required this.items,
    required this.hasNextPage,
    required this.currentPage,
  });
}

class AnimePageLogic {
  static final RegExp _htmlTagRegex = RegExp(r'<[^>]*>', multiLine: true);
  static final RegExp _multiSpace = RegExp(r'\s{2,}');

  String _cleanString(String? input) {
    if (input == null) return '';
    final decoded = utf8
        .decode(input.toString().runes.toList(), allowMalformed: true)
        .replaceAll('�', '');
    final withoutTags = decoded.replaceAll(_htmlTagRegex, ' ');
    final normalized = withoutTags
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll(_multiSpace, ' ')
        .trim();
    return normalized;
  }

  Future<AnimeSearchResult> searchAnime({
    required String query,
    required int page,
  }) async {
    final uri = Uri.parse(
        "https://api.jikan.moe/v4/anime?q=${Uri.encodeQueryComponent(query)}&page=$page");
    final response = await http.get(uri);
    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;

    final List<dynamic> data = (responseBody['data'] as List?) ?? [];
    final pagination =
        (responseBody['pagination'] as Map<String, dynamic>?) ?? {};
    final bool hasNextPage = (pagination['has_next_page'] as bool?) ?? false;
    final int currentPage = (pagination['current_page'] as int?) ?? page;

    final items = data.whereType<Map<String, dynamic>>().map((x) {
      final model = AnimeModel.fromJson(x);
      model.title = _cleanString(model.title);
      model.synopsis = _cleanString(model.synopsis);
      model.aired_string = _cleanString(model.aired_string);
      model.rating = _cleanString(model.rating);
      return model;
    }).toList();

    return AnimeSearchResult(
      items: items,
      hasNextPage: hasNextPage,
      currentPage: currentPage,
    );
  }

  Future<AnimeModel?> getAnimeDetails(int id) async {
    final box = Hive.box('content_cache');
    final cacheKey = 'anime_details_$id';

    final cached = box.get(cacheKey);
    if (cached is AnimeModel) {
      return cached;
    }

    final uri = Uri.parse("https://api.jikan.moe/v4/anime/$id/full");
    final response = await http.get(uri);
    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    final data = responseBody['data'] as Map<String, dynamic>?;
    if (data == null) return null;

    final model = AnimeModel.fromJson(data);
    model.title = _cleanString(model.title);
    model.synopsis = _cleanString(model.synopsis);
    model.aired_string = _cleanString(model.aired_string);
    model.rating = _cleanString(model.rating);

    await box.put(cacheKey, model);
    return model;
  }

  Future<Map<String, dynamic>?> getAnimeRawDetails(int id) async {
    final box = Hive.box('content_cache');
    final cacheKey = 'anime_raw_$id';
    final cached = box.get(cacheKey);
    if (cached is Map) {
      return Map<String, dynamic>.from(cached);
    }

    final uri = Uri.parse("https://api.jikan.moe/v4/anime/$id/full");
    final response = await http.get(uri);
    if (response.statusCode != 200) return null;

    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    final data = responseBody['data'] as Map<String, dynamic>?;
    if (data == null) return null;

    await box.put(cacheKey, data);
    return data;
  }

  Future<List<Map<String, dynamic>>> getAnimePictures(int id) async {
    final box = Hive.box('content_cache');
    final cacheKey = 'anime_pictures_$id';
    final cached = box.get(cacheKey);
    if (cached is List) {
      return cached.whereType<Map>().map(Map<String, dynamic>.from).toList();
    }

    final uri = Uri.parse("https://api.jikan.moe/v4/anime/$id/pictures");
    final response = await http.get(uri);
    if (response.statusCode != 200) return const [];

    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    final data =
        (responseBody['data'] as List?)?.whereType<Map>().toList() ?? const [];
    await box.put(cacheKey, data);
    return data.map(Map<String, dynamic>.from).toList();
  }

  Future<List<Map<String, dynamic>>> getAnimeVideos(int id) async {
    final box = Hive.box('content_cache');
    final cacheKey = 'anime_videos_$id';
    final cached = box.get(cacheKey);
    if (cached is List) {
      return cached.whereType<Map>().map(Map<String, dynamic>.from).toList();
    }

    final uri = Uri.parse("https://api.jikan.moe/v4/anime/$id/videos");
    final response = await http.get(uri);
    if (response.statusCode != 200) return const [];

    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    final data = <Map<String, dynamic>>[];
    final root = responseBody['data'];
    if (root is Map) {
      final promo = root['promo'];
      if (promo is List) {
        data.addAll(promo.whereType<Map>().map(Map<String, dynamic>.from));
      }
      final episodes = root['episodes'];
      if (episodes is List) {
        data.addAll(episodes.whereType<Map>().map(Map<String, dynamic>.from));
      }
      final music = root['music_videos'];
      if (music is List) {
        data.addAll(music.whereType<Map>().map(Map<String, dynamic>.from));
      }
    }
    await box.put(cacheKey, data);
    return data;
  }

  Future<List<Map<String, dynamic>>> getAnimeCharacters(int id) async {
    final box = Hive.box('content_cache');
    final cacheKey = 'anime_characters_$id';
    final cached = box.get(cacheKey);
    if (cached is List) {
      return cached.whereType<Map>().map(Map<String, dynamic>.from).toList();
    }

    final uri = Uri.parse("https://api.jikan.moe/v4/anime/$id/characters");
    final response = await http.get(uri);
    if (response.statusCode != 200) return const [];

    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    final data =
        (responseBody['data'] as List?)?.whereType<Map>().toList() ?? const [];
    await box.put(cacheKey, data);
    return data.map(Map<String, dynamic>.from).toList();
  }

  Future<List<Map<String, dynamic>>> getAnimeEpisodes(int id) async {
    final box = Hive.box('content_cache');
    final cacheKey = 'anime_episodes_$id';
    final cached = box.get(cacheKey);
    if (cached is List) {
      return cached.whereType<Map>().map(Map<String, dynamic>.from).toList();
    }

    final uri = Uri.parse("https://api.jikan.moe/v4/anime/$id/episodes");
    final response = await http.get(uri);
    if (response.statusCode != 200) return const [];

    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    final data =
        (responseBody['data'] as List?)?.whereType<Map>().toList() ?? const [];
    await box.put(cacheKey, data);
    return data.map(Map<String, dynamic>.from).toList();
  }

  Future<List<AnimeModel>> getTopAnimes({int page = 1, int limit = 10}) async {
    final uri =
        Uri.parse("https://api.jikan.moe/v4/top/anime?page=$page&limit=$limit");
    final response = await http.get(uri);
    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    final List<dynamic> data = (responseBody['data'] as List?) ?? [];

    return data.whereType<Map<String, dynamic>>().map((x) {
      final model = AnimeModel.fromJson(x);
      model.title = _cleanString(model.title);
      model.synopsis = _cleanString(model.synopsis);
      model.aired_string = _cleanString(model.aired_string);
      model.rating = _cleanString(model.rating);
      return model;
    }).toList();
  }
}
