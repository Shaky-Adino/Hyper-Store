import 'package:flutter/material.dart';

class NoMessage extends StatelessWidget {
  final String text;
  NoMessage(this.text);
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(8),
      child: Text(
        text,
      ),
    );
  }
}