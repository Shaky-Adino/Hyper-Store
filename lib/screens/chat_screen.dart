import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../widgets/chat/no_message.dart';
import '../providers/products.dart';
import '../widgets/chat/new_message.dart';
import '../widgets/chat/messages.dart';
import '../widgets/app_drawer.dart';

class ChatScreen extends StatelessWidget{
  static const routeName = '/chat-screen';
  Future<void> _fetchUserProducts(BuildContext context) async {
    await Provider.of<Products>(context, listen: false)
        .fetchUserProducts();
  }
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seller\'s Arena'),
      ),
      drawer: AppDrawer(),
      body: Container(
        child: Column(
          children: [
            Expanded(
              child: Messages()
            ),
            FutureBuilder(
              future: _fetchUserProducts(context),
              builder: (ctx, snapshot){
                if(snapshot.connectionState == ConnectionState.waiting){
                  return NoMessage("Loading your products");
                }
                if(Provider.of<Products>(context, listen: false).userItems.length == 0){
                  return NoMessage("You have no products");
                }
                return NewMessage(Provider.of<Products>(context, listen: false).userItems);
              },
            ),
          ],
        ),
      ),
    );
  }
  
}