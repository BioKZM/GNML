import 'package:flutter/material.dart';
import 'package:flutter_hsvcolor_picker/flutter_hsvcolor_picker.dart';
import 'package:gnml/Helper/theme_helper.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:window_manager/window_manager.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool switchValue = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Color colorPicker = Color(Provider.of<ThemeProvider>(context).color);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    "Window Size",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 230),
                  child: DropdownMenu(
                    onSelected: (value) async {
                      final SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      double width = 800.0;
                      double height = 600.0;

                      switch (value) {
                        case 0:
                          WindowManager.instance
                              .setMaximumSize(const Size(1920, 1080));
                          WindowManager.instance
                              .setSize(const Size(1920, 1080));
                          width = 1920;
                          height = 1080;

                        case 1:
                          WindowManager.instance
                              .setMaximumSize(const Size(1600, 900));
                          WindowManager.instance.setSize(const Size(1600, 900));
                          width = 1600;
                          height = 900;
                        case 2:
                          WindowManager.instance
                              .setMaximumSize(const Size(1366, 768));
                          WindowManager.instance.setSize(const Size(1366, 768));
                          width = 1366;
                          height = 768;
                        case 3:
                          WindowManager.instance
                              .setMaximumSize(const Size(1280, 1024));
                          WindowManager.instance
                              .setSize(const Size(1280, 1024));
                          width = 1280;
                          height = 1024;
                        case 4:
                          WindowManager.instance
                              .setMaximumSize(const Size(1280, 960));
                          WindowManager.instance.setSize(const Size(1280, 960));
                          width = 1280;
                          height = 960;
                        case 5:
                          WindowManager.instance
                              .setMaximumSize(const Size(1280, 768));
                          WindowManager.instance.setSize(const Size(1280, 768));
                          width = 1280;
                          height = 768;
                        case 6:
                          WindowManager.instance
                              .setMaximumSize(const Size(1280, 720));
                          WindowManager.instance.setSize(const Size(1280, 720));
                          width = 1280;
                          height = 720;
                        case 7:
                          WindowManager.instance
                              .setMaximumSize(const Size(1128, 720));
                          WindowManager.instance.setSize(const Size(1128, 720));
                          width = 1128;
                          height = 720;
                        case 8:
                          WindowManager.instance
                              .setMaximumSize(const Size(1128, 634));
                          WindowManager.instance.setSize(const Size(1128, 634));
                          width = 1128;
                          height = 634;
                        case 9:
                          WindowManager.instance
                              .setMaximumSize(const Size(1024, 768));
                          WindowManager.instance.setSize(const Size(1024, 768));
                          width = 1024;
                          height = 768;
                        case 10:
                          WindowManager.instance
                              .setMaximumSize(const Size(800, 600));
                          WindowManager.instance.setSize(const Size(800, 600));
                          width = 800;
                          height = 600;
                      }
                      await prefs.setDouble("width", width);
                      await prefs.setDouble("height", height);
                    },
                    dropdownMenuEntries: const [
                      DropdownMenuEntry(value: 0, label: "1920 x 1080"),
                      DropdownMenuEntry(value: 1, label: "1600 x 900"),
                      DropdownMenuEntry(value: 2, label: "1366 x 768"),
                      DropdownMenuEntry(value: 3, label: "1280 x 1024"),
                      DropdownMenuEntry(value: 4, label: "1280 x 960"),
                      DropdownMenuEntry(value: 5, label: "1280 x 768"),
                      DropdownMenuEntry(value: 6, label: "1280 x 720"),
                      DropdownMenuEntry(value: 7, label: "1128 x 720"),
                      DropdownMenuEntry(value: 8, label: "1128 x 634"),
                      DropdownMenuEntry(value: 9, label: "1024 x 768"),
                      DropdownMenuEntry(value: 10, label: "800 x 600"),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        "Theme Color",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                        ),
                      ),
                    ),
                    Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: SizedBox(
                            width: 600,
                            child: ColorPicker(
                              color: colorPicker,
                              onChanged: (value) {
                                colorPicker = value;
                              },
                              initialPicker: Picker.wheel,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.check),
                          onPressed: () {
                            Provider.of<ThemeProvider>(context, listen: false)
                                .setColor(colorPicker.value);
                          },
                        )
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Future setColor(color) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setInt("themeColor", color.value);
}

Future<int?> getColor() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  var color = prefs.getInt("themeColor");
  if (color == null) {
    return const Color.fromARGB(255, 180, 0, 0).value;
  } else {
    return color;
  }
}

Future setTheme(theme) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setBool("lightTheme", theme);
}
