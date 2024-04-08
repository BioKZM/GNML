import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:gnml/UI/Details/books_detail_page.dart';

List<Widget> getBooks(booksList, context) {
  List<Widget> booksWidgetList = [];
  if (booksList.isEmpty) {
    booksWidgetList.add(
      const Padding(
        padding: EdgeInsets.all(8.0),
        child: Text("Nothing here"),
      ),
    );
  }
  for (var x in booksList) {
    String url = x['imageURL'];
    booksWidgetList.add(
      MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BooksDetailPage(bookID: x['bookID']),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: ListTile(
              title: Text(
                x['bookName'],
                style: const TextStyle(
                    color: Colors.white,
                    fontFamily: "RobotoBold",
                    fontWeight: FontWeight.w100),
              ),
              leading: Image(
                width: 25,
                fit: BoxFit.fill,
                image: CachedNetworkImageProvider(
                  url,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  return booksWidgetList;
}
