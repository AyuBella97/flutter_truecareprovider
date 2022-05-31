import 'package:flutter/material.dart';
import '../../../services/database.dart';
import 'package:TrueCare2u_flutter/appointment/appointment_details.dart';

class LastAppointment extends StatefulWidget{
  final int index;
  final String date;
  final String time;
  final String status;
  var data;

  LastAppointment({ required this.index, required this.time, required this.date, required this.data, required this.status});
  _LastAppointmentState createState()=> _LastAppointmentState();
}

class _LastAppointmentState extends State<LastAppointment>{
 //Your code here

  DatabaseMethods databaseMethods = new DatabaseMethods();
  int? index;
  String? type;
  String? status;
  String? user = null;
  String? time;
  String? date;
  var data;
  var careprovidername = null;
  @override
  void initState() { 
    super.initState();
    setState(() {
        index = widget.index;
        data = widget.data;
    });
    setData();
  }
  setData(){
    setState(() {
      status = data.data['status'];
      user = data.data['userName'];
      type = data.data['type'];
      date = widget.date;
      time = widget.time;
      // print("data raw is === ${data.data['userName']}");
    });
  }

  Widget thistransaction(){
   return Row(
                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                   crossAxisAlignment: CrossAxisAlignment.start,
                   children: <Widget>[
                    Text("$index"""),
                      Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          width: 200,
                          child: user == null ?  Container(child: Text("fetching.."),) :
                          Text(
                            "$user""fetching...",
                            textAlign: TextAlign.start, // has impact
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                        Container(
                          width: 200,
                          child: Text(
                            "$type""",
                            textAlign: TextAlign.start, // has impact
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                        if(status == "pending")...[
                          pendingText(),
                        ]
                        else if(status == "processing")...[
                          processingText(),
                        ]
                        else...[
                          otherText(),
                        ]
                    ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        Text('$date'"",style: TextStyle(color: Colors.black)),
                        Text('$time'"",style: TextStyle(color: Colors.black,)),
                      ],
                      ),
                 ],
                );
                }
                
  Widget pendingText(){
    return Container(
      width: 200,
      child: Text(
        "$status""",
        textAlign: TextAlign.start, // has impact
        style: TextStyle(color: Colors.red[200]),
      ),
    );
  }

  Widget processingText(){
    return Container(
      width: 200,
      child: Text(
        "$status""",
        textAlign: TextAlign.start, // has impact
        style: TextStyle(color: Colors.green),
      ),
    );
  }

  Widget otherText(){
    return Container(
      width: 200,
      child: Text(
        "$status""",
        textAlign: TextAlign.start, // has impact
        style: TextStyle(color: Colors.red),
      ),
    );
  }

  //  getData() async{
  //   await databaseMethods.getCareProvider(careprovider).then((_data){
  //     setState((){
  //       // print("data raw is === ${data.data['createdDate']}");
  //       careprovidername = _data.documents;
       
  //       // careprovidername = careprovider[0].["name"];
  //       print("${careprovidername[0].data['name']} iss !!");
  //     });
  //   });
  // }
  
  @override
  Widget build(BuildContext context) {
    status = widget.status;
    return InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AppointmentDetailPage(
                      data: data, id: '',
                    ),
                  ),
                );
              },
              child: thistransaction(),
            
    );
  
    }
}