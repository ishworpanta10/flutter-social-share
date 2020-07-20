import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import "package:flutter/material.dart";
import 'package:social_share/models/user.dart';
import 'package:social_share/pages/home.dart';
import 'package:social_share/pages/profile.dart';
import 'package:social_share/widgets/progress.dart';

class EditProfile extends StatefulWidget {
  final String currentUserId;

  const EditProfile({this.currentUserId});
  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  bool isLoading = false;
  User user;
  //for validation
  bool bioValid = true;
  bool displayNameValid = true;
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  TextEditingController _displayNameController = TextEditingController();
  TextEditingController _bioController = TextEditingController();

  @override
  void initState() {
    super.initState();
    getUsers();
  }

  Future getUsers() async {
    setState(() {
      isLoading = true;
    });
    DocumentSnapshot doc = await userRef.document(widget.currentUserId).get();
    //deserialize
    user = User.fromDocument(doc);
    _displayNameController.text = user.displayName;
    _bioController.text = user.bio;

    setState(() {
      isLoading = false;
    });
  }

  Column buildDisplayNameEditField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(
          height: 12.0,
        ),
        Text(
          "Display Name",
          style: TextStyle(color: Colors.grey),
        ),
        TextField(
          controller: _displayNameController,
          decoration: InputDecoration(
            hintText: "Update Dipslay Name",
            errorText: displayNameValid ? null : "Display name too short",
          ),
        )
      ],
    );
  }

  Column buildBioEditField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(
          height: 12.0,
        ),
        Text(
          "Short Bio",
          style: TextStyle(color: Colors.grey),
        ),
        TextField(
          controller: _bioController,
          decoration: InputDecoration(
            hintText: "Update Your Short Bio",
            errorText: bioValid ? null : "Bio too long",
          ),
        )
      ],
    );
  }

  handleUpdateProfile() {
    setState(() {
      //display name validator
      _displayNameController.text.trim().length < 3 ||
              _displayNameController.text.trim().isEmpty
          ? displayNameValid = false
          : displayNameValid = true;
      //bio validator
      _bioController.text.trim().length > 100
          ? bioValid = false
          : bioValid = true;
    });

    //update firestore collection

    if (bioValid && displayNameValid) {
      userRef.document(widget.currentUserId).updateData({
        "displayName": _displayNameController.text,
        "bio": _bioController.text,
      });

      SnackBar snackBar = SnackBar(
          content: Text(
        "Profile Updated",
        textAlign: TextAlign.center,
      ));

      _scaffoldKey.currentState.showSnackBar(snackBar);

      Timer(Duration(milliseconds: 800), () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => Profile(
              profileId: currentUser?.id,
            ),
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          "Edit Profile",
          style: TextStyle(color: Colors.black),
        ),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: IconButton(
              icon: Icon(
                Icons.done,
                size: 30.0,
                color: Colors.green,
              ),
              onPressed: () {
                handleUpdateProfile();
              },
            ),
          )
        ],
      ),
      body: isLoading
          ? circularProgress()
          : ListView(
              children: <Widget>[
                Container(
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
                        child: GestureDetector(
                          child: CircleAvatar(
                            radius: 50.0,
                            backgroundColor: Colors.grey,
                            backgroundImage:
                                CachedNetworkImageProvider(user.photoUrl),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: <Widget>[
                            buildDisplayNameEditField(),
                            buildBioEditField(),
                            SizedBox(
                              height: 10.0,
                            ),
                          ],
                        ),
                      ),
                      RaisedButton(
                        onPressed: handleUpdateProfile,
                        child: Text(
                          "Update Profile",
                          style: TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).primaryColor),
                        ),
                      ),
                      SizedBox(
                        height: 16.0,
                      ),
                      FlatButton.icon(
                        onPressed: () async {
                          await googleSignIn.signOut();
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Home(),
                            ),
                          );
                        },
                        icon: Icon(
                          Icons.cancel,
                          color: Colors.red,
                        ),
                        label: Text(
                          "Log Out",
                          style: TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.red),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
