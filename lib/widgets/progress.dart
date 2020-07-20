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
