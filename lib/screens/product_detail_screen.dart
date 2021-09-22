import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shopapp/providers/product.dart';
import './order_confirmation.dart';
import './user_profile.dart';
import '../widgets/prod_ratings.dart';
import './product_review.dart';
import '../helpers/convert_image_to_file.dart';
import '../providers/products.dart';
import '../providers/auth.dart';
import '../providers/cart.dart';
import '../providers/rating.dart';

class ProductDetailScreen extends StatefulWidget {
  // final String title;
  // final double price;

  // ProductDetailScreen(this.title, this.price);
  static const routeName = '/product-detail';

  @override
  _ProductDetailScreenState createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {

  @override
    void initState() {
      Future.delayed(Duration.zero).then((_) {
        Provider.of<Rating>(context, listen: false).update(false);
      });
      super.initState();
    }

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
      // appBar: AppBar(
      //   title: const Text('Hyper Store'),
      // ),
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            // automaticallyImplyLeading: false,
            expandedHeight: 330,
            // backgroundColor: Colors.transparent,
            pinned: true,
            title: const Text('Hyper Store', style: TextStyle(fontWeight: FontWeight.bold)),
            flexibleSpace: FlexibleSpaceBar(
              // title: Text(loadedProduct.title),
              // centerTitle: true,
              background: Container(
                width: deviceSize.width,
                decoration: BoxDecoration(color: Colors.white),
                child: ClipPath(
                  clipper: CustomClipPath(),
                  child: ProductImage(loadedProduct: loadedProduct),
                ),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate(
              [

                ProductDetail(loadedProduct: loadedProduct, cart: cart),

                const SizedBox(height: 40),

                Container(
                  child: FutureBuilder(
                    future: Provider.of<Rating>(context, listen: false).fetchRatings(loadedProduct.id),
                    builder: (ctx, dataSnapshot) {
                      if (dataSnapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      } else {
                        if (dataSnapshot.error != null) {
                          // ...
                          // Do error handling stuff
                          return Center(
                            child: Text('An error occurred!'),
                          );
                        } else {
                          return Consumer<Rating>(
                            builder: (ctx, data, child) => Container(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 10),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text(
                                          'Customer Reviews',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                          ),
                                        ),
                                        if(data.ratings.length > 0)
                                          Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              RatingBarIndicator(
                                                rating: data.average,
                                                itemBuilder: (context, _) => Icon(Icons.star, color: Colors.amber), 
                                                itemSize: 18.0,
                                              ),
                                              const SizedBox(height: 3),
                                              Text('${data.average} out of 5'),
                                            ],
                                          ),
                                      ],
                                    ),
                                  ),

                                  Padding(
                                    padding: EdgeInsets.only(bottom: data.ratings.length > 0 ? 8 : 0),
                                    child: TextButton(
                                      onPressed: (){
                                        Navigator.push(
                                          context, 
                                          MaterialPageRoute(builder: (context) => ProductReview(
                                            loadedProduct.id, 
                                            loadedProduct.title,
                                            ),
                                          ),
                                        );
                                      }, 
                                      child: Row(
                                        children: [
                                          const Icon(Icons.add, color: Colors.blue, size: 18),
                                          const Text(
                                            'Rate this product',
                                            style: TextStyle(
                                              color: Colors.blue,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                        ],
                                      )
                                    ),
                                  ),

                                  if(data.ratings.length == 0)
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 10),
                                      child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Divider(),
                                              Text(
                                                'No reviews yet',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                'Be the first one to rate',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w400,
                                                  fontSize: 14
                                                ),
                                              ),
                                              Divider(),
                                            ],
                                          ),
                                    ),

                                  if(data.ratings.length > 0)
                                    MediaQuery.removePadding(
                                      context: context,
                                      removeTop: true,
                                      child: ListView.builder(
                                        physics: NeverScrollableScrollPhysics(),
                                        shrinkWrap: true,
                                        itemCount: data.showAll ? data.ratings.length : 1,
                                        itemBuilder: (ctx, i) => ProdRatings(
                                          data.ratings[i].title, 
                                          data.ratings[i].review, 
                                          data.ratings[i].imageUrl, 
                                          data.ratings[i].name, 
                                          data.ratings[i].stars,
                                          data.showAll && (i != data.ratings.length-1),
                                        )
                                      ),
                                    ),

                                  if(!data.showAll && data.ratings.length > 0)
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        TextButton(
                                          onPressed: (){
                                            Provider.of<Rating>(context, listen: false).update(true);
                                          }, 
                                          child: Row(
                                            children: [
                                              const Text('Show All', style: TextStyle(color: Colors.blueGrey)),
                                              const Icon(Icons.arrow_drop_down, color: Colors.blueGrey),
                                            ],
                                          )
                                        )
                                      ],
                                    ),

                                  if(data.showAll && data.ratings.length > 0)
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        TextButton(
                                          onPressed: (){
                                            Provider.of<Rating>(context, listen: false).update(false);
                                          }, 
                                          child: Row(
                                            children: [
                                              const Text('Show less', style: TextStyle(color: Colors.blueGrey)),
                                              const Icon(Icons.arrow_drop_up, color: Colors.blueGrey),
                                            ],
                                          )
                                        )
                                      ],
                                    ),
                                ],
                              ),
                            ),
                          );
                        }
                      }
                    },
                  ),
                ),

                const SizedBox(height: 10),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ProductDetail extends StatefulWidget {
  const ProductDetail({
    Key key,
    @required this.loadedProduct,
    @required this.cart,
  }) : super(key: key);

  final Product loadedProduct;
  final Cart cart;

  @override
  _ProductDetailState createState() => _ProductDetailState();
}

