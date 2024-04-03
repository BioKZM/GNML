import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'GNML',
      theme: ThemeData(
          brightness: Brightness.light,
          useMaterial3: true,
          colorSchemeSeed: const Color.fromRGBO(255, 0, 0, 1)),
      darkTheme: ThemeData(
          brightness: Brightness.dark,
          useMaterial3: true,
          highlightColor: Colors.transparent,
          colorSchemeSeed: Colors.blue,
          splashColor: Colors.transparent),
      themeMode: ThemeMode.dark,
      home: const Test(),
    );
  }
}

class Test extends StatefulWidget {
  const Test({super.key});

  @override
  State<Test> createState() => _TestState();
}

class _TestState extends State<Test> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: SizedBox(
          width: double.infinity,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 3, bottom: 3),
                child: FilledButton(
                  onPressed: () {},
                  child: const SizedBox(
                    width: 100,
                    child: Padding(
                      padding: EdgeInsets.all(4.0),
                      child: Text(
                        'Uzun Metin 1İkinci Satır',
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 3, bottom: 3),
                child: FilledButton(
                  onPressed: () {},
                  child: const SizedBox(
                    width: 100,
                    child: Padding(
                      padding: EdgeInsets.all(4.0),
                      child: Text(
                        'Uzun Metin 2',
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 3, bottom: 3),
                child: FilledButton(
                  onPressed: () {},
                  child: const SizedBox(
                    width: 100,
                    child: Padding(
                      padding: EdgeInsets.all(4.0),
                      child: Text(
                        'Uzun Kısa Metin',
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 3, bottom: 3),
                child: FilledButton(
                  onPressed: () {},
                  child: const SizedBox(
                    width: 100,
                    child: Padding(
                      padding: EdgeInsets.all(4.0),
                      child: Text(
                        'Uzun Metin 3İkinci Satır',
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
