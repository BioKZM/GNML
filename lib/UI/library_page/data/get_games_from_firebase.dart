import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:gnml/UI/Details/game_detail_page.dart';

List<Widget> getGames(gamesList, context) {
  List<Widget> gamesWidgetList = [];
  if (gamesList.isEmpty) {
    gamesWidgetList.add(
      const Padding(
        padding: EdgeInsets.all(8.0),
        child: Text("Nothing here"),
      ),
    );
  }
  for (var x in gamesList) {
    String url = x['imageURL'];
    String modifiedURL = "${url.substring(0, 42)}t_micro${url.substring(52)}";
    gamesWidgetList.add(
      GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => GameDetailPage(gameID: x['gameID']),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: ListTile(
              title: Text(
                x['gameName'],
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

  return gamesWidgetList;
}
