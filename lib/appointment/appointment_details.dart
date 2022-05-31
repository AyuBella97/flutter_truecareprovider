import 'package:TrueCare2u_flutter/helper/helperfunctions.dart';
import 'package:TrueCare2u_flutter/models/shared_configs.dart';
import 'package:TrueCare2u_flutter/services/api_services.dart';
import 'package:TrueCare2u_flutter/utils/permissions.dart';
import 'package:TrueCare2u_flutter/videocall/pickuplayout.dart';
import 'package:advance_pdf_viewer/advance_pdf_viewer.dart';
import 'package:agora_rtc_engine/rtc_engine.dart';
// import 'package:advance_pdf_viewer/advance_pdf_viewer.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/database.dart';
import '../videocall/call.dart';
import 'package:TrueCare2u_flutter/chat/chat.dart';
import 'package:TrueCare2u_flutter/helper/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';

import 'labrequest.dart';
import 'widgets/viewimage.dart';
class AppointmentDetailPage extends StatefulWidget {
  final String id;
  var data;
  AppointmentDetailPage({Key? key, required this.id,this.data }) : super(key: key);
  @override
  _AppointmentDetailPageState createState() => _AppointmentDetailPageState();
}

class _AppointmentDetailPageState extends State<AppointmentDetailPage> {
  bool isloading = true;
  var _deeppurple = const Color(0xFF512c7c);
  var _lightpurple = const Color(0xFF997fbb);
  var _orangebutton = const Color(0xFFF47920);
  var _width;
  var _height;

  var data;
  var type;
  var appointmentId;
  var channelId;
  var careprovider;
  var careprovidername;
  var myname;
  var patientname;
  var patientId;
  var deviceToken;
  var price;
  var status;
  var scaffoldKey = GlobalKey<ScaffoldState>();
  var address;
  var mainaddress;
  var status_code;
  var phone;
  // ignore: avoid_init_to_null
  var package = null;
  var appointmentDate;
  var appointmentTime;
  var currentdate;
  var appointmentDateOri;
  var appointmentDateTime;
  var refundStatus;

  // videocall
  var startdatetime;
  var timerremaining;
  // endvideocall

  var _summary;
  var _labresult;
  var _prescription;
  var _notes;

  var addon;
  ClientRole _role = ClientRole.Broadcaster;

  DatabaseMethods databaseMethods = new DatabaseMethods();

  late DateTime  timestamp;
  late DateTime  removedAt;
  var chatRoomId;
  // ClientRole _role = ClientRole.Broadcaster;

  bool isEditable = false;
  int isEditablenumber = 1;
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  var textControllerSummary = new TextEditingController();
  var textControllerPrescription = new TextEditingController();
  var textControllerlabresult = new TextEditingController();
  var textControllernotes = new TextEditingController();
  bool showerror = false;

  // testLab is here
  var testLabId;
  var testLabName;
  var testLabStatus;
  var testLabResult;
  var testLabPaymentStatus;
  var testLabPrice;
  // end testlab
  var arrivalTime;

  var lefttimer;
  @override
  void initState() { 
    super.initState();
    data = widget.data;
    appointmentId = data.data['appointmentId'];
    getlatestdata();
    setData();
    getDraft();
  }
    Future<void> _handleCameraAndMic() async {
    await [Permission.camera, Permission.microphone].request();

  }

  getDraft() async{
    await SharedConfigs().readKey('summary$appointmentId').then((value) {
      print("summary$appointmentId $value");
        setState(() {
          textControllerSummary.text = value??_summary;  
        });
    });
    await SharedConfigs().readKey('notes$appointmentId').then((value) {
        setState(() {
          textControllernotes.text = value??_notes;  
        });
    });;
    await SharedConfigs().readKey('prescription$appointmentId').then((value) {
        setState(() {
          textControllerPrescription.text = value??_prescription;  
        });
    });
  }

