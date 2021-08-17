// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:google_sign_in/google_sign_in.dart';
// class GoogleSignInProvider extends ChangeNotifier{
//   final googleSignIn = GoogleSignIn();

//   GoogleSignInAccount _user;

//   GoogleSignInAccount get user => _user;

//   void _showErrorDialog(String message,BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (ctx) => AlertDialog(
//         title: Text('An Error Occurred!'),
//         content: Text(message),
//         actions: <Widget>[
//           FlatButton(
//             child: Text('Okay'),
//             onPressed: () {
//               Navigator.of(ctx).pop();
//             },
//           )
//         ],
//       ),
//     );
//   }

//   Future googleLogin({@required BuildContext ctx}) async {
//     try
//     {
//       final googleUser = await googleSignIn.signIn();
//       if(googleUser == null)  return;
//       _user = googleUser;

//       final googleAuth = await googleUser.authentication;

//       final credential = GoogleAuthProvider.credential(
//         accessToken: googleAuth.accessToken,
//         idToken: googleAuth.idToken,
//       );

//       await FirebaseAuth.instance.signInWithCredential(credential);
//     } catch (e){
//       _showErrorDialog(e.code, ctx);
//       print(e);
//     }
//     notifyListeners();
//   }

//   Future googleLogout({@required BuildContext ctx})async {
//     try
//     {
//       await googleSignIn.disconnect();
//       FirebaseAuth.instance.signOut();
//     } catch (e) {
//       _showErrorDialog(e.code, ctx);
//     }
//   }
// }