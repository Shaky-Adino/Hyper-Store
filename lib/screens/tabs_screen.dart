import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../helpers/tootipshape.dart';

import '../widgets/app_drawer.dart';
import '../widgets/products_grid.dart';
import '../widgets/badge.dart';
import '../providers/cart.dart';
import './cart_screen.dart';
import '../providers/products.dart';

enum FilterOptions {
  Favorites,
  All,
}

class TabsScreen extends StatefulWidget {
  static const routeName = '/tabs-screen';
  @override
  _TabsScreenState createState() => _TabsScreenState();
}

class _TabsScreenState extends State<TabsScreen> {
  bool _showOnlyFavorites = false;
  bool _isInit = true;
  bool _isLoading = false;


  void setStateIfMounted(f) {
    if (mounted) setState(f);
  }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      setState(() {
        _isLoading = true;
      });
      if(mounted){
        Provider.of<Cart>(context, listen: false).newfetchAndSetCartItems();
      Provider.of<Products>(context, listen: false).newfetchAndSetProducts().then((_) {
          setState(() {
              _isLoading = false;
          });
      });
      }
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Hyper Store',style: TextStyle(fontWeight: FontWeight.bold)),
          actions: <Widget>[
            PopupMenuButton(
              offset: const Offset(0, 20),
              shape: const TooltipShape(),
              onSelected: (FilterOptions selectedValue) {
                setStateIfMounted(() {
                  if (selectedValue == FilterOptions.Favorites) {
                    _showOnlyFavorites = true;
                  } else {
                    _showOnlyFavorites = false;
                  }
                });
              },
              icon: Icon(
                Icons.more_vert,
              ),
              itemBuilder: (_) => [
                    PopupMenuItem(
                      child: Text('Only Favourites'),
                      value: FilterOptions.Favorites,
                    ),
                    PopupMenuItem(
                      child: Text('Show All'),
                      value: FilterOptions.All,
                    ),
                  ],
            ),
            Consumer<Cart>(
              builder: (_, cart, ch) => Badge(
                    child: ch,
                    value: cart.itemCount.toString(),
                  ),
              child: IconButton(
                icon: Icon(
                  Icons.shopping_cart,
                ),
                onPressed: () {
                  Navigator.of(context).pushNamed(CartScreen.routeName);
                },
              ),
            ),
          ],
          bottom: TabBar(
            isScrollable: true,
            tabs: <Widget>[
              Tab(
                icon: Icon(Icons.all_inclusive),
                text: 'All',
              ),
              Tab(
                icon: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: FaIcon(
                    FontAwesomeIcons.tshirt,
                    size: 18,
                  ),
                ),
                text: 'Clothing',
              ),
              Tab(
                icon: Icon(Icons.bolt),
                text: 'Electronics',
              ),
              Tab(
                icon: Icon(Icons.category),
                text: 'Others',
              ),
            ],
          ),
        ),
        drawer: AppDrawer(),
        body: TabBarView(
          children: <Widget>[
            _isLoading ? 
              Center(child: CircularProgressIndicator()) 
                : ProductsGrid(_showOnlyFavorites, 0),
            _isLoading ? 
              Center(child: CircularProgressIndicator()) 
                : ProductsGrid(_showOnlyFavorites, 1),
            _isLoading ? 
              Center(child: CircularProgressIndicator()) 
                : ProductsGrid(_showOnlyFavorites, 2),
            _isLoading ? 
              Center(child: CircularProgressIndicator()) 
                : ProductsGrid(_showOnlyFavorites, 3),
          ],
        ),
      ),
    );
  }
}
