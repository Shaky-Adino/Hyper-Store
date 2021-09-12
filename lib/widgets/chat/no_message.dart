import 'package:flutter/material.dart';

class NoMessage extends StatelessWidget {
  final String text;
  NoMessage(this.text);
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 8),
      padding: EdgeInsets.all(8),
      child: Text(
        text,
      ),
    );
  }
}