import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:social_share/models/user.dart';
import 'package:social_share/pages/edit_profile.dart';
import 'package:social_share/pages/home.dart';
import 'package:social_share/widgets/header.dart';
import 'package:social_share/widgets/post.dart';
import 'package:social_share/widgets/post_tile.dart';
import 'package:social_share/widgets/shimmerPost.dart';
import 'package:social_share/widgets/shimmerProfile.dart';

class Profile extends StatefulWidget {
  final String profileId;
  Profile({this.profileId});
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final String currentUserId = currentUser?.id;

  //for displaying post count in profile
  int postCount = 0;

  bool isloading = false;

  List<Post> posts = [];

  //for toogle grid and posts
  String viewPost = 'list';

  //for folllowing
  bool isFollowing = false;
  int followerCount = 0;
  int followingCount = 0;

  @override
  void initState() {
    super.initState();
    getProfilePost();
    getFollowers();
    getFollowing();
    checkIfFollowing();
  }

  getFollowing() async {
    QuerySnapshot snapshot = await followingRef
        .document(widget.profileId)
        .collection('userFollowing')
        .getDocuments();
    setState(() {
      followingCount = snapshot.documents.length;
    });
  }

  getFollowers() async {
    QuerySnapshot snapshot = await followersRef
        .document(widget.profileId)
        .collection('userFollowers')
        .getDocuments();

    setState(() {
      followerCount = snapshot.documents.length;
    });
  }

  checkIfFollowing() async {
    //check if we our current uid follow them
    DocumentSnapshot doc = await followersRef
        .document(widget.profileId)
        .collection('userFollowers')
        .document(currentUserId)
        .get();

    //   OR
    //   DocumentSnapshot doc = await followingRef
    // .document(currentUserId)
    // .collection('userFollowing')
    // .document(widget.profileId)
    // .get();

    setState(() {
      isFollowing = doc.exists;
      print(doc.exists);
    });
  }

  getProfilePost() async {
    setState(() {
      isloading = true;
    });

    QuerySnapshot snapshot = await postsRef
        .document(widget.profileId)
        .collection('userPosts')
        .orderBy('timestamp', descending: true)
        .getDocuments();

    setState(() {
      isloading = false;
      postCount = snapshot.documents.length;

      //deserialize posts
      posts = snapshot.documents.map((doc) => Post.fromDocument(doc)).toList();
    });
  }

