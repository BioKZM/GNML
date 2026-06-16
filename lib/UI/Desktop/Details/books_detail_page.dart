import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:vault/data/model/book_model.dart';
import 'package:vault/Helper/content_type.dart';
import 'package:vault/Helper/theme_helper.dart';
import 'package:vault/Logic/bookspage_logic.dart';
import 'package:vault/Providers/library_provider.dart';
import 'package:vault/ui/widgets/circularprogressindicator.dart';
import 'package:vault/ui/widgets/custom_app_window.dart';
import 'package:provider/provider.dart';

class BooksDetailPage extends StatefulWidget {
  final String bookID;
  const BooksDetailPage({
    super.key,
    required this.bookID,
  });

  @override
  State<BooksDetailPage> createState() => _BooksDetailPageState();
}

class _BooksDetailPageState extends State<BooksDetailPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    int themeColor = Provider.of<ThemeProvider>(context).color;
    return FutureBuilder<List<BookModel>>(
        future: BooksPageLogic().searchBooks(widget.bookID),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            BookModel? data;
            for (var x in snapshot.data!.toList()) {
              if (x.id?.split("/").last == widget.bookID) {
                data = x;
              } else {
                data = snapshot.data?[0];
              }
            }
            if (data == null) {
              return const Scaffold(
                  body: Center(child: Text("Book not found")));
            }
            String? description = data.description;
            description = utf8
                .decode(data.description.toString().runes.toList(),
                    allowMalformed: true)
                .replaceAll("", "");
            return Consumer<LibraryProvider>(
              builder: (context, libraryProvider, child) {
                final isLiked = libraryProvider.isInLibrary(
                  ContentType.books,
                  widget.bookID,
                );
                final bookMap = {
                  "id": widget.bookID,
                  "type": "book",
                  "title": data!.title,
                  "imageURL": data.imageURL,
                  "folder": "library",
                };
                return Scaffold(
                  body: Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage(data.imageURL.toString()),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: Container(
                      height: double.maxFinite,
                      color: Colors.black.withValues(alpha: 0.7),
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
                          child: Column(
                            children: [
                              SizedBox(
                                height: 45,
                                width: MediaQuery.of(context).size.width,
                                child: CustomAppWindow(
                                  isExitable: true,
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(64, 96, 64, 48),
                                child: Table(
                                  children: [
                                    TableRow(
                                      children: [
                                        TableCell(
                                          child: Column(
                                            children: [
                                              Card(
                                                elevation: 0,
                                                child: SizedBox(
                                                  height: 350,
                                                  child: ClipRRect(
                                                    borderRadius:
                                                        const BorderRadius.all(
                                                            Radius.circular(
                                                                12)),
                                                    child: Image(
                                                        image: NetworkImage(data
                                                            .imageURL
                                                            .toString()),
                                                        fit: BoxFit.fill),
                                                  ),
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    right: 16.0),
                                                child: Card(
                                                  child: IconButton(
                                                    highlightColor:
                                                        Color(themeColor),
                                                    hoverColor:
                                                        Colors.transparent,
                                                    icon: isLiked
                                                        ? Tooltip(
                                                            message:
                                                                "Remove from Library",
                                                            child: Icon(
                                                              Icons.favorite,
                                                              color: Color(
                                                                  themeColor),
                                                            ),
                                                          )
                                                        : const Tooltip(
                                                            message:
                                                                "Add to Library",
                                                            child: Icon(Icons
                                                                .favorite_outline),
                                                          ),
                                                    onPressed: () {
                                                      if (isLiked) {
                                                        libraryProvider
                                                            .removeFromLibrary(
                                                          ContentType.books,
                                                          widget.bookID,
                                                        );
                                                      } else {
                                                        libraryProvider
                                                            .addOrUpdateItem(
                                                          type:
                                                              ContentType.books,
                                                          id: widget.bookID,
                                                          title: data?.title,
                                                          imageUrl:
                                                              data?.imageURL,
                                                          extra: bookMap,
                                                        );
                                                      }
                                                    },
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        TableCell(
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 64),
                                            child: SizedBox(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(data.title.toString(),
                                                      style: const TextStyle(
                                                          fontSize: 50,
                                                          fontFamily:
                                                              'RobotoBold')),
                                                  const Divider(
                                                      color:
                                                          Colors.transparent),
                                                  const Divider(
                                                      color:
                                                          Colors.transparent),
                                                  const Divider(
                                                      color:
                                                          Colors.transparent),
                                                  const Divider(
                                                      color:
                                                          Colors.transparent),
                                                  Row(
                                                    children: [
                                                      const Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text("Authors: "),
                                                          Text(
                                                              "Publish Date: "),
                                                          Text("Page Count: "),
                                                        ],
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(left: 16),
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Row(
                                                              children:
                                                                  getAuthorList(
                                                                      data),
                                                            ),
                                                            getPublishDate(
                                                                data),
                                                            getPageCount(data),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  const VerticalDivider(
                                                    indent: 20,
                                                  ),
                                                  Row(
                                                    children: [
                                                      Expanded(
                                                        child:
                                                            Text(description!),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                        TableCell(
                                          child: Container(
                                            height: 350,
                                            color: Colors.transparent,
                                            child: const Card(
                                              elevation: 0,
                                              color: Colors.transparent,
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                  columnWidths: const {
                                    0: FlexColumnWidth(0.5),
                                    1: FlexColumnWidth(2),
                                    2: FlexColumnWidth(0.5),
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          } else {
            bool connectionBool = true;
            if (snapshot.connectionState == ConnectionState.done) {
              connectionBool = false;
            }
            return Scaffold(
              appBar: AppBar(
                title: const Text("Book Details"),
              ),
              body: Center(
                  child: connectionBool
                      ? const CustomCPI()
                      : Card(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(
                                    'An error occurred while loading data. Click to try again'),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: IconButton(
                                  icon: const Icon(Icons.refresh),
                                  onPressed: () {
                                    setState(() {});
                                  },
                                ),
                              )
                            ],
                          ),
                        )),
            );
          }
        });
  }
}

String getPublishedDate(data) {
  if (data.first_publish_year == null) {
    return "Unknown";
  }
  String date = data.first_publish_year;
  return date = date.substring(0, 4);
}

List<Widget> getAuthorList(data) {
  int index = 0;
  List<Widget> authorList = [];

  if (data.authors != null) {
    for (var x in data.authors) {
      if (data.authors.length > 1 && index == 0 ||
          index < data.authors.length - 1) {
        authorList.add(
          Text(x),
        );
        authorList.add(const Text("—"));
      } else {
        authorList.add(
          Text(x),
        );
      }

      index += 1;
    }
  } else {
    authorList.add(
      Text(
        "Unknown",
        style: TextStyle(color: Colors.grey.shade600),
      ),
    );
  }

  return authorList;
}

Widget getPublishDate(data) {
  if (data.publish_year == null) {
    return const Text("Unknown", style: TextStyle(color: Colors.grey));
  } else {
    return Text(data.publish_year.toString());
  }
}

Widget getPageCount(data) {
  if (data.page_count == null) {
    return const Text("Unknown", style: TextStyle(color: Colors.grey));
  } else {
    return Text(data.page_count.toString());
  }
}
