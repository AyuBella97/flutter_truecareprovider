import 'package:TrueCare2u_flutter/appointment/appointment.dart';
import 'package:TrueCare2u_flutter/appointment/widgets/allappointment.dart';
import 'package:TrueCare2u_flutter/chat/chatroom.dart';
import 'package:TrueCare2u_flutter/helper/constants.dart';
import 'package:TrueCare2u_flutter/services/database.dart';
import 'package:TrueCare2u_flutter/videocall/pickuplayout.dart';
import 'package:flutter/material.dart';

class AppointmentIndex extends StatelessWidget {
  var _orangebutton = const Color(0xFFF47920);
  
  
  @override
  Widget build(BuildContext context) {
    var _height = MediaQuery.of(context).size.height;
    var _width = MediaQuery.of(context).size.width;

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

    return new WillPopScope(
      onWillPop: _onWillPop,
      child: DefaultTabController(
        length: 2,
        child: PickupLayout(scaffold:Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: const Color(0xFF512c7c),
            bottom: TabBar(
              labelColor: Colors.white,
              indicatorColor: const Color(0xff381f58),
              unselectedLabelColor: Colors.grey,
              tabs: [
                Tab(text: "Upcoming",),
                Tab(text: "Completed"),
              ],
            ),
            title: Text('My Appointments',style: TextStyle(color: Colors.white),),
            centerTitle: true,
          ),
          body: TabBarView(
            children: [
              AppointmentPage(index:0),
              AppointmentPage(index:1),
              // AppointmentPageArchieve(),
              // Icon(Icons.directions_transit),
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.center,
              //   crossAxisAlignment: CrossAxisAlignment.center,
              //   children: <Widget>[
              //   Icon(Icons.notifications),
              //   Center(child:Text("No test")),
              // ],)
            ],
          ),
        ),),
      ),
    );
  }
}