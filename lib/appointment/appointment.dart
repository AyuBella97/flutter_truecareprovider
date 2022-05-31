import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../services/database.dart';
import '../helper/helperfunctions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import './widgets/allappointment.dart';
class AppointmentPage extends StatefulWidget {
  final int index;

  const AppointmentPage({Key? key, required this.index}) : super(key: key);
  @override
  _AppointmentPageState createState() => _AppointmentPageState();
}

class _AppointmentPageState extends State<AppointmentPage> {
  // List myList;
  ScrollController _scrollController = ScrollController();
  DatabaseMethods databaseMethods = new DatabaseMethods();
  Stream<QuerySnapshot>? alltransaction = null;
  bool _isloading = false;
  @override
  void initState() {
    super.initState();
    getAllTransaction();
  }

  Future<void> getAllTransaction() async {
    setState(() {
      _isloading = true;
    });
    var id = await HelperFunctions.getUserIdSharedPreference();
    print("widget.index === ${widget.index}");
    if(widget.index == 0){
     databaseMethods.getAlltransaction(id!).then((_data){
            setState((){
              alltransaction = _data;
              
              // ignore: unnecessary_brace_in_string_interps
              print("all transaction == ${alltransaction}");
              
              });
        
     });
    }else{
      databaseMethods.getArchievetransaction(id).then((_data){
            setState((){
              alltransaction = _data;
              
              // ignore: unnecessary_brace_in_string_interps
              print("all transaction == ${alltransaction}");
              
              });
        
     });
    }
     setState(() {
       _isloading = false;
     });
      }


  Future<void> _getData() async{
    setState(() {
        getAllTransaction();
    });
    
  }

  Widget allTransaction(){
     return StreamBuilder(
      stream: alltransaction,
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
      });
    
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
    if(_isloading){
      return Container(child:Center(child: CircularProgressIndicator(),));
    }
    if(snapshot.data.docs.length == 0){
         return widget.index == 0 ?  Container(child:Center(child: Text("No appointments scheduled"),)):
         Container(child:Center(child: Text("No appointments scheduled"),)) ;
    }
    else if(snapshot.hasData){ 
      print("snapshot.data.documents.length ${snapshot.data.docs.length}");
    return ListView.builder(
            // reverse: true,
          // controller:_scrollController,
          // scrollDirection: Axis.vertical,
          shrinkWrap: true,
          itemCount: snapshot.data.docs.length,
            itemBuilder: (context, index){
              print("snapshot data ${snapshot.data.docs.length}");
              var dynamicSwitch = snapshot.data.docs[index].data["status"];
              var rawdata = snapshot.data.docs[index];
              var patientname = snapshot.data.docus[index].data["userName"];
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
                margin: EdgeInsets.only(left: 10,right: 10,top: 5,bottom: 5),
                decoration: customboxshadow,
                height: 100,
                child:AllAppointment(
                index:index+1,
                time:time,
                service: service,
                date:formatteddate,
                month:month,
                day:day,
                year:year,
                status: dynamicSwitch,
                patientname:patientname,
                data: rawdata, package: '',
              ),
              );
            });
  }
  else{ 
    return Container(child:Center(child:Text("no data")));
    }
  }

  @override
  Widget build(BuildContext context) {
    var _height = MediaQuery.of(context).size.height;
    var _width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body:RefreshIndicator(
          onRefresh: () async {_getData();},
          child:Container(
            // margin: EdgeInsets.only(),
        height: _height,
        width: _width,
        child:allTransaction(),)),
        );
  }
}


