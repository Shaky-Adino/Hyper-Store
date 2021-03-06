import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/products.dart';
import '../widgets/user_product_item.dart';
import '../widgets/app_drawer.dart';
import './edit_product_screen.dart';

class UserProductsScreen extends StatelessWidget {
  static const routeName = '/user-products';

  Future<void> _refreshProducts(BuildContext context) async {
    await Provider.of<Products>(context, listen: false).fetchUserProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Products'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.of(context).pushNamed(EditProductScreen.routeName);
            },
          ),
        ],
      ),
      drawer: AppDrawer(),
      body: FutureBuilder(
        future: _refreshProducts(context),
        builder: (ctx, snapshot) =>
            snapshot.connectionState == ConnectionState.waiting
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : RefreshIndicator(
                    onRefresh: () => _refreshProducts(context),
                    child: Consumer<Products>(
                      builder: (ctx, productsData, _) => Padding(
                            padding: const EdgeInsets.all(8),
                            child: productsData.userItems.length > 0 ? ListView.builder(
                              itemCount: productsData.userItems.length,
                              itemBuilder: (_, i) => Column(
                                    children: [
                                      UserProductItem(
                                        productsData.userItems[i].id,
                                        productsData.userItems[i].title,
                                        productsData.userItems[i].imageUrl0,
                                      ),
                                      const Divider(),
                                    ],
                                  ),
                            ) : SizedBox.expand(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      const Text(
                                        'You haven\'t added any products to the store yet.',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 20,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                          ),
                    ),
                  ),
      ),
      floatingActionButton: Container(
        margin: const EdgeInsets.only(bottom: 20),
        child: FloatingActionButton.extended(
          onPressed: (){
            Navigator.of(context).pushNamed(EditProductScreen.routeName);
          }, 
          label: const Text('Add Product', style: TextStyle(color: Colors.yellow),),
          backgroundColor: Colors.black,
        ),
      ),
    );
  }
}
