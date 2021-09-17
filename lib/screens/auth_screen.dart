import 'dart:io';
import 'dart:ui';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import './forgot_password.dart';
import '../widgets/pickers/user_image_picker.dart';
import '../helpers/scale_route.dart';

import '../widgets/wave_widget.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shopapp/screens/splash_screen.dart';
import './intro_screen.dart';
import '../providers/auth.dart';
import '../models/http_exception.dart';

enum AuthMode { Signup, Login }

class AuthScreen extends StatefulWidget {
  static const routeName = '/auth-screen';
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with SingleTickerProviderStateMixin{
  final GlobalKey<FormState> _formKey = GlobalKey();
  AuthMode _authMode = AuthMode.Login;
  bool flag = false;
  Map<String, String> _authData = {
    'email': '',
    'password': '',
  };
  String username;
  File _userImageFile;
  var _isLoading = false;
  final _passwordController = TextEditingController();
  AnimationController _controller;
  Animation<Offset> _slideAnimation, _slideAnimation2;
  Animation<double> _opacityAnimation, anime;

  bool showPassword1 = false, showPassword2 = false;
  bool isLoading1 = false;
  VideoPlayerController _vcontroller;

  // void checkFirstSeen() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   bool _seen = (prefs.getBool('seen') ?? false);

  //   if (!_seen) {
  //     await prefs.setBool('seen', true);
  //     Navigator.push(context,SlideRightRoute(page: IntroScreen()));
  //   }
  //   setState(() {
  //       isLoading1 = false;
  //   });
  // }

  void _pickedImage(File image) {
    _userImageFile = image;
  }
  
  void setStateIfMounted(f) {
    if (mounted) setState(f);
  }

  @override
  void initState() {
    flag = false;
    super.initState();
    // isLoading1 = true;
    _vcontroller = VideoPlayerController.asset(
        'assets/fire.mp4')
      ..initialize().then((_) {
        _vcontroller.play();
        _vcontroller.setLooping(true);
        _vcontroller.setVolume(0.0);
        // Ensure the first frame is shown after the video is initialized
        setState(() {});
      });
    // checkFirstSeen();
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
    _slideAnimation2 = Tween<Offset>(
      begin: Offset(0, 1.5),
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
    _controller.dispose();
    _vcontroller.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text('An Error Occurred!'),
        content: Text(message),
        actions: <Widget>[
          FlatButton(
            child: Text('Okay', style: TextStyle(color: Colors.black),),
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
      setStateIfMounted(() {
        _isLoading = true;
      });

      try {
        await Provider.of<Auth>(context,listen: false).newgoogleLogin();
      } on HttpException catch (error) {
        handleError(error);
      } catch (error) {
        const errorMessage = 'Could not authenticate you. Please try again later.';
        _showErrorDialog(errorMessage);
      }

      setStateIfMounted(() {
        _isLoading = false;
      });

      return;
    }

    if(_userImageFile == null && _authMode == AuthMode.Signup){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please pick an image', textAlign: TextAlign.center),
          backgroundColor: Theme.of(context).errorColor,
        ),
      );
      return;
    }

    if (!_formKey.currentState.validate()) {
      // Invalid!
      return;
    }
    _formKey.currentState.save();
    setStateIfMounted(() {
      _isLoading = true;
    });
    try {
      if (_authMode == AuthMode.Login) {
        // Log user in
        await Provider.of<Auth>(context,listen: false).newlogin(
          _authData['email'].trim(),
          _authData['password'].trim(),
        );
      } else {
        // Sign user up
        await Provider.of<Auth>(context,listen: false).newsignUp(
          username.trim(),
          _userImageFile,
          _authData['email'].trim(),
          _authData['password'].trim(),
        );
      }
    } on HttpException catch (error) {
      handleError(error);
    } catch (error) {
      print(error);
       const errorMessage = 'Could not authenticate you. Please try again later.';
      _showErrorDialog(errorMessage);
    }

    setStateIfMounted(() {
      _isLoading = false;
    });
  }

  void handleError(Exception error){
    // var errorMessage = 'Authentication failed';
    //   if (error.toString().contains('EMAIL_EXISTS')) {
    //     errorMessage = 'This email address is already in use.';
    //   } else if (error.toString().contains('INVALID_EMAIL')) {
    //     errorMessage = 'This is not a valid email address';
    //   } else if (error.toString().contains('WEAK_PASSWORD')) {
    //     errorMessage = 'This password is too weak.';
    //   } else if (error.toString().contains('EMAIL_NOT_FOUND')) {
    //     errorMessage = 'Could not find a user with that email.';
    //   } else if (error.toString().contains('INVALID_PASSWORD')) {
    //     errorMessage = 'Invalid password.';
    //   }
    _showErrorDialog(error.toString());
  }

  void _switchAuthMode() {
    if (_authMode == AuthMode.Login) {
      setStateIfMounted(() {
        _authMode = AuthMode.Signup;
      });
      _controller.forward();
    } else {
      setStateIfMounted(() {
        _authMode = AuthMode.Login;
      });
      _controller.reverse();
    }
  }

  @override
    void didChangeDependencies() {
      if(flag)
      {
        _vcontroller.play();
      _vcontroller.setLooping(true);
      }
      flag = true;
      super.didChangeDependencies();
    }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    final bool keyBoardOpen = MediaQuery.of(context).viewInsets.bottom > 0;

    if(isLoading1)
      return SplashScreen();

    else
      return GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Scaffold(
          body: Stack(
            children: [

              Container(
                height: deviceSize.height - 400,
                color: Colors.yellow,
              ),

              AnimatedPositioned(
                duration: Duration(milliseconds: 500),
                curve: Curves.easeOutQuad,
                top: keyBoardOpen ? -deviceSize.height / 3.5 : 0.0,
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
                            decoration: BoxDecoration(borderRadius: BorderRadius.circular(1000)),
                            child: ClipOval(
                                    child: VideoPlayer(_vcontroller)
                                  ),
                        ),
                      ],
                    ),
                ),
              ),

