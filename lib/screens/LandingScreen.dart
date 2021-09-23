import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './tabs_screen.dart';
import '../providers/auth.dart';
import '../providers/orders.dart';
import '../providers/cart.dart';
import '../providers/products.dart';
import 'products_overview_screen.dart';
import 'auth_screen.dart';

class LandingScreen extends StatelessWidget {
  static const routeName = '/landing-screen';

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (ctx, userSnapshot){
                if(userSnapshot.hasData){

                  Provider.of<Products>(ctx, listen: false).updates(FirebaseAuth.instance.currentUser.uid);
                  Provider.of<Cart>(ctx, listen: false).updates(FirebaseAuth.instance.currentUser.uid);
                  Provider.of<Orders>(ctx, listen: false).updates(FirebaseAuth.instance.currentUser.uid);

                  Provider.of<Auth>(ctx, listen: false).setUserDetails();
                  
                  return TabsScreen();
                }
                return AuthScreen();
            },
    );
  }
}
