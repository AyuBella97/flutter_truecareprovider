import 'package:TrueCare2u_flutter/helper/constants.dart';
import 'package:TrueCare2u_flutter/helper/helperfunctions.dart';
import 'package:TrueCare2u_flutter/services/database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'pickupscreens.dart';
import 'provider/callprovider.dart';

class PickupLayout extends StatelessWidget {
  final Widget scaffold;

  PickupLayout({
    required this.scaffold,
  });

//   @override
//   _PickupLayoutState createState() => _PickupLayoutState();
// }

// class _PickupLayoutState extends State<PickupLayout> {
//   CallProvider callProvider;
//   Stream<QuerySnapshot> callIncoming;


  getSharedPreferences() async {
    Constants.myName = (await HelperFunctions.getUserNameSharedPreference())!;
    Constants.myId = (await HelperFunctions.getUserIdSharedPreference())!;
  }

  @override
  Widget build(BuildContext context) {
    // final UserProvider userProvider = Provider.of<UserProvider>(context);
    final CallProvider callProvider = Provider.of<CallProvider>(context);
    print("Constants.myId pickuplayour ${Constants.myId}");
    if(Constants.myId != null){
    return StreamBuilder<QuerySnapshot>(
            stream: DatabaseMethods().getcallIncoming(id:Constants.myId),
            builder: (context, AsyncSnapshot snapshot) {
              // var length = snapshot.data.documents.length;
              if (snapshot.hasData && snapshot.data.docs.length>0) {
                var thismapdata = snapshot.data.docs[0].data;
                callProvider.setToRinging();
                // print("thismapdata $thismapdata");
                if (snapshot.data.docs.length>0) {
                  return PickupScreen(mapData: thismapdata);
                }
              }
              else{
                callProvider.setToIdle();
              }
              return scaffold;
            },
          );
          }
          else{
            getSharedPreferences();
            return Scaffold(body: Center(child: CircularProgressIndicator(),),);
          };
  }

}