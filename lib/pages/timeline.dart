import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:social_share/widgets/header.dart';

final _userRef = Firestore.instance.collection('users');

class Timeline extends StatefulWidget {
  @override
  _TimelineState createState() => _TimelineState();
}

class _TimelineState extends State<Timeline> {
  @override
  void initState() {
    super.initState();
    getUsers();
    // getUserById();
  }

  // get single user by its id

  // getUserById() async {
  //   final id = 'jI7S4ODSYzRsFJBIaA1p';
  //   DocumentSnapshot doc = await _userRef.document(id).get();
  //   print(doc.data);
  //
  // }

  // getUsers() {
  //   _userRef.getDocuments().then((QuerySnapshot snapshots) {
  //     snapshots.documents.forEach((DocumentSnapshot snapshot) {
  //       print(snapshot.data);
  //
  //     });
  //   });
  // }

  //alternative using future instead of .then to get all data of collection

  // getUsers() async {
  //   final snapshots = await _userRef.getDocuments();
  //   final snapshot = snapshots.documents;
  //   snapshot.forEach((doc) {
  //     print(doc.data);
  //   });
  // }

  //using filter with where args
  getUsers() async {
    final snapshots =
        await _userRef.where("isAdmin", isEqualTo: true).getDocuments();
    final snapshot = snapshots.documents;
    snapshot.forEach((doc) {
      print(doc.data);
    });
  }

  @override
  Widget build(context) {
    return Scaffold(
      appBar: header(context, isAppTitle: true),
      body: Center(
        child: Text("Timeline"),
      ),
    );
  }
}
