import 'package:flutter/material.dart';

AppBar header(context, {bool isAppTitle = false, String titleText}) {
  return AppBar(
    title: Text(
     isAppTitle ? "Social Share" : titleText,
      style: TextStyle(
        fontSize: isAppTitle? 50.0 : 22.0,
        fontFamily:isAppTitle ? 'Signatra' :  "",
        color: Colors.white,
      ),
    ),
    titleSpacing: 1.6,
    centerTitle: true,
    backgroundColor: Theme.of(context).accentColor,
  );
}
