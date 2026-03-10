import 'dart:convert';

import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:vault/Data/Model/anime_model.dart';

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