  Column buildCountColumn(String label, int count) {
    return Column(
      children: <Widget>[
        Text(
          count.toString(),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20.0,
          ),
        ),
        SizedBox(
          height: 4.0,
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey,
            fontSize: 15.0,
            fontWeight: FontWeight.w600,
          ),
        )
      ],
    );
  }

  Container buildButton({String text, Function onPressed}) {
    return Container(
      padding: const EdgeInsets.only(top: 2.0),
      child: FlatButton(
        onPressed: onPressed,
        child: Container(
          alignment: Alignment.center,
          width: MediaQuery.of(context).size.width * .55,
          height: 27.0,
          decoration: BoxDecoration(
            color: isFollowing ? Colors.white : Colors.blue,
            border: Border.all(
              color: isFollowing ? Colors.grey : Colors.blue,
            ),
            borderRadius: BorderRadius.circular(6.0),
          ),
          child: Text(
            text,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isFollowing ? Colors.black : Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  editProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfile(currentUserId: currentUserId),
      ),
    );
  }

  handleUnfollowUser() {
    setState(() {
      isFollowing = false;
    });
    //remove follower
    followersRef
        .document(widget.profileId)
        .collection("userFollowers")
        .document(currentUserId)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });

    //remove following count from following collection
    followingRef
        .document(currentUserId)
        .collection("userFollowing")
        .document(widget.profileId)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });

    //delete activity feed item

    activityFeedRef
        .document(widget.profileId)
        .collection("feedItems")
        .document(currentUserId)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
  }

  handleFollowUser() {
    setState(() {
      isFollowing = true;
    });

    //make auth user followers of THAT (Another) user
    // (update their followes collection)
    followersRef
        .document(widget.profileId)
        .collection("userFollowers")
        .document(currentUserId)
        .setData({});

    //Put that user on your folllowing collection(update your following collection)
    followingRef
        .document(currentUserId)
        .collection("userFollowing")
        .document(widget.profileId)
        .setData({});

    //add activity feed item for that user to notify that we follow them

    activityFeedRef
        .document(widget.profileId)
        .collection("feedItems")
        .document(currentUserId)
        .setData({
      "type": "follow",
      "ownerId": widget.profileId,
      "userId": currentUser.id,
      "username": currentUser.username,
      "userProfileImg": currentUser.photoUrl,
      "timestamp": timestamp,
    });
  }

  buildProfileButton() {
    //if user is same checking own profile  show edit profile button
    bool isProfileOwner = currentUserId == widget.profileId;
    if (isProfileOwner) {
      return buildButton(
        text: "Edit Profile",
        onPressed: editProfile,
      );
    }
    //if user is another  show follow unfollow button
    else if (isFollowing) {
      return buildButton(
        text: "Unfollow",
        onPressed: handleUnfollowUser,
      );
    } else if (!isFollowing) {
      return buildButton(
        text: "Follow",
        onPressed: handleFollowUser,
      );
    }
  }

  buildProfileHeader() {
    return FutureBuilder(
      future: userRef.document(widget.profileId).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return ShimmerProfileHeader();
        }
        User user = User.fromDocument(snapshot.data);
        return Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  CircleAvatar(
                    radius: 40.0,
                    backgroundColor: Colors.grey,
                    backgroundImage: CachedNetworkImageProvider(user?.photoUrl),
                  ),
                  Expanded(
                    child: Column(
                      children: <Widget>[
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            buildCountColumn(
                              "Posts",
                              postCount,
                            ),
                            buildCountColumn(
                              "Followers",
                              followerCount,
                            ),
                            buildCountColumn(
                              "Following",
                              followingCount,
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            buildProfileButton(),
                          ],
                        )
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 12.0,
              ),
              Container(
                alignment: Alignment.centerLeft,
                child: Text(
                  user.username,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16.0,
                  ),
                ),
              ),
              SizedBox(
                height: 4.0,
              ),
              Container(
                alignment: Alignment.centerLeft,
                child: Text(
                  user.displayName,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(
                height: 2.0,
              ),
              Container(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(right: 30.0),
                  child: Text(
                    user.bio,
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  buildProfilePostView() {
    if (isloading) {
      return ShimmerPost();
    } else if (posts.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20.0),
        color: Colors.white,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SvgPicture.asset(
              'assets/images/no_content.svg',
              height: 330.0,
            ),
            SizedBox(
              height: 20.0,
            ),
            Text(
              'No Posts ',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.redAccent,
                  fontSize: 30.0),
            ),
          ],
        ),
      );
    } else if (viewPost == 'grid') {
      List<GridTile> gridTiles = [];
      //post is decerialized and from firestore
      posts.forEach((post) {
        gridTiles.add(
          GridTile(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6.0),
              child: PostTile(post: post),
            ),
          ),
        );
      });
      return GridView.count(
        crossAxisCount: 3,
        crossAxisSpacing: 4.5,
        mainAxisSpacing: 4.5,
        childAspectRatio: 1.0,
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        children: gridTiles,
      );
    } else if (viewPost == 'list') {
      return Column(
        children: posts,
      );
    }
  }

  setPostView(String view) {
    setState(() {
      viewPost = view;
    });
  }

  Row buildTogglePostOption() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        IconButton(
          icon: Icon(
            Icons.list,
            size: 30,
            color: viewPost == 'list'
                ? Theme.of(context).primaryColor
                : Colors.grey,
          ),
          onPressed: () => setPostView('list'),
        ),
        IconButton(
          icon: Icon(
            Icons.grid_on,
            color: viewPost == 'grid'
                ? Theme.of(context).primaryColor
                : Colors.grey,
          ),
          onPressed: () => setPostView('grid'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(context, titleText: 'Profile'),
      body: ListView(
        children: <Widget>[
          buildProfileHeader(),
          Divider(),
          buildTogglePostOption(),
          Divider(
            height: 0.0,
          ),
          buildProfilePostView(),
        ],
      ),
    );
  }
}
