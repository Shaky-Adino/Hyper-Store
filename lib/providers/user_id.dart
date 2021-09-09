import 'package:flutter/widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
class UserId with ChangeNotifier{
  String _userId;
  String get userId {
    return _userId;
  }
  void updateUserId(){
    _userId = FirebaseAuth.instance.currentUser.uid;
    notifyListeners();
  }
}