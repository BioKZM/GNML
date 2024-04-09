import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gnml/UI/homepage.dart';
import 'package:gnml/UI/Authentication/login_page.dart';
import 'package:gnml/Widgets/circularprogressindicator.dart';

class Redirect extends StatefulWidget {
  const Redirect({Key? key}) : super(key: key);

  @override
  State<Redirect> createState() => _RedirectState();
}

class _RedirectState extends State<Redirect> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const LoginPage();
        } else if (snapshot.connectionState == ConnectionState.active) {
          return const HomePage();
        } else {
          return const CustomCPI();
        }
      },
    );
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
