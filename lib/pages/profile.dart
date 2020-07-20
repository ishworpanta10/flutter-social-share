import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:social_share/models/user.dart';
import 'package:social_share/pages/edit_profile.dart';
import 'package:social_share/pages/home.dart';
import 'package:social_share/widgets/header.dart';
import 'package:social_share/widgets/progress.dart';

class Profile extends StatefulWidget {
  final String profileId;
  Profile({this.profileId});
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final String currentUserId = currentUser?.id;
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
            color: Colors.blue,
            border: Border.all(
              color: Colors.blue,
            ),
            borderRadius: BorderRadius.circular(6.0),
          ),
          child: Text(
            text,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
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

  buildProfileButton() {
    bool isProfileOwner = currentUserId == widget.profileId;
    if (isProfileOwner) {
      return buildButton(
        text: "Edit Profile",
        onPressed: editProfile,
      );
    }
  }

  buildProfileHeader() {
    return FutureBuilder(
      future: userRef.document(widget.profileId).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
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
                    backgroundImage: CachedNetworkImageProvider(user.photoUrl),
                  ),
                  Expanded(
                    child: Column(
                      children: <Widget>[
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            buildCountColumn(
                              "posts",
                              21,
                            ),
                            buildCountColumn(
                              "followers",
                              344,
                            ),
                            buildCountColumn(
                              "following",
                              65,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(context, titleText: 'Profile'),
      body: ListView(
        children: <Widget>[
          buildProfileHeader(),
        ],
      ),
    );
  }
}