  setData() async{
    setState(() {
      
      print("data isisisisis   ${data.data}");
      patientId = data.data['userId'];
      type = data.data['type'];
      patientname = data.data['username'];
      channelId = data.data['channelId'];
      
      address = data.data['address'];
      status_code = data.data['status_code'];

      if(type == "Video Call"){
        timestamp = data.data['endDateTime'].toDate();
        if(data.data['appointmentDateTime'] != null){
          startdatetime = DateTime.parse('${data.data['appointmentDateTime']}');
        }
        timerremaining = data.data['lefttimer']??data.data['timer'];
        Constants.lefttimer = data.data['lefttimer']??data.data['timer']??15;
      }

      if(type == "Chat"){
        if(data.data['RoomId'] != null || data.data['RoomId'] != ""){
          channelId = data.data['RoomId'];
        }
        print("data.data['deleteDateTime'] is ${data.data['deleteDateTime']}");
        timestamp = data.data['endDateTime'].toDate();
        removedAt = data.data['deleteDateTime'].toDate();
        chatRoomId = data.data['chatRoomId'];
      }

      careprovider = data.data["cpCode"];
      price = data.data["price"];
      status = data.data["status"];
      package = data.data["package"];
      phone = data.data["phone"];
      appointmentDate = data.data["appointmentDate"];
      appointmentTime = data.data["appointmentTime"];
      appointmentDateOri  = appointmentDate;
      appointmentDateTime = data.data["appointmentDateTime"];
      // current data
      currentdate = DateTime.now();
      
      var appointmentDate2 ;
      if(appointmentDate !=null){
        appointmentDate2 = DateTime.parse(appointmentDate);
        appointmentDate = appointmentDate2;
      }
      
      // 

      refundStatus = data.data["refundStatus"];

      _summary = data.data["summary"];
      _notes = data.data["notes"];
      _prescription = data.data["prescription"];

      address = data.data['address'];
      if(address == null || address == ""){
        mainaddress = "${data.data["address1"]} ${data.data["address2"]}";
      }
      else{
        mainaddress = address;
      }

      addon = data.data['addon'];
      if(addon == null){
        addon = false;
      }

    });

    if(chatRoomId != null){
      print("chatRoomIdchatRoomId $chatRoomId");
     await databaseMethods.getChatsDevicesToken(chatRoomId).then((_data){
      print("documents.lengthdocuments.length ${_data.docs.length}");
      if(_data.docs.length>0){
        setState(() {
        deviceToken = _data.docs[0].data["device_token"];
        });
      }
    });
    }

    Constants.testLab = data.data['testlab']??null;
    var testId = data.data['testId'];
    if(testId != null && testId != ""){
      await getTestLab(testId);
    }

    var arrivaltime2 = data.data['arrivalTime'];
    if(arrivaltime2 != null){
      arrivalTime = formatToproperdate(arrivaltime2);
    }
  }

  formatToproperdate(thistimeparse){
    var arrivalTime3 = thistimeparse.toDate();
    var formatteddate = DateFormat('dd-MM-yyyy').format(arrivalTime3);
    var formatteddate2 = DateFormat('HH:mm').format(arrivalTime3);
    return "$formatteddate $formatteddate2";
  }

  getTestLab(testId)async{
      await DatabaseMethods().getTestLab(testId).then((thisdata){
        if(thisdata.docs.length>0){
          print("getTestLabgetTestLab ${thisdata.docs[0].data}");
          setState(() {
            testLabId =  thisdata.docus[0].data['testId'];
            testLabName = thisdata.docs[0].data['testlab'];
            testLabStatus = thisdata.docs[0].data['status'];
            testLabResult = thisdata.docs[0].data['result'];
            testLabPaymentStatus = thisdata.docs[0].data['paymentStatus'];
            testLabPrice = thisdata.docs[0].data['testprice'];
          });
        }
      });
  }

  Future<void> _refreshData() async{
    setState(() {
        getlatestdata();
        getDraft();
    });
  }

  getlatestdata() async{
    await databaseMethods.getSurveyData(appointmentId).then((_data){
      setState(() {
        data = _data.docs[0];
      });
        print('data is ${_data.docs[0].data}');
        setData();
        
    });
    
    setState(() {
      isloading = false;
    });
  }
  

