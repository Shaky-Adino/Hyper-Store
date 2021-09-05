import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import './screens/splash_screen.dart';
import './screens/cart_screen.dart';
import './screens/products_overview_screen.dart';
import './screens/product_detail_screen.dart';
import './providers/products.dart';
import './providers/cart.dart';
import './providers/orders.dart';
import './providers/auth.dart';
import './screens/orders_screen.dart';
import './screens/user_products_screen.dart';
import './screens/edit_product_screen.dart';
import './screens/auth_screen.dart';
import './helpers/custom_route.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
} 

class MyApp extends StatelessWidget {
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();
  @override
  Widget build(BuildContext context) {
    // Firebase.initializeApp();
    return FutureBuilder(
      future: _initialization,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          //create a page asking if user is connected to internet
          print(snapshot.error);
        }
        if (snapshot.connectionState == ConnectionState.done) {
          return MultiProvider(
                    providers: [
                      ChangeNotifierProvider(
                        create: (ctx) => Auth(),
                      ),
                      ChangeNotifierProxyProvider<Auth, Products>(
                        create: (_) => Products(null, null, []),
                        update: (ctx, auth, previousProducts) => Products(
                          auth.token,
                          auth.userId,
                          previousProducts == null ? [] : previousProducts.items,
                        ),
                      ),
                      ChangeNotifierProxyProvider<Auth, Cart>(
                        create: (_) => Cart(null, null, {}),
                        update: (ctx, auth, previousItems) => Cart(
                          auth.token,
                          auth.userId,
                          previousItems == null ? {} : previousItems.items,
                        ),
                      ),
                      ChangeNotifierProxyProvider<Auth, Orders>(
                        create: (_) => Orders(null, null, []),
                        update: (ctx, auth, previousOrders) => Orders(
                          auth.token,
                          auth.userId,
                          previousOrders == null ? [] : previousOrders.orders,
                        ),
                      ),
                    ],
                    child: Consumer<Auth>(
                      builder: (ctx, auth, _) => MaterialApp(
                        debugShowCheckedModeBanner: false,
                        title: 'MyShop',
                        theme: ThemeData(
                          primarySwatch: Colors.yellow,
                          accentColor: Colors.redAccent,
                          inputDecorationTheme: InputDecorationTheme(
                            labelStyle: TextStyle(color: Colors.black),
                            focusedBorder:UnderlineInputBorder(borderSide: BorderSide(color: Colors.black),) , 
                          ),
                          textSelectionTheme: TextSelectionThemeData(cursorColor: Colors.black,selectionHandleColor: Colors.black),
                          fontFamily: 'Lato',
                          pageTransitionsTheme: PageTransitionsTheme(
                            builders: {
                              TargetPlatform.android: CustomPageTransitionBuilder(),
                              TargetPlatform.iOS: CustomPageTransitionBuilder(),
                            },
                          ),
                        ),
                        home: auth.isAuth
                            ? ProductsOverviewScreen()
                            : FutureBuilder(
                                future: auth.tryAutoLogin(),
                                builder: (ctx, authResultSnapshot) =>
                                    authResultSnapshot.connectionState ==
                                            ConnectionState.waiting
                                        ? SplashScreen()
                                        : AuthScreen(),
                              ),
                        routes: {
                          ProductDetailScreen.routeName: (ctx) => ProductDetailScreen(),
                          CartScreen.routeName: (ctx) => CartScreen(),
                          OrdersScreen.routeName: (ctx) => OrdersScreen(),
                          UserProductsScreen.routeName: (ctx) => UserProductsScreen(),
                          EditProductScreen.routeName: (ctx) => EditProductScreen(),
                        },
                      ),
                    ),
                  );
        }
        return MaterialApp(home: SplashScreen());
      },
    );
  }
}
