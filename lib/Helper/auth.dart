import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  var uuid = const Uuid();

  Future signIn(String email, String password) async {
    UserCredential user = await _auth.signInWithEmailAndPassword(
        email: email, password: password);
    return user.user;
  }

  signOut() async {
    return await _auth.signOut();
  }

  Future<User?> registerENP(
    String username,
    String email,
    String password,
    String date,
  ) async {
    String id = uuid.v4();
    UserCredential user = await _auth.createUserWithEmailAndPassword(
        email: email, password: password);

    await _firestore.collection("brews").doc(user.user?.email).set({
      'id': id,
      'username': username,
      'email': email,
      'library': {
        "games": [],
        "movies": [],
        "series": [],
        "books": [],
        "actors": [],
      },
      'imageURL':
          "https://firebasestorage.googleapis.com/v0/b/scheduleme-adde6.appspot.com/o/placeholder.jpg?alt=media&token=9cfa9b9d-eb60-409b-8a5f-b3b54a5c1b10",
      'creationDate': date,
    });
    return user.user;
  }
}
