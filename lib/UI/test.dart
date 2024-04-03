// // Expanded(
// //             child: Padding(
// //               padding: const EdgeInsets.only(right: 8.0),
// //               child: SizedBox(
// //                 height: 500,
// //                 width: double.infinity,
// //                 child: Card(
// //                   elevation: 5,
// //                   child: Column(
// //                     crossAxisAlignment: CrossAxisAlignment.start,
// //                     children: [
// //                       Center(
// //                         child: Padding(
// //                           padding: const EdgeInsets.all(8.0),
// //                           child: Card(
// //                             color: Colors.purple.withOpacity(0.5),
// //                             elevation: 0,
// //                             child: const Padding(
// //                               padding: EdgeInsets.fromLTRB(16, 4, 16, 4),
// //                               child: Text(
// //                                 "Now Playing",
// //                                 style: TextStyle(fontWeight: FontWeight.bold),
// //                               ),
// //                             ),
// //                           ),
// //                         ),
// //                       ),
// //                       Expanded(
// //                         child: StatefulBuilder(
// //                           builder: (context, setState) {
// //                             return FutureBuilder<int>(
// //                                 future: MoviePageLogic()
// //                                     .getNowPlayingMoviesTotalPages(),
// //                                 builder: (context, snapshot) {
// //                                   int? totalPages = snapshot.data;
// //                                   return FutureBuilder<List<dynamic>>(
// //                                     future: MoviePageLogic()
// //                                         .getNowPlayingMovies(
// //                                             pageIndexNowPlaying),
// //                                     builder: (context, snapshot) {
// //                                       var data = snapshot.data;

