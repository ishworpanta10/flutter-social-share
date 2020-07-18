import 'dart:async';

import 'package:flutter/material.dart';
import 'package:social_share/widgets/header.dart';

class CreateAccount extends StatefulWidget {
  @override
  _CreateAccountState createState() => _CreateAccountState();
}

class _CreateAccountState extends State<CreateAccount> {
  final _formKey = GlobalKey<FormState>();
  final _scaffolfKey = GlobalKey<ScaffoldState>();
  String username;
  String desc;

  submit() {
    final form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      SnackBar snackBar = SnackBar(
          content: Text(
        "Welcome $username",
        textAlign: TextAlign.center,
      ));
      _scaffolfKey.currentState.showSnackBar(snackBar);
      Timer(Duration(milliseconds: 2000), () {
        Navigator.pop(context, username);
      });
    }
  }

  @override
  Widget build(BuildContext parentContext) {
    return Scaffold(
      key: _scaffolfKey,
      appBar: header(context,
          titleText: 'Setup your account', removeBackbutton: true),
      body: ListView(
        children: <Widget>[
          Container(
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(top: 25.0),
                  child: Center(
                    child: Text(
                      'Create a Username',
                      style: TextStyle(fontSize: 25.0),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: <Widget>[
                          TextFormField(
                            autovalidate: true,
                            onSaved: (name) {
                              username = name;
                            },
                            validator: (username) {
                              if (username.trim().length < 3 ||
                                  username.isEmpty) {
                                return "Username too shorts";
                              } else if (username.length > 20) {
                                return "Username too long";
                              } else {
                                return null;
                              }
                            },
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Username',
                              hintText: 'Username must be at least 3 character',
                              labelStyle: TextStyle(fontSize: 15.0),
                            ),
                          ),
                          SizedBox(
                            height: 10.0,
                          ),
                          // TextFormField(
                          //   autovalidate: true,
                          //   onSaved: (description) {
                          //     desc = description;
                          //   },
                          //   validator: (description) {
                          //     return description.length == 0
                          //         ? "Bio cannot be empty"
                          //         : null;
                          //   },
                          //   decoration: InputDecoration(
                          //     border: OutlineInputBorder(),
                          //     labelText: 'Bio',
                          //     hintText: 'Short description',
                          //     labelStyle: TextStyle(fontSize: 15.0),
                          //   ),
                          // ),
                        ],
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: submit,
                  child: Container(
                    height: 50.0,
                    width: 250.0,
                    decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(7.0)),
                    child: Center(
                      child: Text(
                        "Submit",
                        style: TextStyle(
                          fontSize: 15.0,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
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
