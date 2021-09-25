import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './tabs_screen.dart';
import '../providers/auth.dart';

class EmailVerification extends StatefulWidget {

  @override
  _EmailVerificationState createState() => _EmailVerificationState();
}

class _EmailVerificationState extends State<EmailVerification> {
  Timer _timer;

  @override
  void initState() {
      super.initState();
      FirebaseAuth.instance.currentUser.sendEmailVerification();
      Future(() async {
          _timer = Timer.periodic(Duration(seconds: 5), (timer) async {
              await FirebaseAuth.instance.currentUser.reload();
              var user = FirebaseAuth.instance.currentUser;
              if (user.emailVerified){
                timer.cancel();
                Navigator.of(context).pushReplacementNamed(TabsScreen.routeName);;
              } 
          });
      });
  }

  @override
  void dispose() {
      super.dispose();
      if (_timer != null) {
          _timer.cancel();
      }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.yellow,
        body: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 150),
              Text(
                'Hyper Store',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold
                ),
              ),
              SizedBox(height: 30),
              Text(
                'An Email has been sent to ${FirebaseAuth.instance.currentUser.email} \nPlease verify the email to continue.',
                style: TextStyle(
                  fontSize: 15,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 50),
              Center(
                child: CircularProgressIndicator(),
              ),
              SizedBox(height: 20),
              Text(
                'Waiting email verification',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500
                ),
              ),
              SizedBox(height: 45),
              Text(
                'Not ${FirebaseAuth.instance.currentUser.email} ?',
                style: TextStyle(
                  color: Colors.red
                ),
              ),
              SizedBox(height: 8),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Colors.black,
                  onPrimary: Colors.yellow
                ),
                onPressed: (){
                  Provider.of<Auth>(context,listen: false).newlogout();
                }, 
                child: Text('Go Back')
              ),
            ],
          ),
        )
      );
  }
}