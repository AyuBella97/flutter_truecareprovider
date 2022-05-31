import 'package:TrueCare2u_flutter/helper/constants.dart';
import 'package:TrueCare2u_flutter/helper/helperfunctions.dart';
import 'package:TrueCare2u_flutter/services/database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import '../models/user.dart';
// import 'resources/firebase_repository.dart';

class CallProvider with ChangeNotifier {
  DatabaseMethods databaseMethods = DatabaseMethods(); 
  
  playRingtone(){
    FlutterRingtonePlayer.playRingtone(
      asAlarm: false,
      looping: false,
      volume: 1.0,
    );
  }

  var _status = "idle";
  get getStatus => _status;

  void setToRinging() {
    playRingtone();
    _status = "ringing";
    // print("_status $_status");
    notifyListeners();
  }

  void setToIdle() {
    FlutterRingtonePlayer.stop();
    _status = "idle";
    // print("_status $_status");
    notifyListeners();
  }
  


  var _user;
  var _id;
  get getUser => _user;
  get getId => _id;

  Future<void> getUserId() async{
    Constants.myId = (await HelperFunctions.getUserIdSharedPreference())!;
    _id = Constants.myId;
    print("id getUserId $_id");
    notifyListeners();
  }

}