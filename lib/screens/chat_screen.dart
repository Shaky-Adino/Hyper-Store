import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/app_drawer.dart';

class ChatScreen extends StatelessWidget{
  static const routeName = '/chat-screen';
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppDrawer(),
      body: StreamBuilder(
        stream: firestore.collection('chats/NDMmgPiiTvp2b33ZrfnO/messages').snapshots(),
        builder: (ctx, streamSnapshot){
          if(streamSnapshot.connectionState == ConnectionState.waiting){
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          final documents = streamSnapshot.data.docs;
          return ListView.builder(
            itemCount: documents.length,
            itemBuilder: (ctx, index) => Container(
              padding: EdgeInsets.all(8),
              child: Text(documents[index]['text']),
            ),
            );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: (){
          firestore.collection('chats/NDMmgPiiTvp2b33ZrfnO/messages').add({
            'text': 'This was added by clicking the button'
          });
        },
      ),
    );
  }
  
}