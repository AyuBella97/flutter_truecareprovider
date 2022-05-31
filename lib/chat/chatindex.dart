import 'package:TrueCare2u_flutter/chat/chatroom.dart';
import 'package:TrueCare2u_flutter/freshchat/freschat.dart';
import 'package:flutter/material.dart';


class ChatIndex extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            bottom: TabBar(
              tabs: [
                Tab(icon: Icon(Icons.message)),
                Tab(icon: Icon(Icons.notifications)),
              ],
            ),
            title: Text('Messages'),
            centerTitle: true,
          ),
          body: TabBarView(
            children: [
              FreshChat(),
              ChatRoom(),
              // Icon(Icons.directions_transit),
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.center,
              //   crossAxisAlignment: CrossAxisAlignment.center,
              //   children: <Widget>[
              //   Icon(Icons.notifications),
              //   Center(child:Text("No notifications")),
              // ],)
            ],
          ),
        ),
    );
  }
}