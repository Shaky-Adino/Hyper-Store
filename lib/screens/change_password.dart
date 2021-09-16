import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth.dart';

class ChangePassword extends StatefulWidget {

  @override
  _ChangePasswordState createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  bool showPassword = false, showPassword1 = false, showPassword2 = false;
  String oldPassword, newPassword;
  bool _isLoading = false, done = false;

  SnackBar makeBar(String text){
    final snackBar = SnackBar(
      duration: Duration(milliseconds: 2500),
      content: Text(
        '$text', 
        textAlign: TextAlign.center, 
        style: TextStyle(fontSize: 15),
      ),
      backgroundColor: Colors.red,
      elevation: 3,
      padding: EdgeInsets.all(5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(50), topRight: Radius.circular(50))),
    );
    return snackBar;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState.validate()) {
      // Invalid!
      return;
    }
    if(oldPassword == newPassword){
      ScaffoldMessenger.of(context).showSnackBar(makeBar('Please choose a password \ndifferent from exisiting one!'));
      return;
    }
    AuthCredential credential = EmailAuthProvider.credential(
      email: FirebaseAuth.instance.currentUser.email, 
      password: oldPassword
    );
    try {
        await FirebaseAuth.instance.currentUser.reauthenticateWithCredential(credential).then((value)async{
          await FirebaseAuth.instance.currentUser.updatePassword(newPassword).then((value)async{
            await showDialog(
              context: context,
              builder:  (BuildContext context)
                {
                  return AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    content: SingleChildScrollView(
                      child: ListBody(
                        children: <Widget>[
                          Icon(Icons.check, size: 45, color: Colors.green),
                          SizedBox(height: 15),
                          Text("Password Updated Successfully!"),
                        ],
                      ),
                    ),
                    actions: <Widget>[
                      TextButton(
                        child: const Text('Close', style: TextStyle(color:Colors.black)),
                        onPressed: () {
                          done = true;
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  );
                },
            );
          });
        });
      } on FirebaseAuthException catch (e) {
        SnackBar snackBar;
        if(e.code == "invalid-credential" || e.code == "wrong-password"){
          snackBar = makeBar("Invalid Current Password !");
        }
        else if(e.code == "too-many-requests"){
          snackBar = makeBar("Too Many Requests. Please try \nagain after some time.");
        }
        else{
          snackBar = makeBar("Something Went Wrong !");
        }
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
  }

  @override
  Widget build(BuildContext context) {
    var mq = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Hyper Store'),
        ),
        body: SingleChildScrollView(
            child: Container(
              child: Column(
                children: [
                  Stack(
                  children: <Widget>[
                    Container(
                      width: double.infinity,
                      height: MediaQuery.of(context).size.height*0.47,
                      margin: EdgeInsets.fromLTRB(mq.width*0.05, mq.height*0.032, mq.width*0.05, mq.height*0.015),
                      padding: EdgeInsets.only(bottom: mq.height*0.014),
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: Color.fromARGB(255, 0, 0, 0), width: 2),
                        borderRadius: BorderRadius.circular(10),
                        shape: BoxShape.rectangle,
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Padding(
                              padding: EdgeInsets.fromLTRB(mq.width*0.07, mq.height*0.01, mq.width*0.07, 0),
                              child: TextFormField(
                                style: TextStyle(fontSize: 14.0),
                                obscureText: !showPassword,
                                decoration: InputDecoration(
                                  hintText: "Enter your current password",
                                  labelText: "Curent Password",
                                  suffix: GestureDetector(
                                      onTap: (){
                                        setState(() {
                                            showPassword = !showPassword;                             
                                        });
                                      },
                                      child: Icon(
                                        showPassword ? Icons.visibility : Icons.visibility_off,
                                        size: 18,
                                        color: Colors.black,
                                      ),
                                  ),
                                ),
                                validator: (value){
                                  if (value.isEmpty || value.length < 5) {
                                    return 'Invalid password!';
                                  }
                                  return null;
                                },
                                onChanged: (value){
                                  oldPassword = value;
                                }
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.fromLTRB(mq.width*0.07, 0, mq.width*0.07, 0),
                              child: TextFormField(
                                obscureText: !showPassword1,
                                decoration: InputDecoration(
                                  hintText: "Enter your new password",
                                  labelText: "New Password",
                                  suffix: GestureDetector(
                                      onTap: (){
                                        setState(() {
                                          showPassword1 = !showPassword1;                             
                                        });
                                      },
                                      child: Icon(
                                        showPassword1 ? Icons.visibility : Icons.visibility_off,
                                        size: 18,
                                        color: Colors.black,
                                      ),
                                    ),
                                ),
                                validator: (value){
                                  if (value.isEmpty || value.length < 5) {
                                    return 'Password is too short!';
                                  }
                                  return null;
                                },
                                onChanged: (value){
                                  newPassword = value;
                                }
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.fromLTRB(mq.width*0.07, 0, mq.width*0.07, mq.height*0.02),
                              child: TextFormField(
                                obscureText: !showPassword2,
                                decoration: InputDecoration(
                                  hintText: "Re-enter your new password",
                                  labelText: "Confirm New Password",
                                  suffix: GestureDetector(
                                    onTap: (){
                                      setState(() {
                                        showPassword2 = !showPassword2;                                  
                                      });
                                    },
                                    child: Icon(
                                      showPassword2 ? Icons.visibility : Icons.visibility_off,
                                      size: 18,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                                validator: (value){
                                  if (value != newPassword) {
                                    return 'Passwords do not match!';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            Material(
                              color: _isLoading ? Theme.of(context).scaffoldBackgroundColor : Colors.black,
                              borderRadius: BorderRadius.circular(15),
                              child: InkWell(
                                onTap: () async {
                                  FocusManager.instance.primaryFocus?.unfocus();
                                  setState(() {
                                    _isLoading = true;
                                  });
                                  await _submit();
                                  setState(() {
                                    _isLoading = false;
                                  });
                                  if(done)
                                    Navigator.of(context).pop();
                                },
                                child: _isLoading ? CircularProgressIndicator() 
                                  : Container(
                                  width: 160,
                                  height: 40,
                                  alignment: Alignment.center,
                                  child: Text(
                                    "Change Password",
                                    style: TextStyle(
                                      color: Colors.yellow, 
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      left: MediaQuery.of(context).size.width*0.1,
                      top: MediaQuery.of(context).size.height*0.015,
                      child: Container(
                        padding: EdgeInsets.only(bottom: 10, left: 10, right: 10),
                        color: Theme.of(context).scaffoldBackgroundColor,
                        child: Text(
                          'Change Password',
                          style: TextStyle(color: Colors.black, fontSize: 24),
                        ),
                      )
                    ),
                  ],
                ),
                Container(
                  padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
                  margin: EdgeInsets.all(0),
                  child: TextButton(
                    onPressed: () {
                      FirebaseAuth.instance.sendPasswordResetEmail(email: FirebaseAuth.instance.currentUser.email);
                      showDialog(
                        context: context,
                        builder: (BuildContext context)
                        {
                          return AlertDialog(
                            title: const Text('Reset Password'),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            content: SingleChildScrollView(
                              child: ListBody(
                                children: <Widget>[
                                  Text("Password reset link sent to registered email."),
                                ],
                              ),
                            ),
                            actions: <Widget>[
                              TextButton(
                                child: const Text('Close', style: TextStyle(color:Colors.black)),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          );
                        },
                      );
                    },
                    child: Text(
                      "Reset Password",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 15,
                      )
                    ),
                  ),
                ),
                ],
              ),
            ),
          ),
        ),
    );
      
      
      
      
      
      
      
      // Padding(
      //   padding: const EdgeInsets.all(8.0),
      //   child: Container(
      //     child: Form(
      //       key: _formKey,
      //       child: SingleChildScrollView(
      //         child: Column(
      //           children: [
      //             TextFormField(
      //                             style: TextStyle(
      //                               fontSize: 14.0,
      //                             ),
      //                             decoration: InputDecoration(
      //                               prefixIcon: Icon(
      //                                 Icons.lock,
      //                                 size: 18,
      //                                 color: Colors.black,
      //                               ),
      //                               filled: true,
      //                               enabledBorder: UnderlineInputBorder(
      //                                 borderRadius: BorderRadius.circular(10),
      //                                 borderSide: BorderSide.none,
      //                               ),
      //                               focusedBorder: OutlineInputBorder(
      //                                 borderRadius: BorderRadius.circular(10),
      //                               ),
      //                               suffixIcon: GestureDetector(
      //                                 onTap: (){
      //                                   setState(() {
      //                                       showPassword = !showPassword;                             
      //                                   });
      //                                 },
      //                                 child: Icon(
      //                                   showPassword ? Icons.visibility : Icons.visibility_off,
      //                                   size: 18,
      //                                   color: Colors.black,
      //                                 ),
      //                               ),
      //                               labelText: 'Current Password'
      //                             ),
      //                             obscureText: !showPassword,
      //                             validator: (value) {
      //                               if (value.isEmpty || value.length < 5) {
      //                                 return 'Invalid password!';
      //                               }
      //                               return null;
      //                             },
      //                             onChanged: (value) {
      //                               oldPassword = value;
      //                             },
      //                           ),
      //             TextFormField(
      //                             style: TextStyle(
      //                               fontSize: 14.0,
      //                             ),
      //                             decoration: InputDecoration(
      //                               prefixIcon: Icon(
      //                                 Icons.vpn_key,
      //                                 size: 18,
      //                                 color: Colors.black,
      //                               ),
      //                               filled: true,
      //                               enabledBorder: UnderlineInputBorder(
      //                                 borderRadius: BorderRadius.circular(10),
      //                                 borderSide: BorderSide.none,
      //                               ),
      //                               focusedBorder: OutlineInputBorder(
      //                                 borderRadius: BorderRadius.circular(10),
      //                               ),
      //                               suffixIcon: GestureDetector(
      //                                 onTap: (){
      //                                   setState(() {
      //                                        showPassword1 = !showPassword1;                             
      //                                   });
      //                                 },
      //                                 child: Icon(
      //                                   showPassword1 ? Icons.visibility : Icons.visibility_off,
      //                                   size: 18,
      //                                   color: Colors.black,
      //                                 ),
      //                               ),
      //                               labelText: 'New Password'
      //                             ),
      //                             obscureText: !showPassword1,
      //                             validator: (value) {
      //                               if (value.isEmpty || value.length < 5) {
      //                                 return 'Password is too short!';
      //                               }
      //                               return null;
      //                             },
      //                             onChanged: (value) {
      //                               newPassword = value;
      //                             },
      //                           ),

      //             TextFormField(
      //                                   style: TextStyle(
      //                                     fontSize: 14.0,
      //                                   ),
      //                                   decoration: InputDecoration(
      //                                     prefixIcon: Icon(
      //                                       Icons.vpn_key,
      //                                       size: 18,
      //                                       color: Colors.black,
      //                                     ),
      //                                     filled: true,
      //                                     enabledBorder: UnderlineInputBorder(
      //                                       borderRadius: BorderRadius.circular(10),
      //                                       borderSide: BorderSide.none,
      //                                     ),
      //                                     focusedBorder: OutlineInputBorder(
      //                                       borderRadius: BorderRadius.circular(10),
      //                                     ),
      //                                     suffixIcon: GestureDetector(
      //                                       onTap: (){
      //                                         setState(() {
      //                                             showPassword2 = !showPassword2;                                  
      //                                         });
      //                                       },
      //                                       child: Icon(
      //                                         showPassword2 ? Icons.visibility : Icons.visibility_off,
      //                                         size: 18,
      //                                         color: Colors.black,
      //                                       ),
      //                                     ),
      //                                     labelText: 'Confirm New Password'
      //                                   ),
      //                                   obscureText: !showPassword2,
      //                                   validator: (value) {
      //                                           if (value != newPassword) {
      //                                             return 'Passwords do not match!';
      //                                           }
      //                                           return null;
      //                                         },
      //                                 ),
      //           ],
      //         ),
      //       ),
      //     ),
      //   ),
      // ),
    // );
  }
}