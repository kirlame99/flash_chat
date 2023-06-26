import 'package:flash_chat/screens/registration_screen.dart';
import 'package:flutter/material.dart';
import 'login_screen.dart';
import '../utilities/action_button.dart';
import 'dart:core';


class WelcomeScreen extends StatefulWidget {
  static const String id = 'welcome';

  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  AnimationController? controller;
  Animation? animation;
  Animation? colorAnimation;
  String appName = "Flash Chat_";
  AnimationStatus? animStatus;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    controller = AnimationController(
      vsync: this,
      //duration: Duration(seconds: 2),
    );

    animation = CurvedAnimation(
      parent: controller!,
      curve: Curves.linearToEaseOut,
    );

    colorAnimation = ColorTween(
      begin: Colors.grey,
      end: Colors.white,
    ).animate(controller!);

    controller!.repeat(reverse: true, period: Duration(seconds:3));

    controller!.addStatusListener((status) {
      animStatus = status;
      if (status==AnimationStatus.completed){
        
      }
    });

    controller!.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    controller!.dispose();
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double animValue = animation!.value.toDouble();
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              children: <Widget>[
                Hero(
                  tag: 'logo',
                  child: Container(
                    child: Image.asset('images/logo.png'),
                    height: 80,
                  ),
                ),
                Text(
                  animStatus == AnimationStatus.completed
                      ? appName.substring(0, appName.length - 1)
                      : '${appName.substring(0, (appName.length * animValue).toInt())}_',
                  style: TextStyle(
                    fontSize: 45.0,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 48.0,
            ),
            ActionButton(
                buttonColor: Colors.lightBlueAccent,
                onPressed: (){
                  Navigator.pushNamed(context, LoginScreen.id);
                },
                buttonText: 'Login'),
            ActionButton(
                buttonColor: Colors.blueAccent,
                onPressed: (){
                  Navigator.pushNamed(context, RegistrationScreen.id);
                },
                buttonText: 'Register'),
          ],
        ),
      ),
    );
  }
}
