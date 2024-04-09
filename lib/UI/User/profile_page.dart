import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:gnml/Helper/auth.dart';
import 'package:gnml/Helper/theme_helper.dart';
import 'package:gnml/UI/Authentication/login_page.dart';
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
        appBar: AppBar(
          title: const Text("Profile"),
          actions: [
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
          ],
        ),
        body: StreamBuilder<DocumentSnapshot>(
          stream: userData.snapshots(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.hasData &&
                snapshot.connectionState == ConnectionState.active) {
              var list = snapshot.data.data();
              username = list['username'];
              var email = list['email'];
              var creationDate = list['creationDate'];
              var id = list['id'];
              var imageURL = list['imageURL'];
              return Center(
                child: Column(
                  children: [
                    isEditing
                        ? Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 20),
                                child: CircleAvatar(
                                  backgroundColor: Colors.transparent,
                                  backgroundImage: NetworkImage(imageURL),
                                  radius: 75,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Color(themeColor)),
                                  child: const Text("Upload Photo",
                                      style: TextStyle(color: Colors.white)),
                                  onPressed: () async {
                                    FilePickerResult? result =
                                        await FilePicker.platform.pickFiles(
                                      lockParentWindow: true,
                                      dialogTitle: "Pick an image",
                                      type: FileType.image,
                                    );

                                    if (result != null) {
                                      File file =
                                          File(result.files.single.path!);
                                      var byteData = await file.readAsBytes();
                                      var imageExtension = file.path
                                          .split(".")
                                          .last
                                          .toLowerCase();
                                      String path = "/$id/images";
                                      await supa.storage
                                          .from('profileImages')
                                          .uploadBinary(
                                            path,
                                            byteData,
                                            fileOptions: supabase.FileOptions(
                                              upsert: true,
                                              contentType:
                                                  "image/$imageExtension",
                                            ),
                                          );
                                      String publicURL = supa.storage
                                          .from('profileImages')
                                          .getPublicUrl(path);
                                      publicURL = Uri.parse(publicURL).replace(
                                          queryParameters: {
                                            't': DateTime.now()
                                                .millisecondsSinceEpoch
                                                .toString()
                                          }).toString();
                                      userData.update({"imageURL": publicURL});

                                      setState(() {});
                                    }
                                  },
                                ),
                              ),
                            ],
                          )
                        : Padding(
                            padding: const EdgeInsets.only(top: 20.0),
                            child: SizedBox(
                              height: 256,
                              width: 256,
                              child: CircleAvatar(
                                backgroundColor: Colors.transparent,
                                backgroundImage: NetworkImage(
                                  imageURL,
                                ),
                              ),
                            ),
                          ),
                    isEditing
                        ? Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: SizedBox(
                              width: 300,
                              child: TextFormField(
                                controller: usernameInputController,
                                decoration: const InputDecoration(
                                  label: Text("Username"),
                                ),
                              ),
                            ),
                          )
                        : Padding(
                            padding: const EdgeInsets.only(top: 24.0),
                            child: Text(
                              username,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 35),
                            ),
                          ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(email),
                    ),
                    Expanded(
                      child: Align(
                        alignment: AlignmentDirectional.bottomCenter,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text("Since $creationDate"),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black87,
                              foregroundColor: Colors.red),
                          onPressed: () async {
                            SharedPreferences prefs =
                                await SharedPreferences.getInstance();
                            prefs.remove('userEmail');
                            _auth.signOut();
                            // ignore: use_build_context_synchronously
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const LoginPage()),
                            );
                          },
                          child: const Text("Logout")),
                    )
                  ],
                ),
              );
            } else {
              return const Center();
            }
          },
        ));
  }
}
