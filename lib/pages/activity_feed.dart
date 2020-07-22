import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:social_share/pages/home.dart';
import 'package:social_share/widgets/header.dart';
import 'package:social_share/widgets/shimmer.dart';

class ActivityFeed extends StatefulWidget {
  @override
  _ActivityFeedState createState() => _ActivityFeedState();
}

class _ActivityFeedState extends State<ActivityFeed> {
  getActivityFeedFuture() async {
    QuerySnapshot snapshot = await activityFeedRef
        .document(currentUser.id)
        .collection("feedItems")
        .orderBy(
          "timestamp",
          descending: true,
        )
        .limit(50)
        .getDocuments();

    //printing map
    snapshot.documents.forEach((doc) {
      print("Activity Feed Items:  ${doc.data}");
    });

    return snapshot.documents;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(context, titleText: "Activity Feed"),
      body: Container(
        child: FutureBuilder(
            future: getActivityFeedFuture(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: <Widget>[
                      ShimmerList(),
                      SizedBox(
                        height: 10.0,
                      ),
                      ShimmerList(),
                      SizedBox(
                        height: 10.0,
                      ),
                      ShimmerList(),
                      SizedBox(
                        height: 10.0,
                      ),
                      ShimmerList(),
                      SizedBox(
                        height: 10.0,
                      ),
                      ShimmerList(),
                    ],
                  ),
                );
              }
              return ListTile(
                title: Text("Activity feed"),
              );
            }),
      ),
    );
  }
}

class ActivityFeedItem extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Text('Activity Feed Item');
  }
}
