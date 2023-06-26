import 'package:flash_chat/screens/contacts_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../utilities/action_button.dart';
import '../utilities/info_field.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import '../constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegistrationScreen extends StatefulWidget {
  static const String id = 'register';
  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  String? email;
  String? password;
  bool showSpinner = false;
  String errorMessage = '';
  InputDecoration decoration = kInputDecoration;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ModalProgressHUD(
        blur: 0.6,
        inAsyncCall: showSpinner,
        progressIndicator: CupertinoActivityIndicator(),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Flexible(
                child: Hero(
                  tag: 'logo',
                  child: Container(
                    height: 200.0,
                    child: Image.asset('images/logo.png'),
                  ),
                ),
              ),
              SizedBox(
                height: 23.0,
              ),
              errorMessage.isNotEmpty ? Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: Text(
                  errorMessage,
                  style: TextStyle(color:Colors.redAccent),
                  textAlign: TextAlign.center,
                ),
              ) : SizedBox(
                height: 25,
              ),
              InfoField(
                decoration: decoration.copyWith(
                  hintText: 'Enter your email',
                ),
                onChanged: (value) {
                  email = value;
                },
                keyboard: TextInputType.emailAddress,
              ),
              SizedBox(
                height: 8.0,
              ),
              InfoField(
                decoration: decoration.copyWith(
                  hintText: 'Enter your password',
                ),
                onChanged: (value) {
                  password = value;
                },
                obscureText: true,
              ),
              SizedBox(
                height: 24.0,
              ),
              ActionButton(
                  buttonColor: Colors.blueAccent,
                  onPressed: () async {
                    try {
                      setState(() {
                        showSpinner = true;
                      });
                      final newUser =
                          await _auth.createUserWithEmailAndPassword(
                              email: email!, password: password!);
                      _firestore.collection('users').add({
                            'email' : email,
                      });
                      if (newUser != null) {
                        Navigator.pushNamed(context, ContactsScreen.id);
                      }
                      setState(() {
                        showSpinner = false;
                        errorMessage = '';
                        decoration = kInputDecoration;
                      });
                    } catch (e) {
                      setState(() {
                        showSpinner = false;
                        errorMessage = e.toString();
                        decoration = kInputErrorDecoration;
                      });
                    }
                  },
                  buttonText: 'Register'),
            ],
          ),
        ),
      ),
    );
  }
}
