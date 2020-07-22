import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:social_share/models/user.dart';
import 'package:social_share/pages/home.dart';
import 'package:social_share/widgets/custom_image.dart';
import 'package:social_share/widgets/shimmer.dart';

class Post extends StatefulWidget {
  final String postId;
  final String ownerId;
  final String username;
  final String location;
  final String imgCaption;
  final String mediaUrl;
  final dynamic likes;

  const Post(
      {this.postId,
      this.ownerId,
      this.username,
      this.location,
      this.imgCaption,
      this.mediaUrl,
      this.likes});

  factory Post.fromDocument(DocumentSnapshot doc) {
    return Post(
      postId: doc['postId'],
      ownerId: doc['ownerId'],
      username: doc['username'],
      location: doc['location'],
      imgCaption: doc['imageCaption'],
      likes: doc['likes'],
      mediaUrl: doc['mediaUrl'],
    );
  }

  int getLikeCount(likes) {
    //if no likes return 0
    if (likes == null) {
      return 0;
    }

    int count = 0;

    //value are boolean so if true add 1 like
    likes.values.forEach((value) {
      if (value == true) {
        count += 1;
      }
    });
    return count;
  }

  @override
  _PostState createState() => _PostState(
        postId: this.postId,
        ownerId: this.ownerId,
        username: this.username,
        location: this.location,
        imgCaption: this.imgCaption,
        mediaUrl: this.mediaUrl,
        likes: this.likes,
        likeCount: getLikeCount(this.likes),
      );
}

class _PostState extends State<Post> {
  final String postId;
  final String ownerId;
  final String username;
  final String location;
  final String imgCaption;
  final String mediaUrl;
  int likeCount;
  Map likes;

  _PostState({
    this.postId,
    this.ownerId,
    this.username,
    this.location,
    this.imgCaption,
    this.mediaUrl,
    this.likes,
    this.likeCount,
  });

  buildPostHeader() {
    return FutureBuilder(
        future: userRef.document(ownerId).get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return ShimmerList();
          }

          User user = User.fromDocument(snapshot.data);

          return ListTile(
            leading: CircleAvatar(
              // radius: 30.0,
              backgroundColor: Colors.grey,
              backgroundImage: CachedNetworkImageProvider(user.photoUrl),
            ),
            title: GestureDetector(
              onTap: () => print("To profile Page"),
              child: Text(
                user.username,
                style:
                    TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              ),
            ),
            subtitle: Text(location),
            trailing: IconButton(
              icon: Icon(Icons.more_vert),
              onPressed: () => print("Delete Post"),
            ),
          );
        });
  }

  buildPostImage() {
    return GestureDetector(
      onDoubleTap: () => print("Like a post"),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Stack(
          children: <Widget>[
            ClipRRect(
                borderRadius: BorderRadius.circular(16.0),
                child: cachedNetworkImage(mediaUrl)),
          ],
        ),
      ),
    );
  }

  buildPostFooter() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(left: 20.0),
              child: IconButton(
                icon: Icon(
                  Icons.favorite,
                  size: 28.0,
                  color: Colors.pink,
                ),
                onPressed: () => print('Favourite Post'),
              ),
            ),
            IconButton(
              icon: Icon(
                Icons.chat,
                size: 28.0,
                color: Colors.blue[900],
              ),
              onPressed: () => print('Comment in Post'),
            ),
          ],
        ),
        Row(
          children: <Widget>[
            Container(
              margin: const EdgeInsets.only(left: 20.0),
              child: Text(
                '$likeCount likes',
                style:
                    TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              ),
            )
          ],
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              margin: const EdgeInsets.only(left: 20.0),
              child: Text(
                username,
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(
              width: 20.0,
            ),
            Expanded(
              child: Text(imgCaption),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        buildPostHeader(),
        buildPostImage(),
        buildPostFooter(),
        Divider()
      ],
    );
  }
}
