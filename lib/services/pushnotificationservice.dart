  
import 'dart:io';
import 'package:TrueCare2u_flutter/helper/constants.dart';
import 'package:TrueCare2u_flutter/helper/helperfunctions.dart';
import 'package:TrueCare2u_flutter/services/api_services.dart';
import 'package:TrueCare2u_flutter/services/database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';


class PushNotificationService {
  final _fcm = FirebaseMessaging.instance;

  Future initialise() async {
    if (Platform.isIOS) {
      // request permissions if we're on android
      _fcm.requestPermission();
    }

    FirebaseMessaging.onMessage.listen(
          (RemoteMessage message) async {
        print('onMessage: $message');
        _serialiseAndNavigate(message.data);
      },
    );
    FirebaseMessaging.onMessage.listen(
          (RemoteMessage message) async {
        print('onLaunch: $message');
        _serialiseAndNavigate(message.data);
      },
    );
    FirebaseMessaging.onMessage.listen(
          (RemoteMessage message) async {
        print('onResume: $message');
        _serialiseAndNavigate(message.data);
      },
    );
  }

  void _serialiseAndNavigate(Map<String, dynamic> message) {
    var notificationData = message['data'];
    var view = notificationData['view'];
    // print("notificationData view $notificationData $view");
    if (view != null) {
      // Navigate to the create post view
      if (view == 'gotoa') {
        print("view $view");
        // MaterialPageRoute(
        //   builder: (context) => IndexPage(1),
        // );
        // Navigator.pushNamed(context,"LOCATION_PAGE");
      }
    }
  }

  void updateDeviceToken()async{
    var devToken;
    await _fcm.getToken().then((devicetoken){
      print('Device tokenPushNotificationService : $devicetoken');
      devToken = devicetoken;
    });
    if(Constants.myDeviceToken != devToken){
          Map<String,dynamic> mapData = {
            "deviceToken":devToken,
          };
      await  DatabaseMethods().updateDeviceToken(Constants.myId, mapData);
        
        Map<String,dynamic> devicetokentoApi = {
            "Code":Constants.myId,
            "deviceToken":devToken,
          };
          print("asdasdasd $devicetokentoApi");
          await ApiService().updateCareProvider(devicetokentoApi);
        await HelperFunctions.saveUserDeviceTokenPreference(devToken);
      }
  }
}