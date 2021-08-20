import 'package:video_player/video_player.dart';
import 'package:flutter/material.dart';

class IntroScreen extends StatefulWidget {
  @override
  _IntroScreenState createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  VideoPlayerController _controller;
  static Color logoGreen = Color(0xff25bcbb);

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset(
        'assets/fire.mp4')
      ..initialize().then((_) {
        _controller.play();
        _controller.setLooping(true);
        _controller.setVolume(0.0);
        // Ensure the first frame is shown after the video is initialized
        setState(() {});
      });
  }

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
        body: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  width: 400,
                  height: 400,
                  child: VideoPlayer(_controller),
                  margin: EdgeInsets.all(10.0),
                  decoration: BoxDecoration(shape: BoxShape.circle),
                ),
                SizedBox(
                  height: 20,
                ),
                //Texts and Styling of them
                Text(
                  'Welcome to Hyper Store !',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontSize: 28),
                ),
                SizedBox(height: 20),
                Text(
                  'A one-stop portal for you to learn the latest technologies from SCRATCH',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                SizedBox(
                  height: 30,
                ),
                //Our MaterialButton which when pressed will take us to a new screen named as 
                //LoginScreen
                MaterialButton(
                  elevation: 0,
                  height: 50,
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  color: logoGreen,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text('Get Started ',
                          style: TextStyle(color: Colors.white, fontSize: 20)),
                      Icon(Icons.arrow_forward_ios)
                    ],
                  ),
                  textColor: Colors.white,
                )
              ],
            ),
      );
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }
}