class _ProductDetailState extends State<ProductDetail> {
  bool _converting = false;
  int _quantity = 1;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
                    ElevatedButton(
                      onPressed: (){
                        widget.loadedProduct.newtoggleFavoriteStatus(
                          FirebaseAuth.instance.currentUser.uid,
                        );
                        setState(() {});
                      }, 
                      child: Icon(widget.loadedProduct.isFavorite ? Icons.favorite : Icons.favorite_border,),
                      style: ElevatedButton.styleFrom(
                        shape: CircleBorder(),
                        padding: EdgeInsets.all(10),
                        onPrimary: Colors.redAccent
                      ),
                    ),

                    Expanded(
                      child: Text(
                        '${widget.loadedProduct.title}',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),


                    ElevatedButton(
                      onPressed: () async {
                        setState(() {
                          _converting = true;
                        });
                        File img = await ConvertImageToFile.urlToFile(widget.loadedProduct.imageUrl0);
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 5),
            if(_converting)
              Center(child: CircularProgressIndicator()),
            if(_converting)
              const SizedBox(height: 15),
            Text(
              '₹${widget.loadedProduct.price}',
              style: TextStyle(
                color: Colors.deepOrange,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              '${widget.loadedProduct.description}',
              textAlign: TextAlign.center,
              softWrap: true,
              style: TextStyle(
                letterSpacing: 0.2,
                fontSize: 14,
                fontFamily: 'OpenSans'
              ),
            ),
          ],
        ),
      ),

      const SizedBox(height: 15),

      Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 10),
            child: Row(
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
          ),
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

                          const SizedBox(width: 6),

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
                                    widget.cart.newaddItem(widget.loadedProduct.id, widget.loadedProduct.imageUrl0, widget.loadedProduct.price, widget.loadedProduct.title, _quantity);

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
                                              widget.cart.newremoveSingleItem(widget.loadedProduct.id, _quantity);
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

                                        const SizedBox(width: 10),

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
                                  onTap: () async {
                                    final authData = Provider.of<Auth>(context, listen: false);
                                    String username = authData.username;
                                    String url = authData.userImage;
                                    String phone = authData.userPhone;
                                    String address = authData.userAddress;
                                    if(phone == '' || address == ''){
                                      bool _done = false;
                                      await showDialog(
                                        context: context,
                                        barrierDismissible: false,
                                        builder: (BuildContext context)
                                        {
                                          return AlertDialog(
                                            title: const Text('Add your address !'),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(20),
                                            ),
                                            content: SingleChildScrollView(
                                              child: ListBody(
                                                children: <Widget>[Text("Update your profile with your contact information.")]
                                              ),
                                            ),
                                            actions: <Widget>[
                                              TextButton(
                                                child: Text('Later', style: TextStyle(color:Colors.orange[700], fontWeight: FontWeight.bold)),
                                                onPressed: () {
                                                  _done = false;
                                                  Navigator.of(context).pop();
                                                },
                                              ),
                                              TextButton(
                                                child: Text('Update Now', style: TextStyle(color:Colors.orange[700], fontWeight: FontWeight.bold)),
                                                onPressed: () {
                                                  _done = true;
                                                  Navigator.of(context).pop();
                                                },
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                      if(!_done)
                                        return;
                                      bool updated = await Navigator.push(
                                                        context, 
                                                        MaterialPageRoute(builder: (context) => UserProfile(username, url, phone, address))
                                                      );
                                      if(!updated)
                                        return;
                                    }
                                    Navigator.push(
                                      context, 
                                      MaterialPageRoute(builder: (context) => OrderConfirmation(widget.loadedProduct, _quantity))
                                    );
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(20.0),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: <Widget>[
                                        Icon(
                                            Icons.shopping_bag,
                                        ),

                                        const SizedBox(width: 10),

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
      ],
    );
  }
}

class ProductImage extends StatefulWidget {
  const ProductImage({
    Key key,
    @required this.loadedProduct,
  }) : super(key: key);

  final Product loadedProduct;

  @override
  _ProductImageState createState() => _ProductImageState();
}

class _ProductImageState extends State<ProductImage> {
  int _selectedPage = 0;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          decoration: BoxDecoration(color: Colors.yellow),
          padding: const EdgeInsets.only(top: 80.0,bottom: 50.0, left: 20.0, right: 20.0),
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
                      tag: widget.loadedProduct.id,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: CachedNetworkImage(
                          imageUrl: widget.loadedProduct.imageUrl0,
                          progressIndicatorBuilder: (context, url, downloadProgress) => 
                                  Center(child: CircularProgressIndicator(value: downloadProgress.progress)),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: CachedNetworkImage(
                          imageUrl: widget.loadedProduct.imageUrl1,
                          progressIndicatorBuilder: (context, url, downloadProgress) => 
                                  Center(child: CircularProgressIndicator(value: downloadProgress.progress)),
                          fit: BoxFit.cover,
                        ),
                    ),
                    ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: CachedNetworkImage(
                          imageUrl: widget.loadedProduct.imageUrl2,
                          progressIndicatorBuilder: (context, url, downloadProgress) => 
                                  Center(child: CircularProgressIndicator(value: downloadProgress.progress)),
                          fit: BoxFit.cover,
                        ),
                    ),
                    ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: CachedNetworkImage(
                          imageUrl: widget.loadedProduct.imageUrl3,
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
          bottom: 32.0,
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
