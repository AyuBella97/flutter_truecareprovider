import 'dart:async';
import 'dart:math';
import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../helper/helperfunctions.dart';

import '../helper/constants.dart';
import '../services/database.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import './call.dart';

class VideoCallPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => VideoCallPageState();
}

class VideoCallPageState extends State<VideoCallPage> {
  DatabaseMethods databaseMethods = new DatabaseMethods();
  var currentchannelId = null;
  /// create a channelController to retrieve text value
  final _channelController = TextEditingController();
  late final bool isCalling;
  late final int leftTimer;
  /// if channel textField is validated to have error
  bool _validateError = false;

  ClientRole _role = ClientRole.Broadcaster;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setName();
  }

  setName() async {
    Constants.myName = (await HelperFunctions.getUserNameSharedPreference())!;
  }

  @override
  void dispose() {
    // dispose input controller
    _channelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var truecareprovider = "Fikri Tyty";
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Join Video Call'),
        centerTitle: true,
      ),
      body: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          height: 400,
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                      child: TextField(
                    keyboardType: TextInputType.number,
                    controller: _channelController,
                    decoration: InputDecoration(
                      errorText:
                          _validateError ? 'Channel name is mandatory' : null,
                      border: UnderlineInputBorder(
                        borderSide: BorderSide(width: 1),
                      ),
                      hintText: 'Channel name',
                    ),
                  ))
                ],
              ),
              Column(
                children: [
                  ListTile(
                    title: Text(ClientRole.Broadcaster.toString()),
                    leading: Radio(
                      value: ClientRole.Broadcaster,
                      groupValue: _role,
                      onChanged: (ClientRole? value) {
                        setState(() {
                          _role = value!;
                        });
                      },
                    ),
                  ),
                  ListTile(
                    title: Text(ClientRole.Audience.toString()),
                    leading: Radio(
                      value: ClientRole.Audience,
                      groupValue: _role,
                      onChanged: (ClientRole? value) {
                        setState(() {
                          _role = value!;
                        });
                      },
                    ),
                  )
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: RaisedButton(
                        onPressed: onJoin,
                        child: Text('Join'),
                        color: Colors.blueAccent,
                        textColor: Colors.white,
                      ),
                    )
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: RaisedButton(
                        onPressed:() => generateVideoRoom(truecareprovider),
                        child: Text('Generate ID'),
                        color: Colors.blueAccent,
                        textColor: Colors.white,
                      ),
                    )
                  ],
                ),
              ),
              currentchannelId != null ? Container(
                // padding: const EdgeInsets.symmetric(vertical: 20),
                 child:   Expanded(
                        // onPressed:() => generateVideoRoom(truecareprovider),
                        child: Text('$currentchannelId'"click generate",
                        style:TextStyle(color: Colors.blueAccent,)),
                        
                    )
              ) : Container(child:Text("click generate")),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> onJoin() async {
    // update input validation
    setState(() {
      _channelController.text.isEmpty
          ? _validateError = true
          : _validateError = false;
    });
    if (_channelController.text.isNotEmpty) {
      // await for camera and mic permissions before pushing video page
      await _handleCameraAndMic();
      // push video page with given channel name
      
      var text = _channelController.text;
      var channel = int.parse(text);
      var data;

      print("my name is ${Constants.myName} and $channel");
      QuerySnapshot querySnapshot = await databaseMethods.getVideoRoom(Constants.myName,channel);

      if(querySnapshot.docs.isEmpty){
        print("error da");
        _showErroVideoDialog(context);
      }
      else{
        DateTime  timestamp = querySnapshot.docs[0]['endDateTime'].toDate();
        var now = new DateTime.now();
        print("now =========== ${now}");
        // int timeInMillis = timestamp.nanoseconds;
        // var date = DateTime.fromMillisecondsSinceEpoch(timeInMillis);
        // var formattedDate = DateFormat.yMMMd().format(date);
       print("timestamp is ${timestamp}");
       if(now.isBefore(timestamp)){
        data = querySnapshot.docs[0].data;
        goTocallPage(querySnapshot.docs[0]['channelId'],timestamp);
       }
       else{
         _showErroVideoDialog(context);
       }
      }
      
      
      
    }
  }



  goTocallPage(_channelid, _timestamp) async {
    await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CallPage(
            channelName: _channelController.text,
            role: _role.toString(),
            channelid:_channelid,
            endTime:_timestamp, patientname: '', isCalling: isCalling, appointmentId: '', id: '', leftTimer: leftTimer,
          ),
        ),
      );
    // Navigator.pushNamed(context, '/CALL_PAGE', arguments: channelid);
  }

  Future<void> generateVideoRoom(String truecareprovider) async {
    
    List<String> users = [Constants.myName,truecareprovider];
    String videoRoomId = databaseMethods.getVideoRoomId(Constants.myName, truecareprovider); //getChatRoomId(Constants.myName,userName);
    var now = DateTime.now();
    print(now);
    var expired  = now.add(Duration(minutes: 5));
    print(expired);
    var rng = new Random();
    var channelId = rng.nextInt(999999);
    videoRoomId = videoRoomId+'$channelId';
    print('videoRoomId $videoRoomId');
    // date1.subtract(Duration(days: 7, hours: 3, minutes: 43, seconds: 56)); 
    Map<String, dynamic> videoRoom = {
      "users": users,
      "videoRoomId" : videoRoomId,
      "channelId": channelId,
      "startDateTime" : now,
      "endDateTime" : expired,
    };

    databaseMethods.addVideoRoom(videoRoomId,videoRoom);
    setState((){
      currentchannelId = channelId;
    });
  }

  Future<void> _handleCameraAndMic() async {
    await [Permission.camera, Permission.microphone].request();
  }
}

  Future<void> _showErroVideoDialog(context) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Video Lobby not Found'),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Container(alignment: Alignment.center,child:Text('Lobby may be expired or session already end.',),),
              Container(alignment: Alignment.center,child:Text('Please Contact admin for further assistance',),),
            ],
          ),
        ),
        actions: <Widget>[
          FlatButton(
            child: Text('Ok'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}
