import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/products.dart';

class ProductDetailScreen extends StatefulWidget {
  // final String title;
  // final double price;

  // ProductDetailScreen(this.title, this.price);
  static const routeName = '/product-detail';

  @override
  _ProductDetailScreenState createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {

  int _selectedPage = 0;

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    final productId = ModalRoute.of(context).settings.arguments as String; 
    final loadedProduct = Provider.of<Products>(context, listen: false).findById(productId);

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
                decoration: BoxDecoration(color: Colors.white),
                child: ClipPath(
                  clipper: CustomClipPath(),
                  child: Stack(
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
                                for(var i=0;i<4;i++)
                                  Hero(
                                    tag: loadedProduct.id,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(20),
                                      child: Image.network(
                                          loadedProduct.imageUrl,
                                          fit: BoxFit.cover,
                                        ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                      ),
                      Positioned(
                        bottom: 57.0,
                        left: deviceSize.width/3 + 7,
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
                SizedBox(height: 10),
                Text(
                  '₹${loadedProduct.price}',
                  style: TextStyle(
                    color: Colors.deepOrange,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: 10,
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10),
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
