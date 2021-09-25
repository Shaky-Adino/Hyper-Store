import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../screens/edit_product_screen.dart';
import '../providers/products.dart';

class UserProductItem extends StatelessWidget {
  final String id;
  final String title;
  final String imageUrl;

  UserProductItem(this.id, this.title, this.imageUrl);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      leading: CircleAvatar(
        backgroundImage: CachedNetworkImageProvider(imageUrl),
      ),
      trailing: Container(
        width: 100,
        child: Row(
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.edit, color: Colors.black),
              onPressed: () {
                Navigator.of(context)
                    .pushNamed(EditProductScreen.routeName, arguments: id);
              },
              color: Theme.of(context).primaryColor,
            ),
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: () async {
                try {
                  await showDialog(
                    context: context, 
                    barrierDismissible: false,
                    builder: (BuildContext context){
                      return AlertDialog(
                        title: Text("Are you sure?"),
                        shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                        content: Text("This action is permanent and can't be undone !"),
                        actions: [
                          TextButton(
                            onPressed: (){
                              Navigator.of(context).pop();
                            }, 
                            child: Text("CANCEL",style: TextStyle(color:Colors.orange[700], fontWeight: FontWeight.bold))
                          ),
                          TextButton(
                            onPressed: () async {
                              await Provider.of<Products>(context, listen: false).newdeleteProduct(id);
                              Navigator.of(context).pop();
                            }, 
                            child: Text("YES",style: TextStyle(color:Colors.orange[700], fontWeight: FontWeight.bold))
                          ),
                        ],
                      );
                    }
                  );
                } catch (error) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Deleting failed!', 
                        style: TextStyle(color: Colors.white),
                        textAlign: TextAlign.center
                      ),
                      backgroundColor: Colors.redAccent,
                      elevation: 3,
                      padding: EdgeInsets.all(3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(50), 
                          topRight: Radius.circular(50)
                        ),
                      ),
                    ),
                  );
                }
              },
              color: Theme.of(context).errorColor,
            ),
          ],
        ),
      ),
    );
  }
}
