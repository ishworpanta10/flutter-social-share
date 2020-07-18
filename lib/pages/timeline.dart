import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:social_share/widgets/header.dart';
import 'package:social_share/widgets/progress.dart';

final _userRef = Firestore.instance.collection('users');

class Timeline extends StatefulWidget {
  @override
  _TimelineState createState() => _TimelineState();
}

class _TimelineState extends State<Timeline> {
  @override
  void initState() {
    super.initState();
    // getUsers();
    // getUserById();
    // insertUser();
    // updateUser();
    deleteUser();
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
  // getUsers() async {
  //   final snapshots = await _userRef
  //       // Filters
  //       .limit(2)
  //       .orderBy('postsCount', descending: true)
  //       .where("isAdmin", isEqualTo: true)
  //       .where("username", isEqualTo: "Ishwor")
  //       .getDocuments();
  //   final snapshot = snapshots.documents;
  //   snapshot.forEach((doc) {
  //     print(doc.data);
  //   });
  // }

  //Inseting documents to firebase

  // insertUser() {
  //   _userRef.add({
  //     'username': 'Messi',
  //     'isAdmin': false,
  //     'postsCount': 6,
  //   });
  // }

  //Inserting witn own id
  // insertUser() {
  //   _userRef.document('abcd').setData({
  //     'username': 'Messi',
  //     'isAdmin': false,
  //     'postsCount': 6,
  //   });
  // }

  //Updating documents firebase
  updateUser() async {
    final doc = await _userRef.document('abcd').get();
    if (doc.exists) {
      doc.reference.updateData({
        'username': 'Sanny',
        'isAdmin': false,
        'postsCount': 6,
      });
    }
  }

  //Deleting documents from firebase

  deleteUser() async {
    final doc = await _userRef.document('abcd').get();

    if (doc.exists) {
      doc.reference.delete();
    }
  }

  @override
  Widget build(context) {
    return Scaffold(
      appBar: header(context, isAppTitle: true),
      body: StreamBuilder<QuerySnapshot>(
          stream: _userRef.snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return circularProgress();
            }
            final List<Text> children = snapshot.data.documents
                .map((doc) => Text(doc['username']))
                .toList();
            return ListView(
              children: children,
            );
          }),
    );
  }
}
