import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../screens/landingScreen.dart';
import '../screens/products_overview_screen.dart';
import '../helpers/custom_route.dart';

import '../screens/chat_screen.dart';
import '../screens/orders_screen.dart';
import '../screens/user_products_screen.dart';
import '../providers/auth.dart';

class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    String username = Provider.of<Auth>(context).username;
    return Drawer(
      child: Column(
        children: <Widget>[
          AppBar(
            title: Text('Hello $username!'),
            automaticallyImplyLeading: false,
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.shop),
            title: Text('Shop'),
            onTap: () {
              Navigator.of(context).pushReplacementNamed(ProductsOverviewScreen.routeName);
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.payment),
            title: Text('Orders'),
            onTap: () {
              Navigator.of(context).pushReplacementNamed(OrdersScreen.routeName);
              // Navigator.of(context).pushReplacement(
              //   CustomRoute(
              //     builder: (ctx) => OrdersScreen(),
              //   ),
              // );
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.edit),
            title: Text('Manage Products'),
            onTap: () {
              Navigator.of(context)
                  .pushReplacementNamed(UserProductsScreen.routeName);
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.chat),
            title: Text('Chat Screen'),
            onTap: () {
              Navigator.of(context)
                  .pushReplacementNamed(ChatScreen.routeName);
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.exit_to_app),
            title: Text('Logout'),
            onTap: () async {
              await Provider.of<Auth>(context,listen: false).newlogout();
              // Navigator.of(context).pop();
              // Navigator.of(context).pushReplacementNamed(LandingScreen.routeName);
            },
          ),
        ],
      ),
    );
  }
}
