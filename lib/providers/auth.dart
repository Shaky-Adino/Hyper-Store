import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/widgets.dart';
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
  // String _userId;
  String _username, _profilePic, _email, _phone, _address;
  // Timer _authTimer;

  // bool get isAuth {
  //   return token != null;
  // }

  bool newUser;
  Auth(this.newUser);

  // String get token {
  //   if (_expiryDate != null &&
  //       _expiryDate.isAfter(DateTime.now()) &&
  //       _token != null) {
  //     return _token;
  //   }
  //   return null;
  // }

  // String get userId {
  //   return _userId;
  // }

  String get username{
    return _username;
  }

  String get userEmail{
    return _email;
  }

  String get userPhone{
    return _phone;
  }

  String get userAddress{
    return _address;
  }

  String get userImage{
    return _profilePic;
  }

  Future<void> setUserDetails() async {
    _auth = FirebaseAuth.instance;
    if(_auth.currentUser == null)
      return;
      if(!newUser){
        final userData = await firestore.collection('users').doc(_auth.currentUser.uid).get();
        _username = userData.data()['username'];
        _profilePic = userData.data()['image_url'];
        _email = userData.data()['email'];
        _phone = userData.data()['phone'];
        _address = userData.data()['address'];
        notifyListeners();
      }
    newUser = false;
  }

  Future<void> newlogin(String email, String password) async {
    _auth = FirebaseAuth.instance;
    try{
      authResult = await _auth.signInWithEmailAndPassword(email: email, password: password);
    } catch(e){
      throw HttpException(e.code);
    }
  }

  Future<void> newgoogleLogin() async {
    newUser = true;
    _auth = FirebaseAuth.instance;
    final GoogleSignInAccount googleUser = await GoogleSignIn().signIn();
    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    authResult = await _auth.signInWithCredential(credential);
    final user = authResult.user;
    final userData = await firestore.collection('users').doc(_auth.currentUser.uid).get();
    if(userData.exists){
      _username = userData.data()['username'];
      _profilePic = userData.data()['image_url'];
      _email = userData.data()['email'];
      _phone = userData.data()['phone'];
      _address = userData.data()['address'];
    }
    else{
      await firestore.collection('users').doc(_auth.currentUser.uid).set({
        'username': user.displayName.contains(' ') ? 
                        user.displayName.substring(0, user.displayName.indexOf(' '))
                          : user.displayName,
        'email': user.email,
        'image_url': user.photoURL,
        'phone': '',
        'address': '',
      });
      _username = user.displayName.contains(' ') ? 
                        user.displayName.substring(0, user.displayName.indexOf(' '))
                          : user.displayName;
      _profilePic = user.photoURL;
      _email = user.email;
      _phone = '';
      _address = '';
    }
    notifyListeners();
  }

  Future<void> newsignUp(String username,File image, String email, String password) async {
    newUser = true;
    _auth = FirebaseAuth.instance;
    try{
      authResult = await _auth.createUserWithEmailAndPassword(email: email, password: password);

      final ref = FirebaseStorage.instance.ref().child('user_image').child(authResult.user.uid + '.jpg');

      await ref.putFile(image);

      final url = await ref.getDownloadURL();

      await firestore.collection('users').doc(_auth.currentUser.uid).set({
        'username': username,
        'email': email,
        'image_url': url,
        'phone': '',
        'address': '',
      });
      _username = username;
      _profilePic = url;
      _email = email;
      _phone = '';
      _address = '';
      notifyListeners();
    } catch(e){
      throw HttpException(e.code);
    }
  }

  Future<void> newlogout() async {
    _username = null;
    _profilePic = null;
    _auth = FirebaseAuth.instance;
    if(_auth.currentUser.providerData[0].providerId.toString().contains('google.com'))
      await GoogleSignIn().signOut();
    await _auth.signOut();
  }

  Future<void> updateUserInfo(String username, String url, String phone, String address) async {
    await firestore.collection('users').doc(_auth.currentUser.uid).set({
      'username': username,
      'email': _email,
      'image_url': url,
      'phone': phone,
      'address': address,
    });
    _username = username;
    _profilePic = url;
    _phone = phone;
    _address = address;
    notifyListeners();
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
