import 'package:TrueCare2u_flutter/helper/constants.dart';
import 'package:TrueCare2u_flutter/helper/helperfunctions.dart';
import 'package:TrueCare2u_flutter/services/database.dart';
import 'package:TrueCare2u_flutter/services/api_services.dart';
import 'dart:math';

 class UpdateProfile{

   getUserDetails() async {
    // var thisvalue;
    
    // await DatabaseMethods().getCareProvider(Constants.myId).then((_data){
    //   thisvalue = _data;
    // });

    // await HelperFunctions.saveUserNameSharedPreference(thisvalue.documents[0].data['userName']);
    // await  HelperFunctions.saveUserPhoneNoPreference(
    //       thisvalue.documents[0].data['phoneNo']);

    // await HelperFunctions.getUserEmailSharedPreference();
    // var thisname = await HelperFunctions.getNameSharedPreference();
    // var thisimage = await HelperFunctions.getImageSharedPreference();
    // var thisusername = await HelperFunctions.getUserNameSharedPreference();

        

    await setData();
  }

  Future<void> setData() async {
    Constants.myDeviceToken =
        (await HelperFunctions.getUserDeviceTokenPreference())!;
    Constants.myEmail = (await HelperFunctions.getUserEmailSharedPreference())!;
    Constants.myName = (await HelperFunctions.getUserNameSharedPreference())!;
    Constants.myId = (await HelperFunctions.getUserIdSharedPreference())!;
    Constants.myPhone = (await HelperFunctions.getUserPhoneNoPreference())!;
    Constants.myImage = (await HelperFunctions.getImageSharedPreference())!;
    Constants.isStaff = (await HelperFunctions.getsaveUserisStaff())!;
    await DatabaseMethods().getCareProvider(Constants.myId).then((_data){
      Constants.mytype = _data.docs[0].data["careType"];
    });
  }


  
}