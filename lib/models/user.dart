import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String id;
  final String username;
  final String email;
  final String bio;
  final String photoUrl;
  final String displayName;

  User(
      {this.id,
      this.username,
      this.email,
      this.bio,
      this.photoUrl,
      this.displayName});

  factory User.fromDocument(DocumentSnapshot doc) {
    return User(
        id: doc['id'],
        username: doc['username'],
        email: doc['email'],
        bio: doc['bio'],
        photoUrl: doc['photoUrl'],
        displayName: doc['displayName']);
  }
}
