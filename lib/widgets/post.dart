import 'dart:async';

import 'package:animator/animator.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:social_share/models/user.dart';
import 'package:social_share/pages/comments.dart';
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
  final String currentUserId = currentUser?.id;
  int likeCount;
  Map likes;
  bool isLiked;
  bool showHeart = false;

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
      onDoubleTap: handleLike,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            ClipRRect(
              borderRadius: BorderRadius.circular(16.0),
              child: cachedNetworkImage(mediaUrl),
            ),
            showHeart
                ? Animator(
                    duration: Duration(milliseconds: 300),
                    tween: Tween(begin: 0.8, end: 1.4),
                    curve: Curves.elasticOut,
                    cycles: 0,
                    builder: (context, animatorState, child) => Transform.scale(
                      scale: animatorState.value,
                      child: Icon(
                        Icons.favorite,
                        size: 100.0,
                        color: Colors.red,
                      ),
                    ),
                  )
                : Text(""),
            // showHeart
            //     ? Icon(
            //         Icons.favorite,
            //         size: 80.0,
            //       )
            //     : Text("")
          ],
        ),
      ),
    );
  }

  handleLike() {
    //to check if user already liked it
    //if islike is true retuen from firestore it is already liked
    bool _isLiked = likes[currentUserId] == true;

    if (_isLiked) {
      postsRef
          .document(ownerId)
          .collection('userPosts')
          .document(postId)
          .updateData({
        'likes.$currentUserId': false,
      });
      removeLikeToActivityFeed();
      setState(() {
        likeCount -= 1;

        //for fav border and fill border
        isLiked = false;
        likes[currentUserId] = false;
      });
    } else if (!_isLiked) {
      postsRef
          .document(ownerId)
          .collection('userPosts')
          .document(postId)
          .updateData({
        'likes.$currentUserId': true,
      });
      addLikeToActivityFeed();
      setState(() {
        likeCount += 1;

        //for fav border and fill border
        isLiked = true;
        likes[currentUserId] = true;
        showHeart = true;
      });
      //for showing heart for half seconf
      Timer(Duration(milliseconds: 500), () {
        setState(() {
          showHeart = false;
        });
      });
    }
  }

  //for adding notifation for Activityfeedpage
  addLikeToActivityFeed() {
    //not shwoing notification if onwer like his/her own post
    //but if other likes showing notifation in actoivity feed
    bool isNotPostOwner = currentUserId != ownerId;

    if (isNotPostOwner) {
      activityFeedRef
          .document(ownerId)
          .collection("feedItems")
          .document(postId)
          .setData({
        "type": "like",
        "username": currentUser.username,
        "userId": currentUser.id,
        "userProfileImg": currentUser.photoUrl,
        "postId": postId,
        "medaiURl": mediaUrl,
        "timestamp": timestamp,
      });
    }
  }

  //for removing notifation for Activityfeedpage

  removeLikeToActivityFeed() {
    bool isNotPostOwner = currentUserId != ownerId;
    if (isNotPostOwner) {
      activityFeedRef
          .document(ownerId)
          .collection("feedItems")
          .document(postId)
          .get()
          .then((doc) {
        if (doc.exists) {
          doc.reference.delete();
        }
      });
    }
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
                  isLiked ? Icons.favorite : Icons.favorite_border,
                  size: 28.0,
                  color: Colors.pink,
                ),
                onPressed: handleLike,
              ),
            ),
            IconButton(
              icon: Icon(
                Icons.chat,
                size: 28.0,
                color: Colors.blue[900],
              ),
              onPressed: () => showComments(
                context,
                postId: postId,
                ownerId: ownerId,
                mediaUrl: mediaUrl,
              ),
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
    isLiked = (likes[currentUserId] == true);
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

showComments(context, {String postId, String mediaUrl, String ownerId}) {
  Navigator.push(context, MaterialPageRoute(builder: (context) {
    return Comments(
      postId: postId,
      postOwnerId: ownerId,
      postMediaUrl: mediaUrl,
    );
  }));
}