              Container(
                margin: keyBoardOpen ? EdgeInsets.only(top: deviceSize.height/16) : EdgeInsets.only(top: deviceSize.height/3),
                padding: const EdgeInsets.fromLTRB(30.0, 25.0, 30.0, 8.0),
                child: SizedBox(
                  height: 500,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      SizedBox(),
                      Flexible(
                        child: Form(
                          key: _formKey,
                          child: SingleChildScrollView(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
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
                                        position: _slideAnimation2,
                                        child: UserImagePicker(_pickedImage)
                                        ),
                                    ),
                                  ),

                                  SizedBox(height: 10),
                                  
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
                                        position: _slideAnimation2,
                                        child: TextFormField(
                                          enabled: _authMode == AuthMode.Signup,
                                          style: TextStyle(
                                            fontSize: 14.0,
                                          ),
                                          decoration: InputDecoration(
                                            prefixIcon: Icon(
                                              Icons.account_circle,
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
                                            labelText: 'Username'
                                          ),
                                          validator: _authMode == AuthMode.Signup
                                              ? (value) {
                                                  if (value.isEmpty || value.length < 3) {
                                                    return 'username is too short!!';
                                                  }
                                                  if(value.contains(' ')){
                                                    return 'no spaces allowed';
                                                  }
                                                  return null;
                                                }
                                              : null,
                                          onSaved: (value){
                                            username = value;
                                          },
                                        ),
                                      ),
                                    ),
                                  ),

                                  SizedBox(height: 5,),

                                  TextFormField(
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
                                      _authData['email'] = value;
                                    },
                                  ),

                                  SizedBox(height: 10.0),

                                  TextFormField(
                                    style: TextStyle(
                                      fontSize: 14.0,
                                    ),
                                    decoration: InputDecoration(
                                      prefixIcon: Icon(
                                        Icons.vpn_key,
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
                                      suffixIcon: GestureDetector(
                                        onTap: (){
                                          setStateIfMounted(() {
                                               showPassword1 = !showPassword1;                             
                                          });
                                        },
                                        child: Icon(
                                          showPassword1 ? Icons.visibility : Icons.visibility_off,
                                          size: 18,
                                          color: Colors.black,
                                        ),
                                      ),
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

                                if(_authMode == AuthMode.Login)
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      TextButton(
                                        onPressed: (){
                                          Navigator.push(
                                            context, 
                                            MaterialPageRoute(builder: (context) => ForgotPassword())
                                          );
                                        }, 
                                        style: TextButton.styleFrom(
                                          padding: EdgeInsets.zero,
                                        ),
                                        child: Text('Forgot password?', style: TextStyle(color: Colors.blue))
                                      )
                                    ],
                                  ),

                                  if(_authMode == AuthMode.Signup)
                                    SizedBox(height: 10),

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
                                            fontSize: 14.0,
                                          ),
                                          decoration: InputDecoration(
                                            prefixIcon: Icon(
                                              Icons.vpn_key,
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
                                            suffixIcon: GestureDetector(
                                              onTap: (){
                                                setStateIfMounted(() {
                                                    showPassword2 = !showPassword2;                                  
                                                });
                                              },
                                              child: Icon(
                                                showPassword2 ? Icons.visibility : Icons.visibility_off,
                                                size: 18,
                                                color: Colors.black,
                                              ),
                                            ),
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
                                                        color: Colors.yellow,
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

                                if(_authMode == AuthMode.Login)
                                  SizedBox(
                                    height: 10,
                                  ),

                                  if (_isLoading)
                                    CircularProgressIndicator()
                                  else
                                    Material(
                                      child: Ink(
                                        decoration: BoxDecoration(
                                          color: Colors.yellow,
                                          borderRadius: BorderRadius.circular(10),
                                          border: Border.fromBorderSide(BorderSide.none),
                                        ),
                                        child: InkWell(
                                          onTap: () => _submit(false),
                                          borderRadius: BorderRadius.circular(10),
                                          child: Container(
                                            height: 50.0,
                                            child: Center(
                                              child: Text(
                                                _authMode == AuthMode.Login ? 'LOGIN' : 'SIGN UP',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w600,fontSize: 16.0,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  SizedBox(
                                    height: 7,
                                  ),
                                  FlatButton(
                                    child: Text(
                                        '${_authMode == AuthMode.Login ? 'SIGNUP' : 'LOGIN'} INSTEAD',
                                        style: TextStyle(fontWeight: FontWeight.w800),
                                        ),
                                    onPressed: _switchAuthMode,
                                    padding: EdgeInsets.symmetric(horizontal: 30.0),
                                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    // textColor: Colors.yellow,
                                  ),
                                ],
                              ),
                          ),
                        ),
                      ),
                    ],
                    ),
                ),
              ),
            ],
          ),
        ),
      );
  }
}
