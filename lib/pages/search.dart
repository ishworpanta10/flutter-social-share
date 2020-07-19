import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:social_share/models/user.dart';
import 'package:social_share/widgets/progress.dart';
import 'home.dart';

class Search extends StatefulWidget {
  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {
  TextEditingController searchController = TextEditingController();
  Future<QuerySnapshot> searchResultFuture;

  AppBar buildSearchField() {
    return AppBar(
      backgroundColor: Colors.white,
      title: TextFormField(
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
    Future<QuerySnapshot> users =
        userRef.where('username', isGreaterThanOrEqualTo: query).getDocuments();
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
          List<Text> searchResult = [];
          snapshot.data.documents.forEach((userlist) {
            User user = User.fromDocument(userlist);
            searchResult.add(
              Text(
                user.username,
              ),
            );
          });
          return ListView(
            children: searchResult,
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor.withOpacity(0.7),
      appBar: buildSearchField(),
      body:
          searchResultFuture == null ? displayNoContent() : buildSearchResult(),
    );
  }
}

class UserResult extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Text("User Result");
  }
}
