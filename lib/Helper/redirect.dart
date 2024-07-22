import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gnml/UI/homepage.dart';
import 'package:gnml/UI/Authentication/login_page.dart';
import 'package:gnml/UI/mobile_homepage.dart';
import 'package:gnml/Widgets/circularprogressindicator.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;

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
          if (!kIsWeb) {
            if (Platform.isWindows) {
              return const HomePage();
            } else if (Platform.isAndroid) {
              return const MobileHomePage();
            } else {
              return const CustomCPI();
            }
          } else {
            return const HomePage();
          }
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
