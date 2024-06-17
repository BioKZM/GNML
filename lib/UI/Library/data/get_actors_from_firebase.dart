import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:gnml/UI/Details/actors_detail_page.dart';

List<Widget> getActors(actorsList, context) {
  List<Widget> actorsWidgetList = [];
  if (actorsList.isEmpty) {
    actorsWidgetList.add(
      const Padding(
        padding: EdgeInsets.all(8.0),
        child: Text("Nothing here"),
      ),
    );
  }

  for (var x in actorsList) {
    String url = x['imageURL'];
    String modifiedURL = "${url.substring(0, 27)}w45${url.substring(35)}";
    actorsWidgetList.add(
      MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ActorDetailPage(actorID: x['actorID']),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: ListTile(
              title: Text(
                x['actorName'],
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

  return actorsWidgetList;
}
