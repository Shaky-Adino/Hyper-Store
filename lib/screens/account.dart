import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/products.dart';
import '../widgets/my_orders.dart';
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
        title: Text('Your Account'),
      ),
      drawer: AppDrawer(),
      body: Container(
        padding: const EdgeInsets.only(left: 8, top: 8, bottom: 8),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('User Profile', style: TextStyle(fontSize: 18)),
              SizedBox(height: 8),
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
                                      children: [Text('Username:')],
                                    ),
                                    title: username == null ? Text('Loading...') : Padding(
                                      padding: const EdgeInsets.only(bottom: 2),
                                      child: Text(username),
                                    ),
                                  ),
                                  Divider(height: 1, thickness: 1,endIndent: 5,indent: 15,),
                                  ListTile(
                                    visualDensity: VisualDensity(horizontal: 0, vertical: -4),
                                    horizontalTitleGap: 5,
                                    leading: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [Text('Email:')],
                                    ),
                                    title: username == null ? Text('Loading...') : Padding(
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
                                backgroundImage: url == null ? AssetImage('assets/images/profile_pic.png') : null,
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
                        Divider(height: 1, thickness: 1,endIndent: 5,indent: 15,),
                        ListTile(
                            visualDensity: VisualDensity(horizontal: 0, vertical: -4),
                            horizontalTitleGap: 5,
                            leading: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [Text('Phone No:')],
                            ),
                            title: phone == null ? Text('Loading...') : Padding(
                              padding: const EdgeInsets.only(bottom: 2),
                              child: Text(phone),
                            ),
                        ),
                        Divider(height: 1, thickness: 1,endIndent: 5,indent: 15,),
                        ListTile(
                            visualDensity: VisualDensity(horizontal: 0, vertical: -4),
                            horizontalTitleGap: 5,
                            leading: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [Text('Address:')],
                            ),
                            title: address == null ? Text('Loading...') : Padding(
                              padding: const EdgeInsets.only(bottom: 2),
                              child: Text(address),
                            ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 5),
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
                      Icon(Icons.account_circle),
                      SizedBox(width: 10),
                      Expanded(child: Text('Edit Profile')),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 8),
              GestureDetector(
                onTap: (){
                  if(FirebaseAuth.instance.currentUser.providerData[0].providerId.toString().contains('google.com')){
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      duration: Duration(milliseconds: 2500),
                      content: Text(
                        'You are signed in through Google', 
                        textAlign: TextAlign.center, 
                        style: TextStyle(fontSize: 15),
                      ),
                      backgroundColor: Colors.orange,
                      elevation: 3,
                      padding: EdgeInsets.all(3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(topLeft: Radius.circular(50), 
                          topRight: Radius.circular(50)
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
                      Icon(Icons.vpn_key, color: Colors.yellow),
                      SizedBox(width: 10),
                      Expanded(child: Text('Change Password', style: TextStyle(color: Colors.yellow))),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 8),

              Text('Your Orders', style: TextStyle(fontSize: 18)),

              SizedBox(height: 8),

              Container(
                child: FutureBuilder(
                  future: Provider.of<Orders>(context, listen: false).newfetchAndSetOrders(),
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
                        return Consumer<Orders>(
                          builder: (ctx, orderData, child) => Container(
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