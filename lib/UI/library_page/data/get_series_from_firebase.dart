import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:gnml/UI/Details/serie_detail_page.dart';

List<Widget> getSeries(seriesList, context) {
  List<Widget> seriesWidgetList = [];
  if (seriesList.isEmpty) {
    seriesWidgetList.add(
      const Padding(
        padding: EdgeInsets.all(8.0),
        child: Text("Nothing here"),
      ),
    );
  }
  for (var x in seriesList) {
    String url = x['imageURL'];
    String modifiedURL = "${url.substring(0, 27)}w45${url.substring(35)}";
    seriesWidgetList.add(
      MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SerieDetailPage(serieID: x['serieID']),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: ListTile(
              title: Text(
                x['serieName'],
                style: const TextStyle(
                    color: Colors.white,
                    fontFamily: "RobotoBold",
                    fontWeight: FontWeight.w100),
              ),
              leading: Image(
                width: 25,
                fit: BoxFit.fill,
                image: CachedNetworkImageProvider(
                  modifiedURL,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  return seriesWidgetList;
}
