import '../services/database.dart';
import '../helper/constants.dart';
import '../helper/helperfunctions.dart';
import '../services/auth.dart';
import './chat.dart';
import './search.dart';
import 'package:flutter/material.dart';

import 'widgets/chatroomtiles.dart';

class ChatRoom extends StatefulWidget {
  @override
  _ChatRoomState createState() => _ChatRoomState();
}

class _ChatRoomState extends State<ChatRoom> {
  var _width;
  var _height;
  var _orangebutton = const Color(0xFFF47920);
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  late Stream chatRooms;
  bool _isloading = false;
  late Stream latestChat;
  late Widget exitPage;

  @override
  void initState() {
    getUserInfogetChats();
    super.initState();
  }

  Widget chatRoomsList() {
    return StreamBuilder(
      stream: chatRooms,
      builder: (context, snapshot) {
        if(snapshot.connectionState == ConnectionState.waiting){
                  return Container(child:Center(child: CircularProgressIndicator(),));
                } 
        else if(snapshot.connectionState == ConnectionState.active){
                  return streamBuilder(snapshot);
                }              
                return streamBuilder(snapshot);
      },
    );
  }

  removedChat(chatroomid) {
    Map<String,dynamic> mapData = {
      "isRemovedbyCareprovider":true,
    };
    DatabaseMethods().removedChatRoom(chatroomid, mapData);
  }