// //                                       if (snapshot.hasData &&
// //                                           snapshot.connectionState ==
// //                                               ConnectionState.done) {
// //                                         return PageView.builder(
// //                                           itemBuilder: (context, index) {
// //                                             return Column(
// //                                               children: [
// //                                                 Expanded(
// //                                                   child: SizedBox(
// //                                                     child: GridView.builder(
// //                                                       gridDelegate:
// //                                                           const SliverGridDelegateWithMaxCrossAxisExtent(
// //                                                         maxCrossAxisExtent: 300,
// //                                                       ),
// //                                                       itemCount: data?.length,
// //                                                       itemBuilder: (context,
// //                                                           innerIndex) {
// //                                                         var movieID = 0;
// //                                                         if (data![innerIndex]
// //                                                                 .id !=
// //                                                             null) {
// //                                                           movieID =
// //                                                               data[innerIndex]
// //                                                                   .id!;
// //                                                         }
// //                                                         return GestureDetector(
// //                                                           onTap: () {
// //                                                             Navigator.push(
// //                                                               context,
// //                                                               MaterialPageRoute(
// //                                                                 builder: (context) =>
// //                                                                     MovieDetailPage(
// //                                                                         movieID:
// //                                                                             movieID),
// //                                                               ),
// //                                                             );
// //                                                           },
// //                                                           child: Padding(
// //                                                             padding:
// //                                                                 const EdgeInsets
// //                                                                     .all(8.0),
// //                                                             child: Column(
// //                                                               children: [
// //                                                                 Expanded(
// //                                                                   child:
// //                                                                       SizedBox(
// //                                                                     height: double
// //                                                                         .infinity,
// //                                                                     width: 180,
// //                                                                     child:
// //                                                                         GridTile(
// //                                                                       child:
// //                                                                           Card(
// //                                                                         elevation:
// //                                                                             0,
// //                                                                         shape:
// //                                                                             const RoundedRectangleBorder(
// //                                                                           side:
// //                                                                               BorderSide(
// //                                                                             color:
// //                                                                                 Colors.transparent,
// //                                                                           ),
// //                                                                           borderRadius:
// //                                                                               BorderRadius.all(
// //                                                                             Radius.circular(12),
// //                                                                           ),
// //                                                                         ),
// //                                                                         child:
// //                                                                             Column(
// //                                                                           children: [
// //                                                                             Expanded(
// //                                                                               child: SizedBox(
// //                                                                                 height: 240,
// //                                                                                 width: 180,
// //                                                                                 child: ClipRRect(
// //                                                                                   borderRadius: const BorderRadius.only(
// //                                                                                     topLeft: Radius.circular(12),
// //                                                                                     topRight: Radius.circular(12),
// //                                                                                   ),
// //                                                                                   child: Image(
// //                                                                                     fit: BoxFit.fill,
// //                                                                                     image: CachedNetworkImageProvider(
// //                                                                                       data[innerIndex].image_url.toString(),
// //                                                                                     ),
// //                                                                                   ),
// //                                                                                 ),
// //                                                                               ),
// //                                                                             ),
// //                                                                             SizedBox(
// //                                                                               width: 180,
// //                                                                               child: Padding(
// //                                                                                 padding: const EdgeInsets.all(8.0),
// //                                                                                 child: FittedBox(
// //                                                                                   fit: BoxFit.scaleDown,
// //                                                                                   child: Text(
// //                                                                                     data[innerIndex].title.toString(),
// //                                                                                     softWrap: true,
// //                                                                                     textAlign: TextAlign.center,
// //                                                                                   ),
// //                                                                                 ),
// //                                                                               ),
// //                                                                             ),
// //                                                                           ],
// //                                                                         ),
// //                                                                       ),
// //                                                                     ),
// //                                                                   ),
// //                                                                 )
// //                                                               ],
// //                                                             ),
// //                                                           ),
// //                                                         );
// //                                                       },
// //                                                     ),
// //                                                   ),
// //                                                 ),
// //                                                 Row(
// //                                                   mainAxisAlignment:
// //                                                       MainAxisAlignment.center,
// //                                                   children: [
// //                                                     Padding(
// //                                                       padding:
// //                                                           const EdgeInsets.all(
// //                                                               8.0),
// //                                                       child: IconButton(
// //                                                         icon: const Icon(
// //                                                           Icons
// //                                                               .arrow_circle_left_outlined,
// //                                                           color: Colors.white,
// //                                                         ),
// //                                                         onPressed: () {
// //                                                           if (pageIndexNowPlaying >
// //                                                               1) {
// //                                                             setState(() =>
// //                                                                 pageIndexNowPlaying =
// //                                                                     1);
// //                                                           }
// //                                                         },
// //                                                       ),
// //                                                     ),
// //                                                     Padding(
// //                                                       padding:
// //                                                           const EdgeInsets.all(
// //                                                               8.0),
// //                                                       child: IconButton(
// //                                                         icon: const Icon(
// //                                                           Icons.arrow_left,
// //                                                           color: Colors.white,
// //                                                         ),
// //                                                         onPressed: () {
// //                                                           if (pageIndexNowPlaying >
// //                                                               1) {
// //                                                             setState(() =>
// //                                                                 pageIndexNowPlaying -=
// //                                                                     1);
// //                                                           }
// //                                                         },
// //                                                       ),
// //                                                     ),
// //                                                     Padding(
// //                                                       padding:
// //                                                           const EdgeInsets.all(
// //                                                               8.0),
// //                                                       child: Text(
// //                                                           "${pageIndexNowPlaying.toString()}/$totalPages"),
// //                                                     ),
// //                                                     Padding(
// //                                                       padding:
// //                                                           const EdgeInsets.all(
// //                                                               8.0),
// //                                                       child: IconButton(
// //                                                         icon: const Icon(
// //                                                           Icons.arrow_right,
// //                                                           color: Colors.white,
// //                                                         ),
// //                                                         onPressed: () {
// //                                                           if (pageIndexNowPlaying <
// //                                                               totalPages!) {
// //                                                             setState(() {
// //                                                               pageIndexNowPlaying +=
// //                                                                   1;
// //                                                             });
// //                                                           }
// //                                                         },
// //                                                       ),
// //                                                     ),
// //                                                     Padding(
// //                                                       padding:
// //                                                           const EdgeInsets.all(
// //                                                               8.0),
// //                                                       child: IconButton(
// //                                                         icon: const Icon(
// //                                                           Icons
// //                                                               .arrow_circle_right_outlined,
// //                                                           color: Colors.white,
// //                                                         ),
// //                                                         onPressed: () {
// //                                                           if (pageIndexNowPlaying <
// //                                                               totalPages!) {
// //                                                             setState(() {
// //                                                               pageIndexNowPlaying =
// //                                                                   totalPages;
// //                                                             });
// //                                                           }
// //                                                         },
// //                                                       ),
// //                                                     ),
// //                                                   ],
// //                                                 ),
// //                                               ],
// //                                             );
// //                                           },
// //                                         );
// //                                       } else {
// //                                         bool connectionBool = true;
// //                                         if (snapshot.connectionState ==
// //                                             ConnectionState.done) {
// //                                           connectionBool = false;
// //                                         }
// //                                         return connectionBool
// //                                             ? const ShimmerEffect()
// //                                             : Center(
// //                                                 child: Card(
// //                                                   child: Column(
// //                                                     mainAxisSize:
// //                                                         MainAxisSize.min,
// //                                                     children: [
// //                                                       const Padding(
// //                                                         padding:
// //                                                             EdgeInsets.all(8.0),
// //                                                         child: Text(
// //                                                             'Veriler yüklenirken bir hata oluştu. Yeniden denemek için tıkla'),
// //                                                       ),
// //                                                       Padding(
// //                                                         padding:
// //                                                             const EdgeInsets
// //                                                                 .all(8.0),
// //                                                         child: IconButton(
// //                                                           icon: const Icon(
// //                                                               Icons.refresh),
// //                                                           onPressed: () {
// //                                                             setState(() {});
// //                                                           },
// //                                                         ),
// //                                                       )
// //                                                     ],
// //                                                   ),
// //                                                 ),
// //                                               );
// //                                       }
// //                                     },
// //                                   );
// //                                 });
// //                           },
// //                         ),
// //                       ),
// //                     ],
// //                   ),
// //                 ),
// //               ),
// //             ),
// //           ),

