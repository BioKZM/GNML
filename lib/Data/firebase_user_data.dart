import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseUserData {
  User? user;
  FirebaseUserData({
    required this.user,
  });

  Future<DocumentSnapshot> getData() async {
    CollectionReference collectionReference =
        FirebaseFirestore.instance.collection('brews');

    DocumentReference documentReference =
        collectionReference.doc('${user?.email}');

    DocumentSnapshot documentSnapshot = await documentReference.get();

    return documentSnapshot;
  }

  Future<void> updateData(
    List games,
    List movies,
    List series,
    List books,
    List actors,
  ) async {
    CollectionReference collectionReference =
        FirebaseFirestore.instance.collection('brews');
    DocumentReference documentReference =
        collectionReference.doc('${user?.email}');
    Map<String, dynamic> updatedData = {
      "library": {
        "games": games,
        "movies": movies,
        "series": series,
        "books": books,
        "actors": actors,
      }
    };

    await documentReference.update(updatedData);
  }
}
