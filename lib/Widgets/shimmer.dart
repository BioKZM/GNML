import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerEffect extends StatelessWidget {
  const ShimmerEffect({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0),
      child: SizedBox(
        width: 200.0,
        height: 100.0,
        child: Shimmer.fromColors(
          baseColor: Colors.grey.shade500,
          highlightColor: Colors.grey.shade200,
          child: const Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      SizedBox(
                        height: 100,
                        width: 100,
                        child: Card(),
                      ),
                    ],
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(top: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: 20,
                            width: 90,
                            child: Card(),
                          ),
                          SizedBox(
                            height: 20,
                            width: 70,
                            child: Card(),
                          ),
                          SizedBox(
                            height: 20,
                            width: 40,
                            child: Card(),
                          ),
                          SizedBox(
                            height: 20,
                            width: 120,
                            child: Card(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Column(
                    children: [
                      SizedBox(
                        height: 100,
                        width: 100,
                        child: Card(),
                      ),
                    ],
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(top: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: 20,
                            width: 90,
                            child: Card(),
                          ),
                          SizedBox(
                            height: 20,
                            width: 70,
                            child: Card(),
                          ),
                          SizedBox(
                            height: 20,
                            width: 40,
                            child: Card(),
                          ),
                          SizedBox(
                            height: 20,
                            width: 120,
                            child: Card(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Column(
                    children: [
                      SizedBox(
                        height: 100,
                        width: 100,
                        child: Card(),
                      ),
                    ],
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(top: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: 20,
                            width: 90,
                            child: Card(),
                          ),
                          SizedBox(
                            height: 20,
                            width: 70,
                            child: Card(),
                          ),
                          SizedBox(
                            height: 20,
                            width: 40,
                            child: Card(),
                          ),
                          SizedBox(
                            height: 20,
                            width: 120,
                            child: Card(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
