import 'package:flash_chat/screens/contacts_screen.dart';
import 'package:flutter/material.dart';
import 'package:flash_chat/screens/welcome_screen.dart';
import 'package:flash_chat/screens/login_screen.dart';
import 'package:flash_chat/screens/registration_screen.dart';
import 'package:flash_chat/screens/chat_screen.dart';
import 'package:device_preview/device_preview.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() => runApp(
    //DevicePreview(builder: (context) => FlashChat())
    FlashChat());

class FlashChat extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        ),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
          } else if (snapshot.connectionState == ConnectionState.done) {
            return MaterialApp(
              //locale: DevicePreview.locale(context),
              //builder: DevicePreview.appBuilder,
              initialRoute: WelcomeScreen.id,
              routes: {
                LoginScreen.id: (context) => LoginScreen(),
                RegistrationScreen.id: (context) => RegistrationScreen(),
                WelcomeScreen.id: (context) => WelcomeScreen(),
                ChatScreen.id: (context) => ChatScreen(),
                ContactsScreen.id: (context) => ContactsScreen(),
              },
            );
          }
          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
            ),
            //constraints: BoxConstraints.expand(),
            child: Center(
              child: Container(
                child: Image.asset('images/logo.png'),
                //height: 200,
              ),
            ),
          );
        });
  }
}
