import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:vault/Services/database_service.dart';

class FirebaseDatabaseImpl implements DatabaseService {
  final FirebaseFirestore _firestore;

  FirebaseDatabaseImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<Map<String, dynamic>?> getUserDocument(String uid) async {
    final snapshot = await _firestore.collection('users').doc(uid).get();
    final data = snapshot.data();
    if (data == null) return null;
    return Map<String, dynamic>.from(data);
  }

  @override
  Future<void> setUserDocument(
    String uid,
    Map<String, dynamic> data, {
    bool merge = true,
  }) async {
    await _firestore
        .collection('users')
        .doc(uid)
        .set(data, SetOptions(merge: merge));
  }

  @override
  Future<void> ensureUserInitialized({
    required User user,
    String? username,
    String? imageUrl,
    String? creationDate,
  }) async {
    final docRef = _firestore.collection('users').doc(user.uid);
    final snapshot = await docRef.get();
    final baseHandle = _slugify(
      username ?? user.displayName ?? user.email?.split('@').first ?? 'user',
    );

    if (!snapshot.exists || snapshot.data() == null) {
      final handle = await _ensureUniqueHandle(baseHandle, uid: user.uid);
      await setUserDocument(
        user.uid,
        {
          'schemaVersion': 1,
          'email': user.email,
          'username':
              username ?? user.displayName ?? user.email?.split('@').first,
          'imageURL': imageUrl ?? user.photoURL,
          'handle': handle,
          'profile': {
            'photoUrl': imageUrl ?? user.photoURL,
            'bannerUrl': null,
          },
          'settings': {
            'lastBackgroundChange': null,
          },
          'showcases': {
            'enabled': {
              'rareAchievements': false,
              'favoriteCollection': true,
              'screenshotGallery': false,
            },
            'favoriteCollection': [],
          },
          'library': {},
          'folders': {
            'favorites': {'type': 'default'},
            'completed': {'type': 'default'},
            'backlog': {'type': 'default'},
          },
          'customFolders': [],
          if (creationDate != null) 'creationDate': creationDate,
        },
        merge: true,
      );
      return;
    }

    final existing = snapshot.data() ?? {};
    final patch = <String, dynamic>{};
    if (existing['schemaVersion'] != 1) patch['schemaVersion'] = 1;
    patch['email'] = user.email;
    patch['username'] =
        username ?? user.displayName ?? user.email?.split('@').first;
    if (existing['handle'] == null) {
      patch['handle'] = await _ensureUniqueHandle(baseHandle, uid: user.uid);
    }
    if (existing['profile'] is! Map ||
        ((existing['profile'] as Map)['photoUrl'] == null)) {
      patch['profile.photoUrl'] = imageUrl ?? user.photoURL;
    }
    if (existing['settings'] is! Map) {
      patch['settings.lastBackgroundChange'] = null;
    }
    if (existing['showcases'] == null) {
      patch['showcases'] = {
        'enabled': {
          'rareAchievements': false,
          'favoriteCollection': true,
          'screenshotGallery': false,
        },
        'favoriteCollection': [],
      };
    }
    if (existing['library'] == null) patch['library'] = {};
    if (existing['folders'] == null) {
      patch['folders'] = {
        'favorites': {'type': 'default'},
        'completed': {'type': 'default'},
        'backlog': {'type': 'default'},
      };
    }
    if (existing['customFolders'] == null) patch['customFolders'] = [];
    if (creationDate != null && existing['creationDate'] == null) {
      patch['creationDate'] = creationDate;
    }
    if (patch.isEmpty) return;
    await docRef.set(patch, SetOptions(merge: true));
  }

  @override
  Future<void> updateProfileCustomization({
    required String uid,
    String? handle,
    String? profileImageUrl,
    String? backgroundUrl,
    Map<String, dynamic>? showcases,
  }) async {
    final docRef = _firestore.collection('users').doc(uid);

    String? nextHandle;
    if (handle != null) {
      nextHandle = await _ensureUniqueHandle(_slugify(handle), uid: uid);
    }

    if (backgroundUrl != null) {
      final snapshot = await docRef.get();
      final data = snapshot.data() ?? {};
      final settings = (data['settings'] as Map?) ?? {};
      final existing = settings['lastBackgroundChange'];
      if (existing is Timestamp) {
        final now = DateTime.now();
        final earliest = existing.toDate().add(const Duration(days: 30));
        if (now.isBefore(earliest)) {
          throw StateError('BACKGROUND_CHANGE_RATE_LIMIT');
        }
      }
    }

    final patch = <String, dynamic>{};
    if (nextHandle != null) patch['handle'] = nextHandle;
    if (profileImageUrl != null) {
      patch['profile.photoUrl'] = profileImageUrl;
      patch['imageURL'] = profileImageUrl;
    }
    if (backgroundUrl != null) {
      patch['profile.bannerUrl'] = backgroundUrl;
      patch['settings.lastBackgroundChange'] = Timestamp.now();
    }
    if (showcases != null) {
      patch['showcases'] = showcases;
    }

    if (patch.isEmpty) return;
    await docRef.set(patch, SetOptions(merge: true));
  }

  @override
  Future<Map<String, dynamic>?> getPublicUserByHandle(String handle) async {
    final normalized = _slugify(handle);
    final query = await _firestore
        .collection('users')
        .where('handle', isEqualTo: normalized)
        .limit(1)
        .get();
    if (query.docs.isEmpty) return null;
    return Map<String, dynamic>.from(query.docs.first.data());
  }

  String _slugify(String input) {
    final lower = input.toLowerCase().trim();
    final cleaned = lower.replaceAll(RegExp(r'[^a-z0-9_]+'), '_');
    final compact =
        cleaned.replaceAll(RegExp(r'_+'), '_').replaceAll(RegExp(r'^_|_$'), '');
    return compact.isEmpty ? 'user' : compact;
  }

  Future<String> _ensureUniqueHandle(String base, {String? uid}) async {
    String candidate = base;
    int attempt = 0;
    while (attempt < 10) {
      final query = await _firestore
          .collection('users')
          .where('handle', isEqualTo: candidate)
          .limit(1)
          .get();
      if (query.docs.isEmpty) return candidate;
      final existingUid = query.docs.first.id;
      if (uid != null && existingUid == uid) return candidate;
      attempt += 1;
      candidate = '${base}_${(1000 + attempt * 137) % 9000}';
    }
    return '${base}_${DateTime.now().millisecondsSinceEpoch % 10000}';
  }
}
