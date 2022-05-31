// import 'dart:html';

import 'package:intl/intl.dart';
import 'package:badges/badges.dart';
import '../../services/database.dart';
import '../../helper/constants.dart';
import '../../helper/helperfunctions.dart';
import '../../services/auth.dart';
import '../chat.dart';
import '../../transition/enterexitroute.dart';
// import 'linepainter.dart';
import 'package:flutter/material.dart';

class ChatRoomsTile extends StatefulWidget {
  final String userName;
  final String chatRoomId;
  final DateTime endDateTime;
  final List<dynamic> deviceToken;
  final Widget exitPage;
  
  Stream latestChat;
  String patientId;
  ChatRoomsTile({required this.userName, required this.chatRoomId, required this.endDateTime, required this.deviceToken, required this.exitPage, required this.latestChat, required this.patientId,});

@override
  _ChatRoomsTileState createState() => _ChatRoomsTileState();
}

class _ChatRoomsTileState extends State<ChatRoomsTile> {
  var mainPurple = const Color(0xFF512c7c);
  var messagecount =0 ;
  Stream latestChat = null as Stream;
  Stream unreadmessage = null as Stream;
  var data;
  var profilephoto;
  bool _isloading = true;
  var datesent=null;
  @override
  void initState() {
    super.initState();
    getLastMessage(widget.chatRoomId);
    getpatientphoto(widget.patientId);
    unreadchat();
  }

  getpatientphoto(patientId){
    DatabaseMethods().getPatientInfo(patientId).then((_data){
      setState(() {
        data = _data.docs;
        profilephoto = data[0].data['profilePhoto'];
      });
    });
  }

  getLastMessage(chatRoomId) async{
    DatabaseMethods().getLastChats(chatRoomId).then((snapshot){
      setState(() {
          latestChat = snapshot;
      });            
  });

  
    setState(() {
        _isloading = false;
      });
  }

    
  Widget lastMessage(){
    // print("Constants.myName ${Constants.myName}");
    // print("chatRoomId ${widget.chatRoomId}");
      return StreamBuilder(
      stream: latestChat,
      builder: (context, AsyncSnapshot snapshot) {
        bool isYou = false;
        bool isRead = false;
        if(snapshot.connectionState == ConnectionState.active){
            if(snapshot.data.docs.length > 0){
              isRead = snapshot.data.docs[0].data["isRead"]??false;
              isYou = Constants.myId == snapshot.data.docs[0].data["sendByUserId"];
              datesent = snapshot.data.docs[0].data["dateSent"].toDate()??null;
              return Row(children: <Widget>[
                isYou && isRead ? new Icon(
                  Icons.done_all,
                  color: Colors.blue,
                  size: 16.0,
                ):Text(''), 
                isYou && !isRead ? new Icon(
                  Icons.done_all,
                  color: Colors.grey,
                  size: 16.0,
                ):Text(''),
                SizedBox(width: 5,),
                Expanded(child:Text(snapshot.data.docs[0].data["message"]??'',textAlign: TextAlign.start,maxLines: 1,overflow: TextOverflow.ellipsis,style:TextStyle(color: Colors.grey))),
              ],);
              }
              else{
                return Text('',textAlign: TextAlign.start,style:TextStyle(color: Colors.grey),);
              }
        }
        else{
          return Text('');
        }
        
      });
  }

