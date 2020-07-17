import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:social_share/pages/activity_feed.dart';
import 'package:social_share/pages/profile.dart';
import 'package:social_share/pages/search.dart';
import 'package:social_share/pages/timeline.dart';
import 'package:social_share/pages/upload.dart';

final GoogleSignIn _googleSignIn = GoogleSignIn();

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
    _googleSignIn.onCurrentUserChanged.listen((account) {
      handleSignIn(account);
    }, onError: (error) {
      print('Error signing in : $error');
    });

    //reauthenticated user
    _googleSignIn.signInSilently(suppressErrors: false).then((account) {
      handleSignIn(account);
    }).catchError((error) {
      print('Error signing in : $error');
    });
  }

  //handle google sign in
  handleSignIn(GoogleSignInAccount account) {
    if (account != null) {
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

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  //login with google account
  login() {
    _googleSignIn.signIn();
  }

  //logout google user

  logout() {
    _googleSignIn.signOut();
  }

  _onPageChanged(int pageIndex) {
    setState(() {
      this.pageIndex = pageIndex;
    });
  }

  _changeIndex(int pageIndex) {
    _pageController.jumpToPage(pageIndex);
  }

  //widget to display for authenticated users
  Scaffold buildAuthScreen() {
    // return RaisedButton(
    //   onPressed: logout,
    //   child: Text('Logout'),
    // );
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        physics: NeverScrollableScrollPhysics(),
        children: <Widget>[
          Timeline(),
          ActivityFeed(),
          Upload(),
          Search(),
          Profile(),
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