//           Expanded(
//             child: Padding(
//               padding: const EdgeInsets.only(
//                 top: 16,
//               ),
//               child: Column(
//                 children: [
//                   Expanded(
//                     child: Padding(
//                       padding: const EdgeInsets.only(right: 8.0),
//                       child: SizedBox(
//                         width: double.infinity,
//                         child: Card(
//                           elevation: 5,
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Center(
//                                 child: Padding(
//                                   padding: const EdgeInsets.all(8.0),
//                                   child: Card(
//                                     color: Colors.purple.withOpacity(0.5),
//                                     elevation: 0,
//                                     child: const Padding(
//                                       padding:
//                                           EdgeInsets.fromLTRB(16, 4, 16, 4),
//                                       child: Text(
//                                         "Now Playing",
//                                         style: TextStyle(
//                                             fontWeight: FontWeight.bold),
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                               Expanded(
//                                 child: StatefulBuilder(
//                                   builder: (context, setState) {
//                                     return FutureBuilder<int>(
//                                         future: MoviePageLogic()
//                                             .getNowPlayingMoviesTotalPages(),
//                                         builder: (context, snapshot) {
//                                           int? totalPages = snapshot.data;
//                                           return FutureBuilder<List<dynamic>>(
//                                             future: MoviePageLogic()
//                                                 .getNowPlayingMovies(
//                                                     pageIndexNowPlaying),
//                                             builder: (context, snapshot) {
//                                               var data = snapshot.data;

//                                               if (snapshot.hasData &&
//                                                   snapshot.connectionState ==
//                                                       ConnectionState.done) {
//                                                 return PageView.builder(
//                                                   itemBuilder:
//                                                       (context, index) {
//                                                     return Column(
//                                                       children: [
//                                                         Expanded(
//                                                           child: SizedBox(
//                                                             child: GridView
//                                                                 .builder(
//                                                               gridDelegate:
//                                                                   const SliverGridDelegateWithMaxCrossAxisExtent(
//                                                                 maxCrossAxisExtent:
//                                                                     300,
//                                                               ),
//                                                               itemCount:
//                                                                   data?.length,
//                                                               itemBuilder:
//                                                                   (context,
//                                                                       innerIndex) {
//                                                                 var movieID = 0;
//                                                                 if (data![innerIndex]
//                                                                         .id !=
//                                                                     null) {
//                                                                   movieID =
//                                                                       data[innerIndex]
//                                                                           .id!;
//                                                                 }
//                                                                 return GestureDetector(
//                                                                   onTap: () {
//                                                                     Navigator
//                                                                         .push(
//                                                                       context,
//                                                                       MaterialPageRoute(
//                                                                         builder:
//                                                                             (context) =>
//                                                                                 MovieDetailPage(movieID: movieID),
//                                                                       ),
//                                                                     );
//                                                                   },
//                                                                   child:
//                                                                       Padding(
//                                                                     padding:
//                                                                         const EdgeInsets
//                                                                             .all(
//                                                                             8.0),
//                                                                     child:
//                                                                         Column(
//                                                                       children: [
//                                                                         Expanded(
//                                                                           child:
//                                                                               SizedBox(
//                                                                             height:
//                                                                                 double.infinity,
//                                                                             width:
//                                                                                 180,
//                                                                             child:
//                                                                                 GridTile(
//                                                                               child: Card(
//                                                                                 elevation: 0,
//                                                                                 shape: const RoundedRectangleBorder(
//                                                                                   side: BorderSide(
//                                                                                     color: Colors.transparent,
//                                                                                   ),
//                                                                                   borderRadius: BorderRadius.all(
//                                                                                     Radius.circular(12),
//                                                                                   ),
//                                                                                 ),
//                                                                                 child: Column(
//                                                                                   children: [
//                                                                                     Expanded(
//                                                                                       child: SizedBox(
//                                                                                         height: 240,
//                                                                                         width: 180,
//                                                                                         child: ClipRRect(
//                                                                                           borderRadius: const BorderRadius.only(
//                                                                                             topLeft: Radius.circular(12),
//                                                                                             topRight: Radius.circular(12),
//                                                                                           ),
//                                                                                           child: Image(
//                                                                                             fit: BoxFit.fill,
//                                                                                             image: CachedNetworkImageProvider(
//                                                                                               data[innerIndex].image_url.toString(),
//                                                                                             ),
//                                                                                           ),
//                                                                                         ),
//                                                                                       ),
//                                                                                     ),
//                                                                                     SizedBox(
//                                                                                       width: 180,
//                                                                                       child: Padding(
//                                                                                         padding: const EdgeInsets.all(8.0),
//                                                                                         child: FittedBox(
//                                                                                           fit: BoxFit.scaleDown,
//                                                                                           child: Text(
//                                                                                             data[innerIndex].title.toString(),
//                                                                                             softWrap: true,
//                                                                                             textAlign: TextAlign.center,
//                                                                                           ),
//                                                                                         ),
//                                                                                       ),
//                                                                                     ),
//                                                                                   ],
//                                                                                 ),
//                                                                               ),
//                                                                             ),
//                                                                           ),
//                                                                         )
//                                                                       ],
//                                                                     ),
//                                                                   ),
//                                                                 );
//                                                               },
//                                                             ),
//                                                           ),
//                                                         ),
//                                                         Row(
//                                                           mainAxisAlignment:
//                                                               MainAxisAlignment
//                                                                   .center,
//                                                           children: [
//                                                             Padding(
//                                                               padding:
//                                                                   const EdgeInsets
//                                                                       .all(8.0),
//                                                               child: IconButton(
//                                                                 icon:
//                                                                     const Icon(
//                                                                   Icons
//                                                                       .arrow_circle_left_outlined,
//                                                                   color: Colors
//                                                                       .white,
//                                                                 ),
//                                                                 onPressed: () {
//                                                                   if (pageIndexNowPlaying >
//                                                                       1) {
//                                                                     setState(() =>
//                                                                         pageIndexNowPlaying =
//                                                                             1);
//                                                                   }
//                                                                 },
//                                                               ),
//                                                             ),
//                                                             Padding(
//                                                               padding:
//                                                                   const EdgeInsets
//                                                                       .all(8.0),
//                                                               child: IconButton(
//                                                                 icon:
//                                                                     const Icon(
//                                                                   Icons
//                                                                       .arrow_left,
//                                                                   color: Colors
//                                                                       .white,
//                                                                 ),
//                                                                 onPressed: () {
//                                                                   if (pageIndexNowPlaying >
//                                                                       1) {
//                                                                     setState(() =>
//                                                                         pageIndexNowPlaying -=
//                                                                             1);
//                                                                   }
//                                                                 },
//                                                               ),
//                                                             ),
//                                                             Padding(
//                                                               padding:
//                                                                   const EdgeInsets
//                                                                       .all(8.0),
//                                                               child: Text(
//                                                                   "${pageIndexNowPlaying.toString()}/$totalPages"),
//                                                             ),
//                                                             Padding(
//                                                               padding:
//                                                                   const EdgeInsets
//                                                                       .all(8.0),
//                                                               child: IconButton(
//                                                                 icon:
//                                                                     const Icon(
//                                                                   Icons
//                                                                       .arrow_right,
//                                                                   color: Colors
//                                                                       .white,
//                                                                 ),
//                                                                 onPressed: () {
//                                                                   if (pageIndexNowPlaying <
//                                                                       totalPages!) {
//                                                                     setState(
//                                                                         () {
//                                                                       pageIndexNowPlaying +=
//                                                                           1;
//                                                                     });
//                                                                   }
//                                                                 },
//                                                               ),
//                                                             ),
//                                                             Padding(
//                                                               padding:
//                                                                   const EdgeInsets
//                                                                       .all(8.0),
//                                                               child: IconButton(
//                                                                 icon:
//                                                                     const Icon(
//                                                                   Icons
//                                                                       .arrow_circle_right_outlined,
//                                                                   color: Colors
//                                                                       .white,
//                                                                 ),
//                                                                 onPressed: () {
//                                                                   if (pageIndexNowPlaying <
//                                                                       totalPages!) {
//                                                                     setState(
//                                                                         () {
//                                                                       pageIndexNowPlaying =
//                                                                           totalPages;
//                                                                     });
//                                                                   }
//                                                                 },
//                                                               ),
//                                                             ),
//                                                           ],
//                                                         ),
//                                                       ],
//                                                     );
//                                                   },
//                                                 );
//                                               } else {
//                                                 bool connectionBool = true;
//                                                 if (snapshot.connectionState ==
//                                                     ConnectionState.done) {
//                                                   connectionBool = false;
//                                                 }
//                                                 return connectionBool
//                                                     ? const ShimmerEffect()
//                                                     : Center(
//                                                         child: Card(
//                                                           child: Column(
//                                                             mainAxisSize:
//                                                                 MainAxisSize
//                                                                     .min,
//                                                             children: [
//                                                               const Padding(
//                                                                 padding:
//                                                                     EdgeInsets
//                                                                         .all(
//                                                                             8.0),
//                                                                 child: Text(
//                                                                     'Veriler yüklenirken bir hata oluştu. Yeniden denemek için tıkla'),
//                                                               ),
//                                                               Padding(
//                                                                 padding:
//                                                                     const EdgeInsets
//                                                                         .all(
//                                                                         8.0),
//                                                                 child:
//                                                                     IconButton(
//                                                                   icon: const Icon(
//                                                                       Icons
//                                                                           .refresh),
//                                                                   onPressed:
//                                                                       () {
//                                                                     setState(
//                                                                         () {});
//                                                                   },
//                                                                 ),
//                                                               )
//                                                             ],
//                                                           ),
//                                                         ),
//                                                       );
//                                               }
//                                             },
//                                           );
//                                         });
//                                   },
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                   Expanded(
//                     child: Padding(
//                       padding: const EdgeInsets.only(right: 8.0),
//                       child: Card(
//                         elevation: 5,
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Center(
//                               child: Padding(
//                                 padding: const EdgeInsets.all(8.0),
//                                 child: Card(
//                                   color: Colors.purple.withOpacity(0.5),
//                                   elevation: 0,
//                                   child: const Padding(
//                                     padding: EdgeInsets.fromLTRB(16, 4, 16, 4),
//                                     child: Text(
//                                       "Top Rated",
//                                       style: TextStyle(
//                                           fontWeight: FontWeight.bold),
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             ),
//                             Expanded(
//                               child: StatefulBuilder(
//                                 builder: (context, setState) {
//                                   return FutureBuilder<int>(
//                                       future: MoviePageLogic()
//                                           .getTopRatedMoviesTotalPages(),
//                                       builder: (context, snapshot) {
//                                         int? totalPages = snapshot.data;
//                                         return FutureBuilder<List<dynamic>>(
//                                           future: MoviePageLogic()
//                                               .getTopRatedMovies(
//                                                   pageIndexTopRated),
//                                           builder: (context, snapshot) {
//                                             var data = snapshot.data;

//                                             if (snapshot.hasData &&
//                                                 snapshot.connectionState ==
//                                                     ConnectionState.done) {
//                                               return PageView.builder(
//                                                 itemBuilder: (context, index) {
//                                                   return Column(
//                                                     children: [
//                                                       Expanded(
//                                                         child: SizedBox(
//                                                           child:
//                                                               GridView.builder(
//                                                             gridDelegate:
//                                                                 const SliverGridDelegateWithMaxCrossAxisExtent(
//                                                               maxCrossAxisExtent:
//                                                                   300,
//                                                             ),
//                                                             itemCount:
//                                                                 data?.length,
//                                                             itemBuilder:
//                                                                 (context,
//                                                                     innerIndex) {
//                                                               var movieID = 0;
//                                                               if (data![innerIndex]
//                                                                       .id !=
//                                                                   null) {
//                                                                 movieID = data[
//                                                                         innerIndex]
//                                                                     .id!;
//                                                               }
//                                                               return GestureDetector(
//                                                                 onTap: () {
//                                                                   Navigator
//                                                                       .push(
//                                                                     context,
//                                                                     MaterialPageRoute(
//                                                                       builder: (context) =>
//                                                                           MovieDetailPage(
//                                                                               movieID: movieID),
//                                                                     ),
//                                                                   );
//                                                                 },
//                                                                 child: Padding(
//                                                                   padding:
//                                                                       const EdgeInsets
//                                                                           .all(
//                                                                           8.0),
//                                                                   child: Column(
//                                                                     children: [
//                                                                       Expanded(
//                                                                         child:
//                                                                             SizedBox(
//                                                                           height:
//                                                                               double.infinity,
//                                                                           width:
//                                                                               180,
//                                                                           child:
//                                                                               GridTile(
//                                                                             child:
//                                                                                 Card(
//                                                                               elevation: 0,
//                                                                               shape: const RoundedRectangleBorder(
//                                                                                 side: BorderSide(
//                                                                                   color: Colors.transparent,
//                                                                                 ),
//                                                                                 borderRadius: BorderRadius.all(
//                                                                                   Radius.circular(12),
//                                                                                 ),
//                                                                               ),
//                                                                               child: Column(
//                                                                                 children: [
//                                                                                   Expanded(
//                                                                                     child: SizedBox(
//                                                                                       height: 240,
//                                                                                       width: 180,
//                                                                                       child: ClipRRect(
//                                                                                         borderRadius: const BorderRadius.only(
//                                                                                           topLeft: Radius.circular(12),
//                                                                                           topRight: Radius.circular(12),
//                                                                                         ),
//                                                                                         child: Image(
//                                                                                           fit: BoxFit.fill,
//                                                                                           image: CachedNetworkImageProvider(data[innerIndex].image_url.toString()),
//                                                                                         ),
//                                                                                       ),
//                                                                                     ),
//                                                                                   ),
//                                                                                   SizedBox(
//                                                                                     width: 180,
//                                                                                     child: Padding(
//                                                                                       padding: const EdgeInsets.all(8.0),
//                                                                                       child: FittedBox(
//                                                                                         fit: BoxFit.scaleDown,
//                                                                                         child: Text(
//                                                                                           data[innerIndex].title.toString(),
//                                                                                           softWrap: true,
//                                                                                           textAlign: TextAlign.center,
//                                                                                         ),
//                                                                                       ),
//                                                                                     ),
//                                                                                   ),
//                                                                                 ],
//                                                                               ),
//                                                                             ),
//                                                                           ),
//                                                                         ),
//                                                                       )
//                                                                     ],
//                                                                   ),
//                                                                 ),
//                                                               );
//                                                             },
//                                                           ),
//                                                         ),
//                                                       ),
//                                                       Row(
//                                                         mainAxisAlignment:
//                                                             MainAxisAlignment
//                                                                 .center,
//                                                         children: [
//                                                           Padding(
//                                                             padding:
//                                                                 const EdgeInsets
//                                                                     .all(8.0),
//                                                             child: IconButton(
//                                                               icon: const Icon(
//                                                                 Icons
//                                                                     .arrow_circle_left_outlined,
//                                                                 color: Colors
//                                                                     .white,
//                                                               ),
//                                                               onPressed: () {
//                                                                 if (pageIndexTopRated >
//                                                                     1) {
//                                                                   setState(() =>
//                                                                       pageIndexTopRated =
//                                                                           1);
//                                                                 }
//                                                               },
//                                                             ),
//                                                           ),
//                                                           Padding(
//                                                             padding:
//                                                                 const EdgeInsets
//                                                                     .all(8.0),
//                                                             child: IconButton(
//                                                               icon: const Icon(
//                                                                 Icons
//                                                                     .arrow_left,
//                                                                 color: Colors
//                                                                     .white,
//                                                               ),
//                                                               onPressed: () {
//                                                                 if (pageIndexTopRated >
//                                                                     1) {
//                                                                   setState(() =>
//                                                                       pageIndexTopRated -=
//                                                                           1);
//                                                                 }
//                                                               },
//                                                             ),
//                                                           ),
//                                                           Padding(
//                                                             padding:
//                                                                 const EdgeInsets
//                                                                     .all(8.0),
//                                                             child: Text(
//                                                                 "${pageIndexTopRated.toString()}/$totalPages"),
//                                                           ),
//                                                           Padding(
//                                                             padding:
//                                                                 const EdgeInsets
//                                                                     .all(8.0),
//                                                             child: IconButton(
//                                                               icon: const Icon(
//                                                                 Icons
//                                                                     .arrow_right,
//                                                                 color: Colors
//                                                                     .white,
//                                                               ),
//                                                               onPressed: () {
//                                                                 if (pageIndexTopRated <
//                                                                     totalPages!) {
//                                                                   setState(() {
//                                                                     pageIndexTopRated +=
//                                                                         1;
//                                                                   });
//                                                                 }
//                                                               },
//                                                             ),
//                                                           ),
//                                                           Padding(
//                                                             padding:
//                                                                 const EdgeInsets
//                                                                     .all(8.0),
//                                                             child: IconButton(
//                                                               icon: const Icon(
//                                                                 Icons
//                                                                     .arrow_circle_right_outlined,
//                                                                 color: Colors
//                                                                     .white,
//                                                               ),
//                                                               onPressed: () {
//                                                                 if (pageIndexTopRated <
//                                                                     totalPages!) {
//                                                                   setState(() {
//                                                                     pageIndexTopRated =
//                                                                         totalPages;
//                                                                   });
//                                                                 }
//                                                               },
//                                                             ),
//                                                           ),
//                                                         ],
//                                                       ),
//                                                     ],
//                                                   );
//                                                 },
//                                               );
//                                             } else {
//                                               bool connectionBool = true;
//                                               if (snapshot.connectionState ==
//                                                   ConnectionState.done) {
//                                                 connectionBool = false;
//                                               }
//                                               return connectionBool
//                                                   ? const ShimmerEffect()
//                                                   : Center(
//                                                       child: Card(
//                                                         child: Column(
//                                                           mainAxisSize:
//                                                               MainAxisSize.min,
//                                                           children: [
//                                                             const Padding(
//                                                               padding:
//                                                                   EdgeInsets
//                                                                       .all(8.0),
//                                                               child: Text(
//                                                                   'Veriler yüklenirken bir hata oluştu. Yeniden denemek için tıkla'),
//                                                             ),
//                                                             Padding(
//                                                               padding:
//                                                                   const EdgeInsets
//                                                                       .all(8.0),
//                                                               child: IconButton(
//                                                                 icon: const Icon(
//                                                                     Icons
//                                                                         .refresh),
//                                                                 onPressed: () {
//                                                                   setState(
//                                                                       () {});
//                                                                 },
//                                                               ),
//                                                             )
//                                                           ],
//                                                         ),
//                                                       ),
//                                                     );
//                                             }
//                                           },
//                                         );
//                                       });
//                                 },
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                   Expanded(
//                     child: Padding(
//                       padding: const EdgeInsets.only(right: 8.0),
//                       child: Card(
//                         elevation: 5,
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Center(
//                               child: Padding(
//                                 padding: const EdgeInsets.all(8.0),
//                                 child: Card(
//                                   color: Colors.purple.withOpacity(0.5),
//                                   elevation: 0,
//                                   child: const Padding(
//                                     padding: EdgeInsets.fromLTRB(16, 4, 16, 4),
//                                     child: Text(
//                                       "Upcoming",
//                                       style: TextStyle(
//                                           fontWeight: FontWeight.bold),
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             ),
//                             Expanded(
//                               child: StatefulBuilder(
//                                 builder: (context, setState) {
//                                   return FutureBuilder<int>(
//                                       future: MoviePageLogic()
//                                           .getUpcomingMoviesTotalPages(),
//                                       builder: (context, snapshot) {
//                                         int? totalPages = snapshot.data;
//                                         return FutureBuilder<List<dynamic>>(
//                                           future: MoviePageLogic()
//                                               .getUpcomingMovies(
//                                                   pageIndexUpcoming),
//                                           builder: (context, snapshot) {
//                                             var data = snapshot.data;

//                                             if (snapshot.hasData &&
//                                                 snapshot.connectionState ==
//                                                     ConnectionState.done) {
//                                               return PageView.builder(
//                                                 itemBuilder: (context, index) {
//                                                   return Column(
//                                                     children: [
//                                                       Expanded(
//                                                         child: SizedBox(
//                                                           child:
//                                                               GridView.builder(
//                                                             gridDelegate:
//                                                                 const SliverGridDelegateWithMaxCrossAxisExtent(
//                                                               maxCrossAxisExtent:
//                                                                   300,
//                                                             ),
//                                                             itemCount:
//                                                                 data?.length,
//                                                             itemBuilder:
//                                                                 (context,
//                                                                     innerIndex) {
//                                                               var movieID = 0;
//                                                               if (data![innerIndex]
//                                                                       .id !=
//                                                                   null) {
//                                                                 movieID = data[
//                                                                         innerIndex]
//                                                                     .id!;
//                                                               }
//                                                               return GestureDetector(
//                                                                 onTap: () {
//                                                                   Navigator
//                                                                       .push(
//                                                                     context,
//                                                                     MaterialPageRoute(
//                                                                       builder: (context) =>
//                                                                           MovieDetailPage(
//                                                                               movieID: movieID),
//                                                                     ),
//                                                                   );
//                                                                 },
//                                                                 child: Padding(
//                                                                   padding:
//                                                                       const EdgeInsets
//                                                                           .all(
//                                                                           8.0),
//                                                                   child: Column(
//                                                                     children: [
//                                                                       Expanded(
//                                                                         child:
//                                                                             SizedBox(
//                                                                           height:
//                                                                               double.infinity,
//                                                                           width:
//                                                                               180,
//                                                                           child:
//                                                                               GridTile(
//                                                                             child:
//                                                                                 Card(
//                                                                               elevation: 0,
//                                                                               shape: const RoundedRectangleBorder(
//                                                                                 side: BorderSide(
//                                                                                   color: Colors.transparent,
//                                                                                 ),
//                                                                                 borderRadius: BorderRadius.all(
//                                                                                   Radius.circular(12),
//                                                                                 ),
//                                                                               ),
//                                                                               child: Column(
//                                                                                 children: [
//                                                                                   Expanded(
//                                                                                     child: SizedBox(
//                                                                                       height: 240,
//                                                                                       width: 180,
//                                                                                       child: ClipRRect(
//                                                                                         borderRadius: const BorderRadius.only(
//                                                                                           topLeft: Radius.circular(12),
//                                                                                           topRight: Radius.circular(12),
//                                                                                         ),
//                                                                                         child: Image(
//                                                                                           fit: BoxFit.fill,
//                                                                                           image: CachedNetworkImageProvider(data[innerIndex].image_url.toString()),
//                                                                                         ),
//                                                                                       ),
//                                                                                     ),
//                                                                                   ),
//                                                                                   SizedBox(
//                                                                                     width: 180,
//                                                                                     child: Padding(
//                                                                                       padding: const EdgeInsets.all(8.0),
//                                                                                       child: FittedBox(
//                                                                                         fit: BoxFit.scaleDown,
//                                                                                         child: Text(
//                                                                                           data[innerIndex].title.toString(),
//                                                                                           softWrap: true,
//                                                                                           textAlign: TextAlign.center,
//                                                                                         ),
//                                                                                       ),
//                                                                                     ),
//                                                                                   ),
//                                                                                 ],
//                                                                               ),
//                                                                             ),
//                                                                           ),
//                                                                         ),
//                                                                       )
//                                                                     ],
//                                                                   ),
//                                                                 ),
//                                                               );
//                                                             },
//                                                           ),
//                                                         ),
//                                                       ),
//                                                       Row(
//                                                         mainAxisAlignment:
//                                                             MainAxisAlignment
//                                                                 .center,
//                                                         children: [
//                                                           Padding(
//                                                             padding:
//                                                                 const EdgeInsets
//                                                                     .all(8.0),
//                                                             child: IconButton(
//                                                               icon: const Icon(
//                                                                 Icons
//                                                                     .arrow_circle_left_outlined,
//                                                                 color: Colors
//                                                                     .white,
//                                                               ),
//                                                               onPressed: () {
//                                                                 if (pageIndexUpcoming >
//                                                                     1) {
//                                                                   setState(() =>
//                                                                       pageIndexUpcoming =
//                                                                           1);
//                                                                 }
//                                                               },
//                                                             ),
//                                                           ),
//                                                           Padding(
//                                                             padding:
//                                                                 const EdgeInsets
//                                                                     .all(8.0),
//                                                             child: IconButton(
//                                                               icon: const Icon(
//                                                                 Icons
//                                                                     .arrow_left,
//                                                                 color: Colors
//                                                                     .white,
//                                                               ),
//                                                               onPressed: () {
//                                                                 if (pageIndexUpcoming >
//                                                                     1) {
//                                                                   setState(() =>
//                                                                       pageIndexUpcoming -=
//                                                                           1);
//                                                                 }
//                                                               },
//                                                             ),
//                                                           ),
//                                                           Padding(
//                                                             padding:
//                                                                 const EdgeInsets
//                                                                     .all(8.0),
//                                                             child: Text(
//                                                                 "${pageIndexUpcoming.toString()}/$totalPages"),
//                                                           ),
//                                                           Padding(
//                                                             padding:
//                                                                 const EdgeInsets
//                                                                     .all(8.0),
//                                                             child: IconButton(
//                                                               icon: const Icon(
//                                                                 Icons
//                                                                     .arrow_right,
//                                                                 color: Colors
//                                                                     .white,
//                                                               ),
//                                                               onPressed: () {
//                                                                 if (pageIndexUpcoming <
//                                                                     totalPages!) {
//                                                                   setState(() {
//                                                                     pageIndexUpcoming +=
//                                                                         1;
//                                                                   });
//                                                                 }
//                                                               },
//                                                             ),
//                                                           ),
//                                                           Padding(
//                                                             padding:
//                                                                 const EdgeInsets
//                                                                     .all(8.0),
//                                                             child: IconButton(
//                                                               icon: const Icon(
//                                                                 Icons
//                                                                     .arrow_circle_right_outlined,
//                                                                 color: Colors
//                                                                     .white,
//                                                               ),
//                                                               onPressed: () {
//                                                                 if (pageIndexUpcoming <
//                                                                     totalPages!) {
//                                                                   setState(() {
//                                                                     pageIndexUpcoming =
//                                                                         totalPages;
//                                                                   });
//                                                                 }
//                                                               },
//                                                             ),
//                                                           ),
//                                                         ],
//                                                       ),
//                                                     ],
//                                                   );
//                                                 },
//                                               );
//                                             } else {
//                                               bool connectionBool = true;
//                                               if (snapshot.connectionState ==
//                                                   ConnectionState.done) {
//                                                 connectionBool = false;
//                                               }
//                                               return connectionBool
//                                                   ? const ShimmerEffect()
//                                                   : Center(
//                                                       child: Card(
//                                                         child: Column(
//                                                           mainAxisSize:
//                                                               MainAxisSize.min,
//                                                           children: [
//                                                             const Padding(
//                                                               padding:
//                                                                   EdgeInsets
//                                                                       .all(8.0),
//                                                               child: Text(
//                                                                   'Veriler yüklenirken bir hata oluştu. Yeniden denemek için tıkla'),
//                                                             ),
//                                                             Padding(
//                                                               padding:
//                                                                   const EdgeInsets
//                                                                       .all(8.0),
//                                                               child: IconButton(
//                                                                 icon: const Icon(
//                                                                     Icons
//                                                                         .refresh),
//                                                                 onPressed: () {
//                                                                   setState(
//                                                                       () {});
//                                                                 },
//                                                               ),
//                                                             )
//                                                           ],
//                                                         ),
//                                                       ),
//                                                     );
//                                             }
//                                           },
//                                         );
//                                       });
//                                 },
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),