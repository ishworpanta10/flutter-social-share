import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:social_share/models/user.dart';
import 'package:social_share/pages/activity_feed.dart';
import 'package:social_share/pages/create_account.dart';
import 'package:social_share/pages/profile.dart';
import 'package:social_share/pages/search.dart';
import 'package:social_share/pages/upload.dart';

final GoogleSignIn googleSignIn = GoogleSignIn();
final _firestore = Firestore.instance;
final CollectionReference userRef = _firestore.collection('users');
final CollectionReference postsRef = _firestore.collection('posts');
final CollectionReference commentRef = _firestore.collection('comments');
final CollectionReference feedRef = _firestore.collection('feeds');

final StorageReference storageRef = FirebaseStorage.instance.ref();
final DateTime timestamp = DateTime.now();

User currentUser = User();

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int pageIndex = 0;
  bool isAuth = false;

  PageController _pageController;

  //init state run first when page loads
  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    //detect when user signed in
    googleSignIn.onCurrentUserChanged.listen((account) {
      handleSignIn(account);
    }, onError: (error) {
      print('Error signing in : $error');
    });

    //reauthenticated user
    googleSignIn.signInSilently(suppressErrors: false).then((account) {
      handleSignIn(account);
    }).catchError((error) {
      print('Error signing in Silently : $error');
    });
  }

  //handle google sign in
  handleSignIn(GoogleSignInAccount account) {
    if (account != null) {
      createUserInFirestore();
      setState(() {
        print('User signed in account : $account');
        isAuth = true;
      });
    } else {
      setState(() {
        isAuth = false;
      });
    }
  }

  createUserInFirestore() async {
    //check if user exits in users collection in db according to their id
    final GoogleSignInAccount user = googleSignIn.currentUser;
    DocumentSnapshot doc = await userRef.document(user.id).get();

    //if user doesnot exit take to create account page
    if (!doc.exists) {
      final username = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CreateAccount(),
        ),
      );

      //after getting userInfo make a new user document in users collection
      userRef.document(user.id).setData({
        "id": user.id,
        "username": username,
        "bio": "",
        "photoUrl": user.photoUrl == null ? {} : user.photoUrl,
        "email": user.email,
        "displayName": user.displayName,
        "timestamp": timestamp,
      });

      //after adding new data we need to deserialize so
      doc = await userRef.document(user.id).get();
    }

    //if doc exits we make its data accessible to all pages
    currentUser = User.fromDocument(doc);
    // print(currentUser);
    print(currentUser.username);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  //login with google account
  login() {
    googleSignIn.signIn();
  }

  //logout google user

  logout() {
    googleSignIn.signOut();
  }

  _onPageChanged(int pageIndex) {
    setState(() {
      this.pageIndex = pageIndex;
    });
  }

  //animate to change page
  _changeIndex(int pageIndex) {
    _pageController.animateToPage(pageIndex,
        duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
  }

  //widget to display for authenticated users
  Scaffold buildAuthScreen() {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        physics: NeverScrollableScrollPhysics(),
        children: <Widget>[
          // Timeline(),
          RaisedButton(
            onPressed: logout,
            child: Text("Log Out"),
          ),
          ActivityFeed(),
          Upload(
            currentUser: currentUser,
          ),
          Search(),
          //null aware operator to see current user is not null ?
          Profile(profileId: currentUser?.id),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        currentIndex: pageIndex,
        onTap: _changeIndex,
        items: [
          BottomNavigationBarItem(
            title: Text('Home'),
            icon: Icon(Icons.whatshot),
          ),
          BottomNavigationBarItem(
            title: Text('Feed'),
            icon: Icon(Icons.notifications_active),
          ),
          BottomNavigationBarItem(
            title: Text('Upload'),
            icon: Icon(
              Icons.photo_camera,
              size: 35.0,
            ),
          ),
          BottomNavigationBarItem(
            title: Text('Search'),
            icon: Icon(Icons.search),
          ),
          BottomNavigationBarItem(
            title: Text('Profile'),
            icon: Icon(Icons.account_circle),
          ),
        ],
      ),
    );
  }

  //widget to display for unauthenticated users
  Scaffold buildUnAuthScreen() {
    var theme = Theme.of(context);
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              theme.accentColor.withOpacity(0.7),
              theme.primaryColor,
            ],
          ),
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              'Social Share',
              style: TextStyle(
                fontSize: 90.0,
                fontFamily: 'Signatra',
                color: Colors.white,
              ),
            ),
            GestureDetector(
              onTap: login,
              child: Container(
                height: 60.0,
                width: 260.0,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/google_signin_button.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return isAuth ? buildAuthScreen() : buildUnAuthScreen();
  }
}
