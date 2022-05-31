import 'package:flutter/material.dart';
import '../../services/database.dart';
import 'package:TrueCare2u_flutter/appointment/appointment_details.dart';


class AllAppointment extends StatefulWidget{
  final int index;
  final String date;
  final String month;
  final String time;
  final String day;
  final String year;
  final String status;
  final String patientname;
  final String package;
  final String service;
  var data;
  AllAppointment({ required this.index, required this.time, required this.date, required this.data, required this.status, required this.month, required this.day, required this.patientname, required this.year, required this.package, required this.service});
  _AllAppointmentState createState()=> _AllAppointmentState();
}

class _AllAppointmentState extends State<AllAppointment>{
 //Your code here
  var _height ;
    var _width;
  DatabaseMethods databaseMethods = new DatabaseMethods();
  late int index;
  late String type;
  late String status;
  late String date;
  late String time;
  late String month;
  var appointmentId;
  late String patientname;
  late String userId;
  late String package;
  var userpicture;
  var data;
  var newdata;
  @override
  void initState() { 
    super.initState();
    setState(() {
      data = widget.data;
    });
    setData();
    getlatestdata();
    // getData();

  }

  getlatestdata(){
    databaseMethods.getSurveyData(appointmentId).then((_data){
      setState(() {
        newdata = _data.docs[0];
      });
        print('data is ${_data.docs[0].data}');
        setData();
        
    });
  }
  setData(){
    setState(() {
      status = data.data['status'];
      patientname = data.data['username'];
      type = data.data['type'];
      appointmentId = data.data['appointmentId'];
      index = widget.index;
      date = widget.date;
      time = widget.time;
      month = widget.month;

      userId = data.data["userId"];
      package = data.data["package"];
      // print("data raw is === ${data.data['userName']}");
    });
    getPictureUser();
  }
  getPictureUser() async {
    await DatabaseMethods().getPatientInfo(userId).then((_value){
      if(_value.docs.length > 0){
        setState(() {
          userpicture = _value.docs[0].data["profilePicture"];
      });
      }
      
      
    });
  }

  Widget pictureContainer(){
    return Container(
      height: 50,
      width: 50,
      decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  borderRadius: new BorderRadius.all(Radius.circular(10.0)),
                  border: Border.all(width: 1.0, color: const Color(0xff5f3f87)),
                  image: DecorationImage(
                    image: userpicture != null && userpicture != "" ? NetworkImage(userpicture):AssetImage('assets/icon/default-profile.png') as ImageProvider,
                    fit: BoxFit.fill
                  ),
                  ),
      child: Text(""),
      // Column(
      //   mainAxisAlignment: MainAxisAlignment.center,
      //   crossAxisAlignment: CrossAxisAlignment.center,
      //   children: [
      //   Text("$date",style: TextStyle(color: const Color(0xff5f3f87),fontSize: 20,fontWeight: FontWeight.bold),textAlign: TextAlign.center,),
      //   Text("$month",style: TextStyle(color: const Color(0xff959595),fontWeight: FontWeight.bold),textAlign: TextAlign.center,),
      // ],),
    );
  }
  Widget thistransaction(){
    print("day month ... ${widget.date} ${widget.month} ${widget.time} ${widget.year}");
    String datetime;
    if(widget.time!=null && widget.date != null){
      datetime = "${widget.date} ${widget.month} ${widget.year} | ${widget.time}";
    }
    else if(widget.time==null && widget.date != null){
      datetime = "${widget.date} ${widget.month} ${widget.year}";
    } 
    else{
      datetime = "TBC";
    }
   return Container(
    //  margin: EdgeInsets.only( right: 20,bottom: 5,top: 10),
     child:Row(
                   mainAxisAlignment: MainAxisAlignment.start,
                   crossAxisAlignment: CrossAxisAlignment.center,
                   children: <Widget>[
                    //  if(index % 3 == 0)...[
                    //    leftContainerpurple(),
                    //  ]
                    //  else if(index % 3 == 1)...[
                    //    leftContainerorange(),
                    //  ]
                    //  else...[
                    //    leftContainergreen(),
                    //  ],
                      SizedBox(width: 10,),
                      pictureContainer(),
                      SizedBox(width: 15,),
                      Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                          Container(
                          width: _width*0.25,child:Text("Patient Name",style: TextStyle(color:Colors.grey),)),
                          Container(
                          width: _width*0.4,
                          child:
                          Text(
                            "${patientname.toUpperCase()}",
                            textAlign: TextAlign.start, // has impact
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: TextStyle(color: const Color(0xff5f3f87),fontSize: 14),
                          ) ,
                        ),
                        ],),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                          Container(
                          width: _width*0.25,child:Text("Date & Time",style: TextStyle(color:Colors.grey),),),
                          Container(
                          width: _width*0.4,
                          child:
                          Text(
                            "${datetime}",
                            textAlign: TextAlign.start, // has impact
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: TextStyle(color: const Color(0xff5f3f87),fontSize: 14),
                          ) ,
                        ),
                        ],),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                          Container(
                          width: _width*0.25,child:Text("Service",style: TextStyle(color:Colors.grey),),),
                          Container(
                          width: _width*0.4,
                          child:
                          Text(
                            "${widget.service}",
                            textAlign: TextAlign.start, // has impact
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: TextStyle(color: const Color(0xff5f3f87),fontSize: 14),
                          ) ,
                        ),
                        ],),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                          Container(
                          width: _width*0.25,child:Text("Status",style: TextStyle(color:Colors.grey),),),
                          Container(
                          width: _width*0.3,
                          child:
                          Text(
                            "${status}",
                            textAlign: TextAlign.start, // has impact
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: TextStyle(color:status == "Confirm" || status == "Completed" || status == "Done"? Colors.green:Colors.red,fontSize: 14),
                          ),
                        ),
                        Icon(status == "Confirm" || status == "Completed" || status == "Done" ? Icons.check_circle_outline:Icons.error_outline,color: status == "Confirm" || status == "Completed" || status == "Done" ? Colors.green:Colors.red[300],)
                        ],),
                        
                        
                       
                        
                        // statusText(status),
                    ],
                    ),
                    // Column(
                    //   crossAxisAlignment: CrossAxisAlignment.end,
                    //   mainAxisAlignment: MainAxisAlignment.center,
                    //   children: <Widget>[
                    //     Text('$date'??"",style: TextStyle(color: Colors.black)),
                    //     Text('$time'??"",style: TextStyle(color: Colors.black,)),
                    //   ],
                    //   ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(Icons.arrow_forward_ios,size: 12,color: Colors.grey,)
                      ],
                      ),  
                 ],
                ),
                );
                }
         
  
  @override
  Widget build(BuildContext context) {
     _height = MediaQuery.of(context).size.height;
     _width = MediaQuery.of(context).size.width;
    return InkWell(
              onTap: () {
                // Navigator.pushNamed(context, '/CURRENT_APPOINTMENT', arguments: arg);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AppointmentDetailPage(
                      data: newdata, id: '',
                    ),
                  ),
                );
              },
              child: thistransaction(),
        
    );
  
    }
}