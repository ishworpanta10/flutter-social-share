import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:social_share/models/user.dart';
import 'package:social_share/pages/activity_feed.dart';
import 'package:social_share/widgets/progress.dart';
import 'home.dart';

class Search extends StatefulWidget {
  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search>
    with AutomaticKeepAliveClientMixin<Search> {
  TextEditingController searchController = TextEditingController();
  Future<QuerySnapshot> searchResultFuture;

  AppBar buildSearchField() {
    return AppBar(
      backgroundColor: Colors.white,
      title: TextFormField(
        textCapitalization: TextCapitalization.words,
        controller: searchController,
        decoration: InputDecoration(
          hintText: "Seach for a user . . . ",
          filled: true,
          prefixIcon: Icon(
            Icons.account_circle,
            size: 28.0,
          ),
          suffixIcon: IconButton(
            icon: Icon(Icons.clear),
            onPressed: clearSearch,
          ),
        ),
        onFieldSubmitted: handleSearch,
      ),
    );
  }

  Container displayNoContent() {
    final double height = MediaQuery.of(context).size.height;
    // final double width = MediaQuery.of(context).size.width;

    return Container(
      child: Center(
        child: ListView(
          shrinkWrap: true,
          children: <Widget>[
            SvgPicture.asset(
              'assets/images/search.svg',
              height: height * 0.4,
            ),
            Text(
              "Find Users",
              style: TextStyle(
                  fontSize: 60.0,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontStyle: FontStyle.italic),
              textAlign: TextAlign.center,
            )
          ],
        ),
      ),
    );
  }

  clearSearch() {
    searchController.clear();
  }

  handleSearch(String query) {
    Future<QuerySnapshot> users = userRef
        .where('username', isGreaterThanOrEqualTo: query)
        // .where('displayName', isGreaterThanOrEqualTo: query)
        .getDocuments();
    setState(() {
      searchResultFuture = users;
      // print(
      //     "result: ${searchResultFuture.then((value) => print(value.documents.length))}");
    });
  }

  buildSearchResult() {
    return FutureBuilder(
        future: searchResultFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return circularProgress();
          }
          List<UserResult> searchResults = [];
          snapshot.data.documents.forEach((userlist) {
            User user = User.fromDocument(userlist);
            UserResult userResult = UserResult(
              user: user,
            );
            searchResults.add(userResult);
          });
          if (searchResults.isEmpty) {
            return Center(
              child: Text(
                "No User with that username !",
                style: TextStyle(color: Colors.white),
              ),
            );
          }
          return ListView(
            children: searchResults,
          );
        });
  }

  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor.withOpacity(0.7),
      appBar: buildSearchField(),
      body:
          searchResultFuture == null ? displayNoContent() : buildSearchResult(),
    );
  }
}

class UserResult extends StatelessWidget {
  final User user;

  UserResult({this.user});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.7),
        borderRadius: BorderRadius.circular(12.0),
      ),
      width: MediaQuery.of(context).size.width * 0.9,
      child: Column(
        children: <Widget>[
          ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.grey,
              backgroundImage: CachedNetworkImageProvider(user.photoUrl),
            ),
            title: Text(
              user.displayName,
              style:
                  TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
            ),
            subtitle: Text(
              user.username,
              style: TextStyle(color: Colors.white),
            ),
            onTap: () => showProfile(context, profileId: user.id),
          ),
          SizedBox(
            height: 10.0,
          ),
          Divider(
            color: Colors.white,
            height: 2.0,
          )
        ],
      ),
    );
  }
}
