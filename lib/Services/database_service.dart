import 'package:firebase_auth/firebase_auth.dart';

abstract class DatabaseService {
  Future<Map<String, dynamic>?> getUserDocument(String uid);

  Future<void> setUserDocument(
    String uid,
    Map<String, dynamic> data, {
    bool merge = true,
  });

  Future<void> patchUserDocument(String uid, Map<String, dynamic> patch);

  Future<void> deleteUserFields(String uid, List<String> fieldPaths);

  Future<void> ensureUserInitialized({
    required User user,
    String? username,
    String? imageUrl,
    String? creationDate,
  });

  Future<void> updateProfileCustomization({
    required String uid,
    String? handle,
    String? profileImageUrl,
    String? backgroundUrl,
    Map<String, dynamic>? showcases,
  });

  Future<Map<String, dynamic>?> getPublicUserByHandle(String handle);
}
