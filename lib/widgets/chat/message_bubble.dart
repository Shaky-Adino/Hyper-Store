import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopapp/providers/products.dart';
import 'package:shopapp/screens/product_detail_screen.dart';

class MessageBubble extends StatelessWidget{
  final String message, username, userImage, productTitle, productImage, productId, id;
  final bool isMe;
  final Key key;

  MessageBubble(this.message, this.username, this.userImage,
   this.productTitle, this.productImage, this.productId, this.isMe, this.id, this.key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Row(
          mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            InkWell(
              onTap: (){
                if(Provider.of<Products>(context, listen: false).findById(productId) == null)
                  return;
                Navigator.of(context).pushNamed(
                  ProductDetailScreen.routeName,
                  arguments: productId,
                );
              },
              onLongPress: () async {
                if(!isMe)
                  return;
                try {
                  await showDialog(
                    context: context, 
                    barrierDismissible: false,
                    builder: (BuildContext context){
                      return AlertDialog(
                        title: const Text("Delete this message?"),
                        shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                        content: const Text("This action is permanent and can't be undone !"),
                        actions: [
                          TextButton(
                            onPressed: (){
                              Navigator.of(context).pop();
                            }, 
                            child: const Text("CANCEL",style: TextStyle(color: Colors.orange),)
                          ),
                          TextButton(
                            onPressed: () async {
                              await FirebaseFirestore.instance.collection('chat').doc(id).delete();
                              Navigator.of(context).pop();
                            }, 
                            child: const Text("YES",style: TextStyle(color: Colors.orange),)
                          ),
                        ],
                      );
                    }
                  );
                } catch (error) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Deleting failed!', textAlign: TextAlign.center,),
                    ),
                  );
                }
              },
              child: Container(
                decoration: BoxDecoration(
                  color: !isMe ? Colors.grey[300] : Colors.yellow,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(12),
                    topRight: const Radius.circular(12),
                    bottomLeft: !isMe ? const Radius.circular(0) : const Radius.circular(12),
                    bottomRight: isMe ? const Radius.circular(0) : const Radius.circular(12),
                  ),
                ),
                width: 140,
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                margin: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                child: Column(
                  crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: isMe ? 8 : 0, right: !isMe ? 8 : 0),
                      child: Text(
                        "$productTitle  ",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: CachedNetworkImage(
                            imageUrl: productImage,
                            progressIndicatorBuilder: (context, url, downloadProgress) => 
                              Center(child: CircularProgressIndicator(value: downloadProgress.progress)),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    Text(message, 
                      style: TextStyle(
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.start,
                    ),
                    Text(
                      "- $username",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        Positioned(
          top: 0,
          left: isMe ? null : 120,
          right: isMe ? 120 : null,
          child: CircleAvatar(
            backgroundImage: CachedNetworkImageProvider(userImage),
          ),
        ),
      ],
      clipBehavior: Clip.none,
    );
  }
  
}