  Widget countunreadmessage(){
      return StreamBuilder(
      stream: unreadmessage,
      builder: (context, AsyncSnapshot snapshot) {
        if(snapshot.connectionState == ConnectionState.active){
          var length = snapshot.data.docs.length;
          messagecount = length;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              datesent != null ? Text(
                  new DateFormat('jm').format(datesent),
                  style: TextStyle(
                    fontSize: 12.0,
                    color:  const Color(0xffb9a6cf) ,
                  ),
                ):Text(''),
            if(length != 0)...[
               Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(12.0)),
                    color: const Color(0xffb9a6cf),
                  ),
                  width: 24.0,
                  height: 24.0,
                  alignment: Alignment.center,
                  margin: EdgeInsets.only(right: 4.0, top: 4.0),
                  child: Text(
                      '${length}'"",
                    style: TextStyle(color: Colors.white),
                  ),
                )
              ],
          ]);
          }
          else{
            return Text('');
          }
        }
        );
  }

  

  Widget checkLastmessage(){
    if(latestChat != null ){
      return lastMessage();
    }
    else{
      return Text("");
    }
  }

  unreadchat()async {
    await DatabaseMethods().getunreadchats(widget.chatRoomId,widget.patientId).then((snapshot)  {
        setState(()  {
          unreadmessage = snapshot;
        });
    });
  }

  gotochat(){
        Navigator.push(context,EnterExitRoute( enterPage: Chat(
            chatRoomId: widget.chatRoomId,
            userName: widget.userName,
            endDateTime:widget.endDateTime,
            deviceToken: widget.deviceToken,
            profilephoto:profilephoto,
            patientId: widget.patientId,
          ), exitPage: widget.exitPage,));
  }
  
  Widget patientimage(){
    return Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    boxShadow: [ 
                            BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 1,
                            blurRadius: 1,
                            offset: new Offset(0.0,0.0), // changes position of shadow
                        ),
                      ],
                  shape: BoxShape.rectangle,
                  borderRadius: new BorderRadius.all(Radius.circular(10.0)),
                  border: Border.all(width: 1.0, color: const Color(0xFFFFFFFF)),
                  image: DecorationImage(
                    image: profilephoto != null && profilephoto != "" ? NetworkImage(profilephoto): AssetImage('assets/icon/default-profile.png') as ImageProvider,
                    fit: BoxFit.fill
                  ),
                  ),
                );
  }
  @override
  Widget build(BuildContext context) {
    var _width = MediaQuery.of(context).size.width;
    var _height = MediaQuery.of(context).size.height;
    return Container(
   padding: EdgeInsets.fromLTRB(10,0,10,0),
   margin: EdgeInsets.fromLTRB(1,0,0,5),
   decoration: BoxDecoration(
          boxShadow: [ 
                            BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 1,
                            blurRadius: 2,
                            offset: new Offset(-5.0, 0), // changes position of shadow
                        ),
                      ],
          color:  Colors.white,),
   height: _height*0.1,
   width: _width,
   child: ListTile(
        contentPadding: EdgeInsets.symmetric(vertical: 2.0, horizontal: 16.0),
        leading: GestureDetector(
          onTap: () {
            // onTapProfile();
          },
          child: messagecount != 0 ?
          Badge(
            position: BadgePosition.topStart(top: 0, start: -5),
            badgeColor: Colors.green,
            badgeContent: Text('',
              style: TextStyle(color: Colors.white),
            ),
            child:patientimage(),):patientimage(),
        ),
            title:Text(
                widget.userName,
                maxLines: 1,
                style: TextStyle(
                  color: mainPurple,
                  fontSize: 16.0,
                  // fontWeight: FontWeight.bold,
                ),
              ),
        subtitle: checkLastmessage(), 
        trailing: countunreadmessage(),
        onTap: gotochat,
      ),
      );
    // return GestureDetector(
    //   onTap: (){
    //     Navigator.push(context,EnterExitRoute( enterPage: Chat(
    //         chatRoomId: widget.chatRoomId,
    //         userName: widget.userName,
    //         endDateTime:widget.endDateTime,
    //         deviceToken: widget.deviceToken,
    //       ),));
    //   },
    //   child: Container(
    //     margin: EdgeInsets.symmetric(horizontal:1,vertical:1,),
    //     color: Colors.black26,
    //     padding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
    //     child: Row(
    //       children: [
    //         Container(
    //           height: 40,
    //           width: 40,
    //           decoration: BoxDecoration(
    //               color: Colors.blue,
    //               borderRadius: BorderRadius.circular(30),
    //               image:  DecorationImage(
    //                     image: profilephoto != null ? NetworkImage(profilephoto):NetworkImage(''),
    //                     fit: BoxFit.cover)
    //                     ,),
    //           child: profilephoto == null ? Text(widget.userName.substring(0, 1),
    //               textAlign: TextAlign.center,
    //               style: TextStyle(
    //                   color: Colors.white,
    //                   fontSize: 40,
    //                   fontFamily: 'OverpassRegular',
    //                   fontWeight: FontWeight.w300)) :Container(),
    //         ),
    //         SizedBox(
    //           width: 12,
    //         ),
    //         Column(
    //           mainAxisAlignment:MainAxisAlignment.start,
    //           crossAxisAlignment: CrossAxisAlignment.start,
    //           children: <Widget>[
    //           Text(widget.userName,
    //             textAlign: TextAlign.start,
    //             style: TextStyle(
    //                 color: Colors.white,
    //                 fontSize: 16,
    //                 fontFamily: 'OverpassRegular',
    //                 fontWeight: FontWeight.w300)),
    //           checkLastmessage(),
              
    //         ],),
    //       ],
    //     ),
    //   ),
    // );
  }
}