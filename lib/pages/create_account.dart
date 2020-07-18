import 'package:flutter/material.dart';
import 'package:social_share/widgets/header.dart';

class CreateAccount extends StatefulWidget {
  @override
  _CreateAccountState createState() => _CreateAccountState();
}

class _CreateAccountState extends State<CreateAccount> {
  final _formKey = GlobalKey<FormState>();
  String username;
  String desc;

  submit() {
    _formKey.currentState.save();
    Navigator.pop(context, username);
  }

  @override
  Widget build(BuildContext parentContext) {
    return Scaffold(
      appBar: header(context, titleText: 'Setup your account'),
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
                              return username.length < 3
                                  ? "Username cannot be less than 3 character"
                                  : null;
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
