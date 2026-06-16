import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:uuid/uuid.dart';
import 'package:vault/Services/database_service.dart';
import 'package:vault/Services/firebase_database_impl.dart';

class AuthService {
  FirebaseAuth get _auth => FirebaseAuth.instance;
  final DatabaseService _database;

  var uuid = const Uuid();

  static const String _placeholderImageUrl =
      'https://firebasestorage.googleapis.com/v0/b/scheduleme-adde6.appspot.com/o/placeholder.jpg?alt=media&token=9cfa9b9d-eb60-409b-8a5f-b3b54a5c1b10';

  AuthService({DatabaseService? database})
      : _database = database ?? FirebaseDatabaseImpl();

  Future signIn(String email, String password) async {
    UserCredential user = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return user.user;
  }

  signOut() async {
    return await _auth.signOut();
  }

  Future<User?> signInWithGoogle() async {
    if (kIsWeb) {
      final credential = await _auth.signInWithPopup(GoogleAuthProvider());
      if (credential.user != null) {
        await _database.ensureUserInitialized(user: credential.user!);
      }
      return credential.user;
    }

    final googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) return null;
    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    final userCredential = await _auth.signInWithCredential(credential);
    if (userCredential.user != null) {
      await _database.ensureUserInitialized(user: userCredential.user!);
    }
    return userCredential.user;
  }

  Future<User?> signInWithApple() async {
    if (kIsWeb) {
      final credential = await _auth.signInWithPopup(AppleAuthProvider());
      if (credential.user != null) {
        await _database.ensureUserInitialized(user: credential.user!);
      }
      return credential.user;
    }

    final appleCredential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
    );

    final oauthCredential = OAuthProvider('apple.com').credential(
      idToken: appleCredential.identityToken,
      accessToken: appleCredential.authorizationCode,
    );

    final userCredential = await _auth.signInWithCredential(oauthCredential);
    if (userCredential.user != null) {
      await _database.ensureUserInitialized(user: userCredential.user!);
    }
    return userCredential.user;
  }

  Future<User?> registerENP(
    String username,
    String email,
    String password,
    String date,
  ) async {
    UserCredential user = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final created = user.user;
    if (created != null) {
      await _database.ensureUserInitialized(
        user: created,
        username: username,
        imageUrl: _placeholderImageUrl,
        creationDate: date,
      );
      await _database.patchUserDocument(
        created.uid,
        {
          'id': uuid.v4(),
        },
      );
    }
    return user.user;
  }
}
