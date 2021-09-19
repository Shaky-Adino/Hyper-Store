import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../providers/auth.dart';

class UserProfile extends StatefulWidget {
  final String username, url, phone, address;

  UserProfile(this.username, this.url, this.phone, this.address);

  @override
  _UserProfileState createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  File _pickedImage;
  String _newUsername, _newUrl, _newPhone, _newAddress;

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

  Future<void> _saveForm(BuildContext ctx) async {
    if (!_formKey.currentState.validate()) {
      // Invalid!
      return;
    }
    _formKey.currentState.save();

    FocusScope.of(context).unfocus();

    showDialog(
      context: context, 
      barrierDismissible: false,
      builder: (BuildContext context){
        return AlertDialog(
          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
          content: Row(
            children: [
              CircularProgressIndicator(),
              Container(margin: EdgeInsets.only(left: 10),child:Text("Saving..." )),
            ],
          ),
        );
      }
    );

    if(_pickedImage != null){
      await FirebaseStorage.instance.refFromURL(widget.url).delete();

      final ref = FirebaseStorage.instance.ref().child('user_image')
                    .child(FirebaseAuth.instance.currentUser.uid + '.jpg');

      await ref.putFile(_pickedImage);

      _newUrl = await ref.getDownloadURL();
    }
    else
      _newUrl = widget.url;

    await Provider.of<Auth>(context, listen: false).updateUserInfo(_newUsername, _newUrl, _newPhone, _newAddress);

    Navigator.of(context).pop();
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Hyper Store'),
        ),
        body: WillPopScope(
          onWillPop: () async {
            Navigator.pop(context, false);
            return false;
          },
          child: Container(
            padding: const EdgeInsets.all(10),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundImage: _pickedImage == null ? null : FileImage(_pickedImage),
                    child: _pickedImage == null ?
                      CachedNetworkImage(
                            imageUrl: widget.url,
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

                  const SizedBox(height: 10),

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
                                        if(value == widget.username)
                                          return null;
                                        if (value.isEmpty || value.length < 3)
                                          return 'Username is too short!!';
                                        if(value.contains(' '))
                                          return 'No spaces allowed';
                                        return null;
                                    },
                          onSaved: (value){
                                      _newUsername = value;
                                      _newPhone = _newPhone;
                                      _newAddress = _newAddress;
                                  },
                        ),

                        const SizedBox(height: 10),

                        TextFormField(
                          keyboardType: TextInputType.phone,
                          initialValue: widget.phone,
                          style: TextStyle(fontSize: 14.0),
                          decoration: InputDecoration(
                            prefixIcon: Icon(
                                          Icons.phone,
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
                            labelText: 'Phone No'
                          ),
                          validator: (value) {
                                        if (value.isEmpty || value.length < 10 || value.length > 10) {
                                            return 'Enter a valid phone no.';
                                        }
                                        if(value.contains(' ')){
                                          return 'no spaces allowed';
                                        }
                                        return null;
                                    },
                          onSaved: (value){
                                      _newUsername = _newUsername;
                                      _newPhone = value;
                                      _newAddress = _newAddress;
                                  },
                        ),

                        const SizedBox(height: 10),

                        TextFormField(
                          initialValue: widget.address,
                          maxLines: 3,
                          keyboardType: TextInputType.multiline,
                          style: TextStyle(fontSize: 14.0),
                          decoration: InputDecoration(
                            prefixIcon: Icon(
                                          Icons.home,
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
                            labelText: 'Address'
                          ),
                          validator: (value) {
                                        if (value.isEmpty || value.length < 10) {
                                            return 'Should be at least 10 characters long.';
                                        }
                                        return null;
                                    },
                          onSaved: (value){
                                      _newUsername = _newUsername;
                                      _newPhone = _newPhone;
                                      _newAddress = value;
                                  },
                        ),

                        const SizedBox(height: 20),

                        Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(8)),
                                onPressed: (){
                                  _saveForm(context);
                                }, 
                                child: Text("SAVE",style: TextStyle(fontWeight: FontWeight.bold),softWrap: false,)
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}