import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../screens/product_detail_screen.dart';
import '../providers/cart.dart';
import '../providers/products.dart';

class CartItem extends StatelessWidget {
  final String id;
  final String productId;
  final double price;
  final int quantity;
  final String title;

  CartItem(
    this.id,
    this.productId,
    this.price,
    this.quantity,
    this.title,
  );

  @override
  Widget build(BuildContext context) {
    final product = Provider.of<Products>(context).findById(productId);
    return Dismissible(
      key: ValueKey(id),
      background: Container(
        color: Theme.of(context).errorColor,
        child: Icon(
          Icons.delete,
          color: Colors.white,
          size: 40,
        ),
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20),
        margin: EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 4,
        ),
      ),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) {
        return showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text('Are you sure?'),
            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
            content: Text(
              'Do you want to remove the item from the cart?',
            ),
            actions: <Widget>[
              FlatButton(
                child: Text('No',style: TextStyle(color:Colors.orange[700], fontWeight: FontWeight.bold)),
                onPressed: () {
                  Navigator.of(ctx).pop(false);
                },
              ),
              FlatButton(
                child: Text('Yes',style: TextStyle(color:Colors.orange[700], fontWeight: FontWeight.bold)),
                onPressed: () {
                  Navigator.of(ctx).pop(true);
                },
              ),
            ],
          ),
        );
      },
      onDismissed: (direction) {
        Provider.of<Cart>(context, listen: false).newremoveItem(productId);
      },
      child: GestureDetector(
        onTap: () {
            Navigator.of(context).pushNamed(
              ProductDetailScreen.routeName,
              arguments: productId,
            );
          },
        child: Card(
          margin: EdgeInsets.symmetric(
            horizontal: 15,
            vertical: 4,
          ),
          child: Padding(
                  padding: const EdgeInsets.all(8.0),
                            child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: 90,
                                        height: 90,
                                        child: Hero(
                                          tag: productId,
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(8.0),
                                            child: CachedNetworkImage(
                                                imageUrl: product.imageUrl0,
                                                placeholder: (context, url) => CircularProgressIndicator(),
                                                fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                          padding: const EdgeInsets.only(left: 16.0),
                                          child: Column(
                                            mainAxisAlignment:
                                            MainAxisAlignment.start,
                                            crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                product.title,
                                                style: TextStyle(
                                                    fontSize: 18.0,
                                                    color: Colors.black,
                                                    fontWeight:
                                                    FontWeight.w600),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets
                                                    .symmetric(
                                                  vertical: 4.0,
                                                ),
                                                child: Text(
                                                  "₹${product.price}",
                                                  style: TextStyle(
                                                      fontSize: 16.0,
                                                      color: Theme.of(context)
                                                          .accentColor,
                                                      fontWeight:
                                                      FontWeight.w600),
                                                ),
                                              ),
                                              Text(
                                                "Total: ₹${(price * quantity)}",
                                                style: TextStyle(fontWeight:FontWeight.w400),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Spacer(),
                                        Padding(
                                          padding: const EdgeInsets.only(right: 5.0),
                                          child: CircleAvatar(
                                              backgroundColor: Colors.yellow,
                                              child: Padding(
                                                  padding: EdgeInsets.all(4.0),
                                                  child: FittedBox(
                                                    child: Text('$quantity x', style: TextStyle(color: Colors.black),),
                                                  ),
                                              ),
                                          ),
                                        ),
                                    ],
                            ),        
          ),
        ),
      ),
    );
  }
}
