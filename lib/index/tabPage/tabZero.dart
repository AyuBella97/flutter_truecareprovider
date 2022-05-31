
import 'dart:math';

import 'package:TrueCare2u_flutter/appointment/appointmentindex.dart';
import 'package:TrueCare2u_flutter/appointment/widgets/allappointment.dart';
import 'package:TrueCare2u_flutter/services/pushnotificationservice.dart';
import 'package:TrueCare2u_flutter/videocall/pickuplayout.dart';

import '../../services/database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../helper/constants.dart';
import '../../helper/helperfunctions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../indexpage.dart';
import 'widgets/latestappoinment.dart';
import './widgets/custom_shape.dart';
import './widgets/profiletile.dart';
import 'package:english_words/english_words.dart';
import '../../route/route.dart';
import '../../models/shared_configs.dart';
import 'package:new_version/new_version.dart';
import 'package:flutter/scheduler.dart';



class TabZero extends StatefulWidget {
  @override
  _TabZeroState createState() => _TabZeroState();
}



class _TabZeroState extends State<TabZero> {

  var _deeppurple = const Color(0xFF512c7c);
  var _orangebutton = const Color(0xFFF47920);
  var _width;
  var _height;
  var totalcollection = 0.00;

  DatabaseMethods databaseMethods = new DatabaseMethods();
  var servicetype;
  var route = MyCustomroute();
  var scaffoldKey = GlobalKey<ScaffoldState>();
  SharedConfigs configs = SharedConfigs();
  bool isExpanded = false;
  bool isExpanded1 = false;
  late Stream<QuerySnapshot> alldata;

