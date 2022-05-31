import 'dart:io';
import 'package:TrueCare2u_flutter/chat/provider/viewstate.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';

import '../style/style.dart';
import '../helper/constants.dart';
import '../services/database.dart';
import '../helper/helperfunctions.dart';
import 'provider/imageuploadprovider.dart';
import 'utils/utilities.dart';
import 'widgets/message_items.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:TrueCare2u_flutter/widgetsGloabal/formattimer.dart';
import 'package:image_picker/image_picker.dart';
class Chat extends StatefulWidget {
  final String chatRoomId;
  final String userName;
  final String profilephoto;
  var endDateTime;
  final patientId;
  final List<dynamic> deviceToken;
  Chat({required this.chatRoomId, required this.userName, required this.endDateTime, required this.deviceToken, required this.profilephoto, this.patientId});

  @override
  _ChatState createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  var _deeppurple = const Color(0xFF512c7c);
  late ImageUploadProvider _imageUploadProvider;
  // var deviceToken;
  // timer
  late double fontSize;
  late Timer _timer;
  int _start = 10;
  // timer

  late Stream<QuerySnapshot> chats;
  TextEditingController messageEditingController = new TextEditingController();
  late TextInputAction _textInputAction;
  bool isSent = false; 
  bool enterIsSend = HelperFunctions.enterIsSend ?? HelperFunctions.defaultEnterIsSend;
  ScrollController _scrollController = new ScrollController(); 
  String appbartitle = "";
  var endDateTime;
  bool expired = false;
  
  readMessage() async {
      Map<String,dynamic> mapData = {
         "isRead": true, 
      };
      await DatabaseMethods().readMessage(widget.chatRoomId,mapData,widget.patientId);
  }

  

  Widget chatMessages(){
    return Container(
      // padding: const EdgeInsets.only(bottom:20.0),
      // margin: const EdgeInsets.only(bottom:60.0),
      child: StreamBuilder(
      stream: chats,
      builder: (context, AsyncSnapshot snapshot){
        if(snapshot.connectionState == ConnectionState.active){
          // sentMessage();
          isSent = true;
          readMessage();
          
          
        }
        return snapshot.hasData ?  ListView.builder(
          controller: _scrollController,
          itemCount: snapshot.data.docs.length,
            itemBuilder: (context, index){
              // var dataissent = snapshot.data.documents[index].data["isSent"];
              // print("dataissent $index $dataissent");
                 
              var url = snapshot.data.docs[index].data["photoUrl"];
              if(url != null){
                // return CachedImage(url: snapshot.data.documents[index].data["photoUrl"]);
                return MessageItem(
                imageUrl: url,
                message: snapshot.data.docs[index].data["message"],
                isYou: Constants.myId == snapshot.data.docs[index].data["sendByUserId"],
                isRead: snapshot.data.docs[index].data["isRead"],
                isSent: isSent,
                timestamp: snapshot.data.docs[index].data["dateSent"].toDate(), fontSize: fontSize,
              );
              }
              else{
                return MessageItem(
                  message: snapshot.data.docs[index].data["message"],
                  isYou: Constants.myId == snapshot.data.docs[index].data["sendByUserId"],
                  isRead: snapshot.data.docs[index].data["isRead"],
                  isSent: isSent,
                  timestamp: snapshot.data.docs[index].data["dateSent"].toDate(), fontSize: fontSize, imageUrl: '',
                );
              }
            }) : Container();
      },
    ),
  );
    
  }

  gotobottomchat(){
    Future.delayed(Duration(seconds: 1),
    ()=> {
    if(_scrollController.hasClients){
            _scrollController.animateTo(
                _scrollController.position.maxScrollExtent,
                curve: Curves.easeOut,
                duration: const Duration(milliseconds: 300),
                )}
    });
  }

  addMessage() async {
    print("devicetoken == ${widget.deviceToken}");
    if (messageEditingController.text.isNotEmpty) {
      Map<String, dynamic> chatMessageMap = {
        "sendBy": Constants.myName,
        "sendByUserId":Constants.myId,
        "message": messageEditingController.text,
        "time": DateTime
            .now()
            .millisecondsSinceEpoch,
        "device_token":widget.deviceToken,
        "title":"${Constants.myName}",
        "body":"${messageEditingController.text}",
        "isRead":false,
        "isSent":true,
        "dateSent":DateTime.now(),
      };

    await  DatabaseMethods().addMessage(widget.chatRoomId, chatMessageMap);

      setState(() {
        messageEditingController.text = "";
      });

      await gotobottomchat();
    }
  }

  
  void startTimer() {
    if (_timer != null) {
      _timer.cancel();
      _timer = null as Timer;
    } else {
      _timer = new Timer.periodic(
        const Duration(seconds: 1),
        (Timer timer) => setState(
          () {
            if (_start < 1) {
              timer.cancel();
              setState(() {
                expired = true;
              });
              // _onCallEnd(context);
            } else {
              _start = _start - 1;
              // print("timer == $_start");
            }
          },
        ),
      );
    }
  }

  

