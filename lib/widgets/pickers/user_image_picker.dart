import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UserImagePicker extends StatefulWidget {
  final void Function(File pickedImage) imagePickFn;
  UserImagePicker(this.imagePickFn);
  
  @override
  _UserImagePickerState createState() => _UserImagePickerState();
}

class _UserImagePickerState extends State<UserImagePicker> {
  File _pickedImage;

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
    widget.imagePickFn(pickedImageFile);
  }
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          flex: 3,
          child: CircleAvatar(
            backgroundColor: Colors.grey.withOpacity(0.2),
            radius: 50,
            backgroundImage: _pickedImage != null ? FileImage(_pickedImage) : null,
            child: _pickedImage == null ? Padding(
              padding: const EdgeInsets.all(6.0),
              child: ClipOval(
                child: Image.asset('assets/images/profile_pic1.png'),
              ),
            ) : null,
          ),
        ),
        Flexible(
          flex: 1,
          child: TextButton.icon(
            style: TextButton.styleFrom(
              primary: Colors.orange,
            ),
            onPressed: _pickImage,
            icon: Icon(Icons.image, size: 19,),
            label: Text('Add Image', overflow: TextOverflow.visible,),
          ),
        ),
      ],
    );
  }
}