import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/product.dart';
import '../providers/products.dart';
import './product_item.dart';

class ProductsGrid extends StatelessWidget {
  final bool showFavs;
  final int category;
  ProductsGrid(this.showFavs, this.category);

  @override
  Widget build(BuildContext context) {
    final productsData = Provider.of<Products>(context);
    List<Product> products;
    String txt;
    switch (category) {
      case 0:
        txt = '.';
        products = showFavs ? productsData.favoriteItems : productsData.items;
        break;
      case 1:
        txt = ' under Clothing category.';
        products = showFavs ? productsData.clothingFavoriteItems : productsData.clothingItems;
        break;
      case 2:
        txt = ' under Electronics category.';
        products = showFavs ? productsData.electronicFavoriteItems : productsData.electronicItems;
        break;
      case 3:
        txt = ' under Others category.';
        products = showFavs ? productsData.otherFavoriteItems : productsData.otherItems;
        break;
    }
    if(products.length > 0)
      return GridView.builder(
        padding: const EdgeInsets.all(10.0),
        itemCount: products.length,
        itemBuilder: (ctx, i) => ChangeNotifierProvider.value(
              // builder: (c) => products[i],
              value: products[i],
              child: ProductItem(
                  // products[i].id,
                  // products[i].title,
                  // products[i].imageUrl,
                  ),
            ),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 3 / 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
      );
    return SizedBox.expand(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'You haven\'t marked any items as favourite$txt',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 20,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
