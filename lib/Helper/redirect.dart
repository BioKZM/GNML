import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gnml/UI/homepage.dart';
import 'package:gnml/UI/Authentication/login_page.dart';
import 'package:updat/theme/chips/floating_with_silent_download.dart';
import 'package:updat/updat_window_manager.dart';
import 'package:http/http.dart' as http;

class Redirect extends StatefulWidget {
  const Redirect({Key? key}) : super(key: key);

  @override
  State<Redirect> createState() => _RedirectState();
}

class _RedirectState extends State<Redirect> {
  @override
  Widget build(BuildContext context) {
    if (FirebaseAuth.instance.currentUser == null) {
      return const LoginPage();
    } else {
      return const HomePage();
    }
    // return StreamBuilder<User?>(
    //   stream: FirebaseAuth.instance.authStateChanges(),
    //   builder: (BuildContext context, snapshot) {
    //     print(snapshot.hasData);
    //     print(snapshot.connectionState);
    //     if (snapshot.hasData &&
    //         snapshot.connectionState == ConnectionState.active) {
    //       return const HomePage();
    //     } else if (snapshot.connectionState == ConnectionState.waiting) {
    //       return const Center(
    //           child: CircularProgressIndicator(color: Colors.red));
    //     } else {
    //       return const LoginPage();
    //     }
    //   },
    // );
  }
}

String get platformExt {
  switch (Platform.operatingSystem) {
    case 'windows':
      {
        return 'exe';
      }

    case 'macos':
      {
        return 'dmg';
      }

    case 'linux':
      {
        return 'AppImage';
      }
    default:
      {
        return 'zip';
      }
  }
}
