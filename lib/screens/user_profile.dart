import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../providers/auth.dart';

class UserProfile extends StatefulWidget {
  final String username, url;

  UserProfile(this.username, this.url);

  @override
  _UserProfileState createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  File _pickedImage;
  String _newUsername;

  void _pickImage() async {
    final picker = ImagePicker();
    final img = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
    );
    final pickedImageFile = File(img.path);
    setState(() {
        _pickedImage = pickedImageFile;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authData = Provider.of<Auth>(context);
    String url = authData.userImage;
    return Scaffold(
      appBar: AppBar(
        title: Text('User Profile'),
      ),
      body: Container(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            CircleAvatar(
              radius: 60,
              backgroundImage: _pickedImage == null ? null : FileImage(_pickedImage),
              child: _pickedImage == null ?
                CachedNetworkImage(
                      imageUrl: url,
                      imageBuilder: (context, imageProvider) => Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
                        ),
                      ),
                      progressIndicatorBuilder: (context, url, downloadProgress) => 
                        Center(child: CircularProgressIndicator(value: downloadProgress.progress)),
                      fit: BoxFit.cover,
                    ) : null,
            ),

            TextButton.icon(
              style: TextButton.styleFrom(
                primary: Colors.orange,
                padding: EdgeInsets.zero,
              ),
              onPressed: _pickImage,
              icon: Icon(Icons.image, size: 19,),
              label: Text('Edit Image', overflow: TextOverflow.visible),
            ),

            SizedBox(height: 10),

            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    initialValue: widget.username,
                    style: TextStyle(fontSize: 14.0),
                    decoration: InputDecoration(
                      prefixIcon: Icon(
                                    Icons.account_circle,
                                    size: 18,
                                    color: Colors.black,
                                  ),
                      filled: true,
                      enabledBorder: UnderlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: BorderSide.none,
                                      ),
                      focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                      labelText: 'Username'
                    ),
                    validator: (value) {
                                  if (value.isEmpty || value.length < 3) {
                                      return 'username is too short!!';
                                  }
                                  if(value.contains(' ')){
                                    return 'no spaces allowed';
                                  }
                                  return null;
                              },
                    onSaved: (value){
                                _newUsername = value;
                            },
                  ),                
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}