import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:social_share/pages/home.dart';
// import 'package:social_share/widgets/custom_image.dart';
import 'package:social_share/widgets/header.dart';
import 'package:social_share/widgets/shimmer.dart';
// import 'package:uuid/uuid.dart';
import 'package:timeago/timeago.dart' as timeago;

class Comments extends StatefulWidget {
  final String postId;
  final String postOwnerId;
  final String postMediaUrl;

  Comments({this.postId, this.postOwnerId, this.postMediaUrl});

  @override
  CommentsState createState() => CommentsState(
        postId: this.postId,
        postMediaUrl: this.postMediaUrl,
        postOwnerId: this.postOwnerId,
      );
}

class CommentsState extends State<Comments> {
  TextEditingController commetController = TextEditingController();
  final String postId;
  final String postOwnerId;
  final String postMediaUrl;
  // String commentId = Uuid().v4();

  CommentsState({this.postId, this.postOwnerId, this.postMediaUrl});

  buildComment() {
    return StreamBuilder(
        stream: commentRef
            .document(postId)
            .collection("comments")
            .orderBy(
              "timestamp",
              descending: false,
            )
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Container(
              padding: const EdgeInsets.all(14.0),
              child: ShimmerList(),
            );
          }

          //deserialize comment data as like user and posts
          //below in comment stl widget

          List<Comment> comments = [];

          snapshot.data.documents.forEach((comment) {
            comments.add(Comment.fromDocument(comment));
          });

          return ListView(
            children: comments,
          );
        });
  }

  addComment() {
    commentRef.document(postId).collection('comments')
        // .document(commentId)
        //by adding auto id is assigned
        .add({
      "username": currentUser.username,
      "comments": commetController.text,
      "timestamp": timestamp,
      "avatarUrl": currentUser.photoUrl,
      "userId": currentUser.id,
    });
    commetController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(
        context,
        titleText: "Comments",
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: buildComment(),
          ),
          Divider(),
          ListTile(
            title: TextFormField(
              textCapitalization: TextCapitalization.sentences,
              controller: commetController,
              decoration: InputDecoration(
                border: InputBorder.none,
                labelText: "Write a comment ....",
              ),
            ),
            trailing: OutlineButton(
              borderSide: BorderSide.none,
              child: Icon(
                Icons.send,
                color: Colors.blue,
              ),
              onPressed: addComment,
            ),
          )
        ],
      ),
    );
  }
}

class Comment extends StatelessWidget {
  final String username;
  final String userId;
  final String avatarUrl;
  final String comments;
  final Timestamp timestamp;

  const Comment({
    this.username,
    this.userId,
    this.avatarUrl,
    this.comments,
    this.timestamp,
  });

  factory Comment.fromDocument(DocumentSnapshot doc) {
    return Comment(
      //constructor field ==> :doc["this is field of firstore collection doc"]
      username: doc['username'],
      userId: doc['userId'],
      avatarUrl: doc['avatarUrl'],
      comments: doc['comments'],
      timestamp: doc['timestamp'],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.grey,
            backgroundImage: CachedNetworkImageProvider(avatarUrl),
          ),
          title: Text(comments),
          subtitle: Text(
            timeago.format(
              timestamp.toDate(),
            ),
          ),
        ),
        Divider(),
      ],
    );
  }
}
