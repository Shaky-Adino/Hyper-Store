import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import './message_bubble.dart';

class Messages extends StatelessWidget {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: firestore.collection('chat').orderBy('createdAt', descending: true).snapshots(),
      builder: (ctx, chatSnapshot){
        if(chatSnapshot.connectionState == ConnectionState.waiting){
            return Center(
              child: CircularProgressIndicator(),
            );
        }
        final chatDocs = chatSnapshot.data.docs;
        return ListView.builder(
          reverse: true,
          itemCount: chatDocs.length,
          itemBuilder: (ctx, index) => MessageBubble(
            chatDocs[index].data()['text'], 
            chatDocs[index].data()['username'],
            chatDocs[index].data()['userImage'],
            chatDocs[index].data()['productTitle'],
            chatDocs[index].data()['productImage'],
            chatDocs[index].data()['productId'],
            chatDocs[index].data()['userId'] == FirebaseAuth.instance.currentUser.uid,
            ValueKey(chatDocs[index].id),
          ),
        );
      }
    );
  }
}