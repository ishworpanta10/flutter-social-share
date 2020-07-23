import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:social_share/pages/home.dart';
import 'package:social_share/pages/post_screen.dart';
import 'package:social_share/pages/profile.dart';
import 'package:social_share/widgets/header.dart';
import 'package:social_share/widgets/shimmer.dart';
import 'package:timeago/timeago.dart' as timeago;

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

    List<ActivityFeedItem> activityfeedsItems = [];

    snapshot.documents.forEach((doc) {
      activityfeedsItems.add(
        ActivityFeedItem.fromDocument(doc),
      );
    });

    // return snapshot.documents;
    return activityfeedsItems;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orangeAccent,
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

              return ListView(
                children: snapshot.data,
              );
            }),
      ),
    );
  }
}

Widget mediaPreview;
String activityItemText;

class ActivityFeedItem extends StatelessWidget {
  final String commentData;
  final String mediaUrl;
  final String postId;
  final Timestamp timestamp;
  final String type;

  // like , follow and comment
  final String userId;
  final String userProfileImg;
  final String username;

  const ActivityFeedItem(
      {this.commentData,
      this.mediaUrl,
      this.postId,
      this.timestamp,
      this.type,
      this.userId,
      this.userProfileImg,
      this.username});

  factory ActivityFeedItem.fromDocument(DocumentSnapshot doc) {
    return ActivityFeedItem(
      commentData: doc['commentData'],
      mediaUrl: doc['mediaUrl'],
      postId: doc['postId'],
      timestamp: doc['timestamp'],
      type: doc['type'],
      userId: doc['userId'],
      userProfileImg: doc['userProfileImg'],
      username: doc['username'],
    );
  }

  showPost(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) {
        return PostScreen(
          postId: postId,
          userId: currentUser.id,
        );
      }),
    );
  }

  configureMediaPreview(context) {
    if (type == "like" || type == "comment") {
      mediaPreview = GestureDetector(
        onTap: () => showPost(context),
        child: Container(
          height: 50.0,
          width: 50.0,
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0),
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: CachedNetworkImageProvider(mediaUrl),
                  )),
            ),
          ),
        ),
      );
    } else {
      mediaPreview = Text("");
    }

    if (type == "like") {
      activityItemText = "liked your post";
    } else if (type == "follow") {
      activityItemText = "following you";
    } else if (type == "comment") {
      activityItemText = "commented on a post :\n $commentData";
    } else {
      activityItemText = "Error : Unknown Type '$type' ";
    }
  }

  @override
  Widget build(BuildContext context) {
    print(postId);
    configureMediaPreview(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Container(
        color: Colors.white54,
        child: ListTile(
          leading: GestureDetector(
            onTap: () => showProfile(context, profileId: userId),
            child: CircleAvatar(
              backgroundColor: Colors.grey,
              backgroundImage: CachedNetworkImageProvider(userProfileImg),
            ),
          ),
          title: GestureDetector(
            onTap: () => showProfile(context, profileId: userId),
            child: RichText(
                overflow: TextOverflow.ellipsis,
                text: TextSpan(
                    style: TextStyle(
                      fontSize: 14.0,
                      color: Colors.black,
                    ),
                    children: [
                      TextSpan(
                        text: username,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(text: " $activityItemText"),
                    ])),
          ),

          //subtitle
          subtitle: Text(
            timeago.format(
              timestamp.toDate(),
            ),
            overflow: TextOverflow.ellipsis,
          ),
          trailing: mediaPreview,
          isThreeLine: true,
        ),
      ),
    );
  }
}

showProfile(BuildContext context, {String profileId}) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => Profile(
        profileId: profileId,
      ),
    ),
  );
}
