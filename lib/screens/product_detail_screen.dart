import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:share_plus/share_plus.dart';
import '../helpers/convert_image_to_file.dart';
import '../providers/products.dart';
import '../providers/auth.dart';
import '../providers/cart.dart';

class ProductDetailScreen extends StatefulWidget {
  // final String title;
  // final double price;

  // ProductDetailScreen(this.title, this.price);
  static const routeName = '/product-detail';

  @override
  _ProductDetailScreenState createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {

  int _selectedPage = 0, _quantity = 1;
  bool _converting = false;

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    final productId = ModalRoute.of(context).settings.arguments as String; 
    final loadedProduct = Provider.of<Products>(context, listen: false).findById(productId);
    final cart = Provider.of<Cart>(context, listen: false);

    return Scaffold(
      backgroundColor: Colors.white,
      // appBar: AppBar(
      //   title: Text(loadedProduct.title),
      // ),
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            automaticallyImplyLeading: false,
            expandedHeight: 330,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(loadedProduct.title),
              centerTitle: true,
              background: Container(
                width: deviceSize.width,
                decoration: BoxDecoration(color: Colors.white),
                child: ClipPath(
                  clipper: CustomClipPath(),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        decoration: BoxDecoration(color: Colors.yellow),
                        padding: const EdgeInsets.only(top: 30.0,bottom: 80.0, left: 20.0, right: 20.0),
                        child: Card(
                          clipBehavior: Clip.hardEdge,
                            elevation: 5,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20),),
                            child: PageView(
                              onPageChanged: (num){
                                setState(() {
                                      _selectedPage = num;                            
                                });
                              },
                              children: [
                                  Hero(
                                    tag: loadedProduct.id,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(20),
                                      child: CachedNetworkImage(
                                        imageUrl: loadedProduct.imageUrl0,
                                        progressIndicatorBuilder: (context, url, downloadProgress) => 
                                                Center(child: CircularProgressIndicator(value: downloadProgress.progress)),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  ClipRRect(
                                      borderRadius: BorderRadius.circular(20),
                                      child: CachedNetworkImage(
                                        imageUrl: loadedProduct.imageUrl1,
                                        progressIndicatorBuilder: (context, url, downloadProgress) => 
                                                Center(child: CircularProgressIndicator(value: downloadProgress.progress)),
                                        fit: BoxFit.cover,
                                      ),
                                  ),
                                  ClipRRect(
                                      borderRadius: BorderRadius.circular(20),
                                      child: CachedNetworkImage(
                                        imageUrl: loadedProduct.imageUrl2,
                                        progressIndicatorBuilder: (context, url, downloadProgress) => 
                                                Center(child: CircularProgressIndicator(value: downloadProgress.progress)),
                                        fit: BoxFit.cover,
                                      ),
                                  ),
                                  ClipRRect(
                                      borderRadius: BorderRadius.circular(20),
                                      child: CachedNetworkImage(
                                        imageUrl: loadedProduct.imageUrl3,
                                        progressIndicatorBuilder: (context, url, downloadProgress) => 
                                                Center(child: CircularProgressIndicator(value: downloadProgress.progress)),
                                        fit: BoxFit.cover,
                                      ),
                                  ),
                              ],
                            ),
                          ),
                      ),
                      Positioned(
                        bottom: 57.0,
                        child: Row(children: [
                            for(var i=0;i<4;i++)
                              AnimatedContainer(
                                duration: Duration(milliseconds: 200),
                                curve: Curves.easeInCubic,
                                margin: EdgeInsets.symmetric(horizontal: 5.0),
                                width: (_selectedPage == i ? 35.0 : 12.0),
                                height: 12.0,
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                              )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate(
              [
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                              ElevatedButton(
                                onPressed: (){
                                  loadedProduct.newtoggleFavoriteStatus(
                                    FirebaseAuth.instance.currentUser.uid,
                                  );
                                  setState(() {});
                                }, 
                                child: Icon(loadedProduct.isFavorite ? Icons.favorite : Icons.favorite_border,),
                                style: ElevatedButton.styleFrom(
                                  shape: CircleBorder(),
                                  padding: EdgeInsets.all(10),
                                  onPrimary: Colors.redAccent
                                ),
                              ),

                              if(!_converting)
                                Text(
                                  '₹${loadedProduct.price}',
                                  style: TextStyle(
                                    color: Colors.deepOrange,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),

                              if(_converting)
                                Center(child: CircularProgressIndicator()),

                              ElevatedButton(
                                onPressed: () async {
                                  setState(() {
                                    _converting = true;
                                  });
                                  File img = await ConvertImageToFile.urlToFile(loadedProduct.imageUrl0);
                                  setState(() {
                                    _converting = false;
                                  });
                                  Share.shareFiles(
                                    [img.path], 
                                    text: 'Check out this product on Hyper Store',
                                    subject: 'Hyper Store product'
                                  );
                                }, 
                                child: Icon(Icons.share),
                                style: ElevatedButton.styleFrom(
                                  shape: CircleBorder(),
                                  padding: EdgeInsets.all(10),
                                ),
                              ),
                    ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  width: double.infinity,
                  child: Text(
                    '${loadedProduct.description}\n Avocado trees are partially self-pollinating and are often propogated through grafting to maintain a predictable quality of the fruit',
                    textAlign: TextAlign.center,
                    softWrap: true,
                    style: TextStyle(
                      letterSpacing: 0.2,
                      fontSize: 14,
                      fontFamily: 'OpenSans'
                    ),
                  ),
                ),
                SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Row(
                      children: [
                        InkWell(
                          customBorder: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          onTap: (){
                            if(_quantity > 1){
                              setState(() {
                                _quantity--;
                              });
                            }
                          },
                          child: Container(
                            width: 35,
                            height: 35,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(15),
                                bottomLeft: Radius.circular(15),
                              )
                            ),
                            child: Icon(
                              Icons.remove,
                              color: Colors.black,
                              size: 20,
                            ),
                          ),
                        ),
                        Container(
                          width: 35,
                          height: 35,
                          color: Colors.grey[50],
                          child: Center(
                            child: Text(
                              '$_quantity',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        ),
                        InkWell(
                          customBorder: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          onTap: (){
                            setState(() {
                              _quantity++;
                            });
                          },
                          child: Container(
                            width: 35,
                            height: 35,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.only(
                                topRight: Radius.circular(15),
                                bottomRight: Radius.circular(15),
                              )
                            ),
                            child: Icon(
                              Icons.add,
                              color: Colors.black,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(width: deviceSize.width/2,)
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                          Row(
                              children: <Widget>[
                                  Icon(
                                    Icons.airport_shuttle,
                                    color: Colors.grey[600],
                                  ),
                                  SizedBox(
                                    width: 6,
                                  ),
                                  Text(
                                    "Standard: Friday Evening",
                                    style: TextStyle(
                                        color: Colors.grey[600],
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.2,
                                        fontSize: 12,
                                        fontFamily: 'OpenSans'),
                                  ),
                                ],
                              ),
                              Text(
                                "You save : 20%",
                                style: TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    fontFamily: 'OpenSans-Bold'),
                              ),
                            ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 15.0),
                  child: Material(
                      child: Ink(
                                decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10.0),
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment(0.8, 0.0),
                                        colors: <Color>[Colors.orange,Color(0xffeeee00)]
                                      )
                                ),
                                child: InkWell(
                                          onTap: () {
                                            cart.newaddItem(loadedProduct.id, loadedProduct.price, loadedProduct.title, _quantity);

                                            ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                            ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    'Added item to cart!',
                                                  ),
                                                  duration: Duration(seconds: 2),
                                                  action: SnackBarAction(
                                                    label: 'UNDO',
                                                    onPressed: () {
                                                      cart.newremoveSingleItem(loadedProduct.id, _quantity);
                                                    },
                                                  ),
                                                ),
                                            );
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.all(20.0),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: <Widget>[
                                                Icon(
                                                    Icons.shopping_cart,
                                                ),
                                                SizedBox(
                                                    width: 10,
                                                ),
                                                Text(
                                                    "Add to cart",
                                                    style: TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 20,
                                                        fontWeight: FontWeight.bold,
                                                        fontFamily: 'OpenSans-Bold'),
                                                )
                                              ],
                                            ),
                                          ),
                                  ),
                      ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 15.0),
                  child: Material(
                      child: Ink(
                                decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10.0),
                                      color: Colors.orange
                                      // gradient: LinearGradient(
                                      //   begin: Alignment.topLeft,
                                      //   end: Alignment(0.8, 0.0),
                                      //   colors: <Color>[Colors.orange,Color(0xffeeee00)]
                                      // )
                                ),
                                child: InkWell(
                                          onTap: () {},
                                          child: Padding(
                                            padding: const EdgeInsets.all(20.0),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: <Widget>[
                                                Icon(
                                                    Icons.shopping_bag,
                                                ),
                                                SizedBox(
                                                    width: 10,
                                                ),
                                                Text(
                                                    "Buy Now",
                                                    style: TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 20,
                                                        fontWeight: FontWeight.bold,
                                                        fontFamily: 'OpenSans-Bold'),
                                                )
                                              ],
                                            ),
                                          ),
                                  ),
                      ),
                  ),
                ),
                SizedBox(
                  height: 800,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CustomClipPath extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height);
    path.quadraticBezierTo(size.width / 2, size.height - 35, size.width, size.height);
    path.lineTo(size.width, 0);

    return path;
  }
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
