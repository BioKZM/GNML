import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:vault/data/model/user_library.dart';
import 'package:vault/Helper/content_type.dart';
import 'package:vault/Services/database_service.dart';
import 'package:vault/Services/firebase_database_impl.dart';

class LibraryProvider extends ChangeNotifier {
  UserLibrary? _library;
  final DatabaseService _database;

  String? detailsTitle;
  String? detailsDescription;
  String? detailsScoreText;
  String? detailsDateText;
  String? detailsImageUrl;
  String? detailsGenreText;

  bool _isLoading = true;
  bool _isDirty = false;
  final Set<String> _pendingUpserts = <String>{};
  final Set<String> _pendingDeletes = <String>{};

  UserLibrary? get library => _library;
  bool get isLoading => _isLoading;
  bool get isDirty => _isDirty;
  Map<String, dynamic> get libraryMap => _library?.library ?? const {};
  List<String> get customFolders =>
      List.unmodifiable(_library?.customFolders ?? const []);

  LibraryProvider({DatabaseService? database})
      : _database = database ?? FirebaseDatabaseImpl();

  Future<void> init() async {
    _isLoading = true;
    notifyListeners();

    final box = await Hive.openBox('user_library');
    final localData = box.get('data');
    final currentUid = FirebaseAuth.instance.currentUser?.uid;
    final cachedUid = box.get('uid')?.toString();

    if (localData != null && currentUid != null && cachedUid == currentUid) {
      _library = UserLibrary.fromSnapshot(Map<String, dynamic>.from(localData));
      _pendingUpserts
        ..clear()
        ..addAll(_readStringSet(box.get('pendingUpserts')));
      _pendingDeletes
        ..clear()
        ..addAll(_readStringSet(box.get('pendingDeletes')));
      _isDirty = box.get('isDirty', defaultValue: false) == true;
    } else {
      await box.delete('data');
      await box.delete('pendingUpserts');
      await box.delete('pendingDeletes');
      await box.delete('isDirty');
      await box.put('uid', currentUid);
      await fetchFromFirebase();
    }

    _isLoading = false;
    notifyListeners();
  }

  void setDetails({
    String? title,
    String? description,
    String? scoreText,
    String? dateText,
    String? imageUrl,
    String? genreText,
  }) {
    if (title != null) detailsTitle = title;
    if (description != null) detailsDescription = description;
    if (scoreText != null) detailsScoreText = scoreText;
    if (dateText != null) detailsDateText = dateText;
    if (imageUrl != null) detailsImageUrl = imageUrl;
    if (genreText != null) detailsGenreText = genreText;
    notifyListeners();
  }

  Future<void> addOrUpdateItem({
    required ContentType type,
    required Object id,
    String? title,
    String? imageUrl,
    Map<String, dynamic>? extra,
    String folder = 'library',
  }) async {
    final key = '${_typePrefix(type)}_${id.toString()}';
    final existing = libraryMap[key] is Map<String, dynamic>
        ? libraryMap[key] as Map<String, dynamic>
        : libraryMap[key] is Map
            ? Map<String, dynamic>.from(libraryMap[key] as Map)
            : null;

    _library ??= UserLibrary(library: {}, customFolders: []);
    _library!.library[key] = {
      'id': id,
      'type': _typePrefix(type),
      'title': title ?? existing?['title'],
      'imageURL': imageUrl ?? existing?['imageURL'],
      'folder': folder,
      'addedAt': existing?['addedAt'] ?? DateTime.now().millisecondsSinceEpoch,
      'updatedAt': DateTime.now().millisecondsSinceEpoch,
      if (extra != null) ...extra,
    };

    _pendingDeletes.remove(key);
    _pendingUpserts.add(key);
    _isDirty = true;
    await _saveToLocal();
    notifyListeners();
  }

  Future<void> removeFromLibrary(ContentType type, Object id) async {
    if (_library == null) return;

    final key = '${_typePrefix(type)}_${id.toString()}';
    _library!.library.remove(key);
    _pendingUpserts.remove(key);
    _pendingDeletes.add(key);
    _isDirty = true;
    await _saveToLocal();
    notifyListeners();
  }

