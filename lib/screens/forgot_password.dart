import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ForgotPassword extends StatefulWidget {

  @override
  _ForgotPasswordState createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  String _email;
  bool _isLoading = false, _done = false;

  Future<void> _submit() async {
    if (!_formKey.currentState.validate()) {
      // Invalid!
      return;
    }
    _formKey.currentState.save();
    setState(() {
      _isLoading = true;
    });
    try
    {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: _email);
      setState(() {
        _isLoading = false;
      });
      await showDialog(
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
                children: <Widget>[Text("Password reset link sent to your email.")]
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('Close', style: TextStyle(color:Colors.black)),
                  onPressed: () {
                    _done = true;
                    Navigator.of(context).pop();
                  },
              ),
            ],
          );
        },
      );
      return;
    } on FirebaseAuthException catch(e) {
      if(e.code == 'user-not-found'){
        showDialog(
          context: context,
          builder: (BuildContext context)
          {
            return AlertDialog(
              title: const Text('Oops !'),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[const Text("No user found for that email.")]
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Okay', style: TextStyle(color:Colors.black)),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                ),
              ],
            );
          },
        );
      }
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Reset Password'),
        ),
        body: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 20.0, left: 20.0, right: 20.0),
              child: const Text(
                'Password reset link will be sent to your email id !',
                style: TextStyle(fontSize: 20.0),
              ),
            ),
            Expanded(
              child: Form(
                key: _formKey,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
                  child: ListView(
                    children: [
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 10),
                        child: TextFormField(
                          style: TextStyle(
                            fontSize: 14.0,
                          ),
                          decoration: InputDecoration(
                            prefixIcon: Icon(
                              Icons.mail,
                              size: 18,
                              color: Colors.black,
                            ),
                            filled: true,
                            enabledBorder: UnderlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            labelText: 'E-Mail'
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value.isEmpty || !value.contains('@') || !value.contains('.com')) {
                              return 'Invalid email!';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            _email = value;
                          },
                        ),
                      ),
                      SizedBox(height: 10),
                      if(_isLoading)
                        Center(child: CircularProgressIndicator()),
                      if(!_isLoading)
                        Material(
                          child: Ink(
                            decoration: BoxDecoration(
                              color: Colors.yellow,
                              borderRadius: BorderRadius.circular(10),
                                border: Border.fromBorderSide(BorderSide.none),
                              ),
                            child: InkWell(
                              onTap: () async {
                                FocusManager.instance.primaryFocus?.unfocus();
                                await _submit();
                                if(_done)
                                  Navigator.of(context).pop();
                              },
                              borderRadius: BorderRadius.circular(10),
                              child: Container(
                                height: 50.0,
                                child: Center(
                                  child: Text(
                                    'Send Email',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,fontSize: 16.0,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}