  @override
  Widget build(BuildContext context) {
    _height = MediaQuery.of(context).size.height;
    _width = MediaQuery.of(context).size.width;  

    return PickupLayout(
      scaffold:Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text('Appointment Details',style: TextStyle(color: Colors.white,),),
        centerTitle: true,
        backgroundColor: _deeppurple,
        leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: Colors.white,size: 14,),
            onPressed: () => Navigator.of(context).pop(),
          ),
      ),
      body: RefreshIndicator(
          key: scaffoldKey,
          onRefresh: () async {_refreshData();},
          child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child:Container(
            margin: EdgeInsets.only(bottom:10),
          // height: _height,
          width: _width,
          child: isloading ? Center(child:CircularProgressIndicator()):
          Column(
          children: <Widget>[
             
            appointmentDetails(),
            providerform(),
            
          ]
      ),
    ),
    ),
    ),
    ));
  }

  Widget providerform(){
    return Form(
              key: _formKey,
              child: 
              Column(
              children: <Widget>[
                
                
                thisSummary(),
                thisNotes(),
                if(Constants.mytype == "Doctor" || Constants.mytype == "Specialist")...[
                  thisprescription(),
                  thislabtest(),
                ],
                if(appointmentDateTime != null)...[
                  if(DateTime.parse(appointmentDateTime).isBefore(DateTime.now()) && status == "Confirm")...[
                    isEditable ? buttonSubmit():buttonEdit(),
                  ],
                ],
              ]),
              );
  }

    var now = new DateTime.now();
    Widget goTovideoCall(){ 
      return Container(
        margin: EdgeInsets.symmetric(horizontal:15),
        // padding: EdgeInsets.symmetric(vertical: 16.0,horizontal:_width*0.15),
        width: MediaQuery.of(context).size.width,
        alignment: Alignment.center,
        child: RaisedButton(
          onPressed: () => {
              if(Constants.lefttimer! > 0){
                goTocallPage(channelId,timestamp),
              }
              else{
                _showErroVideoDialog(context,channelId),
              }
          },
          color:Colors.green[800],
          child:Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
            Icon(Icons.switch_video,color: Colors.white),
            SizedBox(width:_width*0.02),
            Text("Start Conversation", style: TextStyle(color: Colors.white,fontSize: 16)),
          ],),
              
      ));
    }

      Widget goTochatMessage(){
        return Container(
        padding: EdgeInsets.symmetric(vertical: 16.0),
        width: MediaQuery.of(context).size.width,
        alignment: Alignment.center,
        child: RaisedButton(
          onPressed: () => {
              // if(now.isBefore(removedAt)){
                goToMessagePage(),
              // }
              // else{
              //   _showErroVideoDialog(context,channelId),
              // }
              
          },
          color: _deeppurple,
          child:
              Text("Go To Chat", style: TextStyle(color: Colors.white)),
        ));
      }

      Widget updateArrivalTimeButton(){
        return Container(
        padding: EdgeInsets.symmetric(vertical: 16.0),
        width: MediaQuery.of(context).size.width,
        alignment: Alignment.center,
        child: RaisedButton(
          onPressed: () async {
                updateArrivalTime();
          },
          color: _deeppurple,
          child:
              Text("Arrive", style: TextStyle(color: Colors.white)),
        ));
      }

  final customboxshadow = BoxDecoration(color: Colors.white,borderRadius: BorderRadius.circular(5),
                  boxShadow: [ 
                            BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 1.5,
                            blurRadius: 2,
                            offset: new Offset(2.0, 2.0), // changes position of shadow
                        ),
                      ]);
  buttonSubmit(){
    return Container(
          height: _height*0.05,
          width: _width,
          margin: EdgeInsets.only(top:_height*0.02,bottom: _height*0.02),child:Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
      InkWell(
      onTap: (){
        if (validateTextField(textControllerSummary.text)) {
          _formKey.currentState?.save();
          showConfirmationDialog();
        }
      },
      child: Container(
          height: _height*0.05,
          width: _width*0.2,
          decoration: BoxDecoration(
            color: _deeppurple,borderRadius: BorderRadius.circular(2),
            boxShadow: [ 
                      BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 0.5,
                      blurRadius: 1,
                      offset: new Offset(0.0, 0.0), // changes position of shadow
                  ),
                ]),
                child: Center(child:Text("Submit",style: TextStyle(color: Colors.white),textAlign: TextAlign.center,)),
          ),),
          InkWell(
          onTap: () async {
            if (validateTextField(textControllerSummary.text)) {
                    _formKey.currentState?.save();
                    // updateAppointment();
                    print("summary$appointmentId summaryappointmentId");
                    await SharedConfigs().writeKey('summary$appointmentId',textControllerSummary.text);
                    await SharedConfigs().writeKey('notes$appointmentId',textControllernotes.text);
                    await SharedConfigs().writeKey('prescription$appointmentId',textControllerPrescription.text);
                    setState(() {
                    isEditable = !isEditable;
                  });
                  }
          },
          child: Container(
              height: _height*0.05,
              width: _width*0.23,
              decoration: BoxDecoration(
                color: _orangebutton,borderRadius: BorderRadius.circular(2),
                boxShadow: [ 
                          BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 0.5,
                          blurRadius: 1,
                          offset: new Offset(0.0, 0.0), // changes position of shadow
                      ),
                    ]),
                    child: Center(child:Text("Save",style: TextStyle(color: Colors.white),textAlign: TextAlign.center,)),
              ),),
              // InkWell(
              // onTap: (){
              //           setState(() {
              //           isEditable = !isEditable;
              //           isEditablenumber++;
              //         });
              // },
              // child: Container(
              //     height: _height*0.05,
              //     width: _width*0.15,
              //     decoration: BoxDecoration(
              //       color: Colors.redAccent,borderRadius: BorderRadius.circular(2),
              //       boxShadow: [ 
              //                 BoxShadow(
              //                 color: Colors.grey.withOpacity(0.5),
              //                 spreadRadius: 0.5,
              //                 blurRadius: 1,
              //                 offset: new Offset(0.0, 0.0), // changes position of shadow
              //             ),
              //           ]),
              //           child: Center(child:Text("Cancel",style: TextStyle(color: Colors.white),textAlign: TextAlign.center,)),
              //     ),),
    ],),
    ); 
    
  }

  buttonEdit(){
    return InkWell(
          onTap: (){
              setState(() {
                isEditable = !isEditable;
              });
            
          },
        child: Container(
          height: _height*0.05,
          width: _width*0.2,
          margin: EdgeInsets.only(top:_height*0.02,bottom: _height*0.02),
          decoration: BoxDecoration(
            color: isEditable?Colors.green:_deeppurple,borderRadius: BorderRadius.circular(2),
            boxShadow: [ 
                      BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 0.5,
                      blurRadius: 1,
                      offset: new Offset(0.0, 0.0), // changes position of shadow
                  ),
                ]),
                child: Center(child:Text("Edit",style: TextStyle(color: Colors.white),textAlign: TextAlign.center,)),
          ),
      );
  }

  bool validateTextField(String userInput) {
    if (userInput.isEmpty) {
      setState(() {
        showerror = true;
      });
      return false;
    }
    else{
    setState(() {
      showerror = false;
    });
    return true;
  }
  }
  
  appointmentDetails(){
    String? appointmentDateDetails;
    var datetime;
    String? formatteddate;

    if(appointmentDateOri !=null){
      datetime = DateTime.parse(appointmentDateOri);
    }
    print("datetime $datetime");
    if(datetime !=null){
      formatteddate = DateFormat('dd-MM-yyyy').format(datetime);
    }

    print("appointmentdate mod $formatteddate");

    if(appointmentTime != null && formatteddate != null){
      var appointmentTime2 = appointmentTime.split(":");
      String newappointtime = "${appointmentTime2[0]}:${appointmentTime2[1]??''}";
      appointmentDateDetails = "${formatteddate}  ${newappointtime}";
    }
    else if(formatteddate != null){
      appointmentDateDetails = "${formatteddate}";
    }
    else{
      appointmentDateDetails = "TBC";
    }
    return Container(
            margin: EdgeInsets.only(left:_width*0.05,right: _width*0.05,top: _height*0.05),
            // padding: EdgeInsets.all(15),
            width: _width,
            // height: _height*0.35,
            decoration: customboxshadow,
            child:  Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: new BorderRadius.only(topLeft:Radius.circular(5.0),topRight: Radius.circular(5.0)),
                ),
                width: _width,
                height: _height*0.1,
                child: Container(
                  padding: EdgeInsets.all(_height*0.02),
                  child:Row(children: [
                    userImage(),
                    SizedBox(width: _width*0.03,),
                    Container(
                      width: _width*0.6,
                      child:Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                      Text("Patient name",style: TextStyle(color: Colors.grey,fontSize: 12),),
                      Expanded(child:Text("$patientname",style: TextStyle(fontSize: 16,color: _deeppurple,fontWeight: FontWeight.bold),maxLines: 2,overflow: TextOverflow.ellipsis,),),
                    ],),),
                    SizedBox(width: _width*0.03,),
                    
                     ],)),

                ),
                  

                Container(
                  width: _width,
                padding: EdgeInsets.all(15),
                child:Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  // mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                  Row(
                    children: [
                    Container(
                    width: _width*0.4,  
                    child:
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Appointment Number",style: TextStyle(fontSize: 12,color: Colors.grey,),),
                      Text(appointmentId??"",style: TextStyle(color: _deeppurple,),),
                    ],),
                    ),
                    SizedBox(width: _width*0.01,),
                    Container(
                    width: _width*0.4,  
                    child:
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Service",style: TextStyle(fontSize: 12,color: Colors.grey,),),
                        Text(type??"",style: TextStyle(color: _deeppurple,),),
                    ],),
                    ),
                  ],),
                  SizedBox(height: _height*0.02,),
                  Row(
                    children: [
                    Container(
                    width: _width*0.4,  
                    child:
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Date & Time",style: TextStyle(fontSize: 12,color: Colors.grey,),),
                      Text(appointmentDateDetails,style: TextStyle(color: _deeppurple,),),
                    ],),
                    ),
                    SizedBox(width: _width*0.01,),
                    Container(
                    width: _width*0.4,  
                    child:
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                      Text("Package",style: TextStyle(fontSize: 12,color: Colors.grey,),),
                      Text(package??"",style: TextStyle(color: _deeppurple,),),
                      addon ? Text("With add-ons"):Text(""),
                    ],),
                    ),
                  ],),
                  SizedBox(height: _height*0.02,),
                  Row(
                    children: [
                    Container(
                    width: _width*0.4,  
                    child:
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                      Text("Status",style: TextStyle(fontSize: 12,color: Colors.grey,),),
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,children: [
                        Text(status??"Unknown",style: TextStyle(color: status == "Confirm" || status == "Completed"  ? Colors.green:Colors.red[300],),),
                        Icon(status == "Confirm" || status == "Completed" ? Icons.check_circle_outline:Icons.error_outline,color: status == "Confirm" || status == "Completed" ? Colors.green:Colors.red[300],)
                      ],),
                    ],),
                    ),
                    SizedBox(width: _width*0.01,),
                    Container(
                    width: _width*0.4,  
                    child:
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Payment",style: TextStyle(fontSize: 12,color: Colors.grey,),),
                      
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,children: [
                        if(type == "Video Call" || type == "Chat")...[
                          Text(status_code == "00" ? "Paid":"Unpaid",style: TextStyle(color: status_code == "00" ? Colors.green:Colors.red[300],),),
                          Icon(status_code == "00" ? Icons.check_circle_outline:Icons.highlight_off,color: status_code == "00" ? Colors.green:Colors.red[300],)
                        ]
                        else...[
                        Text(status_code == "00" ? "Paid":"Pending",style: TextStyle(color: status_code == "00" ? Colors.green:Colors.red[300],),),
                        Icon(status_code == "00" ? Icons.check_circle_outline:Icons.error_outline,color: status_code == "00" ? Colors.green:Colors.red[300],)
                        ],
                        
                      ],),],),
                    ),
                  ],),
                  SizedBox(height: _height*0.02,),
              
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                      Text("Care Provider",style: TextStyle(fontSize: 12,color: Colors.grey,),),
                       Text("${Constants.myName}",style: TextStyle(color: _deeppurple,),),
                    ],),
                  SizedBox(height: _height*0.02,),
                  if(data.data['noofdays'] != null)...[
                    data.data['noofdays'] > 1 ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                      Text("Booking Days",style: TextStyle(fontSize: 12,color: Colors.grey,),),
                      Text("${data.data['noofdays']}",style: TextStyle(decoration: TextDecoration.underline,)),
                      SizedBox(height: _height*0.02,),
                    ],):SizedBox(),
                  ],
                  SizedBox(height: _height*0.02,),
                  phone != null ? GestureDetector(
                    onTap: ()async{
                    var phoneurl = "tel:$phone";   
                        if (await canLaunch(phoneurl)) {
                            await launch(phoneurl);
                          }
                      
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                      Text("Phone",style: TextStyle(fontSize: 12,color: Colors.grey,),),
                      Text(phone??"",style: TextStyle(decoration: TextDecoration.underline,)),
                    ],),
                  ):Container(),

                  

                  SizedBox(height: _height*0.02,),
                  type == "Video Call" || type == "Chat" ? SizedBox():
                  GestureDetector(
                    onTap: (){
                      openMaps();
                    },
                  child:
                  Row(
                    children: [
                    Container(
                    width: _width*0.8,  
                    child:
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                      Text("Address",style: TextStyle(fontSize: 12,color: Colors.grey,),),
                      Text(mainaddress??"No Address Given",style: TextStyle(decoration: TextDecoration.underline,),),
                    ],),
                    ),
                    
                  ],),),

                  SizedBox(height: _height*0.02,),
                  type != "Chat" && type != "Video Call" && 
                  arrivalTime == null ?updateArrivalTimeButton():SizedBox(),
                  arrivalTime != null && arrivalTime != ""  ? Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                      Text("Time Arrival",style: TextStyle(fontSize: 12,color: Colors.grey,),),
                      Text(arrivalTime??"",style: TextStyle(decoration: TextDecoration.underline,)),
                    ],),
                  ):SizedBox(),
                  
                ],),
                
              ),
              // goTochatMessage(),
              
              if(startdatetime !=null)...[
                type == "Video Call" && status_code == "00" && status == "Confirm" && now.isAfter(startdatetime) ? goTovideoCall() : Container(),
              ],
              type == "Chat" && status_code == "00" ? goTochatMessage() : Container(),
              SizedBox(height: 10,),
                 
            ],),
            );
  }

   Widget thisSummary(){
    return Container(
            margin: EdgeInsets.only(left:_width*0.05,right: _width*0.05,top: _height*0.02),
            padding: EdgeInsets.only(left:15,right: 15,top: 15),
            width: _width,
            // height: isEditable? _height*0.25: _height*0.15,
            constraints: BoxConstraints(
              minHeight: isEditable? _height*0.4: _height*0.35, minWidth: double.infinity, maxHeight: double.infinity),
            decoration: customboxshadow,
            child:  Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                  
                
                Container(
                  width: _width,
                // padding: EdgeInsets.all(15),
                child:Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  // mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Summary",style: TextStyle(color: _deeppurple,fontSize: 16,fontWeight: FontWeight.bold),),
                    SizedBox(height: _height*0.01,),
                    !isEditable ? Text(textControllerSummary.text):
                    TextFormField(
                      maxLines: 14,
                    textAlign: TextAlign.left,
                    style: TextStyle(fontSize: 14.0),
                    decoration: InputDecoration(
                        // contentPadding: new EdgeInsets.symmetric(vertical: 0.0),
                        enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey, width: 0.5),
                        ),
                        hintText: 'Summary',
                        hintStyle: TextStyle(fontSize: 11.0)),
                    controller: textControllerSummary,
                    validator: (String? value) {
                      if (value!.isEmpty  || value == null || value == "") {
                        return 'Summary is Required';
                      }

                      return null;
                    },
                    onSaved: (String? value) {
                      setState(() {
                          _summary = value;
                      });
                    },    
                  ),
                  Text(showerror?"Summary cannot be empty":"",style: TextStyle(color: Colors.redAccent),),

                ],),
                
              ),

              
                  
            ],),
            );
  }

  Widget thisNotes(){
    return Container(
            margin: EdgeInsets.only(left:_width*0.05,right: _width*0.05,top: _height*0.02),
            padding: EdgeInsets.only(left:_height*0.02,right: _height*0.02,top: _height*0.02,bottom: _height*0.02),
            width: _width,
            // height: isEditable? _height*0.25: _height*0.15,
            constraints: BoxConstraints(
              minHeight: isEditable? _height*0.4: _height*0.35, minWidth: double.infinity, maxHeight: double.infinity),
            decoration: customboxshadow,
            child:  Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                  
                
                Container(
                  width: _width,
                // padding: EdgeInsets.all(15),
                child:Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  // mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Notes (Hidden from Patient)",style: TextStyle(color: _deeppurple,fontSize: 16,fontWeight: FontWeight.bold),),
                    SizedBox(height: _height*0.01,),
                    !isEditable ? Text("No Notes submit.."):
                    TextFormField(
                      maxLines: 14,
                    textAlign: TextAlign.left,
                    style: TextStyle(fontSize: 14.0),
                    decoration: InputDecoration(
                        // contentPadding: new EdgeInsets.symmetric(vertical: 0.0),
                        enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey, width: 0.5),
                        ),
                        hintText: 'Notes',
                        // labelText: 'Name',
                        hintStyle: TextStyle(fontSize: 11.0)),
                    // initialValue: _notes,
                    controller: textControllernotes,
                    validator: (String? value) {
                      if (value!.isEmpty) {
                        value = null;
                      }

                      return null;
                    },
                    onSaved: (String? value) {
                      setState(() {
                          _notes = value!.isEmpty ? null:value;
                      });
                    },    
                  ),

                ],),
                
              ),

              
                  
            ],),
            );
  }

  Widget thisprescription(){
    return Container(
            margin: EdgeInsets.only(left:_width*0.05,right: _width*0.05,top: _height*0.02),
            padding: EdgeInsets.only(left:15,right: 15,top: 15),
            width: _width,
            height: isEditable? _height*0.25: _height*0.15,
            decoration: customboxshadow,
            child:  Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                  
                
                Container(
                  width: _width,
                // padding: EdgeInsets.all(15),
                child:Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  // mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Prescription",style: TextStyle(color: _deeppurple,fontSize: 16,fontWeight: FontWeight.bold),),
                    SizedBox(height: _height*0.01,),
                    !isEditable ? Text("No Prescription submit.."):
                    TextFormField(
                      maxLines: 5,
                    textAlign: TextAlign.left,
                    style: TextStyle(fontSize: 14.0),
                    decoration: InputDecoration(
                        // contentPadding: new EdgeInsets.symmetric(vertical: 0.0),
                        enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey, width: 0.5),
                        ),
                        hintText: 'Prescription',
                        // labelText: 'Name',
                        hintStyle: TextStyle(fontSize: 11.0)),
                    controller: textControllerPrescription,
                    // initialValue: _prescription,
                    onSaved: (String? value) {
                      setState(() {
                          _prescription = value!.isEmpty ? null:value;
                      });
                    },    
                  ),

                ],),
                
              ),

              
                  
            ],),
            );
  }

  Widget thislabtest(){
    return Container(
            margin: EdgeInsets.only(left:_width*0.05,right: _width*0.05,top: _height*0.02),
            padding: EdgeInsets.only(left:15,right: 15,top: 15),
            width: _width,
            height: _height*0.17,
            decoration: customboxshadow,
            child:  Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                  
                
                Text("Laboratory",style: TextStyle(color: _deeppurple,fontSize: 16,fontWeight: FontWeight.bold),),
                SizedBox(height: _height*0.01,),
                
                Container(
                  width: _width,
                // padding: EdgeInsets.all(15),
                child:Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  // mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    
                    (Constants.testLab == null || Constants.testLab == "") && status == "Confirm"  ? InkWell(
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => LabRequest(
                                  appointmentId:appointmentId,
                                ),
                              ),
                            );
                          },
                        child: Container(
                          height: _height*0.05,
                          width: _width*0.8,
                          margin: EdgeInsets.only(top:_height*0.02,bottom: _height*0.02),
                          decoration: BoxDecoration(
                            color: _deeppurple,borderRadius: BorderRadius.circular(2),
                            boxShadow: [ 
                                      BoxShadow(
                                      color: Colors.grey.withOpacity(0.5),
                                      spreadRadius: 0.5,
                                      blurRadius: 1,
                                      offset: new Offset(0.0, 0.0), // changes position of shadow
                                  ),
                                ]),
                                child: Center(child:Text("Request for test",style: TextStyle(color: Colors.white),textAlign: TextAlign.center,)),
                          ),
                      ):Text("${'No Test has been requested'}"),

                ],),
                
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  testLabStatus != null ?  Text("Status : $testLabStatus"):SizedBox(),
              ],),
              if(testLabResult != null)...[
                      GestureDetector(
                        onTap: () {
                            openlink(testLabResult);
                        },
                        child:
                            Center(child:Container(
                            height: _height*0.05,
                            width: _width*0.2,
                            decoration: BoxDecoration(
                              color: _orangebutton,borderRadius: BorderRadius.circular(2),
                              boxShadow: [ 
                                        BoxShadow(
                                        color: Colors.grey.withOpacity(0.5),
                                        spreadRadius: 0.5,
                                        blurRadius: 1,
                                        offset: new Offset(0.0, 0.0), // changes position of shadow
                                    ),
                                  ]),
                                  child: Center(child:Text("view result",style: TextStyle(color: Colors.white),textAlign: TextAlign.center,)),
                            ),),
                          ),
                    ],
                    
                  
            ],),
            );
  }

  // Widget thislabResult(){
  //   return Container(
  //           margin: EdgeInsets.only(left:_width*0.05,right: _width*0.05,top: _height*0.02,bottom: _height*0.05),
  //           // padding: EdgeInsets.all(15),
  //           width: _width,
  //           height: _height*0.15,
  //           decoration: customboxshadow,
  //           child:  Column(
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children: [
                  
                
  //               Container(
  //                 width: _width,
  //               padding: EdgeInsets.all(15),
  //               child:Column(
  //                 crossAxisAlignment: CrossAxisAlignment.start,
  //                 // mainAxisAlignment: MainAxisAlignment.center,
  //                 children: [
  //                   Text("Lab Result",style: TextStyle(color: _deeppurple,fontSize: 16),),
  //                   SizedBox(height: _height*0.01,),
  //                   Text(_labresult??"No Lab Result given"),

  //               ],),
                
  //             ),

              
                  
  //           ],),
  //           );
  // }

  
    
  Widget userImage(){
    return Container(
                  width: 40,
                  height: 40,
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
                    image: AssetImage('assets/icon/default-profile.png'),
                    fit: BoxFit.fill
                  ),
                  ),
                );
  }

  Widget careproviderimage(){
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
                    image: AssetImage('assets/icon/default-profile.png'),
                    fit: BoxFit.fill
                  ),
                  ),
                );
  }

  Future dial(id,context,_channelid)async{
    var videoDeviceToken =[];
    videoDeviceToken.add(data.data["deviceToken"][0]);
    Map<String,dynamic> mapData = {
      "device_token":videoDeviceToken,
      "title":"Incoming call from ${Constants.myName}",
      "body":"$appointmentId video call",
      "message":"$appointmentId",
      "callerId": Constants.myId,
      "callerName": Constants.myName,
      "callerPic": Constants.myImage,
      "receiverId": data.data['userId'],
      "receiverName":patientname,
      // "receiverPic": to.profilePhoto,
      "channelId": _channelid,
      "careprovider":careprovider,
      "careprovidername":careprovidername,
      "careproviderimage":Constants.myImage,
      "endDateTime":timestamp,
      "isPickup":false,
      "id":id,
      "appointmentId":appointmentId,
      "leftTimer":Constants.lefttimer,
    };
    print("mapData dial $mapData");
    await DatabaseMethods().addCall(id, mapData);
    
  }

  goTocallPage(_channelid, _timestamp) async {
    if(await Permissions.cameraAndMicrophonePermissionsGranted()){
      var id = "${Constants.myId}_${data.data['userId']}_$_channelid";
      await dial(id,context,_channelid);
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CallPage(
            appointmentId:appointmentId,
            id:id,
            channelName: _channelid.toString(),//_channelController.text,
            role: _role.toString(),
            channelid:_channelid,
            endTime:_timestamp,
            leftTimer:lefttimer,
            patientname: patientname,
            isCalling: true,
          ),
        ),
      );
      }
      else{}
  }

  goToMessagePage()async{
    print("chatRoomIdchatRoomId $chatRoomId");
     await   Navigator.push(context, MaterialPageRoute(
          builder: (context) => Chat(
            chatRoomId: chatRoomId,
            userName: patientname,
            endDateTime:timestamp,
            deviceToken: deviceToken,
            patientId: patientId, profilephoto: '',
          )
        ));
  }

  Future<void> _showErroVideoDialog(context,channelId) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Video Lobby not Found'),
        content: SingleChildScrollView(
          child: Center(child:ListBody(
            children: <Widget>[
              Container(alignment: Alignment.center,child:Text('Lobby $channelId may be expired or session already end.',),),
              Container(alignment: Alignment.center,child:Text('Please Contact admin for further assistance',),),
            ],
          ),),
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
  // void goToThankYouPage(){
  //    Navigator.push(
  //           context, MaterialPageRoute(builder: (context) => ThankYou()));
  // }


      showConfirmationDialog(){
     return showDialog(
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
                                Text("Confirm to submit?",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16),),
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
                                        updateAppointment();
                                        setState(() {
                                          isEditable = !isEditable;
                                        });
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
                  });

            }      

      updateAppointment() async{
        Map<String, dynamic> surveyData = {};
        surveyData["notes"] = _notes;
        surveyData["summary"] = _summary;
        surveyData["summaryCreatedDate"] = DateTime.now();
        surveyData["labresult"] = _labresult;
        surveyData["prescription"] = _prescription??null;
        surveyData["prescriptionStatus"] = surveyData["prescription"] != null ? "Unread":null;
        surveyData["prescriptionDate"]= surveyData["prescription"] != null ?DateTime.now():null;
        surveyData["status"] = "Completed";
        databaseMethods.updateSurvey(appointmentId,surveyData);
        setState(() {
          status = "Completed";
        });

        Map<String, dynamic> updateAppointmentDatatoApi = {
              "appointmentCode":appointmentId,
              "notes":surveyData["notes"],
              "summary":surveyData["summary"],
              "summaryCreatedDate":DateTime.now(),
              "prescription":surveyData["prescription"],
              "prescriptionStatus":surveyData["prescription"]!=null?"Unread":null,
              "prescriptionDate":surveyData["prescription"]!=null?DateTime.now():null,
              "labresult" : surveyData["labresult"]??null,

              };

        Map<String, dynamic> updateAppointmentDatatoApi2 = {
          "paymentStatus":"$status_code",
          "appointmentCode":appointmentId,
          "appointmentStatus":surveyData["status"],
        }; 

        Map<String,dynamic> createPrescriptionfromAppoinment = {
          "prescription":_prescription,
          "prescriptionDate":DateTime.now(),
          "appointmentCode":appointmentId,
          "prescriptionStatus":"Unread"
        };     
            print("updateAppointmentDatatoApi $updateAppointmentDatatoApi $updateAppointmentDatatoApi2");
            
            await ApiService().updateAppointmentData(updateAppointmentDatatoApi);
            await ApiService().updateAppointmentPaymentStatus(updateAppointmentDatatoApi2);
            if(_prescription != null || _prescription != ""){
              await ApiService().createAppointmentPrescription(createPrescriptionfromAppoinment);
            }
            await SharedConfigs().deleteKey('summary$appointmentId');
            await SharedConfigs().deleteKey('notes$appointmentId');
            await SharedConfigs().deleteKey('prescription$appointmentId');
      }      


      getLocation() async {
        try {
          var _apikey = "AIzaSyDWbwXOGHOTMcn-DJC7nc0crmSBBMNTMNY";
          var endPoint =
              // 'https://maps.googleapis.com/maps/api/geocode/json?latlng=${location?.latitude},${location?.longitude}&key=$_apikey';
              'https://maps.googleapis.com/maps/api/geocode/json?address=$mainaddress&key=$_apikey';

          var response = jsonDecode((await http.get(Uri.parse(endPoint))).body);
          print('response in $response');    
          print('endpoint == $endPoint');
          var data = response['results'][0]['geometry']['location'];
          print('data addressaaa == $data');
          
          return [data['lat'], data['lng']];
        } catch (e) {
          print(e);
        }
      }
      
      openMaps() async {
        var location = await getLocation();

        // final String lat = "37.3230";
        // final String lng = "-122.0312";
        final String googleMapsUrl = "comgooglemaps://?center=${location[0]},${location[1]}";
        final String appleMapsUrl = "https://maps.apple.com/?q=${location[0]},${location[1]}";
        // canLaunch("waze://") 

        if(await canLaunch("waze://")){
          await launch("waze://?ll=${location[0]},${location[1]}&navigate=yes");   
        }
        else if (await canLaunch(googleMapsUrl)) {
          await launch(googleMapsUrl);
        }
        else if (await canLaunch(appleMapsUrl)) {
          await launch(appleMapsUrl, forceSafariVC: false);
        } else {
          throw "Couldn't launch URL";
        }
      }

      openlink(url) async{

        if(RegExp(r".pdf",caseSensitive: false).hasMatch(url)){
         PDFDocument  thisdocument = await PDFDocument.fromURL("$url",);
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PDFViewer(document: thisdocument,minScale: 0.5,)),
          );  
        }
        else if(RegExp(r"(.png|.jpeg|.jpg)",caseSensitive: false).hasMatch(url)){
          // DetailScreen(url: url);
          await Navigator.push(context, 
          MaterialPageRoute(builder: (context) => ViewImage(url:url,appointmentId: appointmentId,))
          );
        }
        else{
          print(url);
        }
      }

      updateArrivalTime() async{
        Map<String, dynamic> surveyData = {
          'arrivalTime':DateTime.now(),
        };
        await databaseMethods.updateSurvey(appointmentId,surveyData);

        Map<String,dynamic> apiData = {
          "appointmentCode":appointmentId,
          'careProviderArrival':DateTime.now(),
        };
        print("apiDataapiData $apiData");
        await ApiService().updateAppointmentData(apiData);
        await getlatestdata();
      }
  
}

// } 

