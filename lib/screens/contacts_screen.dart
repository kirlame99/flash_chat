import 'package:flash_chat/screens/chat_screen.dart';
import 'package:flash_chat/screens/welcome_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flash_chat/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/hasher.dart';

User? loggedInUser;
String? convID;
String? recipient;
Hasher myHasher = Hasher();
List<String> lastMessages = [];
List<String> contactList = [];
bool loading = true;

class ContactsScreen extends StatefulWidget {
  static const String id = 'contacts';

  @override
  _ContactsScreenState createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCurrentUser();
    getContactList();
  }

  void getContactList() async {
    QuerySnapshot<Map> allUsers = await _firestore.collection('users').get();
    contactList = [
      for (var contact in allUsers.docs)
        contact.data()['email'] != loggedInUser!.email
            ? contact.data()['email']
            : ""
    ];
    contactList.removeWhere((element) => element == "");
    contactList.sort((a, b) => a.compareTo(b));
    contactList.insert(0, 'Family Group');
    contactList.insert(1, 'Firebase');
    getLastMessages();
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

  void getLastMessages() async {
    lastMessages = List<String>.filled(contactList.length, '');
    List<Map> lastMessagesMap = List<Map>.filled(contactList.length, {});
    for (int index = 0; index < contactList.length; index++) {
      String convId =
          myHasher.createChatID(loggedInUser!.email!, contactList[index]);
      try {
        var messages = await _firestore.collection(convId).get();
        Map lastMsg = messages.docs.last.data();

        String sender = lastMsg['sender'] == loggedInUser!.email
            ? 'You'
            : lastMsg['sender'];

        lastMessagesMap[index] = {
          'sender': contactList[index],
          'time': lastMsg['time'].toDate(),
          'message': "$sender : ${lastMsg['text']}"
        };
   
      } catch (e) {
        print(e);
        lastMessagesMap[index] = {
          'sender': contactList[index],
          'message': "",
          'time': DateTime.parse("1999-02-27 10:09:00") ,
        };
      }
    }
    lastMessagesMap.sort((a, b) => b['time'].compareTo(a['time']));
    for (int counter = 0; counter < lastMessagesMap.length; counter++) {
      try {
        contactList[counter] = lastMessagesMap[counter]['sender'];
        lastMessages[counter] = lastMessagesMap[counter]['message'];
      } catch (e) {
        contactList[counter] = '';
        lastMessages[counter] = '';
      }
    }
    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                _auth.signOut();
                _firestore.terminate();
                Navigator.pushNamed(context, WelcomeScreen.id);
              }),
        ],
        title: Text('Contacts'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SafeArea(
        child: loading
            ? Center(
                child: CupertinoActivityIndicator(),
              )
            : ListView.builder(
                itemCount: contactList.length,
                itemBuilder: (BuildContext context, int index) {
                  return Container(
                    height: 100,
                    child: ContactTile(contactList: contactList, index: index),
                  );
                },
              ),
      ),
    );
  }
}

class ContactTile extends StatelessWidget {
  const ContactTile({
    super.key,
    required this.contactList,
    required this.index,
  });

  final List<String> contactList;
  final int index;

  @override
  Widget build(BuildContext context) {
    return ListTile(
        leading: Icon(
          contactList[index]=='Family Group' ? Icons.group : Icons.person,
          size: 50,
        ),
        title: Text(
          contactList[index],
          style: kSendButtonTextStyle,
        ),
        subtitle: Text(lastMessages[index]),
        onTap: () {
          recipient = contactList[index];
          convID =
              myHasher.createChatID(loggedInUser!.email!, contactList[index]);
          Navigator.pushNamed(context, ChatScreen.id);
        });
  }
}
