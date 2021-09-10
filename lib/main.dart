import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import './screens/LandingScreen.dart';
import './screens/chat_screen.dart';
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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
} 

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
                    ChangeNotifierProvider(create: (ctx) => Auth()),
                    ChangeNotifierProvider(create: (ctx) => Products()),
                    // ChangeNotifierProxyProvider<UserId, Products>(
                    //       create: (_) => Products(null, []),
                    //       update: (ctx, user, previous) => previous..updates(user.userId)
                    //       //  Products(
                    //       //   auth.userId,
                    //       //   previousProducts == null ? [] : previousProducts.items,
                    //       // ),
                    // ),
                    ChangeNotifierProvider(create: (ctx) => Cart()),
                    // ChangeNotifierProxyProvider<UserId, Cart>(
                    //       create: (_) => Cart(null, {}),
                    //       update: (ctx, user, previous) => previous..updates(user.userId)
                    //       // Cart(
                    //       //   auth.userId,
                    //       //   previousItems == null ? {} : previousItems.items,
                    //       // ),
                    // ),
                    ChangeNotifierProvider(create: (ctx) => Orders()),
                    // ChangeNotifierProxyProvider<UserId, Orders>(
                    //       create: (_) => Orders(null, []),
                    //       update: (ctx, user, previous) => previous..updates(user.userId)
                    //       // Orders(
                    //       //   auth.userId,
                    //       //   previousOrders == null ? [] : previousOrders.orders,
                    //       // ),
                    // ),
                ],
      child: MaterialApp(
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
              home: LandingScreen(),
              // StreamBuilder(
              //             stream: FirebaseAuth.instance.authStateChanges(),
              //             builder: (ctx, userSnapshot){
              //               if(userSnapshot.hasData){

              //                 Provider.of<Products>(ctx, listen: false).updates(FirebaseAuth.instance.currentUser.uid);
              //                 Provider.of<Cart>(ctx, listen: false).updates(FirebaseAuth.instance.currentUser.uid);
              //                 Provider.of<Orders>(ctx, listen: false).updates(FirebaseAuth.instance.currentUser.uid);

              //                 Future.delayed(const Duration(milliseconds: 300), (){
              //                   Provider.of<Auth>(ctx, listen: false).setUserDetails();
              //                 });
              //                       // return Scaffold(appBar: AppBar(title: Text('successful'),),);
              //                 return ProductsOverviewScreen();
              //               }
              //               return AuthScreen();
              //             },
              //   ),
              routes: {
                  LandingScreen.routeName: (ctx) => LandingScreen(),
                  AuthScreen.routeName: (ctx) => AuthScreen(),
                  ProductDetailScreen.routeName: (ctx) => ProductDetailScreen(),
                  ProductsOverviewScreen.routeName: (ctx) => ProductsOverviewScreen(),
                  CartScreen.routeName: (ctx) => CartScreen(),
                  OrdersScreen.routeName: (ctx) => OrdersScreen(),
                  UserProductsScreen.routeName: (ctx) => UserProductsScreen(),
                  EditProductScreen.routeName: (ctx) => EditProductScreen(),
                  ChatScreen.routeName : (ctx) => ChatScreen(),
              },
      ),
    );
          // return MultiProvider(
          //           providers: [
          //             ChangeNotifierProvider(
          //               create: (ctx) => Auth(),
          //             ),
          //             ChangeNotifierProxyProvider<Auth, Products>(
          //               create: (_) => Products(null, null, []),
          //               update: (ctx, auth, previousProducts) => Products(
          //                 auth.token,
          //                 auth.userId,
          //                 previousProducts == null ? [] : previousProducts.items,
          //               ),
          //             ),
          //             ChangeNotifierProxyProvider<Auth, Cart>(
          //               create: (_) => Cart(null, null, {}),
          //               update: (ctx, auth, previousItems) => Cart(
          //                 auth.token,
          //                 auth.userId,
          //                 previousItems == null ? {} : previousItems.items,
          //               ),
          //             ),
          //             ChangeNotifierProxyProvider<Auth, Orders>(
          //               create: (_) => Orders(null, null, []),
          //               update: (ctx, auth, previousOrders) => Orders(
          //                 auth.token,
          //                 auth.userId,
          //                 previousOrders == null ? [] : previousOrders.orders,
          //               ),
          //             ),
          //           ],
          //           child: Consumer<Auth>(
          //             builder: (ctx, auth, _) => MaterialApp(
          //               debugShowCheckedModeBanner: false,
          //               title: 'MyShop',
          //               theme: ThemeData(
          //                 primarySwatch: Colors.yellow,
          //                 accentColor: Colors.redAccent,
          //                 inputDecorationTheme: InputDecorationTheme(
          //                   labelStyle: TextStyle(color: Colors.black),
          //                   focusedBorder:UnderlineInputBorder(borderSide: BorderSide(color: Colors.black),) , 
          //                 ),
          //                 textSelectionTheme: TextSelectionThemeData(cursorColor: Colors.black,selectionHandleColor: Colors.black),
          //                 fontFamily: 'Lato',
          //                 pageTransitionsTheme: PageTransitionsTheme(
          //                   builders: {
          //                     TargetPlatform.android: CustomPageTransitionBuilder(),
          //                     TargetPlatform.iOS: CustomPageTransitionBuilder(),
          //                   },
          //                 ),
          //               ),
          //               home: StreamBuilder(
          //                 stream: FirebaseAuth.instance.authStateChanges(),
          //                 builder: (ctx, userSnapshot){
          //                   if(snapshot.connectionState == ConnectionState.waiting){
          //                     return SplashScreen();
          //                   }
          //                   if(userSnapshot.hasData){
          //                     return ProductsOverviewScreen();
          //                   }
          //                   return AuthScreen();
          //                 },
          //               ),
                        
          //               // auth.isAuth
          //               //     ? ProductsOverviewScreen()
          //               //     : FutureBuilder(
          //               //         future: auth.tryAutoLogin(),
          //               //         builder: (ctx, authResultSnapshot) =>
          //               //             authResultSnapshot.connectionState ==
          //               //                     ConnectionState.waiting
          //               //                 ? SplashScreen()
          //               //                 : AuthScreen(),
          //               //       ),
          //               routes: {
          //                 ProductDetailScreen.routeName: (ctx) => ProductDetailScreen(),
          //                 CartScreen.routeName: (ctx) => CartScreen(),
          //                 OrdersScreen.routeName: (ctx) => OrdersScreen(),
          //                 UserProductsScreen.routeName: (ctx) => UserProductsScreen(),
          //                 EditProductScreen.routeName: (ctx) => EditProductScreen(),
          //                 ChatScreen.routeName : (ctx) => ChatScreen(),
          //               },
          //             ),
          //           ),
          //         );
  }
}
