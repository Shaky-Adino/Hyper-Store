import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopapp/providers/auth.dart';

class NewMessage extends StatefulWidget {
  final products;
  final List<PopupMenuItem<int>> items = [];
  NewMessage(this.products){
    for(int i=0;i<products.length;i++)
      items.add(PopupMenuItem(
        child: Text(products[i].title),
        value: i,
      ));
  }
  @override
  _NewMessageState createState() => _NewMessageState();
}

class _NewMessageState extends State<NewMessage> {
  final _controller = new TextEditingController();
  var _enteredMessage = '';
  int selectedIndex = -1;

  void _sendMessage() {
    FocusScope.of(context).unfocus();
    final user = FirebaseAuth.instance.currentUser;
    final authData = Provider.of<Auth>(context,listen: false);
    final username = authData.username;
    final userImage = authData.userImage;
    FirebaseFirestore.instance.collection('chat').add({
      'text': _enteredMessage,
      'createdAt': Timestamp.now(),
      'userId': user.uid,
      'username': username,
      'userImage': userImage,
      'productTitle': widget.products[selectedIndex].title,
      'productImage': widget.products[selectedIndex].imageUrl0,
      'productId': widget.products[selectedIndex].id,
    });
    _controller.clear();
    setState(() {
        selectedIndex = -1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 8),
      padding: EdgeInsets.all(8),
      child: Column(
        children: [
          Row(
            children: [
                PopupMenuButton(
                  onSelected: (int index){
                    setState(() {
                      selectedIndex = index;
                    });
                  },
                  itemBuilder: (_) => widget.items,
                  child: Container(
                    padding: const EdgeInsets.only(top: 8),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 8, left: 8, right: 8),
                      child: Text('Select your product!', style: TextStyle(color: Colors.yellow),),
                    )
                  ),
                  // child: OutlinedButton(
                  //   onPressed: (){},
                  //   style: ButtonStyle(
                  //     shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0))),
                  //   ),
                  //   child: const Text("Select your product"),
                  // ),
                ),
            ],
          ),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if(selectedIndex >= 0)
                        Text(widget.products[selectedIndex].title),
                      if(selectedIndex >= 0)
                        Container(
                          width: 100,
                          height: 100,
                          child: CachedNetworkImage(
                            imageUrl: widget.products[selectedIndex].imageUrl0,
                            progressIndicatorBuilder: (context, url, downloadProgress) => 
                                Center(child: CircularProgressIndicator(value: downloadProgress.progress)),
                            fit: BoxFit.cover,
                          ),
                        ),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.black),
                                borderRadius: const BorderRadius.only(
                                  topRight: Radius.circular(12),
                                  bottomLeft: Radius.circular(12),
                                  bottomRight: Radius.circular(12),
                                ),
                              ),
                              padding: const EdgeInsets.only(left: 8),
                              child: TextField(
                                enabled: (selectedIndex >= 0),
                                controller: _controller,
                                decoration: InputDecoration(
                                  labelText: 'Add product description...', 
                                  border: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                ),
                                onChanged: (value){
                                    setState(() {
                                      _enteredMessage = value;
                                    });
                                },
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.send),
                            onPressed: (_enteredMessage.trim().isEmpty || selectedIndex < 0) ? null : _sendMessage,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}