import 'package:TrueCare2u_flutter/services/database.dart';
import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:flutter/material.dart';
import '../utils/permissions.dart';
import 'call.dart';

class PickupScreen extends StatelessWidget {
  final Map mapData;
  var _deeppurple = const Color(0xFF512c7c);
  PickupScreen({
    required this.mapData,
  });

  ClientRole _role = ClientRole.Broadcaster;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: _deeppurple,
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(vertical: 100),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              "Incoming...",
              style: TextStyle(
                fontSize: 30,
                color:Colors.white,
              ),
            ),
            SizedBox(height: 50),
            // Image.asset("assets/images/send.png"),
            ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: Image.asset('assets/icon/default-profile.png',height: 180,width: 180,),
            ),
            
            // CachedImage(
            //   url:"aaa",
            //   // call.callerPic,
            //   // isRound: true,
            //   // radius: 180,
            // ),
            SizedBox(height: 15),
            Text(
              mapData['callerName'],
              style: TextStyle(
                color:Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            SizedBox(height: 75),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                // ClipRRect(
                // borderRadius: BorderRadius.circular(100),
                // child:Container(
                //   color: Colors.redAccent,
                //   child:IconButton(
                //   icon: Icon(Icons.call_end),
                //   color: Colors.white,
                //   onPressed: () async {
                //     await DatabaseMethods().endCall(id: mapData["id"]);
                //   },
                // ),),),
                // SizedBox(width: 25),
                
                ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child:Container(
                  color: Colors.green,
                  child:IconButton(
                  icon: Icon(Icons.call),
                  color: Colors.white,
                  onPressed: () async{
                      if( await Permissions.cameraAndMicrophonePermissionsGranted() ){
                          var newmapData = {
                            "isPickup":true,
                          };
                          await DatabaseMethods().updatecallIncoming(mapData["id"],newmapData).then((_value){
                            if(_value){
                              Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CallPage(
                                  appointmentId: mapData["appointmentId"],
                                  id: mapData["id"],
                                  channelName: mapData['channelId'].toString(),//_channelController.text,
                                  role: _role.toString(),
                                  channelid:mapData['channelId'],
                                  endTime:mapData['endDateTime'].toDate(),
                                  patientname: mapData['callerName'],
                                  leftTimer: mapData['leftTimer'],
                                  isCalling: false,
                                ),
                              ),
                            );
                            } 
                          }); 
                          
                         }
                         else{}

                  }       
                ),),),
              ],
            ),
          ],
        ),
      ),
    );
  }
}