  Widget streamBuilder(snapshot){
    if(_isloading){
      return Container(child:Center(child: CircularProgressIndicator(),));
    }
    if(snapshot.data.docs.length == 0){
          return Container(child:Center(child: Text("No Active Chat"),));
    }
    else if(snapshot.hasData) {  
      return ListView.builder(
                itemCount: snapshot.data.docs.length,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  final item = snapshot.data.docs[index].data["chatRoomId"];
                  final appointmentId = snapshot.data.docs[index].data["appointmentId"];
                  List<dynamic> deviceToken = snapshot.data.docs[index].data["device_token"];
                  String patientId = snapshot.data.docs[index].data["usersId"][0];
                  return Dismissible(
                    key: Key(item),
                    confirmDismiss: (DismissDirection direction) async {
                        return await showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return Dialog(
                              shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(5.0)), //this right here
                              child: SingleChildScrollView(
                                // height: 200,
                                child: Padding(
                                  padding: const EdgeInsets.all(15.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      SizedBox(height: _height*0.02,),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: <Widget>[
                                        Text("Confirm to remove?",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16),),
                                      ],),
                                      SizedBox(height: _height*0.02,),
                                      Row(
                                        mainAxisAlignment:MainAxisAlignment.start,
                                        children: <Widget>[
                                          Container(
                                            width: _width*0.3,
                                            child: GestureDetector(
                                              onTap: () {
                                                Navigator.of(context).pop();
                                              },
                                              child:  Text("Cancel",style: TextStyle(color: Colors.blue),),
                                            ),
                                          ),
                                          Container(
                                            width: _width*0.38,
                                            child: RaisedButton(
                                              color: _orangebutton,
                                              onPressed: () {
                                                _scaffoldKey.currentState?.showSnackBar(SnackBar(content: Text("$appointmentId dismissed")));
                                                // Scaffold.of(context).showSnackBar(SnackBar(content: Text("$appointmentId dismissed")));
                                                removedChat(item);  
                                                Navigator.of(context).pop();
                                              },
                                              child: Text("Confirm",style: TextStyle(color: Colors.white)),
                                            ),
                                          )
                                      ],),
                                    
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    // onDismissed: (direction) {
                    //   if(direction == DismissDirection.endToStart){
                    //       // Scaffold.of(context).showSnackBar(SnackBar(content: Text("Swipe to left")));
                    //       Scaffold.of(context)
                    //       .showSnackBar(SnackBar(content: Text("$appointmentId dismissed")));
                    //       removedChat(item);
                    //     }
                    //     else{
                    //     }
                    //   // setState(() {
                    //   //   item.removeAt(index);
                    //   // });
                      
                    // },
                    direction:  DismissDirection.endToStart,
                    background: Container(
                      color: const Color(0xFF512c7c),
                      child: Row(mainAxisAlignment: MainAxisAlignment.end,children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                          Icon(Icons.delete,
                          color: const Color(0xff9b7fbc)),
                          Text("Delete",style: TextStyle(color: Colors.white),)
                        ],
                        ),
                        
                    ],),),
                    child:ChatRoomsTile (
                    userName: snapshot.data.docs[index].data['chatRoomId']
                        .toString()
                        .replaceAll("_", "")
                        .replaceAll("-", " : ")
                        .replaceAll(Constants.myName, ""),
                    chatRoomId: snapshot.data.docs[index].data["chatRoomId"],
                    endDateTime:snapshot.data.docs[index].data["endDateTime"].toDate(),
                    deviceToken:deviceToken,
                    patientId:patientId,
                    latestChat: latestChat, exitPage: exitPage,
                    // latestChat:getLastMessage(snapshot.data.documents[index].data["chatRoomId"]),
                  ),
                  );
                });
      }
      else{
        return Container(child:Center(child: Text("no data"),));
      }
  }
  // Widget chatRoomsList() {
  //   return StreamBuilder(
  //     stream: chatRooms,
  //     builder: (context, snapshot) {
  //       return snapshot.hasData
  //           ? ListView.builder(
  //               itemCount: snapshot.data.documents.length,
  //               shrinkWrap: true,
  //               itemBuilder: (context, index) {
  //                 var endDateTime = snapshot.data.documents[index].data['endDateTime'].toDate();
  //                 return ChatRoomsTile(
  //                   userName: snapshot.data.documents[index].data['chatRoomId']
  //                       .toString()
  //                       .replaceAll("_", "")
  //                       .replaceAll("-", " : ")
  //                       .replaceAll(Constants.myName, ""),
  //                   chatRoomId: snapshot.data.documents[index].data["chatRoomId"],
  //                   endDateTime: endDateTime,
  //                   deviceToken:snapshot.data.documents[index].data["device_token"],
  //                 );
  //               })
  //           : Container();
  //     },
  //   );
  // }

  getUserInfogetChats() async {
    setState(() {
      _isloading = true;
    });
    Constants.myName = (await HelperFunctions.getUserNameSharedPreference())!;
    Constants.myId = (await HelperFunctions.getUserIdSharedPreference())!;
    print('${Constants.myName} ${Constants.myId} == !!');
    DatabaseMethods().getUserChats(Constants.myId).then((snapshots) {
      setState(() {
        _isloading = false;
        chatRooms = snapshots;
        print(
            "we got the data + ${chatRooms.toString()} this is name  ${Constants.myName}");
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    _height = MediaQuery.of(context).size.height;
    _width = MediaQuery.of(context).size.width; 

    return Scaffold(
      key:_scaffoldKey,
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: const Color(0xFF512c7c),
        automaticallyImplyLeading: false,
        title: Text("Active Chat",style: TextStyle(color: Colors.white),),
        elevation: 0.0,
        centerTitle: true,
      ),
      body: Container(
        child: chatRoomsList(),
      ),
    );
  }
}

// class ChatRoomsTile extends StatelessWidget {
//   final String userName;
//   final String chatRoomId;
//   final DateTime endDateTime;
//   final List<dynamic> deviceToken;
  
//   Stream latestChat;
//   String userId;
//   ChatRoomsTile({this.userName,@required this.chatRoomId,this.endDateTime, this.deviceToken});

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: (){
//         Navigator.push(context, MaterialPageRoute(
//           builder: (context) => Chat(
//             chatRoomId: chatRoomId,
//             userName: userName,
//             endDateTime:endDateTime,
//             deviceToken: deviceToken,
//           )
//         ));
//       },
//       child: Container(
//         color: Colors.black26,
//         padding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
//         child: Row(
//           children: [
//             Container(
//               height: 30,
//               width: 30,
//               decoration: BoxDecoration(
//                   color: Colors.blue,
//                   borderRadius: BorderRadius.circular(30)),
//               child: Text(userName.substring(0, 1),
//                   textAlign: TextAlign.center,
//                   style: TextStyle(
//                       color: Colors.white,
//                       fontSize: 30,
//                       fontFamily: 'OverpassRegular',
//                       fontWeight: FontWeight.w200)),
//             ),
//             SizedBox(
//               width: 12,
//             ),
//             Text(userName,
//                 textAlign: TextAlign.start,
//                 style: TextStyle(
//                     color: Colors.white,
//                     fontSize: 16,
//                     fontFamily: 'OverpassRegular',
//                     fontWeight: FontWeight.w300))
//           ],
//         ),
//       ),
//     );
//   }
// }
