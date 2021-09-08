import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/http_exception.dart';

class Auth with ChangeNotifier{

  // static Auth _instance;
  // factory Auth(){
  //   if(_instance == null){
  //     _instance = new Auth._();
  //   }
  //   return _instance;
  // }

  // Auth._();

  
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  FirebaseAuth _auth;
  UserCredential authResult;

  // String _token;
  // DateTime _expiryDate;
  String _userId, _username;
  // Timer _authTimer;

  // bool get isAuth {
  //   return token != null;
  // }

  // String get token {
  //   if (_expiryDate != null &&
  //       _expiryDate.isAfter(DateTime.now()) &&
  //       _token != null) {
  //     return _token;
  //   }
  //   return null;
  // }

  String get userId {
    return _userId;
  }

  String get username{
    return _username;
  }

  Future<void> newlogin(String email, String password) async {
    _auth = FirebaseAuth.instance;
    try{
      authResult = await _auth.signInWithEmailAndPassword(email: email, password: password);
      _userId = _auth.currentUser.uid;
      _username = await firestore.collection('users').doc(_userId).get().then((documentSnapshot) => documentSnapshot.data()['username']);
    } catch(e){
      throw HttpException(e.code);
    }
    notifyListeners();
  }

  Future<void> newgoogleLogin() async {
    _auth = FirebaseAuth.instance;
    final GoogleSignInAccount googleUser = await GoogleSignIn().signIn();
    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    authResult = await _auth.signInWithCredential(credential);
    final user = authResult.user;
    _userId = _auth.currentUser.uid;
    await firestore.collection('users').doc(_userId).set({
        'username': user.displayName,
        'email': user.email
    });
    _username = user.displayName;
    notifyListeners();
  }

  Future<void> newsignUp(String username, String email, String password) async {
    _auth = FirebaseAuth.instance;
    try{
      authResult = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      _userId = _auth.currentUser.uid;
      await firestore.collection('users').doc(_userId).set({
        'username': username,
        'email': email
      });
      _username = username;
    } catch(e){
      throw HttpException(e.code);
    }
    notifyListeners();
  }

  Future<void> newlogout() async {
    _auth = FirebaseAuth.instance;
    _userId = null;
    final GoogleSignIn googleSignIn = new GoogleSignIn();
    bool google = await googleSignIn.isSignedIn();
    if(google)
      await googleSignIn.signOut();
    else
      await _auth.signOut();
  }

  // Future<void> _authenticate(String email, String password, String urlSegment, [String uname]) async {

  //   final url = Uri.parse('https://identitytoolkit.googleapis.com/v1/accounts:$urlSegment?key=AIzaSyCuJULdoB0HrxZokrt2_E_siSQ9f-Ijd3Y');
  //   try {
  //     var postbody;
  //     if(urlSegment == 'signInWithIdp')
  //         postbody = json.encode(
  //           {
  //             'requestUri': 'http://localhost',
  //             'postBody' : 'id_token=$password&providerId=google.com',
  //             'returnSecureToken': true,
  //             'returnIdpCredential': true,
  //           },
  //         );
  //     else
  //         postbody = json.encode(
  //           {
  //             'email': email,
  //             'password': password,
  //             'returnSecureToken': true,
  //           },
  //         );
      
  //     final response = await http.post(
  //       url,
  //       body: postbody,
  //     );
  //     final responseData = json.decode(response.body);
  //     if (responseData['error'] != null) {
  //       throw HttpException(responseData['error']['message']);
  //     }
  //     _token = responseData['idToken'];
  //     _userId = responseData['localId'];

  //     final url2 = Uri.parse('https://shop-app-9aa36.firebaseio.com/username/$_userId.json?auth=$_token');
  //     if(urlSegment == 'signUp')
  //     {
  //       try{
  //         final res = await http.put(
  //           url2,
  //           body: json.encode({
  //             'username': uname,
  //           }),
  //         );
  //         if(res.statusCode >= 400){
  //           throw HttpException('status code >= 400');
  //         }
  //         _username = uname;
  //       } catch(error){
  //         throw HttpException("Authentication Failed");
  //       }
  //     }else{
  //       if(urlSegment == 'signInWithIdp'){
  //         _username = responseData['firstName'];
  //       }
  //       else
  //       {
  //         try{
  //           final res = await http.get(url2);
  //           if(res.statusCode >= 400){
  //             throw Error();
  //           }
  //           var data = json.decode(res.body);
  //           _username = data['username'];
  //         } catch(error){
  //           throw HttpException("Authentication Failed");
  //         }
  //       }
  //     }

  //     _expiryDate = DateTime.now().add(
  //       Duration(
  //         seconds: int.parse(
  //           responseData['expiresIn'],
  //         ),
  //       ),
  //     );  
  //     _autoLogout();
  //     notifyListeners();
  //     final prefs = await SharedPreferences.getInstance();
  //     final userData = json.encode(
  //       {
  //         'token': _token,
  //         'userId': _userId,
  //         'expiryDate': _expiryDate.toIso8601String(),
  //         'username' : _username,
  //       },
  //     );
  //     prefs.setString('userData', userData);
  //   } catch (error) {
  //     throw error;
  //   }
  // }

  // Future<void> signup(String uname, String email, String password) async {
  //   return _authenticate(email, password, 'signUp', uname);
  // }

  // Future<void> googleLogin() async {
  //   final googleSignIn = GoogleSignIn();
  //   final googleUser = await googleSignIn.signIn();
  //   final googleAuth = await googleUser.authentication;
  //   return _authenticate('', googleAuth.idToken , 'signInWithIdp');
  // }

  // Future<void> login(String email, String password) async {
  //   return _authenticate(email, password, 'signInWithPassword');
  // }

  // Future<bool> tryAutoLogin() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   if (!prefs.containsKey('userData')) {
  //     return false;
  //   }
  //   final extractedUserData = json.decode(prefs.getString('userData')) as Map<String, Object>;
  //   final expiryDate = DateTime.parse(extractedUserData['expiryDate']);

  //   if (expiryDate.isBefore(DateTime.now())) {
  //     return false;
  //   }
  //   _token = extractedUserData['token'];
  //   _userId = extractedUserData['userId'];
  //   _expiryDate = expiryDate;
  //   _username = extractedUserData['username'];
  //   notifyListeners();
  //   _autoLogout();
  //   return true;
  // }

  // Future<void> logout() async {
  //   _token = null;
  //   _userId = null;
  //   _expiryDate = null;
  //   if (_authTimer != null) {
  //     _authTimer.cancel();
  //     _authTimer = null;
  //   }
  //   notifyListeners();
  //   final prefs = await SharedPreferences.getInstance();
  //   // prefs.remove('userData');
  //   prefs.clear();
  //   await prefs.setBool('seen', true);
  // }

  // void _autoLogout() {
  //   if (_authTimer != null) {
  //     _authTimer.cancel();
  //   }
  //   final timeToExpiry = _expiryDate.difference(DateTime.now()).inSeconds;
  //   _authTimer = Timer(Duration(seconds: timeToExpiry), logout);
  // }
}