  checkExpired(){
    var now = DateTime.now();
    if(now.isAfter(endDateTime)){
      setState(() {
        expired = true;
      });
    }

      var exp  = endDateTime.difference(now);
      // print("expired is ========= $expired");
      
      setState(() {
       _start = exp.inSeconds;
      });
        startTimer();
      
  }

 
  var enddatetime;
  var enddatetime1;
  @override
  void initState() {
    super.initState();
     enddatetime = "${widget.endDateTime.toString().split('.')[0]}";
     enddatetime1 = enddatetime.split(':')[0]+":"+enddatetime.split(':')[1];
    geChat();
    SchedulerBinding.instance?.addPostFrameCallback((_) {
      gotobottomchat();  
    });
    appbartitle = widget.userName;
    endDateTime = widget.endDateTime;
    // deviceToken = widget.deviceToken;
    checkExpired();
    
    setState(() {
        if(enterIsSend) {
          _textInputAction = TextInputAction.send;
        }
        else {
          _textInputAction = TextInputAction.newline;
        }
      });
  }

  geChat(){
    DatabaseMethods().getChats(widget.chatRoomId).then((val) {
      setState(() {
        chats = val;
      });
    });
  }

  

  @override
  Widget build(BuildContext context) {
    _imageUploadProvider = Provider.of<ImageUploadProvider>(context);
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(100),
        child: Container(color: Colors.grey,),
      ),
      body: 
      Column(
        children: <Widget>[
          Flexible(
            child: chatMessages(),
          ),
          _imageUploadProvider.getViewState == ViewState.LOADING
                ? Container(
                    alignment: Alignment.centerRight,
                    margin: EdgeInsets.only(right: 15),
                    child: CircularProgressIndicator(),
                  )
                : Container(),
          // inputBar(),
          expired ? disabledSendBox() : 
            inputBar(),
        ],
      ),
      // Container(
      //   color: Colors.grey[100],
      //   child: Stack(
      //     children: [
      //       // chatMessages(),
      //       // expired ? disabledSendBox() : sendBox(),
      //       chatMessages(),
      //       // expired ? disabledSendBox() : 
      //       inputBar(),
      //       // inputBar(),
      //       // inputBar(),
      //     ],
      //   ),
      // ),
    );
  }

  Widget inputBar(){
   return Container(
     margin: EdgeInsets.only(left:10,right: 10,),
   alignment: Alignment.bottomCenter,
   child:Padding(
    padding: EdgeInsets.all(8.0),
    child: Row(
      children: <Widget>[
        Expanded(
          child: roundedContainer(),
        ),
        SizedBox(
          width: 5.0,
        ),
        GestureDetector(
          onTap: () {
            addMessage();
          },
          child: CircleAvatar(
            backgroundColor: const Color(0xFF512c7c),
            child: Icon(Icons.send,color: Colors.white,size: 15,),
          ),
        ),
      ],
    ),),
  );
  }
  

  Widget disabledSendBox(){
    return Container(alignment: Alignment.bottomCenter,
              width: MediaQuery
                  .of(context)
                  .size
                  .width,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                color: const Color(0xFF512c7c),
                child: Row(
                  children: [
                    Expanded(
                        child: TextField(
                           enabled: false,
                          style: simpleTextStyle(),
                          decoration: InputDecoration(
                            // alignLabelWithHint: true,
                              hintText: "Chat Session Have Expired. Send New Message is disabled",
                              hintMaxLines: 3,
                              hintStyle: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                              border: InputBorder.none
                          ),
                        )),
                    SizedBox(width: 16,),
                  ],
                ),
              ),
            );
  }

  showImagePicker(){
        return showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return Dialog(
                          shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(20.0)), //this right here
                          child: Container(
                            height: 200,
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  ListTile(onTap: () {
                                    Navigator.pop(context);
                                    pickImage(source: ImageSource.gallery);
                                    },
                                    leading: Icon(Icons.image,size: 30,color:_deeppurple),title: Text("Pick from galley"),),
                                  ListTile(onTap: () {
                                    Navigator.pop(context);
                                    pickImage(source: ImageSource.camera);
                                    },
                                    leading: Icon(Icons.image,size: 30,color:_deeppurple),title: Text("Capture from camera"),),
                                  
                                  SizedBox(
                                    width: 150.0,
                                    child: RaisedButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: Text(
                                        "Cancel",
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      color: _deeppurple,
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        );
                      });

            } 

  void pickImage({required ImageSource source}) async {
    File selectedImage = await Utils.pickImage(source: source);
    uploadThisImage(selectedImage,_imageUploadProvider);
  }

  void uploadThisImage(image,ImageUploadProvider imageUploadProvider){
      uploadImage(image, imageUploadProvider);
  }

  void uploadImage(File image, ImageUploadProvider imageUploadProvider
    ) async {
    // Set some loading value to db and show it to user
    imageUploadProvider.setToLoading();
    // Constants.imageUploadLoading = true;

    // Get url from the image bucket
    String url = await DatabaseMethods().uploadImageToStorage(image);
  
    // Hide loading
    imageUploadProvider.setToIdle();
    // Constants.imageUploadLoading = false;

    Map<String, dynamic> chatMessageMapFile = {
        "sendBy": Constants.myName,
        "sendByUserId":Constants.myId,
        "message": "image",
        "photoUrl":url,
        "time": DateTime.now().millisecondsSinceEpoch,
        "device_token":widget.deviceToken,
        "title":"${Constants.myName}",
        "body":"Send an Image",
        "isRead":false,
        "isSent":isSent,
        "dateSent":DateTime.now(),
      };

    DatabaseMethods().setImageMsg(url,chatMessageMapFile,widget.chatRoomId);
  }

  Widget roundedContainer(){
    return ClipRRect(
    borderRadius: BorderRadius.circular(10.0),
    child: Container(
      color: Colors.white,
      child: Row(
        children: <Widget>[
          SizedBox(width: 8.0),
          // GestureDetector(
          // onTap: () {
          //   // onBackPress();
          // },
          // child: Icon(Icons.keyboard_voice,
          //     size: 30.0, color: const Color(0xff9a7fbb)),
          // ),
          SizedBox(width: 8.0),
          Expanded(
            child: TextField(
              textInputAction: _textInputAction,
              minLines: 1,
              maxLines: null,
              controller: messageEditingController,
              decoration: InputDecoration(
                hintText: 'Type a message',
                border: InputBorder.none,
              ),
              onSubmitted: (String text) {
                if(_textInputAction == TextInputAction.send) {
                  addMessage();
                }
              },
            ),
          ),
          GestureDetector(
            onTap: () => showImagePicker(),
            child:
          Icon(Icons.image,
              size: 30.0, color:const Color(0xff9a7fbb)),
          
          ),
          // Icon(Icons.attachment,
          //     size: 30.0, color:const Color(0xff9a7fbb)),
          // SizedBox(width: 8.0),
          // Icon(Icons.camera_alt,
          //     size: 30.0, color: const Color(0xff9a7fbb)),
          // SizedBox(width: 8.0),
        ],
      ),
    ),
  );
  }

  

  Widget patientimage(){
    return Container(
                  width: 50,
                  height: 50,
                  margin: EdgeInsets.only(right: 10,bottom: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
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
                    image: widget.profilephoto != null && widget.profilephoto != "" ? NetworkImage(widget.profilephoto): AssetImage("assets/Menubar/icon-menubar-account-dark.png") as ImageProvider,
                    fit: BoxFit.fill
                  ),
                  ),
                );
  }
  Widget appBarMain(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFF512c7c),
      toolbarHeight: 100,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios, color: Colors.white,size: 15,),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Column(
        children: <Widget>[
          Text(appbartitle,style: TextStyle(color: Colors.white,fontSize: 12),),
          // _start > 0 ? Text("End on ${enddatetime1}",style: TextStyle(color: Colors.white)) : Container(width: 0,height: 0,),
        ],), 
        flexibleSpace: FlexibleSpaceBar(
            // centerTitle: true,
            title: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  patientimage(),
                ]),),
      elevation: 0.0,
      centerTitle: true,
    );
  }

  @override
  void dispose() {
    // dispose input controller
    _timer.cancel();
    super.dispose();
  }

  

}