  Future<bool> addCustomFolder(String name) async {
    final folderName = name.trim();
    if (folderName.isEmpty || _library == null) return false;
    if (_library!.customFolders.contains(folderName)) return false;
    if (_library!.customFolders.length >= 5) return false;

    _library!.customFolders.add(folderName);
    _isDirty = true;
    await _saveToLocal();
    notifyListeners();
    return true;
  }

  Future<void> removeCustomFolder(String name) async {
    if (_library == null) return;

    _library!.customFolders.remove(name);
    _library!.library.forEach((key, value) {
      if (value is Map && value['folder'] == name) {
        value['folder'] = 'library';
        value['updatedAt'] = DateTime.now().millisecondsSinceEpoch;
        _pendingUpserts.add(key);
      }
    });

    _isDirty = true;
    await _saveToLocal();
    notifyListeners();
  }

  Future<void> syncToFirebase() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || _library == null || !_isDirty) return;

    final now = Timestamp.now();
    final patch = <String, dynamic>{
      'schemaVersion': UserLibrary.schemaVersion,
      'customFolders': _library!.customFolders,
      'folders': UserLibrary.defaultFolders,
      'sync.lastClientCheckpointAt': now,
      'sync.dirtyItemCount': _pendingUpserts.length + _pendingDeletes.length,
      'sync.revision': FieldValue.increment(1),
      ..._buildStatsPatch(),
    };

    for (final key in _pendingUpserts) {
      final item = _library!.library[key];
      if (item is Map) {
        patch['library.$key'] = Map<String, dynamic>.from(item);
      }
    }

    await _database.patchUserDocument(user.uid, patch);

    if (_pendingDeletes.isNotEmpty) {
      await _database.deleteUserFields(
        user.uid,
        _pendingDeletes.map((key) => 'library.$key').toList(),
      );
    }

    await _database.patchUserDocument(user.uid, {
      'sync.lastSuccessfulSyncAt': now,
      'sync.lastClientCheckpointAt': now,
      'sync.dirtyItemCount': 0,
    });

    _pendingUpserts.clear();
    _pendingDeletes.clear();
    _isDirty = false;
    await _saveToLocal();
    notifyListeners();
  }

  Future<void> fetchFromFirebase() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final data = await _database.getUserDocument(user.uid);
    _library = data != null
        ? UserLibrary.fromSnapshot(data)
        : UserLibrary(library: {}, customFolders: []);
    _pendingUpserts.clear();
    _pendingDeletes.clear();
    _isDirty = false;
    await _saveToLocal();
  }

  Future<void> _saveToLocal() async {
    if (_library == null) return;

    final box = await Hive.openBox('user_library');
    await box.put('uid', FirebaseAuth.instance.currentUser?.uid);
    await box.put('data', _library!.toFirebaseMap());
    await box.put('pendingUpserts', _pendingUpserts.toList());
    await box.put('pendingDeletes', _pendingDeletes.toList());
    await box.put('isDirty', _isDirty);
  }

  String _typePrefix(ContentType type) => type.name.replaceAll('s', '');

  bool isInLibrary(ContentType type, Object id) =>
      libraryMap.containsKey('${_typePrefix(type)}_${id.toString()}');

  Set<String> _readStringSet(dynamic raw) {
    if (raw is! List) return <String>{};
    return raw.map((item) => item.toString()).toSet();
  }

  Map<String, dynamic> _buildStatsPatch() {
    final stats = <String, int>{
      'totalItems': _library?.library.length ?? 0,
      'games': 0,
      'movies': 0,
      'series': 0,
      'anime': 0,
      'books': 0,
      'actors': 0,
    };

    for (final item in libraryMap.values) {
      if (item is! Map) continue;
      switch (item['type']) {
        case 'game':
          stats['games'] = stats['games']! + 1;
          break;
        case 'movie':
          stats['movies'] = stats['movies']! + 1;
          break;
        case 'serie':
          stats['series'] = stats['series']! + 1;
          break;
        case 'anime':
          stats['anime'] = stats['anime']! + 1;
          break;
        case 'book':
          stats['books'] = stats['books']! + 1;
          break;
        case 'actor':
          stats['actors'] = stats['actors']! + 1;
          break;
      }
    }

    return {
      for (final entry in stats.entries) 'stats.${entry.key}': entry.value,
    };
  }
}
