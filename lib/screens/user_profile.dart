import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../providers/auth.dart';

class UserProfile extends StatefulWidget {

  @override
  _UserProfileState createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  File _pickedImage;
  bool _edit = false;

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
        actions: [
          IconButton(
            icon: Icon(Icons.edit), 
            onPressed: (){
              setState(() {
                _edit = true;
              });
            }
          )
        ],
      ),
      body: Container(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            CircleAvatar(
              radius: 60,
              backgroundImage: _pickedImage == null ? CachedNetworkImage(
                                  imageUrl: url,
                                  progressIndicatorBuilder: (context, url, downloadProgress) => 
                                        Center(child: CircularProgressIndicator(value: downloadProgress.progress)),
                                  fit: BoxFit.cover,
                                ) : FileImage(_pickedImage),
            ),

            SizedBox(height: 5),

            TextButton.icon(
              style: TextButton.styleFrom(
                primary: Colors.orange,
              ),
              onPressed: _edit ? _pickImage : null,
              icon: Icon(Icons.image, size: 19,),
              label: Text('Edit Image', overflow: TextOverflow.visible),
            ),

            SizedBox(height: 10),

            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    enabled: _edit,
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
                                username = value;
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