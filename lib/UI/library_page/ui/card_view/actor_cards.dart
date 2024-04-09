import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gnml/Data/actor_data.dart';
import 'package:gnml/Data/firebase_user_data.dart';
import 'package:gnml/UI/Details/actors_detail_page.dart';

Card actorCardsTile(
    User? user,
    List<dynamic> actorsList,
    int supportedLength,
    BuildContext context,
    int themeColor,
    List<dynamic> gamesList,
    List<dynamic> moviesList,
    List<dynamic> seriesList,
    List<dynamic> booksList) {
  return Card(
    color: Colors.grey.withOpacity(0.2),
    child: Theme(
      data: ThemeData(
        highlightColor: Colors.transparent,
        hoverColor: Colors.transparent,
        splashColor: Colors.transparent,
      ),
      child: ExpansionTile(
        initiallyExpanded: true,
        textColor: Colors.white,
        collapsedTextColor: Colors.white,
        collapsedIconColor: Colors.white,
        iconColor: Colors.white,
        title: const Text(
          "Actors",
          style: TextStyle(
            color: Colors.white,
            fontFamily: "RobotoBold",
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        children: List.generate(
          (actorsList.length / supportedLength).ceil(),
          (rowIndex) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(
                supportedLength,
                (colIndex) {
                  final index = rowIndex * supportedLength + colIndex;
                  if (index < actorsList.length) {
                    Map<String, dynamic> actorMap = ActorsData()
                        .getActorMapLibrary(
                            actorsList[index]['actorID'], actorsList, index);
                    ValueNotifier<bool> isHovering = ValueNotifier<bool>(false);
                    ValueNotifier<bool> isFavorite = ValueNotifier<bool>(true);
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: MouseRegion(
                        cursor: SystemMouseCursors.click,
                        onEnter: (event) => isHovering.value = true,
                        onExit: (event) => isHovering.value = false,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ActorDetailPage(
                                  actorID: actorsList[index]['actorID'],
                                ),
                              ),
                            );
                          },
                          child: Stack(
                            children: [
                              Card(
                                color: Colors.transparent,
                                shape: const RoundedRectangleBorder(
                                  side: BorderSide(
                                    color: Colors.transparent,
                                  ),
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(8),
                                  ),
                                ),
                                child: GridTile(
                                  child: Column(
                                    children: [
                                      SizedBox(
                                        height: 225,
                                        width: 150,
                                        child: ClipRRect(
                                          borderRadius: const BorderRadius.only(
                                            topLeft: Radius.circular(8),
                                            topRight: Radius.circular(8),
                                          ),
                                          child: Image(
                                            fit: BoxFit.fill,
                                            image: NetworkImage(
                                              "${actorsList[index]['imageURL'].substring(0, 27)}w300${actorsList[index]['imageURL'].substring(35)}",
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 150,
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Tooltip(
                                            message: actorsList[index]
                                                ['actorName'],
                                            child: Text(
                                              actorsList[index]['actorName'],
                                              softWrap: true,
                                              overflow: TextOverflow.ellipsis,
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
                                                  color: Colors.white),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              ValueListenableBuilder(
                                valueListenable: isFavorite,
                                builder: (context, value, child) {
                                  return isFavorite.value
                                      ? const SizedBox()
                                      : Padding(
                                          padding: const EdgeInsets.all(4.0),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color:
                                                  Colors.black.withOpacity(0.5),
                                              borderRadius:
                                                  const BorderRadius.all(
                                                Radius.circular(8),
                                              ),
                                            ),
                                            height: 260,
                                            width: 150,
                                          ),
                                        );
                                },
                              ),
                              ValueListenableBuilder(
                                valueListenable: isHovering,
                                builder: (context, value, child) {
                                  return isHovering.value
                                      ? Positioned(
                                          top: 5,
                                          right: 5,
                                          child: Card(
                                            elevation: 0,
                                            color: const Color.fromARGB(
                                                125, 0, 0, 0),
                                            child: ValueListenableBuilder(
                                                valueListenable: isFavorite,
                                                builder:
                                                    (context, value, child) {
                                                  return isFavorite.value
                                                      ? IconButton(
                                                          highlightColor:
                                                              Color(themeColor),
                                                          hoverColor: Colors
                                                              .transparent,
                                                          onPressed: () {
                                                            ActorsData()
                                                                .removeFromActorsList(
                                                                    actorsList,
                                                                    index);
                                                            FirebaseUserData(
                                                                    user: user)
                                                                .updateData(
                                                                    gamesList,
                                                                    moviesList,
                                                                    seriesList,
                                                                    booksList,
                                                                    actorsList);
                                                            isFavorite.value =
                                                                !isFavorite
                                                                    .value;
                                                          },
                                                          icon: Icon(
                                                            Icons.favorite,
                                                            color: Color(
                                                                themeColor),
                                                          ),
                                                        )
                                                      : IconButton(
                                                          highlightColor:
                                                              Color(themeColor),
                                                          hoverColor: Colors
                                                              .transparent,
                                                          onPressed: () {
                                                            ActorsData()
                                                                .addToActorsList(
                                                                    actorsList,
                                                                    actorMap);
                                                            FirebaseUserData(
                                                                    user: user)
                                                                .updateData(
                                                                    gamesList,
                                                                    moviesList,
                                                                    seriesList,
                                                                    booksList,
                                                                    actorsList);
                                                            isFavorite.value =
                                                                !isFavorite
                                                                    .value;
                                                          },
                                                          icon: const Icon(
                                                            Icons
                                                                .favorite_outline,
                                                            color: Colors.white,
                                                            // color: Color(themeColor),
                                                          ),
                                                        );
                                                }),
                                          ),
                                        )
                                      : const SizedBox();
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  } else {
                    return const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: GridTile(
                        child: Column(
                          children: [
                            SizedBox(
                              height: 225,
                              width: 150,
                            )
                          ],
                        ),
                      ),
                    );
                  }
                },
              ),
            );
          },
        ),
      ),
    ),
  );
}
