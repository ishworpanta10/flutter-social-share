import 'package:flutter/material.dart';
import 'package:social_share/pages/home.dart';
import 'package:social_share/widgets/header.dart';
import 'package:social_share/widgets/post.dart';
import 'package:social_share/widgets/shimmerPost.dart';

class PostScreen extends StatelessWidget {
  final String postId;
  final String userId;

  PostScreen({this.postId, this.userId});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: postsRef
            .document(userId)
            .collection("userPosts")
            .document(postId)
            .get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Scaffold(
              appBar: AppBar(
                backgroundColor: Colors.teal,
              ),
              body: Container(
                padding: const EdgeInsets.symmetric(
                    vertical: 30.0, horizontal: 20.0),
                child: ShimmerPost(),
              ),
            );
          }

          Post post = Post.fromDocument(snapshot.data);
          return Scaffold(
            appBar: header(context, titleText: post.imgCaption),
            body: ListView(
              children: <Widget>[
                Center(
                  child: Container(
                    child: post,
                  ),
                ),
              ],
            ),
          );
        });
  }
}
