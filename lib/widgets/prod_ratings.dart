import 'package:flutter/material.dart';

class ProdRatings extends StatelessWidget {
  final String title, review, imageUrl, name;
  final double stars;

  const ProdRatings(this.title, this.review, this.imageUrl, this.name, this.stars);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(title),
          SizedBox(height: 10),
          Text('stars go here'),
          SizedBox(height: 10),
          Text(review),
          SizedBox(height: 5),
          Text(name),
        ],
      ),
    );
  }
}