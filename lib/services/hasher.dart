import 'package:crypto/crypto.dart';
import 'dart:convert';

class Hasher {
  
  String createChatID (String user, String recipient) {
    var bytes;
    if (recipient == 'Family Group'){
      bytes = utf8.encode('all');
    }
    else{
      bytes = user.compareTo(recipient) > 0? utf8.encode(recipient+user) :  utf8.encode(user+recipient);
    }

    return sha1.convert(bytes).toString();
    
  }

  String createMessageID(String convID){
    String now = DateTime.now().toUtc().toString();

    return convID+now;
  }
}