  bool _isLoading = false;
  bool _hasMore = true;
  // ignore: avoid_init_to_null
  var address = null;
  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance?.addPostFrameCallback((_) {
      checkVersion();
    });
     getSharedPreferences();
     getAddress(); 
    _hasMore = true;
    getCollection();
    getFourtransaction();
    _getData();
    PushNotificationService().updateDeviceToken();
  }

  checkVersion() async{
    final newVersion = NewVersion(androidId: "com.truecare2u.truecare2uprovider",iOSId: "1536540996");
    newVersion.showAlertIfNecessary(context: context);
    final status = await newVersion.getVersionStatus();
    print("${status?.canUpdate}"); // (true)
    print("${status?.localVersion}");  // (1.2.1)
    print("${status?.storeVersion}");  // (1.2.3)
    print("${status?.appStoreLink}");  //
  }

  // checkVersion() async {
  //   final checkVersion = CheckVersion(context: context);
  //   final appStatus = await checkVersion.getVersionStatus();
  //   if (appStatus.canUpdate) {
  //     checkVersion.showUpdateDialog("com.truecare2u.truecare2u", "id1536393020");
  //   }
  //   print("canUpdate ${appStatus.canUpdate}");
  //   print("localVersion ${appStatus.localVersion}");
  //   print("appStoreLink ${appStatus.appStoreUrl}");
  //   print("storeVersion ${appStatus.storeVersion}");
  // }

  getSharedPreferences() async {
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
  
  Future<void> getAddress() async{
    await configs.readKey('savelocation').then((_data){
    setState(() {
      address =  _data;
    });
    
    });
  }

  getCollection() async{
    databaseMethods.getAllinOneMonth(Constants.myId).then((_value){
      print("careProviderPortion data ${_value.docs.length}");
      double income = 0.0;
      for(var i=0;i<_value.docs.length;i++){
        var incomefromthisappointment = _value.docs[i].data["careProviderPortion"];
        if(incomefromthisappointment == null){
          var payment = _value.docs[i].data["price"];
          incomefromthisappointment = int.tryParse("${payment()}")?.toStringAsFixed(2);
        }
        if(incomefromthisappointment != null){
          print("incomefromthisappointment $incomefromthisappointment");
          var thisincome = double.parse("$incomefromthisappointment");
          assert(thisincome is double);
          print("thisincome $thisincome");
          income = income+thisincome;
        }
        
        

      }
      print("income RM${income.toStringAsFixed(2)}");
      setState((){
        totalcollection = income;
      });
      
    });
  }
  
  
  Future<void> getFourtransaction() async{
    setState(() {
      _isLoading = true;
    });
    var myid = await HelperFunctions.getUserIdSharedPreference();
    databaseMethods.getfourtransaction(myid!).then((_data){
      setState(() {
        alldata = _data;
      });
          print("myid is $myid");
          // print("alldata is ${alldata.length}");
    });
    setState(() {
      _isLoading = false;
    });
  }
  Future<void> _getData() async{
    setState(() {
        getFourtransaction();
        getCollection();
    });
    
  }

  Widget workList(){
    return Container(
      margin: EdgeInsets.only(left: 10, right: 10,),
      // shrinkWrap:true,
      // padding: const EdgeInsets.only(bottom:20.0),
      child:StreamBuilder(
      stream: alldata,
      builder: (context, snapshot){
        if(snapshot.connectionState == ConnectionState.waiting){
                  // updateMyUI();
                  return Container(child:Center(child: CircularProgressIndicator(),));
                } 
        else if(snapshot.connectionState == ConnectionState.active){
                  // updateMyUI();
                  return streamBuilder(snapshot);
                }              
                return streamBuilder(snapshot);
        // return snapshot.hasData ? streamBuilder(snapshot) : _isLoading ? Container(): Container(child:Text("no data"));
      },
    ),
  );
    
  }

  final customboxshadow = BoxDecoration(color: Colors.white,borderRadius: BorderRadius.circular(10),
                  boxShadow: [ 
                            BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 0.5,
                            blurRadius: 1,
                            offset: new Offset(2.0, 2.0), // changes position of shadow
                        ),
                      ]);

  String formatTimeOfDay(TimeOfDay tod) {
    final now = new DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, tod.hour, tod.minute);
    final format = DateFormat.jm();  //"6:00 AM"
    return format.format(dt);
}

  Widget streamBuilder(snapshot){
    if(_isLoading){
      return Container(
        height:_height,
        width:_width,
        child:Center(child: CircularProgressIndicator(),));
    }
    if(snapshot.data.docs.length == 0){
        return  Container(height:_height*0.8,
        margin: EdgeInsets.fromLTRB(_height*0.05,_height*0.05,_height*0.05,0),
        width:_width,child: Text("No appointments scheduled",textAlign:TextAlign.center),);
    }
    else if(snapshot.hasData){
      return SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child:Column(children: [
        headermyWorkList(),

        ListView.builder(
          // scrollDirection: Axis.vertical,
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: snapshot.data.docs.length,
            itemBuilder: (context, index){
              var dynamicSwitch = snapshot.data.docs[index].data["status"];
              var rawdata = snapshot.data.docs[index];
              var patientname = snapshot.data.docs[index].data["userName"];
              var package = snapshot.data.docs[index].data["package"];
               var apointmentdate;
               var appointmentTime;
               if(snapshot.data.docs[index].data["appointmentDate"] != null){
                 apointmentdate= snapshot.data.docs[index].data["appointmentDate"];
               }
               if(snapshot.data.docs[index].data["appointmentTime"]!= null){
                 appointmentTime = snapshot.data.docs[index].data["appointmentTime"];
               }
                
               var service = snapshot.data.docs[index].data["type"];
               var datetime;
               if(apointmentdate !=null){
                 datetime = DateTime.parse(apointmentdate);
               }
               
               print("appointmentdate $apointmentdate $datetime");
               var time;
               var appointmentTime2;
               if(appointmentTime != null){
                  appointmentTime2 = TimeOfDay(hour:int.parse(appointmentTime.split(":")[0]),minute: int.parse(appointmentTime.split(":")[1]));
                  time = formatTimeOfDay(appointmentTime2);
               }

                String formatteddate = "TBC";
                String day = "TBC";
                String month = "";
                String year = ""; 
               if(datetime !=null){
                 formatteddate = DateFormat('d').format(datetime);
                 day = DateFormat('EEEE').format(datetime);
                 month = DateFormat('MMM').format(datetime);
                 year = DateFormat('yyyy').format(datetime); 
               }
              return Container(
                margin: EdgeInsets.only(top: 5,bottom: 5),
                decoration: customboxshadow,
                width: _width,
                height: 100,
                child:AllAppointment(
                index:index+1,
                time:time,
                date:formatteddate,
                month:month,
                service: service,
                day:day,
                year:year,
                status: dynamicSwitch,
                patientname:patientname,
                package:package,
                data: rawdata,
              ));
            },
            )
      ],));
        
  }
            else{ 
            return Container(child:Center(child:Text("no data")));
            }
  }


  

  void viewallapp() {
    // Navigator.pushNamed(context, '/ALL_APPOINTMENT');
    Navigator.push(context, MaterialPageRoute(
          builder: (context) => IndexPage(1)));
    
  }

  void _handleSubmitted(String value) {
    Navigator.pushNamed(context, '/LOCATION_PAGE');
  } 

  Widget mainHeader() {
    return Stack(
      children: <Widget>[
        Opacity(
          opacity: 1,
          child: ClipPath(
            child: Container(
              height: _height / 6.5,
              decoration: BoxDecoration(
                color: const Color(0xFF512c7c),
              ),
            ),
          ),
        ),
        myProfile(),
      ],
    );
  }
  
  updateCareproviderStatusBusy() async{
    var updateStatus = {
       "status":0,
     };
     await DatabaseMethods().updateCareProvider(Constants.myId,updateStatus); 
  }

  Future<bool> _onWillPop() async {
    return (await showDialog(
      context: context,
      builder: (context) => new AlertDialog(
        title: new Text('Are you sure?'),
        content: new Text('Your status will be set to offline'),
        actions: <Widget>[

          Row(
          mainAxisAlignment:MainAxisAlignment.start,
          children: <Widget>[
            Container(
              width: _width*0.3,
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).pop(false);
                },
                child:  Text("Cancel",style: TextStyle(color: Colors.blue),),
              ),
            ),
              Container(
              width: _width*0.38,
              child: RaisedButton(
                color: _orangebutton,
                onPressed: () async{
                  await updateCareproviderStatusBusy();
                  Navigator.of(context).pop(true);
                },
                child: Text("Confirm",style: TextStyle(color: Colors.white)),
              ),
            )
        ],),
        ],
      ),
    )) ?? false;
  }

  @override
  Widget build(BuildContext context) {
    _height = MediaQuery.of(context).size.height;
    _width = MediaQuery.of(context).size.width;
    return new PickupLayout(
      scaffold:Scaffold(
      backgroundColor: Colors.grey[200],
      key: scaffoldKey,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      body: RefreshIndicator(
          onRefresh: () async {_getData();},
        child:SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child:Stack(children: <Widget>[
            Column(
            children: <Widget>[
              mainHeader(),
              // if(Constants.isStaff != "1")...[
              //   myMoneyCollection(),
              //   Container(
              //     child:Center(
              //       child: Text("RM${totalcollection.toStringAsFixed(2)}",style: TextStyle(color: _deeppurple,fontSize: _height/15),),
              //     )
              //   ),
              // ],
              
              
              // last transaction
              _isLoading ? 
              Container(child: CircularProgressIndicator(),) 
              :RefreshIndicator(
                  child: workList(),
                  onRefresh: () async {_getData();},
              ),
            ],
          ),
            ],
          ),
        ),
      
    )
    // body: Column(
    //         children: <Widget>[
    //           SingleChildScrollView(
    //           physics: AlwaysScrollableScrollPhysics(),
    //       child:Stack(children: <Widget>[
    //         Column(
    //         children: <Widget>[
    //           mainHeader(),
    //           myMoneyCollection(),
    //           Container(
    //             child:Center(
    //               child: Text("RM550.00",style: TextStyle(color: _deeppurple,fontSize: _height/15),),
    //             )
    //           ), 
    //           headermyWorkList(),
    //           // last transaction
    //           _isLoading ? 
    //           Container(child:Center(child: CircularProgressIndicator(),)) 
    //           :workList(),
    //           // Divider(),
    //         ],
    //       ),
    //         ],
    //       ),),
          // mainHeader(),
          // myMoneyCollection(),
          // Container(
          //   child:Center(
          //     child: Text("RM550.00",style: TextStyle(color: _deeppurple,fontSize: _height/15),),
          //   )
          // ), 
          // headermyWorkList(),
          // _isLoading ? 
          //     Container(child:Center(child: CircularProgressIndicator(),)) 
          //     :
          //     Expanded(
          //       flex: 1,
          //       child: RefreshIndicator(
          //         child: workList(),
          //         onRefresh: () async {_getData();},
          //       ),
          //     ),
            // ],
          // ),
        ),
        );
    // );
  }

  Widget myProfile(){
    return Container(
          margin: EdgeInsets.only(left: 10, right: 40, top: _height / 15),
          width: _width,
          height: 50,
          padding: EdgeInsets.only(top: 0,right: 10,left: 10),
          child:Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  borderRadius: new BorderRadius.all(Radius.circular(10.0)),
                  border: Border.all(width: 1.0, color: const Color(0xFFFFFFFF)),
                  image: DecorationImage(
                    image: Constants.myImage != null && Constants.myImage != "" ? NetworkImage(Constants.myImage):AssetImage('assets/icon/default-profile.png') as ImageProvider,
                    fit: BoxFit.fill
                  ),
                  ),
                ),
                SizedBox(width: 10,),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                  Text("Welcome Back,",style: TextStyle(color: Colors.white),),
                  Text("${Constants.myName}",style: TextStyle(fontSize: 20,color: Colors.white,fontWeight: FontWeight.bold),)
                ],),
              
          ],),
        );
  }

  Widget myMoneyCollection(){
    return Container(
                margin: EdgeInsets.only(left: 30, right: 30, top: _height*0.01),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text('My Collection',
                        style: TextStyle(
                             fontSize: 16)),
                  ],
                ),
              );
  }

  Widget headermyWorkList(){
    return Container(
                margin: EdgeInsets.only(left: 30, right: 30, top: _height*0.05),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text('My Upcoming Appointment',
                        style: TextStyle(
                             fontSize: 16)),
                    GestureDetector(
                        onTap: viewallapp,
                        child: Row(children: [
                          Text(
                          "View all",
                          style: TextStyle(
                              color: _deeppurple,
                              ),
                          ),
                          Icon(Icons.arrow_forward_ios,size: 16,)
                        ],),
                        
                        
                        ),
                  ],
                ),
              );
  }

  
  Widget locationAddressSet(){
    if(address !=  null){
      return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,  
      children: <Widget>[
      Text("Current Location Set to:"),
      Center(
        child: Text(
          address??'none',
          textAlign: TextAlign.center,
        ),
      ),
      ],
    );
    }
    else{
     return Text("Current Location is not Set");
    }
  }

  




void showmodal(BuildContext context){
showModalBottomSheet(
            context: context,
            builder: (BuildContext context) {
              return DraggableScrollableSheet(
                initialChildSize: 0.5,
                maxChildSize: 1,
                minChildSize: 0.25,
                builder:
                    (BuildContext context, ScrollController scrollController) {
                  return Container(
                    color: Colors.white,
                    child: ListView.builder(
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      controller: scrollController,
                      itemCount: 25,
                      itemBuilder: (BuildContext context, int index) {
                        return ListTile(title: Text('Item $index'));
                      },
                    ),
                  );
                },
              );
            },
          );
}



Widget header() => Ink(
        decoration: BoxDecoration(
            color: Colors.blue[200]),
        child: Padding(
          padding: const EdgeInsets.only(left:16.0,right:16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: new Text("truecare2uprovider"),
                ),
              ],
              ),
          ),
        );
}


