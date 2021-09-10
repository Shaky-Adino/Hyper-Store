import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/chat/new_message.dart';
import '../widgets/chat/messages.dart';
import '../widgets/app_drawer.dart';

class ChatScreen extends StatelessWidget{
  static const routeName = '/chat-screen';
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('FlutterChat'),
      ),
      drawer: AppDrawer(),
      body: Container(
        child: Column(
          children: [
            Expanded(
              child: Messages()
            ),
            NewMessage(),
          ],
        ),
      ),
    );
  }
  
}