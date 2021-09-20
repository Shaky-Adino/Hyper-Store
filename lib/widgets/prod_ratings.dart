import 'package:cached_network_image/cached_network_image.dart';
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
            Row(
              children: [
                CachedNetworkImage(
                  imageUrl: imageUrl,
                  imageBuilder: (context, imageProvider) => Container(
                    width: 20.0,
                    height: 20.0,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
                    ),
                  ),
                  placeholder: (context, url) => ClipOval(child: Image.asset('assets/images/profile_pic.png')),
                ),

                const SizedBox(width: 8),

                Text(
                  name, 
                  style: TextStyle(fontWeight: FontWeight.w500)
                ),
              ],
            ),

            const SizedBox(height: 3),

            RatingBarIndicator(
              rating: stars,
              itemBuilder: (context, _) => Icon(Icons.star, color: Colors.amber), 
              itemSize: 18.0,
            ),

            const SizedBox(height: 4),

            if(title != '')
              Padding(
                padding: const EdgeInsets.only(left: 2),
                child: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
              ),

            if(review != '')
              const SizedBox(height: 5),

            if(review != '')
              Padding(
                padding: const EdgeInsets.only(left: 2),
                child: Text(review),
              ),
          ],
        ),
      ),
    );
  }
}