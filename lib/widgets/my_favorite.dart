import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../screens/product_detail_screen.dart';
import '../providers/product.dart';

class MyFavorite extends StatelessWidget {
  final Product prod;
  MyFavorite(this.prod);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
          onTap: (){
            Navigator.of(context).pushNamed(
              ProductDetailScreen.routeName,
              arguments: prod.id,
            );
          },
          child: Container(
            width: 120,
            padding: const EdgeInsets.only(left: 8, right: 8, top: 5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(20))
            ),
            child: Column(
                children: [
                  Expanded(
                    child: Container(
                      width: 100,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: CachedNetworkImage(
                          imageUrl: prod.imageUrl0,
                          placeholder: (context, url) => CircularProgressIndicator(),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 3)
                ],
            ),
          ),
        ),
    );
  }
}