import 'dart:io';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:gnml/Helper/auth.dart';
import 'package:gnml/Helper/theme_helper.dart';
import 'package:gnml/UI/Authentication/login_page.dart';
import 'package:gnml/Widgets/custom_app_window.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  User? user = FirebaseAuth.instance.currentUser;
  final _firestore = FirebaseFirestore.instance;
  final AuthService _auth = AuthService();
  TextEditingController usernameInputController = TextEditingController();
  bool isEditing = false;
  String username = "";
  final firebase = FirebaseStorage.instance;
  final supa = supabase.Supabase.instance.client;
  final List<String> imageUrls = [
    'https://images.igdb.com/igdb/image/upload/t_cover_big/co2on2.jpg',
    'https://images.igdb.com/igdb/image/upload/t_cover_big/co20n4.jpg',
    'https://images.igdb.com/igdb/image/upload/t_cover_big/co1wyy.jpg',
    'https://images.igdb.com/igdb/image/upload/t_cover_big/co2sjh.jpg',
    'https://images.igdb.com/igdb/image/upload/t_cover_big/co670h.jpg',
    'https://images.igdb.com/igdb/image/upload/t_cover_big/co1vcf.jpg',
    'https://images.igdb.com/igdb/image/upload/t_cover_big/co1tmu.jpg',
    'https://images.igdb.com/igdb/image/upload/t_cover_big/co1qrj.jpg',
    'https://images.igdb.com/igdb/image/upload/t_cover_big/co2855.jpg',
    'https://images.igdb.com/igdb/image/upload/t_cover_big/co1rgi.jpg',
    'https://images.igdb.com/igdb/image/upload/t_cover_big/co3pah.jpg',
    'https://images.igdb.com/igdb/image/upload/t_cover_big/co1q1f.jpg',
    'https://images.igdb.com/igdb/image/upload/t_cover_big/co1r7f.jpg',
    'https://images.igdb.com/igdb/image/upload/t_cover_big/co7497.jpg',
    'https://images.igdb.com/igdb/image/upload/t_cover_big/co1r77.jpg',
    'https://images.igdb.com/igdb/image/upload/t_cover_big/co1rba.jpg',
    'https://images.igdb.com/igdb/image/upload/t_cover_big/co1rb4.jpg',
    'https://images.igdb.com/igdb/image/upload/t_cover_big/co66nd.jpg',
    'https://images.igdb.com/igdb/image/upload/t_cover_big/co39vc.jpg',
    'https://images.igdb.com/igdb/image/upload/t_cover_big/co2a23.jpg',
    'https://images.igdb.com/igdb/image/upload/t_cover_big/co2crj.jpg',
    'https://images.igdb.com/igdb/image/upload/t_cover_big/co2una.jpg',
    'https://images.igdb.com/igdb/image/upload/t_cover_big/co1voj.jpg',
    'https://images.igdb.com/igdb/image/upload/t_cover_big/co6kqt.jpg',
    'https://images.igdb.com/igdb/image/upload/t_cover_big/co4jni.jpg',
    'https://images.igdb.com/igdb/image/upload/t_cover_big/co1ir3.jpg',
    'https://images.igdb.com/igdb/image/upload/t_cover_big/co2gn3.jpg',
    'https://images.igdb.com/igdb/image/upload/t_cover_big/co69sm.jpg',
    'https://images.igdb.com/igdb/image/upload/t_cover_big/co7jfv.jpg',
    'https://images.igdb.com/igdb/image/upload/t_cover_big/co691r.jpg',
  ];
  @override
  void initState() {
    getUser();
    super.initState();
  }

  void getUser() async {
    user = FirebaseAuth.instance.currentUser;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    CollectionReference data = _firestore.collection('brews');
    var userData = data.doc("${user!.email}");
    int themeColor = Provider.of<ThemeProvider>(context).color;
    return Scaffold(
        body: StreamBuilder<DocumentSnapshot>(
      stream: userData.snapshots(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasData &&
            snapshot.connectionState == ConnectionState.active) {
          var list = snapshot.data.data();
          username = list['username'];
          var creationDate = list['creationDate'];
          var id = list['id'];
          var imageURL = list['imageURL'];
          return Stack(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 60, 10, 0),
                child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 10,
                            mainAxisSpacing: 10,
                            crossAxisSpacing: 10,
                            childAspectRatio: 0.6),
                    itemCount: imageUrls.length,
                    itemBuilder: (context, index) {
                      return Image.network(
                        imageUrls[index],
                        fit: BoxFit.fill,
                      );
                    }),
              ),
              BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                child: Container(
                  color: Colors.black.withOpacity(0.7),
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                ),
              ),
              Center(
                child: Card(
                  elevation: 5,
                  color: const Color.fromARGB(255, 22, 22, 22).withOpacity(0.9),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          isEditing
                              ? IconButton(
                                  icon: const Icon(
                                    Icons.check,
                                  ),
                                  onPressed: () async {
                                    var newName = usernameInputController.text;

                                    if (newName.isNotEmpty) {
                                      username = usernameInputController.text;
                                      userData.update({
                                        'username': newName,
                                      });
                                    } else {
                                      userData.update(
                                        {'username': username},
                                      );
                                    }
                                    setState(() {
                                      isEditing = !isEditing;
                                    });
                                  },
                                )
                              : IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () {
                                    setState(() {
                                      isEditing = !isEditing;
                                    });
                                  },
                                ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(32, 0, 32, 32),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                isEditing
                                    ? Column(
                                        children: [
                                          Stack(
                                            children: [
                                              SizedBox(
                                                height: 128,
                                                width: 128,
                                                child: CircleAvatar(
                                                  backgroundColor:
                                                      Colors.transparent,
                                                  backgroundImage: NetworkImage(
                                                    imageURL,
                                                  ),
                                                ),
                                              ),
                                              Positioned(
                                                bottom: 0,
                                                right: 0,
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    border: Border.all(
                                                        color: Colors.grey,
                                                        width: 2),
                                                  ),
                                                  child: IconButton(
                                                    icon: const Icon(FluentIcons
                                                        .camera_16_filled),
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                            backgroundColor:
                                                                Colors.black),
                                                    onPressed: () async {
                                                      FilePickerResult? result =
                                                          await FilePicker
                                                              .platform
                                                              .pickFiles(
                                                        lockParentWindow: true,
                                                        dialogTitle:
                                                            "Pick an image",
                                                        type: FileType.image,
                                                      );

                                                      if (result != null) {
                                                        File file = File(result
                                                            .files
                                                            .single
                                                            .path!);
                                                        var byteData =
                                                            await file
                                                                .readAsBytes();
                                                        var imageExtension =
                                                            file.path
                                                                .split(".")
                                                                .last
                                                                .toLowerCase();
                                                        String path =
                                                            "/$id/images";
                                                        await supa.storage
                                                            .from(
                                                                'profileImages')
                                                            .uploadBinary(
                                                              path,
                                                              byteData,
                                                              fileOptions: supabase
                                                                  .FileOptions(
                                                                upsert: true,
                                                                contentType:
                                                                    "image/$imageExtension",
                                                              ),
                                                            );
                                                        String publicURL = supa
                                                            .storage
                                                            .from(
                                                                'profileImages')
                                                            .getPublicUrl(path);
                                                        publicURL = Uri.parse(
                                                                publicURL)
                                                            .replace(
                                                                queryParameters: {
                                                              't': DateTime
                                                                      .now()
                                                                  .millisecondsSinceEpoch
                                                                  .toString()
                                                            }).toString();
                                                        userData.update({
                                                          "imageURL": publicURL
                                                        });

                                                        setState(() {});
                                                      }
                                                    },
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      )
                                    : SizedBox(
                                        height: 128,
                                        width: 128,
                                        child: CircleAvatar(
                                          backgroundColor: Colors.transparent,
                                          backgroundImage: NetworkImage(
                                            imageURL,
                                          ),
                                        ),
                                      ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 70.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      isEditing
                                          ? Padding(
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                      0, 8, 0, 8),
                                              child: SizedBox(
                                                width: 300,
                                                child: TextFormField(
                                                  controller:
                                                      usernameInputController,
                                                  decoration:
                                                      const InputDecoration(
                                                    label: Text("Username"),
                                                  ),
                                                ),
                                              ),
                                            )
                                          : Text(
                                              username,
                                              style: const TextStyle(
                                                  // fontWeight: FontWeight.bold,
                                                  fontSize: 30),
                                            ),
                                      Padding(
                                        padding: const EdgeInsets.all(2.0),
                                        child: Text(
                                          "Since $creationDate",
                                          style: const TextStyle(
                                            fontSize: 13,
                                          ),
                                        ),
                                      ),
                                      isEditing
                                          ? Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 32.0),
                                              child: ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        Colors.black87,
                                                    foregroundColor:
                                                        Colors.red),
                                                onPressed: () async {
                                                  SharedPreferences prefs =
                                                      await SharedPreferences
                                                          .getInstance();
                                                  prefs.remove('userEmail');
                                                  _auth.signOut();
                                                  // ignore: use_build_context_synchronously
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            const LoginPage()),
                                                  );
                                                },
                                                child: Text("Logout",
                                                    style: TextStyle(
                                                        color:
                                                            Color(themeColor))),
                                              ),
                                            )
                                          : Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 16.0),
                                              child: ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        Colors.black87,
                                                    foregroundColor:
                                                        Colors.red),
                                                onPressed: () async {
                                                  SharedPreferences prefs =
                                                      await SharedPreferences
                                                          .getInstance();
                                                  prefs.remove('userEmail');
                                                  _auth.signOut();
                                                  // ignore: use_build_context_synchronously
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            const LoginPage()),
                                                  );
                                                },
                                                child: Text("Logout",
                                                    style: TextStyle(
                                                        color:
                                                            Color(themeColor))),
                                              ),
                                            )
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              // Padding(
              //   padding: const EdgeInsets.fromLTRB(8.0, 41, 8, 8),
              //   child: IconButton(
              //     icon: const Icon(FluentIcons.arrow_left_12_filled),
              //     onPressed: () {
              //       Navigator.pop(context);
              //     },
              //   ),
              // ),
              SizedBox(
                height: 45,
                width: MediaQuery.of(context).size.width,
                child: CustomAppWindow(
                  isExitable: true,
                ),
              ),
            ],
          );
        } else {
          return const Center();
        }
      },
    ));
  }
}
