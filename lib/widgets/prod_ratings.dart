import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class ProdRatings extends StatelessWidget {
  final String title, review, imageUrl, name;
  final double stars;

  const ProdRatings(this.title, this.review, this.imageUrl, this.name, this.stars);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title),
            SizedBox(height: 10),
            RatingBarIndicator(
              rating: stars,
              itemBuilder: (context, _) => Icon(Icons.star, color: Colors.amber), 
              itemSize: 18.0,
            ),
            SizedBox(height: 10),
            Text(review),
            SizedBox(height: 5),
            Text(name),
          ],
        ),
      ),
    );
  }
}