import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:vault/Data/Model/user_library.dart';
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
  UserLibrary? get library => _library;
  bool get isLoading => _isLoading;
  Map<String, dynamic> get libraryMap => _library?.library ?? const {};
  List<String> get customFolders =>
      List.unmodifiable(_library?.customFolders ?? const []);

  LibraryProvider({DatabaseService? database})
      : _database = database ?? FirebaseDatabaseImpl();

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

  Future<void> init() async {
    _isLoading = true;
    notifyListeners();

    try {
      final currentUid = FirebaseAuth.instance.currentUser?.uid;
      final box = Hive.isBoxOpen('user_library')
          ? Hive.box('user_library')
          : await Hive.openBox('user_library');
      var localData = box.get('data');

      if (localData != null) {
        try {
          // Ensure map keys are Strings
          final castedData = Map<String, dynamic>.from(localData);
          final cachedUid = castedData['uid']?.toString();
          if (currentUid != null && cachedUid == currentUid) {
            if (castedData['schemaVersion'] == UserLibrary.schemaVersion) {
              _library = UserLibrary.fromSnapshot(castedData);
            } else {
              await fetchFromFirebase();
            }
          } else {
            await fetchFromFirebase();
          }
        } catch (e) {
          debugPrint("Error parsing local Hive data: $e");
          // Fallback to Firebase if local data is corrupt
          await fetchFromFirebase();
        }
      } else {
        await fetchFromFirebase();
      }
    } catch (e) {
      debugPrint("LibraryProvider init error: $e");
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchFromFirebase() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        try {
          user = await FirebaseAuth.instance
              .authStateChanges()
              .firstWhere((u) => u != null)
              .timeout(const Duration(seconds: 3));
        } catch (_) {}
      }
      if (user == null) {
        debugPrint("LibraryProvider: No user logged in.");
        _library = UserLibrary(
          library: {},
          customFolders: const [],
        );
        return;
      }

      final data = await _database.getUserDocument(user.uid);
      if (data == null) {
        await _database.ensureUserInitialized(user: user);
        _library = UserLibrary(library: {}, customFolders: const []);
        await _saveToHive();
        return;
      }

      if (data['schemaVersion'] != UserLibrary.schemaVersion) {
        await _database.setUserDocument(
          user.uid,
          UserLibrary(library: {}, customFolders: const []).toFirebaseMap(),
          merge: true,
        );
        _library = UserLibrary(library: {}, customFolders: const []);
      } else {
        _library = UserLibrary.fromSnapshot(data);
      }

      await _saveToHive();
    } catch (e) {
      debugPrint("Error fetching from Firebase: $e");
      _library = UserLibrary(
        library: {},
        customFolders: const [],
      );
    }
  }

  String _typePrefix(ContentType type) {
    switch (type) {
      case ContentType.games:
        return 'game';
      case ContentType.movies:
        return 'movie';
      case ContentType.series:
        return 'serie';
      case ContentType.books:
        return 'book';
      case ContentType.actors:
        return 'actor';
      case ContentType.anime:
        return 'anime';
    }
  }

  String compoundKey(ContentType type, Object id) => '${_typePrefix(type)}_$id';

  bool isInLibrary(ContentType type, Object id) {
    final lib = _library;
    if (lib == null) return false;
    return lib.library.containsKey(compoundKey(type, id));
  }

  String? folderOf(ContentType type, Object id) {
    final lib = _library;
    if (lib == null) return null;
    final raw = lib.library[compoundKey(type, id)];
    if (raw is! Map) return null;
    final folder = raw['folder']?.toString();
    return folder?.isEmpty == true ? null : folder;
  }

  Future<void> addOrUpdateItem({
    required ContentType type,
    required Object id,
    String? title,
    String? imageUrl,
    Map<String, dynamic>? extra,
    String folder = 'library',
  }) async {
    final lib = _library ?? UserLibrary(library: {}, customFolders: const []);
    final key = compoundKey(type, id);
    final existing = lib.library[key];
    final merged = <String, dynamic>{
      'id': id,
      'type': _typePrefix(type),
      'title': title ?? (existing is Map ? existing['title'] : null),
      'imageURL': imageUrl ?? (existing is Map ? existing['imageURL'] : null),
      'folder': (existing is Map ? existing['folder'] : null) ?? folder,
    };
    if (existing is Map) {
      merged.addAll(Map<String, dynamic>.from(existing));
    }
    if (extra != null) {
      merged.addAll(extra);
    }
    merged['addedAt'] ??= DateTime.now().millisecondsSinceEpoch;
    lib.library[key] = merged;
    _library = lib;
    await _saveToHive();
    notifyListeners();
  }

  Future<void> removeFromLibrary(ContentType type, Object id) async {
    final lib = _library;
    if (lib == null) return;
    final key = compoundKey(type, id);
    lib.library.remove(key);
    await _saveToHive();
    notifyListeners();
  }

  Future<void> moveToFolder(ContentType type, Object id, String folder) async {
    final lib = _library;
    if (lib == null) return;
    final key = compoundKey(type, id);
    final raw = lib.library[key];
    if (raw is! Map) return;
    final updated = Map<String, dynamic>.from(raw);
    updated['folder'] = folder;
    lib.library[key] = updated;
    await _saveToHive();
    notifyListeners();
  }

  Future<bool> addCustomFolder(String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return false;
    final lib = _library ?? UserLibrary(library: {}, customFolders: const []);

    final lower = trimmed.toLowerCase();
    const reserved = {'favorites', 'completed', 'backlog', 'library'};
    if (reserved.contains(lower)) return false;

    final existingLower = lib.customFolders.map((e) => e.toLowerCase()).toSet();
    if (existingLower.contains(lower)) return false;
    if (lib.customFolders.length >= 5) return false;

    final next = [...lib.customFolders, trimmed];
    _library = UserLibrary(library: lib.library, customFolders: next);
    await _saveToHive();
    notifyListeners();
    return true;
  }

  Future<void> removeCustomFolder(String name) async {
    final lib = _library;
    if (lib == null) return;
    final lower = name.toLowerCase().trim();
    final nextFolders =
        lib.customFolders.where((f) => f.toLowerCase() != lower).toList();

    for (final entry in lib.library.entries) {
      final raw = entry.value;
      if (raw is! Map) continue;
      final m = Map<String, dynamic>.from(raw);
      if ((m['folder']?.toString().toLowerCase()) == lower) {
        m['folder'] = 'library';
        lib.library[entry.key] = m;
      }
    }

    _library = UserLibrary(library: lib.library, customFolders: nextFolders);
    await _saveToHive();
    notifyListeners();
  }

  Future<void> _saveToHive() async {
    if (_library == null) return;
    final box = Hive.isBoxOpen('user_library')
        ? Hive.box('user_library')
        : await Hive.openBox('user_library');

    Map<String, dynamic> data = {
      'uid': FirebaseAuth.instance.currentUser?.uid,
      ..._library!.toFirebaseMap(),
    };

    await box.put('data', data);
  }

  Future<void> syncToFirebase() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null || _library == null) return;

    try {
      await _database.setUserDocument(
        user.uid,
        _library!.toFirebaseMap(),
        merge: true,
      );
    } catch (e) {
      debugPrint("Sync error: $e");
    }
  }
}
