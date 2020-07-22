import 'package:flutter/material.dart';
import 'package:social_share/widgets/custom_image.dart';
import 'package:social_share/widgets/post.dart';

class PostTile extends StatelessWidget {
  final Post post;

  PostTile({this.post});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => print("showing Posts"),
      child: cachedNetworkImage(post.mediaUrl),
    );
  }
}
