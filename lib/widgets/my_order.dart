import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../screens/product_detail_screen.dart';
import '../providers/product.dart';

class MyOrder extends StatelessWidget {
  final Product prod;
  MyOrder(this.prod);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: prod == null ? const EdgeInsets.all(8.0) : const EdgeInsets.all(0),
        child: InkWell(
          onTap: (){
            if(prod == null)
              return;
            Navigator.of(context).pushNamed(
              ProductDetailScreen.routeName,
              arguments: prod.id,
            );
          },
          child: Container(
            width: prod == null ? 100 : 120,
            padding: const EdgeInsets.only(left: 8, right: 8, top: 5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(const Radius.circular(20)),
              color: prod == null ? Colors.grey : null,
            ),
            child: prod == null ? 
              Center(child: const Text('Removed \nfrom store'))
              : Column(
                children: [
                  Expanded(
                    child: Container(
                      width: 100,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: CachedNetworkImage(
                          imageUrl: prod.imageUrl0,
                          placeholder: (context, url) => CircularProgressIndicator(),
                          fit: prod.imageUrl0 == prod.imageUrl1 ? BoxFit.contain : BoxFit.cover,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 3)
                ],
              ),
          ),
        ),
      ),
    );
  }
}