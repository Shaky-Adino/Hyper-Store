import 'dart:ui';
import 'package:flutter/services.dart';

import '../widgets/wave_widget.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shopapp/screens/splash_screen.dart';
import './intro_screen.dart';
import '../providers/auth.dart';
import '../models/http_exception.dart';

enum AuthMode { Signup, Login }

class AuthScreen extends StatefulWidget {
  static const routeName = '/auth';

  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with SingleTickerProviderStateMixin{
  final GlobalKey<FormState> _formKey = GlobalKey();
  AuthMode _authMode = AuthMode.Login;
  Map<String, String> _authData = {
    'email': '',
    'password': '',
  };
  var _isLoading = false;
  final _passwordController = TextEditingController();
  AnimationController _controller;
  Animation<Offset> _slideAnimation;
  Animation<double> _opacityAnimation, anime;

  bool showPassword1 = false, showPassword2 = false;
  bool isLoading1 = true;
  VideoPlayerController _vcontroller;

  void checkFirstSeen() async {
    final prefs = await SharedPreferences.getInstance();
    bool _seen = (prefs.getBool('seen') ?? false);

    if (!_seen) {
      await prefs.setBool('seen', true);
      await Navigator.push(context, MaterialPageRoute(builder: (context) => IntroScreen()));
    }
    setState(() {
        isLoading1 = false;
    });
  }

  @override
  void initState() {
    super.initState();
    isLoading1 = true;
    _vcontroller = VideoPlayerController.asset(
        'assets/fire.mp4')
      ..initialize().then((_) {
        _vcontroller.play();
        _vcontroller.setLooping(true);
        _vcontroller.setVolume(0.0);
        // Ensure the first frame is shown after the video is initialized
        setState(() {});
      });
    checkFirstSeen();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(
        milliseconds: 300,
      ),
    );
    _slideAnimation = Tween<Offset>(
      begin: Offset(0, -1.5),
      end: Offset(0, 0),
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.fastOutSlowIn,
      ),
    );
    _opacityAnimation = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeIn,
      ),
    );
    anime = Tween(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeIn,
      ),
    );
  }

  void dispose() {
    super.dispose();
    _controller.dispose();
    _vcontroller.dispose();
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('An Error Occurred!'),
        content: Text(message),
        actions: <Widget>[
          FlatButton(
            child: Text('Okay'),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          )
        ],
      ),
    );
  }

  Future<void> _submit(bool googleSignin) async {
    if(googleSignin){
      setState(() {
        _isLoading = true;
      });

      try {
        await Provider.of<Auth>(context,listen: false).googleLogin();
      } on HttpException catch (error) {
        handleError(error);
      } catch (error) {
        const errorMessage = 'Could not authenticate you. Please try again later.';
        _showErrorDialog(errorMessage);
      }

      setState(() {
        _isLoading = false;
      });

      return;
    }
    if (!_formKey.currentState.validate()) {
      // Invalid!
      return;
    }
    _formKey.currentState.save();
    setState(() {
      _isLoading = true;
    });
    try {
      if (_authMode == AuthMode.Login) {
        // Log user in
        await Provider.of<Auth>(context, listen: false).login(
          _authData['email'],
          _authData['password'],
        );
      } else {
        // Sign user up
        await Provider.of<Auth>(context, listen: false).signup(
          _authData['email'],
          _authData['password'],
        );
      }
    } on HttpException catch (error) {
      handleError(error);
    } catch (error) {
       const errorMessage = 'Could not authenticate you. Please try again later.';
      _showErrorDialog(errorMessage);
    }

    setState(() {
      _isLoading = false;
    });
  }

  void handleError(Exception error){
    var errorMessage = 'Authentication failed';
      if (error.toString().contains('EMAIL_EXISTS')) {
        errorMessage = 'This email address is already in use.';
      } else if (error.toString().contains('INVALID_EMAIL')) {
        errorMessage = 'This is not a valid email address';
      } else if (error.toString().contains('WEAK_PASSWORD')) {
        errorMessage = 'This password is too weak.';
      } else if (error.toString().contains('EMAIL_NOT_FOUND')) {
        errorMessage = 'Could not find a user with that email.';
      } else if (error.toString().contains('INVALID_PASSWORD')) {
        errorMessage = 'Invalid password.';
      }
      _showErrorDialog(errorMessage);
  }

  void _switchAuthMode() {
    if (_authMode == AuthMode.Login) {
      setState(() {
        _authMode = AuthMode.Signup;
      });
      _controller.forward();
    } else {
      setState(() {
        _authMode = AuthMode.Login;
      });
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    final bool keyBoardOpen = MediaQuery.of(context).viewInsets.bottom > 0;

    if(isLoading1)
      return SplashScreen();

    else
      return Scaffold(
        body: Stack(
          children: [

            Container(
              height: deviceSize.height - 200,
              color: Colors.blue,
            ),

            AnimatedPositioned(
              duration: Duration(milliseconds: 500),
              curve: Curves.easeOutQuad,
              top: keyBoardOpen ? -deviceSize.height / 3.7 : 0.0,
              child: WaveWidget(
                size: deviceSize,
                yOffset: deviceSize.height/3.0,
                color: Colors.white,
              ),
            ),

            AnimatedPositioned(
              duration: Duration(milliseconds: 300),
              curve: Curves.easeOutQuad,
              top: keyBoardOpen ? -deviceSize.height / 3.7 : 0.0,
              child: Padding(
                padding: const EdgeInsets.only(top: 100.0, left: 66.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                          width: 230,
                          height: 230,
                          child: ClipOval(
                                child: VideoPlayer(_vcontroller)
                              ),
                      ),
                    ],
                  ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(30.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Center(
                  //   child: Container(
                  //       width: 200,
                  //       height: 200,
                  //       child: ClipOval(
                  //         child: VideoPlayer(_vcontroller)
                  //       ),
                  //     ),
                  // ),
                  SizedBox(
                    height: 20,
                  ),
                  Form(
                    key: _formKey,
                    child: SingleChildScrollView(
                      child: Column(
                          children: <Widget>[
                            TextFormField(
                              style: TextStyle(
                                color: Colors.blue,
                                fontSize: 14.0,
                              ),
                              cursorColor: Colors.blue,
                              decoration: InputDecoration(
                                prefixIcon: Icon(
                                  Icons.mail_outline,
                                  size: 18,
                                  color: Colors.blue,
                                ),
                                filled: true,
                                enabledBorder: UnderlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide.none,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(color: Colors.blue),
                                ),
                                labelStyle: TextStyle(color: Colors.blue),
                                focusColor: Colors.blue,
                                labelText: 'E-Mail'
                                ),
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) {
                                if (value.isEmpty || !value.contains('@')) {
                                  return 'Invalid email!';
                                }
                                return null;
                              },
                              onSaved: (value) {
                                _authData['email'] = value;
                              },
                            ),

                            SizedBox(height: 10.0),

                            TextFormField(
                              style: TextStyle(
                                color: Colors.blue,
                                fontSize: 14.0,
                              ),
                              cursorColor: Colors.blue,
                              decoration: InputDecoration(
                                prefixIcon: Icon(
                                  Icons.lock_outline,
                                  size: 18,
                                  color: Colors.blue,
                                ),
                                filled: true,
                                enabledBorder: UnderlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide.none,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(color: Colors.blue),
                                ),
                                suffixIcon: GestureDetector(
                                  onTap: (){
                                    setState(() {
                                         showPassword1 = !showPassword1;                             
                                    });
                                  },
                                  child: Icon(
                                    showPassword1 ? Icons.visibility : Icons.visibility_off,
                                    size: 18,
                                    color: Colors.blue,
                                  ),
                                ),
                                labelStyle: TextStyle(color: Colors.blue),
                                focusColor: Colors.blue,
                                labelText: 'Password'
                              ),
                              obscureText: !showPassword1,
                              controller: _passwordController,
                              validator: (value) {
                                if (value.isEmpty || value.length < 5) {
                                  return 'Password is too short!';
                                }
                                return null;
                              },
                              onSaved: (value) {
                                _authData['password'] = value;
                              },
                            ),

                            SizedBox(height: 10.0),

                            AnimatedContainer(
                              constraints: BoxConstraints(
                                minHeight: _authMode == AuthMode.Signup ? 60 : 0,
                                maxHeight: _authMode == AuthMode.Signup ? 120 : 0,
                              ),
                              duration: Duration(milliseconds: 300),
                              curve: Curves.easeIn,
                              child: FadeTransition(
                                opacity: _opacityAnimation,
                                child: SlideTransition(
                                  position: _slideAnimation,
                                  child: TextFormField(
                                    enabled: _authMode == AuthMode.Signup,
                                    style: TextStyle(
                                      color: Colors.blue,
                                      fontSize: 14.0,
                                    ),
                                    cursorColor: Colors.blue,
                                    decoration: InputDecoration(
                                      prefixIcon: Icon(
                                        Icons.lock_outline,
                                        size: 18,
                                        color: Colors.blue,
                                      ),
                                      filled: true,
                                      enabledBorder: UnderlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: BorderSide.none,
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: BorderSide(color: Colors.blue),
                                      ),
                                      suffixIcon: GestureDetector(
                                        onTap: (){
                                          setState(() {
                                                showPassword2 = !showPassword2;                                  
                                          });
                                        },
                                        child: Icon(
                                          showPassword2 ? Icons.visibility : Icons.visibility_off,
                                          size: 18,
                                          color: Colors.blue,
                                        ),
                                      ),
                                      labelStyle: TextStyle(color: Colors.blue),
                                      focusColor: Colors.blue,
                                      labelText: 'Confirm Password'
                                    ),
                                    obscureText: !showPassword2,
                                    validator: _authMode == AuthMode.Signup
                                        ? (value) {
                                            if (value != _passwordController.text) {
                                              return 'Passwords do not match!';
                                            }
                                            return null;
                                          }
                                        : null,
                                  ),
                                ),
                              ),
                            ),
                            
                            SizedBox(
                              height: 10,
                            ),

                            // if(_authMode == AuthMode.Login)
                              AnimatedContainer(
                                constraints: BoxConstraints(
                                minHeight: _authMode == AuthMode.Login ? 40 : 0,
                                maxHeight: _authMode == AuthMode.Login ? 50 : 0,
                              ),
                              duration: Duration(milliseconds: 300),
                              curve: Curves.easeIn,
                                child: FadeTransition(
                                  opacity: anime,
                                  child: Container(
                                    decoration: BoxDecoration(
                                                  color: Colors.blue,
                                                  borderRadius: BorderRadius.circular(10)
                                    ),
                                    child: InkWell(
                                      onTap: () => _submit(true),
                                      child: Ink(
                                        color: Colors.white,
                                        child: Padding(
                                            padding: EdgeInsets.all(6),
                                            child: Wrap(
                                              crossAxisAlignment: WrapCrossAlignment.center,
                                              children: [
                                                Container(
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius: BorderRadius.circular(10)
                                                  ),
                                                  padding: EdgeInsets.all(2),
                                                  child: Image.asset(
                                                    'assets/images/search.png',
                                                     height: 28,
                                                     width: 28,
                                                  ),
                                                ),
                                                SizedBox(width: 12),
                                                Text(
                                                  ' Sign in with Google',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 16.0,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                            SizedBox(
                              height: 10,
                            ),

                            if (_isLoading)
                              CircularProgressIndicator()
                            else
                              Material(
                                child: Ink(
                                  decoration: BoxDecoration(
                                    color: Colors.blue,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.fromBorderSide(BorderSide.none),
                                  ),
                                  child: InkWell(
                                    onTap: () => _submit(false),
                                    borderRadius: BorderRadius.circular(10),
                                    child: Container(
                                      height: 60.0,
                                      child: Center(
                                        child: Text(
                                          _authMode == AuthMode.Login ? 'LOGIN' : 'SIGN UP',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,fontSize: 16.0,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              // RaisedButton(
                              //   child:
                              //       Text(_authMode == AuthMode.Login ? 'LOGIN' : 'SIGN UP'),
                              //   onPressed: () => _submit(false),
                              //   shape: RoundedRectangleBorder(
                              //     borderRadius: BorderRadius.circular(30),
                              //   ),
                              //   padding:
                              //       EdgeInsets.symmetric(horizontal: 30.0, vertical: 8.0),
                              //   color: Theme.of(context).primaryColor,
                              //   textColor: Theme.of(context).primaryTextTheme.button.color,
                              // ),
                            SizedBox(
                              height: 10,
                            ),
                            // Material(
                            //     child: Ink(
                            //       decoration: BoxDecoration(
                            //         color: Colors.white,
                            //         borderRadius: BorderRadius.circular(10),
                            //         border: Border.all(color: Colors.blue, width: 1.0),
                            //       ),
                            //       child: InkWell(
                            //         onTap: _switchAuthMode,
                            //         borderRadius: BorderRadius.circular(10),
                            //         child: Container(
                            //           height: 60.0,
                            //           child: Center(
                            //             child: Text(
                            //               '${_authMode == AuthMode.Login ? 'SIGNUP' : 'LOGIN'} INSTEAD',
                            //               style: TextStyle(
                            //                 color: Colors.blue,
                            //                 fontWeight: FontWeight.w600,fontSize: 16.0,
                            //               ),
                            //             ),
                            //           ),
                            //         ),
                            //       ),
                            //     ),
                            //   ),
                            FlatButton(
                              child: Text(
                                  '${_authMode == AuthMode.Login ? 'SIGNUP' : 'LOGIN'} INSTEAD'),
                              onPressed: _switchAuthMode,
                              padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 4),
                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              textColor: Colors.blue,
                            ),
                          ],
                        ),
                    ),
                  ),
                ],
                ),
            ),
          ],
        ),
      );
  }
}
