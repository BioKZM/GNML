import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:gnml/Helper/theme_helper.dart';
import 'package:gnml/UI/User/profile_page.dart';
import 'package:gnml/UI/games_page/games_page.dart';
import 'package:gnml/UI/library_page/library_page.dart';
import 'package:gnml/UI/movies_page/movies_page.dart';
import 'package:gnml/UI/search_page/search_page.dart';
import 'package:gnml/UI/series_page/series_page.dart';
import 'package:gnml/UI/User/settings_page.dart';
import 'package:gnml/Widgets/circularprogressindicator.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:updat/updat.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  User? user = FirebaseAuth.instance.currentUser;
  final _firestore = FirebaseFirestore.instance;

  late TabController _tabController;
  GlobalKey key = GlobalKey();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    CollectionReference data = _firestore.collection('brews');
    var userData = data.doc("${user!.email}");
    return Stack(
      children: [
        StreamBuilder<DocumentSnapshot>(
            stream: userData.snapshots(),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.connectionState == ConnectionState.active) {
                var snapshotData = snapshot.data?.data();
                var imageURL = snapshotData['imageURL'];
                return Stack(
                  children: [
                    Scaffold(
                      body: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                                top: 16.0, left: 48, right: 32, bottom: 16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                MouseRegion(
                                  cursor: SystemMouseCursors.click,
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const ProfilePage(),
                                        ),
                                      );
                                    },
                                    child: SizedBox(
                                      child: CircleAvatar(
                                        radius: 32,
                                        backgroundImage:
                                            CachedNetworkImageProvider(
                                          imageURL,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            left: 64, right: 64),
                                        child: Card(
                                          elevation: 10,
                                          child: TabBarCustom(
                                              _tabController, context),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Tooltip(
                                  message: "Settings",
                                  child: SizedBox(
                                    height: 50,
                                    width: 50,
                                    child: IconButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const SettingsPage(),
                                          ),
                                        );
                                      },
                                      icon: const Icon(
                                          FluentIcons.settings_32_filled),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  left: 32, right: 32, bottom: 32),
                              child: Card(
                                elevation: 0,
                                child: TabBarView(
                                  controller: _tabController,
                                  children: const [
                                    LibraryPage(),
                                    GamesPage(),
                                    MoviesPage(),
                                    SeriesPage(),
                                    SearchPage(),
                                  ],
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                );
              } else {
                return const CustomCPI();
              }
            }),
        FutureBuilder(
            future: getAppVersion(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                String appVersion = "${snapshot.data}";
                return Positioned(
                  bottom: 10,
                  right: 10,
                  child: UpdatWidget(
                    currentVersion: appVersion,
                    getLatestVersion: () async {
                      final data = await http.get(Uri.parse(
                        "https://api.github.com/repos/BioKZM/GNML/releases/latest",
                      ));
                      return jsonDecode(data.body)["tag_name"];
                    },
                    getBinaryUrl: (latestVersion) async {
                      return "https://github.com/BioKZM/GNML/releases/download/$latestVersion/GNML.exe";
                    },
                    appName: "GNML - Game and Movie Library",
                  ),
                );
              } else {
                return const Positioned(
                  bottom: 10,
                  left: 10,
                  child: Card(child: CustomCPI()),
                );
              }
            })
      ],
    );
  }
}

// ignore: non_constant_identifier_names
Widget TabBarCustom(tabController, context) {
  return Material(
    borderRadius: const BorderRadius.all(Radius.circular(12)),
    color: Color(Provider.of<ThemeProvider>(context).color).withOpacity(0.70),
    child: TabBar(
      controller: tabController,
      splashFactory: NoSplash.splashFactory,
      overlayColor:
          MaterialStateProperty.all(const Color.fromARGB(0, 255, 0, 0)),
      dividerColor: Colors.transparent,
      tabs: const [
        Tab(
          icon: Icon(FluentIcons.library_32_filled),
        ),
        Tab(
          text: "Games",
        ),
        Tab(
          text: "Movies",
        ),
        Tab(
          text: "Series",
        ),
        Tab(
          icon: Icon(FluentIcons.search_32_filled),
        ),
      ],
    ),
  );
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

Future<String> getAppVersion() async {
  PackageInfo packageInfo = await PackageInfo.fromPlatform();
  return packageInfo.version;
}
