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
              icon: const Icon(Icons.edit, color: Colors.black),
              onPressed: () {
                Navigator.of(context)
                    .pushNamed(EditProductScreen.routeName, arguments: id);
              },
              color: Theme.of(context).primaryColor,
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () async {
                try {
                  await showDialog(
                    context: context, 
                    barrierDismissible: false,
                    builder: (BuildContext context){
                      bool deleting = false;
                      return StatefulBuilder(
                        builder : (context, setState){
                          return AlertDialog(
                            title: !deleting ? const Text("Are you sure?") : null,
                            shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                            content: deleting ? 
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const SizedBox(height: 10),
                                  Center(child: CircularProgressIndicator()),
                                  const SizedBox(height: 20),
                                  Text('Deleting your product from Hyper Store'),
                                ],
                              )  : const Text("This action is permanent and can't be undone !"),
                            actions: [
                              TextButton(
                                onPressed: (){
                                  Navigator.of(context).pop();
                                }, 
                                child: !deleting ? 
                                  Text("CANCEL",style: TextStyle(color:Colors.orange[700], fontWeight: FontWeight.bold)) : null,
                              ),
                              TextButton(
                                onPressed: () async {
                                  setState((){
                                    deleting = true;
                                  });
                                  await Provider.of<Products>(context, listen: false).newdeleteProduct(id);
                                  setState((){
                                    deleting = false;
                                  });
                                  Navigator.of(context).pop();
                                }, 
                                child: !deleting ?
                                 Text("YES",style: TextStyle(color:Colors.orange[700], fontWeight: FontWeight.bold)) : null,
                              ),
                            ],
                          );
                        }
                      );
                    }
                  );
                } catch (error) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text(
                        'Deleting failed!', 
                        style: TextStyle(color: Colors.white),
                        textAlign: TextAlign.center
                      ),
                      backgroundColor: Colors.redAccent,
                      elevation: 3,
                      padding: const EdgeInsets.all(3),
                      shape: RoundedRectangleBorder(
                        borderRadius: const BorderRadius.only(
                          topLeft: const Radius.circular(50), 
                          topRight: const Radius.circular(50)
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
