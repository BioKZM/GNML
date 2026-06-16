import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
// import 'package:hive.dart';
import 'package:hive/hive.dart';

class UserProvider extends ChangeNotifier {
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;
  FirebaseAuth get _auth => FirebaseAuth.instance;
  Box get _userBox => Hive.box('user_profile');

  Map<String, dynamic>? _userData;
  Map<String, dynamic>? get userData => _userData;

  dynamic _sanitizeForHive(dynamic value) {
    if (value is Timestamp) {
      return value.millisecondsSinceEpoch;
    }
    if (value is Map) {
      return value.map(
        (key, nestedValue) => MapEntry(
          key.toString(),
          _sanitizeForHive(nestedValue),
        ),
      );
    }
    if (value is Iterable) {
      return value.map(_sanitizeForHive).toList();
    }
    return value;
  }

  Future<void> init() async {
    final currentUid = _auth.currentUser?.uid;
    final cachedUid = _userBox.get('uid')?.toString();
    final localData = _userBox.get('profile');

    if (localData != null && currentUid != null && cachedUid == currentUid) {
      _userData = Map<String, dynamic>.from(localData);
      notifyListeners();
    } else if (cachedUid != currentUid) {
      _userData = null;
      await _userBox.delete('profile');
      await _userBox.put('uid', currentUid);
      notifyListeners();
    }

    await refreshUser();
  }

  Future<void> refreshUser() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      _userData = null;
      await _userBox.delete('profile');
      await _userBox.delete('uid');
      notifyListeners();
      return;
    }

    try {
      final doc =
          await _firestore.collection('users').doc(currentUser.uid).get();

      if (doc.exists) {
        _userData = doc.data();
        await _userBox.put('uid', currentUser.uid);
        await _userBox.put('profile', _sanitizeForHive(_userData));
      } else {
        _userData = null;
        await _userBox.put('uid', currentUser.uid);
        await _userBox.delete('profile');
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Kullanici verisi guncellenirken hata: $e');
    }
  }
}
