import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';

class FirebaseMessagingTest extends StatefulWidget {
  
  @override
  FirebaseMessagingTestState createState() => FirebaseMessagingTestState();
}

class FirebaseMessagingTestState extends State<FirebaseMessagingTest>{
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  late List<Message> messagesList;
 
  _getToken(){
    _firebaseMessaging.getToken().then((devivetoken){
      print('Device token : $devivetoken');
    });
  }

_configureFirebaseListeners() {
    FirebaseMessaging.onMessage.listen(
       (RemoteMessage message) async {
          print('onMessage: $message');
          _setMessage(message.data);
       },
    );
    FirebaseMessaging.onMessage.listen(
          (RemoteMessage message) async {
        print('onLaunch: $message');
        _setMessage(message.data);
      },
    );
    FirebaseMessaging.onMessage.listen(
          (RemoteMessage message) async {
        print('onResume: $message');
        _setMessage(message.data);
      },
    );
    _firebaseMessaging.requestPermission(sound: true, badge: true, alert: true);
}
 
_setMessage(Map<String, dynamic> message) {
    final notification = message['notification'];
    final data = message['data'];
    final String title = notification['title'];
    final String body = notification['body'];
    String mMessage = data['message'];
    print("Title: $title, body: $body, message: $mMessage");
    setState(() {
      Message msg = Message(title, body, mMessage);
      messagesList.add(msg);
    });
}

  @override
  void initState() {
    super.initState();
    Firebase.initializeApp();
    messagesList = <Message>[];
    _getToken();
    _configureFirebaseListeners();

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Firebase Notification Test"),
      ),
      body: ListView.builder(
        itemCount: null == messagesList ? 0 : messagesList.length,
        itemBuilder: (BuildContext context, int index) {
          return Card(
            child: Padding(
              padding: EdgeInsets.all(10.0),
              child: Text(
                messagesList[index].message,
                style: TextStyle(
                  fontSize: 16.0,
                  color: Colors.black,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

}

class Message {
  String? title;
  String? body;
  late String message;
  Message(title, body, message) {
    this.title = title;
    this.body = body;
    this.message = message;
  }
}