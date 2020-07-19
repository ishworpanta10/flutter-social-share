import 'package:flutter/material.dart';
import 'package:social_share/models/user.dart';
import 'package:social_share/widgets/header.dart';

class Profile extends StatefulWidget {
  final User currentUser;
  Profile({this.currentUser});
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(context, titleText: 'Profile'),
      body: Center(
        child: Text("Profile"),
      ),
    );
  }
}
