import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/my_favorite.dart';
import '../providers/products.dart';
import '../widgets/my_order.dart';
import '../providers/orders.dart';
import './change_password.dart';
import './user_profile.dart';
import '../providers/auth.dart';
import '../widgets/app_drawer.dart';

class Account extends StatelessWidget {
  static const routeName = '/account-screen';
  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    final authData = Provider.of<Auth>(context);
    String username = authData.username;
    String url = authData.userImage;
    String email = authData.userEmail;
    String phone = authData.userPhone;
    String address = authData.userAddress;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Account'),
      ),
      drawer: AppDrawer(),
      body: Container(
        padding: const EdgeInsets.only(left: 8, top: 8, bottom: 8),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('User Profile', style: TextStyle(fontSize: 18)),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Card(
                  child: SizedBox(
                    child: Column(
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Expanded(
                              child: Column(
                                children: [
                                  ListTile(
                                    visualDensity: VisualDensity(horizontal: 0, vertical: -4),
                                    horizontalTitleGap: 5,
                                    leading: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [const Text('Username:')],
                                    ),
                                    title: username == null ? const Text('Loading...') : Padding(
                                      padding: const EdgeInsets.only(bottom: 2),
                                      child: Text(username),
                                    ),
                                  ),
                                  const Divider(height: 1, thickness: 1,endIndent: 5,indent: 15,),
                                  ListTile(
                                    visualDensity: VisualDensity(horizontal: 0, vertical: -4),
                                    horizontalTitleGap: 5,
                                    leading: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [const Text('Email:')],
                                    ),
                                    title: username == null ? const Text('Loading...') : Padding(
                                      padding: const EdgeInsets.only(bottom: 2),
                                      child: Text(email),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(right: 5),
                              child: CircleAvatar(
                                radius: 35,
                                backgroundImage: url == null ? const AssetImage('assets/images/profile_pic.png') : null,
                                child: url != null ? 
                                  CachedNetworkImage(
                                    imageUrl: url,
                                    imageBuilder: (context, imageProvider) => Container(
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        image: DecorationImage(
                                          image: imageProvider, fit: BoxFit.cover),
                                      ),
                                    ),
                                    progressIndicatorBuilder: (context, url, downloadProgress) => 
                                          Center(child: CircularProgressIndicator(value: downloadProgress.progress)),
                                    fit: BoxFit.cover,
                                  ) : null,
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 1, thickness: 1,endIndent: 5,indent: 15,),
                        ListTile(
                            visualDensity: VisualDensity(horizontal: 0, vertical: -4),
                            horizontalTitleGap: 5,
                            leading: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [const Text('Phone No:')],
                            ),
                            title: phone == null ? const Text('Loading...') : Padding(
                              padding: const EdgeInsets.only(bottom: 2),
                              child: Text(phone),
                            ),
                        ),
                        const Divider(height: 1, thickness: 1,endIndent: 5,indent: 15,),
                        ListTile(
                            visualDensity: VisualDensity(horizontal: 0, vertical: -4),
                            horizontalTitleGap: 5,
                            leading: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [const Text('Address:')],
                            ),
                            title: address == null ? const Text('Loading...') : Padding(
                              padding: const EdgeInsets.only(bottom: 2),
                              child: Text(address),
                            ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 5),

              GestureDetector(
                onTap: (){
                  Navigator.push(
                    context, 
                    MaterialPageRoute(builder: (context) => UserProfile(username, url, phone, address))
                  );
                },
                child: Container(
                  margin: EdgeInsets.only(left: deviceSize.width*0.40),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.yellow,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(40),
                      bottomLeft: const Radius.circular(40),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.account_circle),
                      const SizedBox(width: 10),
                      const Expanded(child: const Text('Edit Profile')),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 8),

              GestureDetector(
                onTap: (){
                  if(FirebaseAuth.instance.currentUser.providerData[0].providerId.toString().contains('google.com')){
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      duration: const Duration(milliseconds: 2500),
                      content: const Text(
                        'You are signed in through Google', 
                        textAlign: TextAlign.center, 
                        style: TextStyle(fontSize: 15),
                      ),
                      backgroundColor: Colors.orange,
                      elevation: 3,
                      padding: const EdgeInsets.all(3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(50), 
                          topRight: const Radius.circular(50)
                        ),
                      ),
                    ));
                  }
                  else{
                    Navigator.push(
                      context, 
                      MaterialPageRoute(builder: (context) => ChangePassword())
                    );
                  }
                },
                child: Container(
                  margin: EdgeInsets.only(left: deviceSize.width*0.50),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(40),
                      bottomLeft: const Radius.circular(40),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.vpn_key, color: Colors.yellow),
                      const SizedBox(width: 10),
                      const Expanded(child: const Text('Change Password', style: TextStyle(color: Colors.yellow))),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 8),

              const Text('Your Orders', style: TextStyle(fontSize: 18)),

              const SizedBox(height: 8),

              Container(
                child: FutureBuilder(
                  future: Provider.of<Orders>(context, listen: false).newfetchAndSetOrders(),
                  builder: (ctx, dataSnapshot) {
                    if (dataSnapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else {
                      if (dataSnapshot.error != null) {
                        return Center(
                          child: const Text('An error occurred!'),
                        );
                      } else {
                        return Consumer<Orders>(
                          builder: (ctx, orderData, child) => orderData.products.length > 0 ?
                          Container(
                            height: 120,
                            child: ListView.builder(
                              shrinkWrap: true,
                              scrollDirection: Axis.horizontal,
                              itemCount: orderData.products.length,
                              itemBuilder: (ctx, i) => MyOrder(
                                Provider.of<Products>(context, listen: false)
                                      .findById(orderData.products.keys.elementAt(i))
                              ),
                            ),
                          ) : Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: const Text('You haven\'t ordered anything yet.', style: TextStyle(color: Colors.orange),),
                          ),
                        );
                      }
                    }
                  },
                ),
              ),

              const SizedBox(height: 8),

              const Text('Your Favourites', style: TextStyle(fontSize: 18)),

              const SizedBox(height: 8),

              Container(
                child: FutureBuilder(
                  future: Provider.of<Products>(context, listen: false).newfetchAndSetProducts(),
                  builder: (ctx, dataSnapshot) {
                    if (dataSnapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else {
                      if (dataSnapshot.error != null) {
                        return Center(
                          child: Text('An error occurred!'),
                        );
                      } else {
                        return Consumer<Products>(
                          builder: (ctx, prodData, child) => prodData.favoriteItems.length > 0 ?
                          Container(
                            height: 120,
                            child: ListView.builder(
                              shrinkWrap: true,
                              scrollDirection: Axis.horizontal,
                              itemCount: prodData.favoriteItems.length,
                              itemBuilder: (ctx, i) => MyFavorite(prodData.favoriteItems[i]),
                            ),
                          ) : Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: const Text('There are no items in this.', style: TextStyle(color: Colors.orange),),
                          ),
                        );
                      }
                    }
                  },
                ),
              ),

              const SizedBox(height: 8),

              const Text('Your Products', style: TextStyle(fontSize: 18)),

              const SizedBox(height: 8),

              Container(
                child: FutureBuilder(
                  future: Provider.of<Products>(context, listen: false).fetchUserProducts(),
                  builder: (ctx, dataSnapshot) {
                    if (dataSnapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else {
                      if (dataSnapshot.error != null) {
                        return Center(
                          child: Text('An error occurred!'),
                        );
                      } else {
                        return Consumer<Products>(
                          builder: (ctx, prodData, child) =>prodData.userItems.length > 0 ?
                           Container(
                            height: 120,
                            child: ListView.builder(
                              shrinkWrap: true,
                              scrollDirection: Axis.horizontal,
                              itemCount: prodData.userItems.length,
                              itemBuilder: (ctx, i) => MyFavorite(prodData.userItems[i]),
                            ),
                          ) : Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: const Text('You haven\'t added any products to the store yet.', style: TextStyle(color: Colors.orange),),
                          ),
                        );
                      }
                    }
                  },
                ),
              ),
            ],
          ),
        )
      ),
    );
  }
}