class MessageTile extends StatelessWidget {
  final String message;
  final bool sendByMe;

  MessageTile({required this.message, required this.sendByMe});


  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
          top: 8,
          bottom: 8,
          left: sendByMe ? 0 : 24,
          right: sendByMe ? 24 : 0),
      alignment: sendByMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: sendByMe
            ? EdgeInsets.only(left: 30)
            : EdgeInsets.only(right: 30),
        padding: EdgeInsets.only(
            top: 17, bottom: 17, left: 20, right: 20),
        decoration: BoxDecoration(
            borderRadius: sendByMe ? BorderRadius.only(
                topLeft: Radius.circular(23),
                topRight: Radius.circular(23),
                bottomLeft: Radius.circular(23)
            ) :
            BorderRadius.only(
        topLeft: Radius.circular(23),
          topRight: Radius.circular(23),
          bottomRight: Radius.circular(23)),
            gradient: LinearGradient(
              colors: sendByMe ? [
                const Color(0xff007EF4),
                const Color(0xff2A75BC)
              ]
                  : [
                const Color(0xff2A75BC),
                const Color(0xff007EF4)
              ],
            )
        ),
        child: Text(message,
            textAlign: TextAlign.start,
            style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontFamily: 'OverpassRegular',
            fontWeight: FontWeight.w300)),
      ),
    );
  }

  
}

