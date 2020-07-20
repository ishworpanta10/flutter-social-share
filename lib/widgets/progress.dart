import 'package:flutter/material.dart';

Container circularProgress() {
  return Container(
    // alignment: Alignment.center,
    child: Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation(Colors.purple),
      ),
    ),
  );
}

Container linearProgress() {
  return Container(
    alignment: Alignment.topCenter,
    padding: const EdgeInsets.only(bottom: 10.0),
    child: LinearProgressIndicator(
      valueColor: AlwaysStoppedAnimation(Colors.purple),
    ),
  );
}

showLoading(context) {
  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (context) {
      return SimpleDialog(
        contentPadding: EdgeInsets.all(20),
        children: <Widget>[
          Row(
            children: <Widget>[
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Text('Please wait...')
            ],
          )
        ],
      );
    },
  );
}
