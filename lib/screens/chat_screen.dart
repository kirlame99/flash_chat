
import 'package:flash_chat/screens/welcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:flash_chat/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'contacts_screen.dart';
import '../services/hasher.dart';

User? loggedInUser;
Hasher myHasher = Hasher();

class ChatScreen extends StatefulWidget {
  static const String id = 'chat';

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  String messageText = '';
  List<Map> allMessages = [];
  final messageTextController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCurrentUser();
    messagesStream();
  }

  void getCurrentUser() {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        loggedInUser = user;
      }
    } catch (e) {
      print(e);
    }
  }

  void messagesStream() async {
    await for (var snapshot in _firestore.collection(convID!).snapshots()) {
      setState(() {
        allMessages = [for (var message in snapshot.docs) message.data()]
            .reversed
            .toList();
        //allMessages = allMessages.reversed.toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
          child: BackButtonIcon(),
          onTap: () {
            Navigator.pushNamed(context, ContactsScreen.id);
          },
        ),
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                //Implement logout functionality
                _auth.signOut();
                _firestore.terminate();
                Navigator.pushNamed(context, WelcomeScreen.id);
              }),
        ],
        title: Row(
          children: [
            Icon(
              recipient != 'Family Group' ? Icons.person : Icons.group,
              size: 50,
            ),
            SizedBox(width: 10),
            Text(
              recipient!,
              style: TextStyle(
                color: Colors.white,
              ),
            )
          ],
        ),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            allMessages.isNotEmpty
                ? MessageStream(messages: allMessages)
                : Expanded(
                    child: Center(
                      child: Text(
                        'No flashy message (yet!)',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: messageTextController,
                      onChanged: (value) {
                        messageText = value;
                      },
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      messageTextController.clear();
                      DocumentReference<Map> messageConv = _firestore
                          .collection(convID!)
                          .doc(myHasher.createMessageID(convID!));
                      var myJsonMsg = {
                        'sender': loggedInUser!.email,
                        'recipient': recipient,
                        'text': messageText,
                        'time': DateTime.now(),
                      };
                      try {
                        messageConv.set(myJsonMsg);
                      } catch (e) {
                        print(e);
                      }
                    },
                    child: Text(
                      'Send',
                      style: kSendButtonTextStyle,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MessageStream extends StatelessWidget {
  const MessageStream({
    super.key,
    required this.messages,
  });

  final List<Map> messages;

  @override
  Widget build(BuildContext context) {
    bool sentByUser = true;
    return Expanded(
      child: ListView.builder(
        reverse: true,
        itemCount: messages.length,
        itemBuilder: (BuildContext context, int index) {
          if (messages[index]['sender'] == loggedInUser!.email) {
            sentByUser = true;
          } else {
            sentByUser = false;
          }
          return Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
                crossAxisAlignment: sentByUser
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  Text(
                    messages[index]['sender'],
                    textAlign: sentByUser ? TextAlign.right : TextAlign.left,
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  BubbleText(
                      messages: messages, index: index, sentByUser: sentByUser),
                ]),
          );
        },
      ),
    );
  }
}

class BubbleText extends StatelessWidget {
  const BubbleText({
    super.key,
    required this.messages,
    required this.index,
    required this.sentByUser,
  });

  final List<Map> messages;
  final int index;
  final bool sentByUser;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: sentByUser ? Colors.lightBlueAccent : Colors.white,
      borderRadius: sentByUser
          ? BorderRadius.only(
              topLeft: Radius.circular(25),
              bottomLeft: Radius.circular(25),
              bottomRight: Radius.circular(25))
          : BorderRadius.only(
              topRight: Radius.circular(25),
              bottomLeft: Radius.circular(25),
              bottomRight: Radius.circular(25)),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 10,
          horizontal: 15,
        ),
        child: Text(
          messages[index]['text'],
          textAlign: sentByUser ? TextAlign.right : TextAlign.left,
          style: TextStyle(
            color: sentByUser ? Colors.white : Colors.black,
            fontSize: 15,
          ),
        ),
      ),
    );
  }
}
