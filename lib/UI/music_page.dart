import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:gnml/Logic/musicpage_logic.dart';

class MusicPage extends StatefulWidget {
  const MusicPage({super.key});

  @override
  State<MusicPage> createState() => _MusicPageState();
}

class _MusicPageState extends State<MusicPage>
    with AutomaticKeepAliveClientMixin<MusicPage> {
  bool keepAlive = true;
  @override
  bool get wantKeepAlive => keepAlive;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return FutureBuilder<List<dynamic>>(
      future: MusicPageLogic().getNewReleases(),
      builder: (context, snapshot) {
        bool isOpen = false;
        var data = snapshot.data;
        if (snapshot.hasData &&
            snapshot.connectionState == ConnectionState.done) {
          return ListView.builder(
            itemCount: data?.length,
            itemBuilder: (context, index) {
              return Card(
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: SizedBox(
                            height: 150,
                            width: 150,
                            child: ClipRRect(
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(5)),
                              child: Image(
                                image: CachedNetworkImageProvider(
                                    data![index].image_url),
                                fit: BoxFit.fill,
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                data![index].name,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 32),
                              ),
                              Text(
                                getReleaseDate(
                                  data![index],
                                ),
                              ),
                              Text(
                                data![index].album_type,
                              ),
                              Text("${data![index].total_tracks} Tracks"),
                              StatefulBuilder(builder: (context, setState) {
                                if (isOpen != true) {
                                  return IconButton(
                                    splashColor: Colors.transparent,
                                    highlightColor: Colors.transparent,
                                    hoverColor: Colors.transparent,
                                    padding: EdgeInsets.zero,
                                    alignment: AlignmentDirectional.centerStart,
                                    icon: isOpen
                                        ? const Icon(
                                            Icons.keyboard_arrow_up_rounded)
                                        : const Icon(
                                            Icons.keyboard_arrow_down_rounded),
                                    onPressed: () {
                                      setState(
                                        () {
                                          isOpen = !isOpen;
                                        },
                                      );
                                    },
                                  );
                                } else {
                                  return Column(
                                    children: [
                                      IconButton(
                                        splashColor: Colors.transparent,
                                        highlightColor: Colors.transparent,
                                        hoverColor: Colors.transparent,
                                        padding: EdgeInsets.zero,
                                        alignment:
                                            AlignmentDirectional.centerStart,
                                        icon: isOpen
                                            ? const Icon(
                                                Icons.keyboard_arrow_up_rounded)
                                            : const Icon(Icons
                                                .keyboard_arrow_down_rounded),
                                        onPressed: () {
                                          setState(
                                            () {
                                              isOpen = !isOpen;
                                            },
                                          );
                                        },
                                      ),
                                      FutureBuilder(
                                        future: MusicPageLogic()
                                            .getAlbumTracks(data?[index].id),
                                        builder: (context, snapshot) {
                                          return SizedBox(
                                            height: 200,
                                            width: 500,
                                            child: ListView.builder(
                                              itemBuilder: (context, index) {
                                                data = snapshot.data;
                                                if (snapshot.hasData &&
                                                    snapshot.connectionState ==
                                                        ConnectionState.done) {
                                                  return SizedBox(
                                                    child: Text(
                                                      data![index]
                                                          .name
                                                          .toString(),
                                                    ),
                                                  );
                                                } else {
                                                  return const Center(
                                                    child:
                                                        CircularProgressIndicator(
                                                      color: Colors.red,
                                                    ),
                                                  );
                                                }
                                              },
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  );
                                }
                              }),
                            ],
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              );
            },
          );
        } else {
          return const Center(
              child: CircularProgressIndicator(
            color: Colors.red,
          ));
        }
      },
    );
  }
}

String getReleaseDate(data) {
  String date = data.release_date;
  String day = date.substring(8);
  date = date.substring(0, 7);
  String month = date.substring(5);
  date = date.substring(0, 4);
  String year = date;
  switch (month) {
    case "01":
      month = "January";
    case "02":
      month = "February";
    case "03":
      month = "March";
    case "04":
      month = "April";
    case "05":
      month = "May";
    case "06":
      month = "June";
    case "07":
      month = "July";
    case "08":
      month = "August";
    case "09":
      month = "September";
    case "10":
      month = "October";
    case "11":
      month = "November";
    case "12":
      month = "December";
  }
  return "$day $month $year";
}
