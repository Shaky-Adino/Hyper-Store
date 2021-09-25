import 'package:video_player/video_player.dart';
import 'package:flutter/material.dart';

class IntroScreen extends StatefulWidget {
  @override
  _IntroScreenState createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  VideoPlayerController _controller;

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
      backgroundColor: const Color(0xffffde59),
        body: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  width: 300,
                  height: 300,
                  child: ClipOval(
                    child: VideoPlayer(_controller)
                  ),
                  margin: EdgeInsets.all(10.0),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(1000)),
                  ),
                ),

                const SizedBox(height: 20),
                
                const Text(
                  'Welcome to Hyper Store !',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.black, fontSize: 28),
                ),

                const SizedBox(height: 20),

                const Text(
                  'A one-stop portal for all your needs\nDiscover your favourite place',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.black, fontSize: 16),
                ),

                const SizedBox(height: 30),

                Container(
                    padding: EdgeInsets.symmetric(vertical: 0, horizontal: 40),
                    child: MaterialButton(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      elevation: 8.0,
                      height: 50,
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      color: Colors.black,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          const Text('Get Started ',
                              style: TextStyle(color: Color(0xffffde59), fontSize: 20)),
                          const Icon(Icons.arrow_forward_ios)
                        ],
                      ),
                      textColor: const Color(0xffffde59),
                    ),
                  ),
              ],
            ),
      );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}