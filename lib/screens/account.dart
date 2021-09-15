import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth.dart';
import '../widgets/app_drawer.dart';

class Account extends StatelessWidget {
  static const routeName = '/account-screen';
  @override
  Widget build(BuildContext context) {
    final authData = Provider.of<Auth>(context);
    String username = authData.username;
    String url = authData.userImage;
    String email = authData.userEmail;
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Account'),
      ),
      drawer: AppDrawer(),
      body: Container(
        padding: const EdgeInsets.all(8),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('User Profile'),
              SizedBox(height: 8),
              Card(
                child: Row(
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
                              children: [
                                Text('Username:'),
                              ],
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
                              children: [
                                Text('Email:'),
                              ],
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
                              width: 70.0,
                              height: 70.0,
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
              ),
            ],
          ),
        )
      ),
    );
  }
}