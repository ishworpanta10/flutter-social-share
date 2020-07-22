import 'package:flutter/material.dart';
import 'package:social_share/widgets/post.dart';

class PostTile extends StatelessWidget {
  final Post posts;

  PostTile({this.posts});

  @override
  Widget build(BuildContext context) {
    return Text("Post Tile");
  }
}
