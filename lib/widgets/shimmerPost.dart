import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerPost extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Shimmer.fromColors(
        child: ShimmerProfile(),
        baseColor: Colors.grey[300],
        highlightColor: Colors.white,
      ),
    );
  }
}

class ShimmerProfile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    double containerHeight = 10.0;
    double containerWidth = 260.0;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 7.5, horizontal: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Row(
          //   crossAxisAlignment: CrossAxisAlignment.start,
          //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          //   children: <Widget>[
          //     CircleAvatar(
          //       backgroundColor: Colors.grey,
          //     ),
          //     SizedBox(
          //       width: 20.0,
          //     ),
          //     Expanded(
          //       child: Column(
          //         crossAxisAlignment: CrossAxisAlignment.start,
          //         children: <Widget>[
          //           Container(
          //             height: containerHeight,
          //             width: containerWidth,
          //             color: Colors.grey,
          //           ),
          //           SizedBox(
          //             height: 9.0,
          //           ),
          //           Container(
          //             height: containerHeight,
          //             width: containerWidth * 0.80,
          //             color: Colors.grey,
          //           ),
          //         ],
          //       ),
          //     )
          //   ],
          // ),
          SizedBox(
            height: 10.0,
          ),
          Container(
            height: MediaQuery.of(context).size.height * 0.4,
            width: MediaQuery.of(context).size.width * 0.8,
            decoration: BoxDecoration(
              color: Colors.grey,
              borderRadius: BorderRadius.circular(16.0),
            ),
          ),
          SizedBox(
            height: 10.0,
          ),
          Container(
            height: containerHeight,
            width: containerWidth,
            color: Colors.grey,
          ),
          SizedBox(
            height: 9.0,
          ),
          Container(
            height: containerHeight,
            width: containerWidth * 0.80,
            color: Colors.grey,
          ),
          SizedBox(
            height: 9.0,
          ),
          Container(
            height: containerHeight,
            width: containerWidth * 0.60,
            color: Colors.grey,
          ),
        ],
      ),
    );
  }
}
